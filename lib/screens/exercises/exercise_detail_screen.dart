import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/exercise.dart';
import '../../providers/exercise_provider.dart';
import '../../providers/session_provider.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final int exerciseId;
  const ExerciseDetailScreen({super.key, required this.exerciseId});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late Future<List<Map<String, Object?>>> _history;

  @override
  void initState() {
    super.initState();
    _history = context.read<SessionProvider>().getExerciseHistory(widget.exerciseId);
  }

  @override
  Widget build(BuildContext context) {
    final exercise = context
        .watch<ExerciseProvider>()
        .exercises
        .cast<Exercise?>()
        .firstWhere((e) => e?.id == widget.exerciseId, orElse: () => null);

    if (exercise == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Exercise not found')));
    }

    return Scaffold(
      appBar: AppBar(title: Text(exercise.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text(exercise.category)),
              Chip(label: Text(exercise.primaryMuscle)),
              Chip(label: Text(exercise.equipmentName ?? 'Bodyweight')),
            ],
          ),
          if (exercise.secondaryMuscles != null) ...[
            const SizedBox(height: 12),
            Text('Also works: ${exercise.secondaryMuscles}'),
          ],
          if (exercise.instructions != null) ...[
            const SizedBox(height: 16),
            Text('How to', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(exercise.instructions!),
          ],
          const SizedBox(height: 24),
          Text('Progression', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          FutureBuilder<List<Map<String, Object?>>>(
            future: _history,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
              }
              return _ProgressionChart(rows: snapshot.data!, trackingType: exercise.trackingType);
            },
          ),
        ],
      ),
    );
  }
}

class _ProgressionChart extends StatelessWidget {
  final List<Map<String, Object?>> rows;
  final TrackingType trackingType;

  const _ProgressionChart({required this.rows, required this.trackingType});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No completed sets logged yet. Progress will appear here after your first workout.'),
        ),
      );
    }

    // Best value achieved per date (max weight, max reps, max duration, or max distance).
    final byDate = <String, double>{};
    for (final row in rows) {
      final date = row['date'] as String;
      double value;
      switch (trackingType) {
        case TrackingType.weightReps:
          value = (row['weight_kg'] as num?)?.toDouble() ?? 0;
          break;
        case TrackingType.bodyweightReps:
          value = (row['reps'] as num?)?.toDouble() ?? 0;
          break;
        case TrackingType.time:
          value = (row['duration_seconds'] as num?)?.toDouble() ?? 0;
          break;
        case TrackingType.distanceTime:
          value = (row['distance_km'] as num?)?.toDouble() ?? 0;
          break;
      }
      if (!byDate.containsKey(date) || value > byDate[date]!) {
        byDate[date] = value;
      }
    }
    final dates = byDate.keys.toList()..sort();
    final spots = <FlSpot>[
      for (var i = 0; i < dates.length; i++) FlSpot(i.toDouble(), byDate[dates[i]]!),
    ];

    final unit = switch (trackingType) {
      TrackingType.weightReps => 'kg',
      TrackingType.bodyweightReps => 'reps',
      TrackingType.time => 'sec',
      TrackingType.distanceTime => 'km',
    };

    final chart = Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
        child: SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 26,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= dates.length) return const SizedBox.shrink();
                      final d = dates[i].substring(5); // MM-dd
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(d, style: const TextStyle(fontSize: 10)),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: false,
                  color: Theme.of(context).colorScheme.primary,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        chart,
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 4),
          child: Text('Best $unit per session', style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}
