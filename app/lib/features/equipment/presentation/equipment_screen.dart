import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/equipment/presentation/equipment_provider.dart';
import 'package:pool_os/features/equipment/domain/models/cue.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';
import 'package:pool_os/shared/widgets/searchable_dropdown.dart';

class EquipmentScreen extends ConsumerStatefulWidget {
  const EquipmentScreen({super.key});

  @override
  ConsumerState<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends ConsumerState<EquipmentScreen> {
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.cues.length,
      itemBuilder: (context, index) {
        final cue = state.cues[index];
        final isActiveCue = state.activeCue?.id == cue.id;
        final isBreakCue = state.activeBreakCue?.id == cue.id;

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
                title: Text(
                  cue.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${l10n.get('weight')}: ${cue.weight} oz',
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'set_active') {
                      _setActiveCue(cue);
                    } else if (value == 'set_break') {
                      _setBreakCue(cue);
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
                            isActiveCue ? Icons.check_circle : Icons.circle_outlined,
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
                            isBreakCue ? Icons.check_circle : Icons.circle_outlined,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(l10n.get('active_break_cue')),
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
                        _buildInfoRow(l10n.get('shaft_material'), cue.shaftMaterial),
                        _buildInfoRow(l10n.get('shaft_diameter'), '${cue.shaftDiameter} mm'),
                        _buildInfoRow(l10n.get('tip_brand'), cue.tipBrand),
                        _buildInfoRow(l10n.get('tip_hardness'), cue.tipHardness),
                        _buildInfoRow(l10n.get('tip_size'), cue.tipSize != null ? '${cue.tipSize} mm' : '-'),
                        _buildInfoRow(l10n.get('cue_type'), l10n.get('cue_type_${cue.cueType}')),
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

  void _showEditCueDialog(BuildContext context, Cue cue, AppLocalizations l10n) {
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                ref.read(equipmentNotifierProvider.notifier).updateCue(updatedCue);
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
      SnackBar(content: Text(l10n.get('set_as_active_cue').replaceAll('{name}', cue.name))),
    );
  }

  void _setBreakCue(Cue cue) {
    ref.read(equipmentNotifierProvider.notifier).setActiveBreakCue(cue.id!);
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.get('set_as_break_cue').replaceAll('{name}', cue.name))),
    );
  }

  void _confirmDeleteCue(
      BuildContext context, Cue cue, AppLocalizations l10n) {
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
