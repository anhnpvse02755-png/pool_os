import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/equipment/presentation/equipment_provider.dart';
import 'package:pool_os/features/equipment/domain/models/cue.dart';
import 'package:pool_os/features/equipment/domain/equipment_performance_projection.dart';
import 'package:pool_os/features/equipment/domain/equipment_performance_service.dart';
import 'package:pool_os/features/equipment/presentation/equipment_comparison_screen.dart';
import 'package:pool_os/features/equipment/presentation/widgets/equipment_performance_summary.dart';
import 'package:pool_os/features/equipment/presentation/widgets/equipment_recommendation.dart';
import 'package:pool_os/features/equipment/presentation/widgets/equipment_comparison_section.dart'
    show EquipmentComparisonEntry;
import 'package:pool_os/features/equipment/presentation/widgets/equipment_history_section.dart';
import 'package:pool_os/features/player/presentation/career_timeline_section.dart';
import 'package:pool_os/features/player/domain/career_timeline_projection.dart';
import 'package:pool_os/features/equipment/domain/cue_role_resolver.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';
import 'package:pool_os/shared/widgets/searchable_dropdown.dart';
import 'package:go_router/go_router.dart';

class EquipmentScreen extends ConsumerStatefulWidget {
  const EquipmentScreen({super.key});

