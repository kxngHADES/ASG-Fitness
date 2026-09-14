import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/exercise_provider.dart';
import '../exercises/exercise_detail_screen.dart';

class ProgressionTab extends StatefulWidget {
  const ProgressionTab({super.key});

  @override
  State<ProgressionTab> createState() => _ProgressionTabState();
}

class _ProgressionTabState extends State<ProgressionTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExerciseProvider>();
    final exercises = provider.exercises
        .where((e) => e.name.toLowerCase().contains(_query.toLowerCase()))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search an exercise to see its progress',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, i) {
              final e = exercises[i];
              return ListTile(
                title: Text(e.name),
                subtitle: Text(e.primaryMuscle),
                trailing: const Icon(Icons.show_chart),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ExerciseDetailScreen(exerciseId: e.id!)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
