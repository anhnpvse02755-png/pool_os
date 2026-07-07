import 'package:flutter/material.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// FIX-003: Match Mode Rack Summary Dialog
/// Target time: < 20 seconds per rack
class RackSummaryDialog extends StatefulWidget {
  final bool won;
  final int rackNumber;
  final Function(RackSummaryData) onSave;

  const RackSummaryDialog({
    super.key,
    required this.won,
    required this.rackNumber,
    required this.onSave,
  });

  @override
  State<RackSummaryDialog> createState() => _RackSummaryDialogState();
}

class _RackSummaryDialogState extends State<RackSummaryDialog> {
  final _notesController = TextEditingController();
  
  // Performance
  int _ballsPotted = 0;
  int _largestRun = 0;
  
  // Break
  bool _breakSuccess = false;
  bool _breakScratch = false;
  bool _breakFoul = false;
  
  // Errors (count)
  int _easyMissCount = 0;
  int _hardMissCount = 0;
  int _scratchErrorCount = 0;
  int _positionErrorCount = 0;
  int _safetyErrorCount = 0;
  int _kickErrorCount = 0;
  int _jumpErrorCount = 0;
  
  // Multi-select for strengths and mistakes
  final Set<String> _selectedStrengths = {};
  final Set<String> _selectedMistakes = {};
  
  // Confidence
  int _confidence = 5;
  
  // FIX-003: Shot types in Vietnamese for strength/mistake selection
  static const List<String> _strengthOptions = [
    'thinCut',      // Cắt mỏng
    'thickCut',     // Cắt dày
    'longPot',      // Đánh bi xa
    'draw',         // Draw
    'follow',       // Follow
    'bank',         // Ghiên
    'kick',         // Đá bi
    'jump',         // Nhảy
    'safety',       // An toàn
    'cueBallControl', // Kiểm soát bi cue
  ];
  