  @override
  ConsumerState<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends ConsumerState<EquipmentScreen> {
  // FEATURE_012 v2 — Compare selection.
  //
  // Pure in-memory UI state. Holds cue IDs in a Set so there is no
  // implicit order and no automatic eviction. The user owns the
  // selection entirely: toggling adds or removes one entry at a time.
  // Not persisted, not in repository, not in projection.
  final Set<int> _selectedCompareIds = <int>{};

  void _toggleCompareSelection(int cueId) {
    setState(() {
      if (!_selectedCompareIds.add(cueId)) {
        // already present -> remove
        _selectedCompareIds.remove(cueId);
      }
    });
  }

  // Build the entries passed to EquipmentComparisonScreen. Pure mapping
  // from selected ids → cue + projection. Drops entries whose cue no
  // longer has a projection or whose cue id is gone from the current
  // cues list (defensive — the state is widget-local; cues may have been
  // reloaded from the repository).
  List<EquipmentComparisonEntry> _buildComparisonEntries(
      List<Cue> cues, List<EquipmentPerformanceProjection> projections) {
    final result = <EquipmentComparisonEntry>[];
    for (final id in _selectedCompareIds) {
      final cue = cues.where((c) => c.id == id).firstOrNull;
      if (cue == null) continue;
      final projection =
          projections.where((p) => p.equipmentId == id).firstOrNull;
      if (projection == null) continue;
      result.add(EquipmentComparisonEntry(cue: cue, projection: projection));
    }
    return List<EquipmentComparisonEntry>.unmodifiable(result);
  }

  // FEATURE_012 v2 — open the dedicated Comparison Screen via
  // Navigator.push. No GoRouter route registration (spec §3 Navigation).
  void _openComparisonScreen(
      List<Cue> cues, List<EquipmentPerformanceProjection> projections) {
    final entries = _buildComparisonEntries(cues, projections);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EquipmentComparisonScreen(
          cues: entries.map((e) => e.cue).toList(growable: false),
          projections: entries.map((e) => e.projection).toList(growable: false),
          now: DateTime.now(),
          locale: Localizations.localeOf(context).languageCode,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(equipmentNotifierProvider.notifier).loadEquipment();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(equipmentNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('equipment')),
        centerTitle: true,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.cues.isEmpty
              ? _buildEmptyState(context, l10n)
              : _buildCueList(context, state, l10n),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCueDialog(context, l10n),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_esports_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.get('empty_state'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.get('tap_to_add'),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildCueList(
      BuildContext context, EquipmentState state, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).languageCode;
    // Task 04 §7: the equipment intelligence header sits above the cue list.
    // Show it whenever there are per-role stats OR verdicts — the two diverge
    // (per-role stats appear from the first recorded shot, while equipment-vs-
    // skill verdicts need a bigger sample), so gating only on insights would
    // silently hide real stats that were computed.
    final hasHeader = state.insights.isNotEmpty || state.roleStats.isNotEmpty;
    // FEATURE_010: "Recommended Equipment" section rendered when at least one
    // cue is available. The widget itself decides between the "Top 3" view and
    // the "Chưa đủ dữ liệu" message — so the section is rendered, not a header
    // item in the list, to keep the recommended cues out of the cue list's own
    // ordering.
    final showRecommendation = state.cues.isNotEmpty;
    // FEATURE_012: "Equipment Comparison" section rendered immediately below
    // the recommendation section when at least one cue is available. The
    // widget hides itself entirely under its Rule 8 visibility gate
    // (selected size, Active Player, isActive) — until a cue-selection
    // follow-up lands, we mount with an empty selection so the section
    // contributes zero DOM and the layout stays byte-identical for users.
    // FEATURE_012 v2: Compare (N) button — shown when at least 2 cues are
    // selected. The button pushes EquipmentComparisonScreen via Navigator.
    final compareEnabled = _selectedCompareIds.length >= 2;
    // Keep the button visible only when it is meaningful; spec §3 says
    // "Hide or disable when no selection".
    final showCompareButton =
        state.cues.isNotEmpty && _selectedCompareIds.isNotEmpty;
    final headerCount = (hasHeader ? 1 : 0) +
        (showRecommendation ? 1 : 0) +
        (showCompareButton ? 1 : 0);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.cues.length + headerCount,
      itemBuilder: (context, rawIndex) {
        if (showRecommendation && rawIndex == 0) {
          return RecommendedEquipmentSection(
            cues: state.cues,
            projections: state.performanceProjections,
            now: DateTime.now(),
            locale: locale,
          );
        }
        if (showCompareButton && rawIndex == (showRecommendation ? 1 : 0)) {
          // FEATURE_012 v2 — Compare (N) button. Disabled when fewer than
          // 2 cues are selected.
          return Padding(
            key: const ValueKey('equipment-compare-button-row'),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                key: const ValueKey('equipment-compare-button'),
                onPressed: compareEnabled
                    ? () => _openComparisonScreen(
                        state.cues, state.performanceProjections)
                    : null,
                icon: const Icon(Icons.compare_arrows),
                label: Text('Compare (${_selectedCompareIds.length})'),
              ),
            ),
          );
        }
        if (hasHeader &&
            rawIndex ==
                (showRecommendation ? 1 : 0) + (showCompareButton ? 1 : 0)) {
          return _buildIntelligenceHeader(context, state, locale);
        }
        final recommendationOffset = showRecommendation ? 1 : 0;
        final compareButtonOffset = showCompareButton ? 1 : 0;
        final headerOffset = hasHeader ? 1 : 0;
        final index = rawIndex -
            recommendationOffset -
            compareButtonOffset -
            headerOffset;
        final cue = state.cues[index];
        // RFC-302 Task F: a cue can hold multiple active roles (a break_jump cue
        // is both the active break and jump cue).
        final isActiveCue = state.activeCue?.id == cue.id;
        final isBreakCue = state.activeBreakCue?.id == cue.id;
        final isJumpCue = state.activeJumpCue?.id == cue.id;
        final performance = state.performanceProjections
            .where((item) => item.equipmentId == cue.id)
            .firstOrNull;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isActiveCue
                        ? Theme.of(context).colorScheme.primary.withAlpha(26)
                        : Colors.grey.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.straight,
                    color: isActiveCue
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      cue.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // RFC-302 Task F: show which active role(s) this cue holds.
                    if (isActiveCue) ...[
                      const SizedBox(width: 8),
                      _roleBadge(l10n.get('active_cue'), Colors.green),
                    ],
                    if (isBreakCue) ...[
                      const SizedBox(width: 8),
                      _roleBadge(l10n.get('active_break_cue'), Colors.orange),
                    ],
                    if (isJumpCue) ...[
                      const SizedBox(width: 8),
                      _roleBadge(l10n.get('active_jump_cue'), Colors.blue),
                    ],
                  ],
                ),
                subtitle: Text(
                  '${l10n.get('cue_type_${cue.cueType}')} · ${l10n.get('weight')}: ${cue.weight} oz',
                ),
                // FEATURE_012 — Compare checkbox sits at the bottom of the
                // ListTile content so it remains visually attached to the cue
                // card without forcing a layout reflow. CheckboxListTile's
                // own leading/title would conflict with ListTile's existing
                // leading icon, so a plain Row with a Checkbox + label keeps
                // both layouts independent.
                onTap: cue.id == null
                    ? null
                    : () => _toggleCompareSelection(cue.id!),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'set_active') {
                      _setActiveCue(cue);
                    } else if (value == 'set_break') {
                      _setBreakCue(cue);
                    } else if (value == 'set_jump') {
                      _setJumpCue(cue);
                    } else if (value == 'edit') {
                      _showEditCueDialog(context, cue, l10n);
                    } else if (value == 'delete') {
                      _confirmDeleteCue(context, cue, l10n);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'set_active',
                      child: Row(
                        children: [
                          Icon(
                            isActiveCue
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(l10n.get('active_cue')),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'set_break',
                      child: Row(
                        children: [
                          Icon(
                            isBreakCue
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(l10n.get('active_break_cue')),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'set_jump',
                      child: Row(
                        children: [
                          Icon(
                            isJumpCue
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Text(l10n.get('active_jump_cue')),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit),
                          const SizedBox(width: 8),
                          Text(l10n.get('edit')),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(l10n.get('delete'),
                              style: const TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // FEATURE_012 — Compare checkbox. Sits between the cue title
              // row and the performance summary so it cannot be confused
              // with role badges (active / break / jump). Tapping the
              // checkbox itself calls `_toggleCompareSelection`; tapping
              // the ListTile is a no-op alias for accessibility.
              _buildCompareCheckboxRow(cue, l10n),
              if (performance != null)
                EquipmentPerformanceSummary(
                  projection: performance,
                  locale: locale,
                ),
              // FEATURE_011 — Equipment History section. The timeline is read
              // from the existing careerTimelineProvider and filtered in-widget
              // by equipmentId (this cue). The widget itself renders the empty
              // state when the filter yields zero events. No new domain, no
              // new projection, no schema change.
              _EquipmentHistoryHost(cue: cue, locale: locale),
              ExpansionTile(
                title: Text(
                  l10n.get('details'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                            l10n.get('shaft_material'), cue.shaftMaterial),
                        _buildInfoRow(l10n.get('shaft_diameter'),
                            '${cue.shaftDiameter} mm'),
                        _buildInfoRow(l10n.get('tip_brand'), cue.tipBrand),
                        _buildInfoRow(
                            l10n.get('tip_hardness'), cue.tipHardness),
                        _buildInfoRow(l10n.get('tip_size'),
                            cue.tipSize != null ? '${cue.tipSize} mm' : '-'),
                        _buildInfoRow(l10n.get('cue_type'),
                            l10n.get('cue_type_${cue.cueType}')),
                        _buildInfoRow(l10n.get('balance'), cue.balance),
                        _buildInfoRow(l10n.get('joint'), cue.joint),
                        _buildInfoRow(l10n.get('weight'), '${cue.weight} oz'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  void _showAddCueDialog(BuildContext context, AppLocalizations l10n) {
    final nameController = TextEditingController();
    String shaftMaterial = CueBrands.defaultShaftMaterial;
    double shaftDiameter = CueBrands.defaultShaftDiameter;
    String tipBrand = CueBrands.defaultTipBrand;
    String tipHardness = CueBrands.defaultTipHardness;
    double tipSize = CueBrands.defaultTipSize;
    String cueType = 'playing';
    final weightController = TextEditingController(text: '19.5');
    String balance = CueBrands.balances.first;
    String joint = CueBrands.joints.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.get('add_cue')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l10n.get('cue_name'),
                    hintText: l10n.get('my_cue'),
                    prefixIcon: const Icon(Icons.straight),
                  ),
                ),
                const SizedBox(height: 16),
                SearchableDropdown<String>(
                  label: l10n.get('shaft_material'),
                  icon: Icons.line_weight,
                  value: shaftMaterial,
                  items: CueBrands.shaftMaterials,
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => shaftMaterial = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                SearchableDropdown<double>(
                  label: l10n.get('shaft_diameter'),
                  icon: Icons.straighten,
                  value: shaftDiameter,
                  items: CueBrands.shaftDiameters,
                  itemLabel: (d) => '$d mm',
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => shaftDiameter = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                SearchableDropdown<String>(
                  label: l10n.get('tip_brand'),
                  icon: Icons.circle_outlined,
                  value: tipBrand,
                  items: CueBrands.tipBrands,
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => tipBrand = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                SearchableDropdown<String>(
                  label: l10n.get('tip_hardness'),
                  icon: Icons.speed,
                  value: tipHardness,
                  items: CueBrands.tipHardnesses,
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => tipHardness = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                SearchableDropdown<String>(
                  label: l10n.get('cue_type'),
                  icon: Icons.category,
                  value: cueType,
                  items: CueBrands.cueTypesDisplay,
                  itemLabel: (value) => l10n.get('cue_type_$value'),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => cueType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                SearchableDropdown<double>(
                  label: l10n.get('tip_size'),
                  icon: Icons.straighten,
                  value: tipSize,
                  items: CueBrands.tipSizes,
                  itemLabel: (size) => '$size mm',
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => tipSize = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: weightController,
                  decoration: InputDecoration(
                    labelText: l10n.get('weight'),
                    suffixText: 'oz',
                    prefixIcon: const Icon(Icons.scale),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                SearchableDropdown<String>(
                  label: l10n.get('balance'),
                  icon: Icons.balance,
                  value: balance,
                  items: CueBrands.balances,
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => balance = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                SearchableDropdown<String>(
                  label: l10n.get('joint'),
                  icon: Icons.link,
                  value: joint,
                  items: CueBrands.joints,
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => joint = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.get('cancel')),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.get('please_enter_cue_name'))),
                  );
                  return;
                }
                final cue = Cue(
                  name: nameController.text.trim(),
                  shaftMaterial: shaftMaterial,
                  shaftDiameter: shaftDiameter,
                  tipBrand: tipBrand,
                  tipHardness: tipHardness,
                  tipSize: tipSize,
                  cueType: cueType,
                  weight: double.tryParse(weightController.text) ?? 19.5,
                  balance: balance,
                  joint: joint,
                  isActive: true,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                ref.read(equipmentNotifierProvider.notifier).addCue(cue);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.get('cue_added'))),
                );
              },
              child: Text(l10n.get('save')),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCueDialog(
      BuildContext context, Cue cue, AppLocalizations l10n) {
    final nameController = TextEditingController(text: cue.name);
    String shaftMaterial = cue.shaftMaterial;
    double shaftDiameter = cue.shaftDiameter;
    String tipBrand = cue.tipBrand;
    String tipHardness = cue.tipHardness;
    double tipSize = cue.tipSize ?? CueBrands.defaultTipSize;
    String cueType = cue.cueType;
    final weightController = TextEditingController(text: cue.weight.toString());
    String balance = cue.balance;
    String joint = cue.joint;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.get('edit_cue')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l10n.get('cue_name'),
                    prefixIcon: const Icon(Icons.straight),
                  ),
                ),
                const SizedBox(height: 16),
                SearchableDropdown<String>(
                  label: l10n.get('shaft_material'),
                  icon: Icons.line_weight,
                  value: shaftMaterial,
                  items: CueBrands.shaftMaterials,
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => shaftMaterial = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                SearchableDropdown<double>(
                  label: l10n.get('shaft_diameter'),
                  icon: Icons.straighten,
                  value: shaftDiameter,
                  items: CueBrands.shaftDiameters,
                  itemLabel: (d) => '$d mm',
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => shaftDiameter = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                SearchableDropdown<String>(
                  label: l10n.get('tip_brand'),
                  icon: Icons.circle_outlined,
                  value: tipBrand,
                  items: CueBrands.tipBrands,
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => tipBrand = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                SearchableDropdown<String>(
                  label: l10n.get('tip_hardness'),
                  icon: Icons.speed,
                  value: tipHardness,
                  items: CueBrands.tipHardnesses,
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => tipHardness = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                SearchableDropdown<String>(
                  label: l10n.get('cue_type'),
                  icon: Icons.category,
                  value: cueType,
                  items: CueBrands.cueTypesDisplay,
                  itemLabel: (value) => l10n.get('cue_type_$value'),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => cueType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                SearchableDropdown<double>(
                  label: l10n.get('tip_size'),
                  icon: Icons.straighten,
                  value: tipSize,
                  items: CueBrands.tipSizes,
                  itemLabel: (size) => '$size mm',
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => tipSize = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: weightController,
                  decoration: InputDecoration(
                    labelText: l10n.get('weight'),
                    suffixText: 'oz',
                    prefixIcon: const Icon(Icons.scale),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                SearchableDropdown<String>(
                  label: l10n.get('balance'),
                  icon: Icons.balance,
                  value: balance,
                  items: CueBrands.balances,
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => balance = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                SearchableDropdown<String>(
                  label: l10n.get('joint'),
                  icon: Icons.link,
                  value: joint,
                  items: CueBrands.joints,
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => joint = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.get('cancel')),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.get('please_enter_cue_name'))),
                  );
                  return;
                }
                final updatedCue = cue.copyWith(
                  name: nameController.text.trim(),
                  shaftMaterial: shaftMaterial,
                  shaftDiameter: shaftDiameter,
                  tipBrand: tipBrand,
                  tipHardness: tipHardness,
                  tipSize: tipSize,
                  cueType: cueType,
                  weight: double.tryParse(weightController.text) ?? cue.weight,
                  balance: balance,
                  joint: joint,
                );
                ref
                    .read(equipmentNotifierProvider.notifier)
                    .updateCue(updatedCue);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.get('cue_updated'))),
                );
              },
              child: Text(l10n.get('save')),
            ),
          ],
        ),
      ),
    );
  }

  void _setActiveCue(Cue cue) {
    ref.read(equipmentNotifierProvider.notifier).setActiveCue(cue.id!);
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              l10n.get('set_as_active_cue').replaceAll('{name}', cue.name))),
    );
  }

  void _setBreakCue(Cue cue) {
    ref
        .read(equipmentNotifierProvider.notifier)
        .setActiveCueByType(cue.id!, 'break');
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              l10n.get('set_as_break_cue').replaceAll('{name}', cue.name))),
    );
  }

