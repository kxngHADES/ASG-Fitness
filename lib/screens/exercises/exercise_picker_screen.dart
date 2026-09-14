import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/exercise.dart';
import '../../providers/exercise_provider.dart';

/// Pushed to pick one or more exercises (e.g. for building a plan, or
/// starting a quick ad-hoc workout). Only shows exercises the user can
/// actually perform with their owned equipment.
class ExercisePickerScreen extends StatefulWidget {
  final bool multiSelect;
  const ExercisePickerScreen({super.key, this.multiSelect = false});

  @override
  State<ExercisePickerScreen> createState() => _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends State<ExercisePickerScreen> {
  String _query = '';
  final Set<int> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.multiSelect ? 'Select Exercises' : 'Pick an Exercise'),
        actions: [
          if (widget.multiSelect && _selected.isNotEmpty)
            TextButton(
              onPressed: () => Navigator.of(context).pop(_selected.toList()),
              child: Text('Add (${_selected.length})', style: const TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Consumer<ExerciseProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final available = provider.exercises.where((e) => provider.isAvailable(e)).toList();
          final filtered = available.where((e) => e.name.toLowerCase().contains(_query.toLowerCase())).toList();

          final grouped = <String, List<Exercise>>{};
          for (final e in filtered) {
            grouped.putIfAbsent(e.primaryMuscle, () => []).add(e);
          }
          final muscles = grouped.keys.toList()..sort();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search exercises',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No available exercises match. Add more equipment in Settings.'))
                    : ListView(
                        children: [
                          for (final muscle in muscles) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                              child: Text(
                                muscle,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            for (final e in grouped[muscle]!)
                              widget.multiSelect
                                  ? CheckboxListTile(
                                      title: Text(e.name),
                                      subtitle: Text(e.equipmentName ?? 'Bodyweight'),
                                      value: _selected.contains(e.id),
                                      onChanged: (checked) => setState(() {
                                        if (checked == true) {
                                          _selected.add(e.id!);
                                        } else {
                                          _selected.remove(e.id);
                                        }
                                      }),
                                    )
                                  : ListTile(
                                      title: Text(e.name),
                                      subtitle: Text(e.equipmentName ?? 'Bodyweight'),
                                      onTap: () => Navigator.of(context).pop(e),
                                    ),
                          ],
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
