import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/body_stat.dart';
import '../../providers/body_stat_provider.dart';

class BodyStatsTab extends StatefulWidget {
  const BodyStatsTab({super.key});

  @override
  State<BodyStatsTab> createState() => _BodyStatsTabState();
}

class _BodyStatsTabState extends State<BodyStatsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BodyStatProvider>().load();
    });
  }

  Future<void> _logEntry() async {
    final stat = await _showBodyStatForm(context);
    if (stat != null && mounted) {
      await context.read<BodyStatProvider>().save(stat);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BodyStatProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final stats = provider.stats;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _logEntry,
                icon: const Icon(Icons.add),
                label: const Text('Log Body Stats'),
              ),
            ),
            const SizedBox(height: 16),
            if (stats.where((s) => s.weightKg != null).length >= 2) _WeightChart(stats: stats),
            const SizedBox(height: 16),
            Text('History', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (stats.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No entries yet. Log your first body stat above.')),
              )
            else
              for (final s in stats.reversed) _BodyStatTile(stat: s),
          ],
        );
      },
    );
  }
}

class _WeightChart extends StatelessWidget {
  final List<BodyStat> stats;
  const _WeightChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    final withWeight = stats.where((s) => s.weightKg != null).toList();
    final spots = <FlSpot>[
      for (var i = 0; i < withWeight.length; i++) FlSpot(i.toDouble(), withWeight[i].weightKg!),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
        child: SizedBox(
          height: 200,
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
                      if (i < 0 || i >= withWeight.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(withWeight[i].date.substring(5), style: const TextStyle(fontSize: 10)),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Theme.of(context).colorScheme.primary,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(show: true, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BodyStatTile extends StatelessWidget {
  final BodyStat stat;
  const _BodyStatTile({required this.stat});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (stat.weightKg != null) parts.add('${stat.weightKg} kg');
    if (stat.bodyFatPct != null) parts.add('${stat.bodyFatPct}% BF');
    if (stat.chestCm != null) parts.add('Chest ${stat.chestCm}cm');
    if (stat.waistCm != null) parts.add('Waist ${stat.waistCm}cm');
    if (stat.hipsCm != null) parts.add('Hips ${stat.hipsCm}cm');
    if (stat.armCm != null) parts.add('Arm ${stat.armCm}cm');
    if (stat.thighCm != null) parts.add('Thigh ${stat.thighCm}cm');

    return Card(
      child: ListTile(
        title: Text(stat.date),
        subtitle: Text(parts.isEmpty ? 'No measurements' : parts.join(' · ')),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => context.read<BodyStatProvider>().delete(stat.id!),
        ),
      ),
    );
  }
}

Future<BodyStat?> _showBodyStatForm(BuildContext context) {
  final now = DateTime.now();
  final dateStr = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

  final weightController = TextEditingController();
  final bodyFatController = TextEditingController();
  final chestController = TextEditingController();
  final waistController = TextEditingController();
  final hipsController = TextEditingController();
  final armController = TextEditingController();
  final thighController = TextEditingController();

  return showDialog<BodyStat>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Log Stats — $dateStr'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: weightController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Weight (kg)')),
            TextField(controller: bodyFatController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Body fat % (optional)')),
            TextField(controller: chestController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Chest cm (optional)')),
            TextField(controller: waistController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Waist cm (optional)')),
            TextField(controller: hipsController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Hips cm (optional)')),
            TextField(controller: armController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Arm cm (optional)')),
            TextField(controller: thighController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Thigh cm (optional)')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(BodyStat(
              date: dateStr,
              weightKg: double.tryParse(weightController.text.trim()),
              bodyFatPct: double.tryParse(bodyFatController.text.trim()),
              chestCm: double.tryParse(chestController.text.trim()),
              waistCm: double.tryParse(waistController.text.trim()),
              hipsCm: double.tryParse(hipsController.text.trim()),
              armCm: double.tryParse(armController.text.trim()),
              thighCm: double.tryParse(thighController.text.trim()),
            ));
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