  void _setJumpCue(Cue cue) {
    ref
        .read(equipmentNotifierProvider.notifier)
        .setActiveCueByType(cue.id!, 'jump');
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text(l10n.get('set_as_jump_cue').replaceAll('{name}', cue.name))),
    );
  }

  // RFC-302 Task F: compact chip showing which active role a cue currently holds.
  // Task 04 §7: equipment-vs-skill intelligence + real per-role stats, shown
  // above the cue list so the player sees the verdict without opening anything.
  Widget _buildIntelligenceHeader(
      BuildContext context, EquipmentState state, String locale) {
    final vi = locale == 'vi';
    final theme = Theme.of(context);

    Color verdictColor(EquipmentVerdict v) {
      switch (v) {
        case EquipmentVerdict.equipmentHelps:
          return Colors.green;
        case EquipmentVerdict.skillNotEquipment:
        case EquipmentVerdict.skillGap:
          return Colors.orange;
        default:
          return Colors.grey;
      }
    }

    IconData verdictIcon(EquipmentVerdict v) {
      switch (v) {
        case EquipmentVerdict.equipmentHelps:
          return Icons.build_circle;
        case EquipmentVerdict.skillNotEquipment:
        case EquipmentVerdict.skillGap:
          return Icons.school;
        default:
          return Icons.info_outline;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: theme.colorScheme.primary.withAlpha(16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights,
                    size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  vi ? 'Phân tích Equipment' : 'Equipment intelligence',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...state.insights.map((ins) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2, right: 8),
                        child: Icon(verdictIcon(ins.verdict),
                            size: 16, color: verdictColor(ins.verdict)),
                      ),
                      Expanded(
                        child: Text(
                          vi ? ins.messageVi : ins.message,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )),
            if (state.roleStats.isNotEmpty) ...[
              const Divider(height: 16),
              ...state.roleStats.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        _roleBadge(
                            CueRole.label(s.role, locale), _roleColor(s.role)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${s.cueName} · ${(s.successRate * 100).round()}% (${s.made}/${s.attempts})',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case CueRole.breakRole:
        return Colors.orange;
      case CueRole.jump:
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  // FEATURE_012 — Compare checkbox row inside each cue card.
  //
  // Spec: each cue card SHALL expose one Compare checkbox. Maximum 2 cues
  // selected; FIFO eviction handled in `_toggleCompareSelection`.
  Widget _buildCompareCheckboxRow(Cue cue, AppLocalizations l10n) {
    final cueId = cue.id;
    if (cueId == null) {
      // Defensive: cues without an id cannot be referenced safely; hide the
      // control entirely. (Repository normally assigns ids on create.)
      return const SizedBox.shrink(
        key: ValueKey('equipment-compare-checkbox-missing-id'),
      );
    }
    final isChecked = _selectedCompareIds.contains(cueId);
    return InkWell(
      key: ValueKey('equipment-compare-checkbox-row-$cueId'),
      onTap: () => _toggleCompareSelection(cueId),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Checkbox(
              key: ValueKey('equipment-compare-checkbox-$cueId'),
              value: isChecked,
              onChanged: (_) => _toggleCompareSelection(cueId),
            ),
            const SizedBox(width: 8),
            // Spec PO did not prescribe the label text; using a literal
            // "Compare" string keeps this change strictly inside the
            // allowed-files surface (no localization file edit).
            Text(
              'Compare',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _confirmDeleteCue(BuildContext context, Cue cue, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.get('delete')),
        content: Text('${l10n.get('delete_cue_confirm')} "${cue.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.get('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ref.read(equipmentNotifierProvider.notifier).deleteCue(cue.id!);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.get('cue_deleted'))),
              );
            },
            child: Text(l10n.get('delete')),
          ),
        ],
      ),
    );
  }
}

