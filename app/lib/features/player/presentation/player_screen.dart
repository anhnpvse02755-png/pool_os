import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/player/domain/models/player.dart';
import 'package:pool_os/features/player/presentation/player_provider.dart';
import 'package:pool_os/features/player_state/presentation/player_state_provider.dart';
import 'package:pool_os/features/player_state/presentation/widgets/player_state_card.dart';
import 'package:pool_os/shared/constants/app_constants.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playerNotifierProvider.notifier).loadPlayers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(playerNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('player')),
        actions: [
          if (!state.isEditing)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () =>
                  ref.read(playerNotifierProvider.notifier).startCreating(),
            ),
        ],
      ),
      floatingActionButton: !state.isLoading && state.players.isNotEmpty && !state.isEditing
          ? FloatingActionButton.extended(
              onPressed: () =>
                  ref.read(playerNotifierProvider.notifier).startCreating(),
              icon: const Icon(Icons.person_add),
              label: Text(l10n.get('add_player')),
            )
          : null,
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.isEditing
              ? _buildEditMode(context, state, l10n)
              : state.players.isEmpty
                  ? _buildEmptyState(context, l10n)
                  : _buildPlayerList(context, state, l10n),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.get('no_players_yet'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.get('create_first_player'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () =>
                ref.read(playerNotifierProvider.notifier).startCreating(),
            icon: const Icon(Icons.add),
            label: Text(l10n.get('add_player')),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerList(
      BuildContext context, PlayerState state, AppLocalizations l10n) {
    return Column(
      children: [
        if (state.activePlayer != null)
          _buildActivePlayerCard(context, state.activePlayer!, l10n),
        // Player State §3/§4: warm-up + endurance insight from recent racks.
        // Shows only when there is a match with enough racks to analyze;
        // otherwise renders nothing (never fabricates — doc §9).
        Consumer(
          builder: (context, ref, _) {
            final insight = ref.watch(playerStateInsightProvider);
            return insight.maybeWhen(
              data: (value) => value == null
                  ? const SizedBox.shrink()
                  : PlayerStateCard(
                      warmUp: value.warmUp,
                      endurance: value.endurance,
                    ),
              orElse: () => const SizedBox.shrink(),
            );
          },
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.players.length,
            itemBuilder: (context, index) {
              final player = state.players[index];
              final isActive = player.id == state.activePlayer?.id;
              return _buildPlayerCard(context, player, isActive, state, l10n);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivePlayerCard(
      BuildContext context, Player player, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              player.initials,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          Chip(
            label: Text(l10n.get('active')),
            backgroundColor:
                Theme.of(context).colorScheme.primary.withAlpha(51),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(BuildContext context, Player player, bool isActive,
      PlayerState state, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isActive
            ? null
            : () =>
                ref.read(playerNotifierProvider.notifier).selectPlayer(player),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Text(
                  player.initials,
                  style: TextStyle(
                    color: isActive
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          player.dominantHand == DominantHand.left.name
                              ? Icons.pan_tool
                              : Icons.front_hand,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getDominantHandLabel(player.dominantHand, l10n),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    ref
                        .read(playerNotifierProvider.notifier)
                        .startEditing(player);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(context, player, l10n);
                  } else if (value == 'select') {
                    ref
                        .read(playerNotifierProvider.notifier)
                        .selectPlayer(player);
                  }
                },
                itemBuilder: (context) => [
                  if (!isActive)
                    PopupMenuItem(
                      value: 'select',
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle),
                          const SizedBox(width: 8),
                          Text(l10n.get('select_as_active')),
                        ],
                      ),
                    ),
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
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, Player player, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.get('delete_player')),
        content: Text('${l10n.get('are_you_sure_delete')} "${player.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.get('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(playerNotifierProvider.notifier).deletePlayer(player.id!);
            },
            child: Text(l10n.get('delete')),
          ),
        ],
      ),
    );
  }

  Widget _buildEditMode(
      BuildContext context, PlayerState state, AppLocalizations l10n) {
    final player = state.editingPlayer;
    final nameController = TextEditingController(text: player?.name ?? '');
    String selectedHand = player?.dominantHand ?? DominantHand.right.name;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAvatarSection(context, nameController, l10n),
          const SizedBox(height: 24),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: l10n.get('player_name'),
              prefixIcon: const Icon(Icons.person),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedHand,
            decoration: InputDecoration(
              labelText: l10n.get('dominant_hand'),
              prefixIcon: const Icon(Icons.pan_tool),
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(
                value: DominantHand.left.name,
                child: Text(l10n.get('left')),
              ),
              DropdownMenuItem(
                value: DominantHand.right.name,
                child: Text(l10n.get('right')),
              ),
            ],
            onChanged: (value) => selectedHand = value!,
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      ref.read(playerNotifierProvider.notifier).cancelEditing(),
                  child: Text(l10n.get('cancel')),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: () => _savePlayer(
                    state.editingPlayer,
                    nameController.text,
                    selectedHand,
                  ),
                  child: Text(l10n.get('save')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context,
      TextEditingController nameController, AppLocalizations l10n) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    final avatars = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];

    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: Colors.blue,
          child: Text(
            nameController.text.isEmpty
                ? 'P'
                : nameController.text[0].toUpperCase(),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.get('select_avatar_color'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(colors.length, (index) {
            return GestureDetector(
              onTap: () {},
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors[index],
                ),
                child: Center(
                  child: Text(
                    avatars[index],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _savePlayer(
    Player? existingPlayer,
    String name,
    String dominantHand,
  ) {
    if (name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).get('name_required'))),
      );
      return;
    }

    final player = Player(
      id: existingPlayer?.id,
      name: name.trim(),
      dominantHand: dominantHand,
      language: existingPlayer?.language ?? AppConstants.defaultLanguage.name,
      measurementSystem:
          existingPlayer?.measurementSystem ?? AppConstants.defaultMeasurementSystem.name,
      theme: existingPlayer?.theme ?? AppConstants.themeDark,
      createdAt: existingPlayer?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (existingPlayer != null) {
      ref.read(playerNotifierProvider.notifier).updatePlayer(player);
    } else {
      ref.read(playerNotifierProvider.notifier).createPlayer(player);
    }
  }

  String _getDominantHandLabel(String hand, AppLocalizations l10n) {
    return hand == DominantHand.left.name ? l10n.get('left') : l10n.get('right');
  }
}
