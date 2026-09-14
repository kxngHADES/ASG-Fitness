import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/exercise.dart';
import '../../providers/exercise_provider.dart';
import 'exercise_detail_screen.dart';

class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercises')),
      body: Consumer<ExerciseProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filtered = provider.exercises
              .where((e) => e.name.toLowerCase().contains(_query.toLowerCase()))
              .toList();

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
              SwitchListTile(
                title: const Text('Only show exercises I can do'),
                subtitle: const Text('Based on your equipment'),
                value: provider.onlyAvailable,
                onChanged: (v) => provider.setOnlyAvailable(v),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No exercises match.'))
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
                            for (final e in grouped[muscle]!) _ExerciseTile(exercise: e, provider: provider),
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

class _ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  final ExerciseProvider provider;
  const _ExerciseTile({required this.exercise, required this.provider});

  @override
  Widget build(BuildContext context) {
    final available = provider.isAvailable(exercise);
    return ListTile(
      title: Text(exercise.name),
      subtitle: Text(exercise.equipmentName ?? 'Bodyweight'),
      trailing: available
          ? null
          : Icon(Icons.lock_outline, size: 18, color: Theme.of(context).colorScheme.outline),
      enabled: true,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ExerciseDetailScreen(exerciseId: exercise.id!)),
      ),
    );
  }
}