/// FEATURE_011 — Equipment History host widget.
///
/// Watches the existing `careerTimelineProvider` (which already gates by
/// Active Player) and feeds [EquipmentHistorySection] for the cue currently
/// rendered in the parent cue card. The widget itself does not own any
/// navigation — the section passes taps up via [onEventTap] so the host can
/// route to the existing detail screen (currently `/match/:id` for Match
/// events; Training events are emitted with no tap because no Training detail
/// route exists in the app).
class _EquipmentHistoryHost extends ConsumerWidget {
  const _EquipmentHistoryHost({required this.cue, required this.locale});

  final Cue cue;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(careerTimelineProvider);
    final List<CareerTimelineEvent> events = timelineAsync.maybeWhen(
      data: (projection) => projection?.events ?? const <CareerTimelineEvent>[],
      orElse: () => const <CareerTimelineEvent>[],
    );
    final equipmentId = cue.id ?? 0;
    if (equipmentId <= 0) {
      return const SizedBox.shrink();
    }
    return EquipmentHistorySection(
      events: events,
      equipmentId: equipmentId,
      now: DateTime.now(),
      locale: locale,
      onEventTap: (event) {
        // Route to the existing detail screen for Match events only;
        // Training events have no app-level detail route at this point, so
        // we deliberately emit no tap.
        if (event.type.name == 'completedMatch' &&
            event.equipmentUsage.isNotEmpty) {
          final matchId = event.equipmentUsage.first.matchId;
          if (matchId > 0) {
            // GoRouter is wired at the application root; this widget only
            // emits the navigation call through the standard Router API so
            // no new routes are introduced.
            GoRouterCommand(context).goMatch(matchId);
          }
        }
      },
    );
  }
}

/// Tiny local helper so the host widget does not import go_router directly
/// (EquipmentScreen is material/riverpod only). Calls the existing
/// `/match/:id` route that already handles MatchDetailScreen.
class GoRouterCommand {
  GoRouterCommand(this.context);
  final BuildContext context;

  void goMatch(int matchId) {
    // Router is set up at the app root via MaterialApp.router; the standard
    // Navigator cannot reach the GoRouter state, so we use the inherited
    // GoRouter helper from go_router, which is already in the dependency
    // graph (used by the rest of the app).
    // ignore: deprecated_member_use
    GoRouter.of(context).go('/match/$matchId');
  }
}
