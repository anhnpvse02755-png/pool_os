import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/drill/domain/models/drill.dart';
import 'package:pool_os/features/knowledge/data/knowledge_repository.dart';
import 'package:pool_os/features/knowledge/domain/models/knowledge_item.dart';
import 'package:pool_os/features/knowledge/presentation/providers/knowledge_providers.dart';
import 'package:pool_os/features/knowledge/presentation/widgets/knowledge_feedback.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// RFC-KB-002 — one detail renderer for EVERY knowledge type (technique,
/// commonMistake, equipment, mental, strategy). Shows status badge, an optional
/// Coach-recommendation banner (when opened from Coach), the sectioned content,
/// referenced drills pulled LIVE from DrillLibrary, related-knowledge graph
/// edges, media placeholders, a "Next" learning-path step, feedback, and a beta
/// message. `sources[]` is intentionally NEVER rendered.
class KnowledgeDetailScreen extends ConsumerWidget {
  final String knowledgeId;

  /// True when navigated here from a Coach recommendation → show the banner.
  final bool fromCoach;

  const KnowledgeDetailScreen({
    super.key,
    required this.knowledgeId,
    this.fromCoach = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final itemAsync = ref.watch(knowledgeByIdProvider(knowledgeId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.get('kb_knowledge'))),
      body: itemAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.get('kb_load_error'))),
        data: (item) {
          if (item == null) {
            return Center(child: Text(l10n.get('kb_not_found')));
          }
          return _body(context, ref, l10n, item);
        },
      ),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, AppLocalizations l10n,
      KnowledgeItem item) {
    final repo = ref.read(knowledgeRepositoryProvider);
    final drills = repo.drillsFor(item);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _header(context, l10n, item),
        const SizedBox(height: 12),
        if (fromCoach) _coachBanner(context, l10n),
        if (item.status == KnowledgeStatus.beta ||
            item.status == KnowledgeStatus.draft)
          _betaMessage(context, l10n),
        if (item.summary.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(item.summary, style: const TextStyle(fontSize: 15, height: 1.4)),
        ],
        _mediaPlaceholder(context, l10n, item),
        _section(context, l10n.get('kb_sec_purpose'), [item.purpose]),
        _section(context, l10n.get('kb_sec_prerequisites'), item.prerequisites),
        _section(context, l10n.get('kb_sec_setup'), item.setup),
        _section(context, l10n.get('kb_sec_execution'), item.execution),
        _section(context, l10n.get('kb_sec_success'), item.successCriteria),
        _section(context, l10n.get('kb_sec_failure'), item.failureCriteria),
        _section(context, l10n.get('kb_sec_mistakes'), item.commonMistakes),
        _section(context, l10n.get('kb_sec_corrections'), item.corrections),
        if (drills.isNotEmpty) _drillsSection(context, l10n, drills),
        _relatedSection(context, ref, l10n, item),
        if (item.nextRecommended != null)
          _nextSection(context, ref, l10n, item.nextRecommended!),
        const SizedBox(height: 24),
        KnowledgeFeedback(item: item),
        const SizedBox(height: 16),
        _footer(context, l10n, item),
      ],
    );
  }

  Widget _header(BuildContext context, AppLocalizations l10n, KnowledgeItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.titleVi,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _chip(l10n.get(item.type.labelKey), Colors.blueGrey),
            _chip(l10n.get(item.difficulty.labelKey), Colors.indigo),
            _statusBadge(l10n, item.status),
          ],
        ),
      ],
    );
  }

  Widget _statusBadge(AppLocalizations l10n, KnowledgeStatus status) {
    final color = switch (status) {
      KnowledgeStatus.verified => Colors.green,
      KnowledgeStatus.beta => Colors.orange,
      KnowledgeStatus.draft => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status == KnowledgeStatus.verified
                ? Icons.verified
                : status == KnowledgeStatus.beta
                    ? Icons.science
                    : Icons.edit_note,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(l10n.get(status.labelKey),
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, color: color)),
      );

  Widget _coachBanner(BuildContext context, AppLocalizations l10n) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.psychology, size: 22),
            const SizedBox(width: 10),
            Expanded(child: Text(l10n.get('kb_coach_banner'))),
          ],
        ),
      ),
    );
  }

  Widget _betaMessage(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 16, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(
              child: Text(l10n.get('kb_beta_message'),
                  style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mediaPlaceholder(
      BuildContext context, AppLocalizations l10n, KnowledgeItem item) {
    // The UI already supports media; V1 shows a "coming soon" placeholder.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey.shade700, Colors.blueGrey.shade400],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_circle_outline, size: 36, color: Colors.white),
              const SizedBox(height: 6),
              Text('${l10n.get('kb_sec_media')} · ${l10n.get('kb_media_coming_soon')}',
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<String> lines) {
    final items = lines.where((l) => l.trim().isNotEmpty).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...items.map((line) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(line, style: const TextStyle(height: 1.35))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _drillsSection(
      BuildContext context, AppLocalizations l10n, List<Drill> drills) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.get('kb_sec_related_drills'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...drills.map((d) => Card(
                child: ListTile(
                  leading: const Icon(Icons.fitness_center),
                  title: Text(d.nameVi.isNotEmpty ? d.nameVi : d.name),
                  subtitle: Text('${d.code} · ${'★' * d.difficultyStars}'),
                  dense: true,
                ),
              )),
        ],
      ),
    );
  }

  Widget _relatedSection(BuildContext context, WidgetRef ref,
      AppLocalizations l10n, KnowledgeItem item) {
    if (item.relatedKnowledge.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.get('kb_sec_related_knowledge'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...item.relatedKnowledge.map((ref0) => _refTile(context, ref, l10n, ref0)),
        ],
      ),
    );
  }

  Widget _nextSection(BuildContext context, WidgetRef ref, AppLocalizations l10n,
      KnowledgeRef next) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.get('kb_next'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          _refTile(context, ref, l10n, next, leading: Icons.arrow_forward),
        ],
      ),
    );
  }

  /// A tappable edge to another knowledge item, resolving its title live.
  Widget _refTile(BuildContext context, WidgetRef ref, AppLocalizations l10n,
      KnowledgeRef kref,
      {IconData leading = Icons.link}) {
    final targetAsync = ref.watch(knowledgeByIdProvider(kref.id));
    final title = targetAsync.asData?.value?.titleVi ?? kref.id;
    return Card(
      child: ListTile(
        leading: Icon(leading),
        title: Text(title),
        subtitle: Text(l10n.get(kref.type.labelKey)),
        trailing: const Icon(Icons.chevron_right),
        dense: true,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => KnowledgeDetailScreen(knowledgeId: kref.id),
          ),
        ),
      ),
    );
  }

  Widget _footer(BuildContext context, AppLocalizations l10n, KnowledgeItem item) {
    final updated = item.updatedAt;
    return Text(
      '${l10n.get('kb_version')} ${item.knowledgeVersion}'
      '${updated != null ? ' · ${l10n.get('kb_updated')} ${updated.year}-${updated.month.toString().padLeft(2, '0')}-${updated.day.toString().padLeft(2, '0')}' : ''}'
      '${item.estLearningMinutes > 0 ? ' · ${item.estLearningMinutes} ${l10n.get('kb_est_time')}' : ''}',
      style: const TextStyle(fontSize: 11, color: Colors.grey),
    );
  }
}