  static const List<String> _mistakeOptions = [
    'thinCut',      // Cắt mỏng
    'thickCut',     // Cắt dày
    'longPot',      // Đánh bi xa
    'draw',         // Draw
    'follow',       // Follow
    'bank',         // Ghiên
    'kick',         // Đá bi
    'jump',         // Nhảy
    'safety',       // An toàn
    'cueBallControl', // Kiểm soát bi cue
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _getLocalizedStrength(String key, AppLocalizations l10n) {
    switch (key) {
      case 'thinCut': return l10n.get('thin_cut');
      case 'thickCut': return l10n.get('thick_cut');
      case 'longPot': return l10n.get('long_pot');
      case 'draw': return 'Draw';
      case 'follow': return 'Follow';
      case 'bank': return l10n.get('bank');
      case 'kick': return l10n.get('kick');
      case 'jump': return l10n.get('jump');
      case 'safety': return l10n.get('safety');
      case 'cueBallControl': return l10n.get('cue_ball_control');
      default: return key;
    }
  }

  String _getLocalizedMistake(String key, AppLocalizations l10n) {
    // Same as strength for mistakes
    return _getLocalizedStrength(key, l10n);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = widget.won ? Colors.green : Colors.red;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, color, l10n),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Performance Section
                    _buildSectionTitle(context, l10n.get('performance'), Icons.sports_score),
                    const SizedBox(height: 8),
                    _buildBallsPotted(context, l10n),
                    const SizedBox(height: 8),
                    _buildLargestRun(context, l10n),
                    
                    const SizedBox(height: 16),
                    
                    // Break Section
                    _buildSectionTitle(context, l10n.get('break'), Icons.flash_on),
                    const SizedBox(height: 8),
                    _buildBreakSection(context, l10n),
                    
                    const SizedBox(height: 16),
                    
                    // Errors Section
                    _buildSectionTitle(context, l10n.get('errors'), Icons.warning_amber),
                    const SizedBox(height: 8),
                    _buildErrorsSection(context, l10n),
                    
                    const SizedBox(height: 16),
                    
                    // Best Strengths (multi-select)
                    _buildSectionTitle(context, l10n.get('best_strength'), Icons.star),
                    const SizedBox(height: 8),
                    _buildStrengthSelector(context, l10n),
                    
                    const SizedBox(height: 16),
                    
                    // Biggest Mistakes (multi-select)
                    _buildSectionTitle(context, l10n.get('biggest_mistake'), Icons.error),
                    const SizedBox(height: 8),
                    _buildMistakeSelector(context, l10n),
                    
                    const SizedBox(height: 16),
                    
                    // Confidence
                    _buildSectionTitle(context, l10n.get('confidence'), Icons.psychology),
                    const SizedBox(height: 8),
                    _buildConfidenceSlider(context, l10n),
                    
                    const SizedBox(height: 16),
                    
                    // Notes
                    _buildNotesField(context, l10n),
                  ],
                ),
              ),
            ),
            _buildActions(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, Color color, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        children: [
          Icon(
            widget.won ? Icons.emoji_events : Icons.sentiment_dissatisfied,
            color: color,
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            widget.won 
                ? l10n.get('rack_win')
                : l10n.get('rack_loss'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${l10n.get('rack_count')} ${widget.rackNumber}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBallsPotted(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l10n.get('balls_potted')),
        Row(
          children: [
            IconButton(
              onPressed: _ballsPotted > 0 
                  ? () => setState(() => _ballsPotted--) 
                  : null,
              icon: const Icon(Icons.remove_circle_outline, size: 20),
            ),
            Container(
              width: 50,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_ballsPotted',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _ballsPotted++),
              icon: const Icon(Icons.add_circle_outline, size: 20),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLargestRun(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l10n.get('largest_run')),
        Row(
          children: [
            IconButton(
              onPressed: _largestRun > 0 
                  ? () => setState(() => _largestRun--) 
                  : null,
              icon: const Icon(Icons.remove_circle_outline, size: 20),
            ),
            Container(
              width: 50,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_largestRun',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _largestRun++),
              icon: const Icon(Icons.add_circle_outline, size: 20),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBreakSection(BuildContext context, AppLocalizations l10n) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: Text(l10n.get('break_success')),
          selected: _breakSuccess,
          onSelected: (selected) => setState(() => _breakSuccess = selected),
          avatar: Icon(
            Icons.check_circle,
            size: 18,
            color: _breakSuccess ? Colors.green : Colors.grey,
          ),
        ),
        FilterChip(
          label: Text(l10n.get('scratch')),
          selected: _breakScratch,
          onSelected: (selected) => setState(() => _breakScratch = selected),
          avatar: Icon(
            Icons.warning,
            size: 18,
            color: _breakScratch ? Colors.orange : Colors.grey,
          ),
        ),
        FilterChip(
          label: Text(l10n.get('foul')),
          selected: _breakFoul,
          onSelected: (selected) => setState(() => _breakFoul = selected),
          avatar: Icon(
            Icons.error,
            size: 18,
            color: _breakFoul ? Colors.red : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorsSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        // Easy Miss / Hard Miss
        Row(
          children: [
            Expanded(
              child: _buildErrorCounter(
                context,
                l10n.get('easy_miss'),
                _easyMissCount,
                Colors.grey,
                (v) => setState(() => _easyMissCount = v),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildErrorCounter(
                context,
                l10n.get('hard_miss'),
                _hardMissCount,
                Colors.orange,
                (v) => setState(() => _hardMissCount = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Scratch / Position
        Row(
          children: [
            Expanded(
              child: _buildErrorCounter(
                context,
                l10n.get('scratch'),
                _scratchErrorCount,
                Colors.red,
                (v) => setState(() => _scratchErrorCount = v),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildErrorCounter(
                context,
                l10n.get('position_error'),
                _positionErrorCount,
                Colors.blue,
                (v) => setState(() => _positionErrorCount = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Safety / Kick
        Row(
          children: [
            Expanded(
              child: _buildErrorCounter(
                context,
                l10n.get('safety_error'),
                _safetyErrorCount,
                Colors.purple,
                (v) => setState(() => _safetyErrorCount = v),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildErrorCounter(
                context,
                l10n.get('kick_error'),
                _kickErrorCount,
                Colors.brown,
                (v) => setState(() => _kickErrorCount = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Jump Error
        Row(
          children: [
            Expanded(
              child: _buildErrorCounter(
                context,
                l10n.get('jump_error'),
                _jumpErrorCount,
                Colors.teal,
                (v) => setState(() => _jumpErrorCount = v),
              ),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorCounter(
    BuildContext context,
    String label,
    int value,
    Color color,
    Function(int) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(13),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: value > 0 ? () => onChanged(value - 1) : null,
                child: Icon(Icons.remove, size: 16, color: color),
              ),
              Container(
                width: 24,
                alignment: Alignment.center,
                child: Text(
                  '$value',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              InkWell(
                onTap: () => onChanged(value + 1),
                child: Icon(Icons.add, size: 16, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthSelector(BuildContext context, AppLocalizations l10n) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _strengthOptions.map((option) {
        final isSelected = _selectedStrengths.contains(option);
        return FilterChip(
          label: Text(
            _getLocalizedStrength(option, l10n),
            style: const TextStyle(fontSize: 12),
          ),
          selected: isSelected,
          selectedColor: Colors.green.withAlpha(51),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedStrengths.add(option);
              } else {
                _selectedStrengths.remove(option);
              }
            });
          },
          visualDensity: VisualDensity.compact,
        );
      }).toList(),
    );
  }

  Widget _buildMistakeSelector(BuildContext context, AppLocalizations l10n) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _mistakeOptions.map((option) {
        final isSelected = _selectedMistakes.contains(option);
        return FilterChip(
          label: Text(
            _getLocalizedMistake(option, l10n),
            style: const TextStyle(fontSize: 12),
          ),
          selected: isSelected,
          selectedColor: Colors.red.withAlpha(51),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedMistakes.add(option);
              } else {
                _selectedMistakes.remove(option);
              }
            });
          },
          visualDensity: VisualDensity.compact,
        );
      }).toList(),
    );
  }

  Widget _buildConfidenceSlider(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${l10n.get('confidence')}: $_confidence/10',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              _getConfidenceLabel(l10n),
              style: TextStyle(
                color: _getConfidenceColor(_confidence),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: _confidence.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: '$_confidence',
          onChanged: (value) {
            setState(() => _confidence = value.toInt());
          },
        ),
      ],
    );
  }

  String _getConfidenceLabel(AppLocalizations l10n) {
    if (_confidence <= 3) return l10n.get('low');
    if (_confidence <= 6) return l10n.get('medium');
    return l10n.get('high');
  }

  Color _getConfidenceColor(int value) {
    if (value <= 3) return Colors.red;
    if (value <= 5) return Colors.orange;
    if (value <= 7) return Colors.amber;
    return Colors.green;
  }

  Widget _buildNotesField(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get('notes'),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 2,
          maxLength: 300,
          decoration: InputDecoration(
            hintText: l10n.get('notes_placeholder'),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.get('cancel')),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () {
              final data = RackSummaryData(
                ballsPotted: _ballsPotted,
                largestRun: _largestRun,
                breakSuccess: _breakSuccess,
                breakScratch: _breakScratch,
                breakFoul: _breakFoul,
                easyMissCount: _easyMissCount,
                hardMissCount: _hardMissCount,
                scratchErrorCount: _scratchErrorCount,
                positionErrorCount: _positionErrorCount,
                safetyErrorCount: _safetyErrorCount,
                kickErrorCount: _kickErrorCount,
                jumpErrorCount: _jumpErrorCount,
                bestStrengths: _selectedStrengths.toList(),
                biggestMistakes: _selectedMistakes.toList(),
                confidence: _confidence,
                notes: _notesController.text.isEmpty ? null : _notesController.text,
              );
              widget.onSave(data);
              Navigator.of(context).pop();
            },
            child: Text(l10n.get('save')),
          ),
        ],
      ),
    );
  }
}

/// FIX-003: Rack Summary Data for Match Mode
class RackSummaryData {
  final int ballsPotted;
  final int largestRun;
  final bool breakSuccess;
  final bool breakScratch;
  final bool breakFoul;
  final int easyMissCount;
  final int hardMissCount;
  final int scratchErrorCount;
  final int positionErrorCount;
  final int safetyErrorCount;
  final int kickErrorCount;
  final int jumpErrorCount;
  final List<String> bestStrengths;
  final List<String> biggestMistakes;
  final int confidence;
  final String? notes;

  // Backward compatibility
  String? get biggestMistake => biggestMistakes.isNotEmpty ? biggestMistakes.first : null;
  String? get biggestStrength => bestStrengths.isNotEmpty ? bestStrengths.first : null;

  const RackSummaryData({
    this.ballsPotted = 0,
    this.largestRun = 0,
    this.breakSuccess = false,
    this.breakScratch = false,
    this.breakFoul = false,
    this.easyMissCount = 0,
    this.hardMissCount = 0,
    this.scratchErrorCount = 0,
    this.positionErrorCount = 0,
    this.safetyErrorCount = 0,
    this.kickErrorCount = 0,
    this.jumpErrorCount = 0,
    this.bestStrengths = const [],
    this.biggestMistakes = const [],
    this.confidence = 5,
    this.notes,
  });
}
