import 'package:flutter/material.dart';
import 'package:pool_os/features/equipment/domain/models/cue.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';
import 'package:pool_os/shared/widgets/app_card.dart';

class CueList extends StatelessWidget {
  const CueList({super.key, required this.cues});

  final List<Cue> cues;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (cues.isEmpty) {
      return AppCard(
        child: Center(
          child: Text(loc.get('empty_state')),
        ),
      );
    }
    return ListView.builder(
      itemCount: cues.length,
      itemBuilder: (context, index) {
        final cue = cues[index];
        return AppCard(
          child: ListTile(
            title: Text(cue.name),
            subtitle: Text('${cue.shaft} | ${cue.tip} | ${cue.weight}kg'),
            trailing: Icon(
              cue.isActive ? Icons.check_circle : Icons.radio_button_unchecked,
              color: cue.isActive ? Colors.green : null,
            ),
          ),
        );
      },
    );
  }
}
