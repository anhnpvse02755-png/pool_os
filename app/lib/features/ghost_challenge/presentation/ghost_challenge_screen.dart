import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/ghost_challenge/presentation/ghost_challenge_provider.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class GhostChallengeScreen extends ConsumerStatefulWidget {
  final int matchId;
  final int targetScore;

  const GhostChallengeScreen({
    super.key,
    required this.matchId,
    this.targetScore = 5,
  });

  @override
  ConsumerState<GhostChallengeScreen> createState() =>
      _GhostChallengeScreenState();
}

class _GhostChallengeScreenState extends ConsumerState<GhostChallengeScreen> {
  double _ghostSkillLevel = 0.6;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ghostChallengeNotifierProvider.notifier).startChallenge(
            matchId: widget.matchId,
            targetScore: widget.targetScore,
            ghostSkillLevel: _ghostSkillLevel,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(ghostChallengeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('ghost_challenge')),
        actions: [
          if (state.hasActiveChallenge)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetChallenge,
              tooltip: 'Reset Challenge',
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.challenge == null
              ? _buildSetupView(context, l10n)
              : _buildChallengeView(context, state, l10n),
    );
  }

  Widget _buildSetupView(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.get('ghost_challenge'),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Play against a ghost opponent',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ghost Skill Level',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _ghostSkillLevel,
                    min: 0.2,
                    max: 0.9,
                    divisions: 7,
                    label: _getSkillLabel(_ghostSkillLevel),
                    onChanged: (value) {
                      setState(() {
                        _ghostSkillLevel = value;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Beginner', style: Theme.of(context).textTheme.bodySmall),
                      Text('Expert', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _startChallenge,
              icon: const Icon(Icons.play_arrow),
              label: Text('Start Challenge (${widget.targetScore})'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeView(
    BuildContext context,
    GhostChallengeState state,
    AppLocalizations l10n,
  ) {
    final challenge = state.challenge!;

    return Column(
      children: [
        _buildScoreHeader(context, challenge, l10n),
        if (challenge.isComplete)
          _buildCompletionBanner(context, challenge, l10n)
        else
          Expanded(child: _buildQuickActions(context, challenge, l10n)),
        _buildShotHistory(context, state, l10n),
      ],
    );
  }

  Widget _buildScoreHeader(
    BuildContext context,
    challenge,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreColumn(
            context,
            l10n.get('you'),
            challenge.playerScore,
            challenge.targetScore,
            Colors.green,
          ),
          Text(
            'vs',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          _buildScoreColumn(
            context,
            'Ghost',
            challenge.ghostScore,
            challenge.targetScore,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreColumn(
    BuildContext context,
    String label,
    int score,
    int target,
    Color color,
  ) {
    final progress = score / target;
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: color.withAlpha(51),
                color: color,
                strokeWidth: 6,
              ),
            ),
            Text(
              '$score',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'of $target',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildCompletionBanner(
    BuildContext context,
    challenge,
    AppLocalizations l10n,
  ) {
    final winner = challenge.winner;
    final isPlayerWinner = winner == 'player';
    final isTie = winner == 'tie';

    return Container(
      padding: const EdgeInsets.all(24),
      color: isTie
          ? Colors.amber.withAlpha(51)
          : (isPlayerWinner ? Colors.green.withAlpha(51) : Colors.red.withAlpha(51)),
      child: Column(
        children: [
          Icon(
            isTie
                ? Icons.handshake
                : (isPlayerWinner ? Icons.emoji_events : Icons.sentiment_dissatisfied),
            size: 48,
            color: isTie
                ? Colors.amber
                : (isPlayerWinner ? Colors.green : Colors.red),
          ),
          const SizedBox(height: 16),
          Text(
            isTie
                ? 'It\'s a Tie!'
                : (isPlayerWinner ? 'You Won!' : 'Ghost Wins!'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isTie
                      ? Colors.amber
                      : (isPlayerWinner ? Colors.green : Colors.red),
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(
                onPressed: _resetChallenge,
                icon: const Icon(Icons.refresh),
                label: const Text('New Challenge'),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check),
                label: Text(l10n.get('done')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    challenge,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Who won this rack?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildResultButton(
                  context,
                  Icons.check_circle,
                  l10n.get('rack_win'),
                  Colors.green,
                  () => _recordResult(true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildResultButton(
                  context,
                  Icons.cancel,
                  l10n.get('rack_loss'),
                  Colors.red,
                  () => _recordResult(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildGhostPreview(context, l10n),
        ],
      ),
    );
  }

  Widget _buildResultButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        color: color.withAlpha(26),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              Icon(icon, size: 64, color: color),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGhostPreview(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.info_outline),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ghost is playing at ${(_ghostSkillLevel * 100).toInt()}% skill level',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShotHistory(
    BuildContext context,
    GhostChallengeState state,
    AppLocalizations l10n,
  ) {
    final shots = ref.read(ghostChallengeNotifierProvider.notifier).getShotHistory();

    if (shots.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 120,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.get('history'),
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: shots.length,
              itemBuilder: (context, index) {
                final shot = shots[index];
                return _buildShotChip(context, shot);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShotChip(BuildContext context, shot) {
    final color = shot.shooter == 'player' ? Colors.green : Colors.red;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            shot.made ? Icons.check : Icons.close,
            size: 16,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            '#${shot.rackNumber}',
            style: TextStyle(fontSize: 10, color: color),
          ),
        ],
      ),
    );
  }

  String _getSkillLabel(double level) {
    if (level >= 0.8) return 'Expert';
    if (level >= 0.6) return 'Advanced';
    if (level >= 0.4) return 'Intermediate';
    return 'Beginner';
  }

  void _startChallenge() {
    ref.read(ghostChallengeNotifierProvider.notifier).startChallenge(
          matchId: widget.matchId,
          targetScore: widget.targetScore,
          ghostSkillLevel: _ghostSkillLevel,
        );
  }

  void _recordResult(bool playerWon) {
    if (playerWon) {
      ref.read(ghostChallengeNotifierProvider.notifier).recordPlayerWin();
    } else {
      ref.read(ghostChallengeNotifierProvider.notifier).recordPlayerLoss();
    }
  }

  void _resetChallenge() {
    ref.read(ghostChallengeNotifierProvider.notifier).resetChallenge();
    setState(() {
      _ghostSkillLevel = 0.6;
    });
  }
}
