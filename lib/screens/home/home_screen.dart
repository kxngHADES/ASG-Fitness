import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/body_stat.dart';
import '../../models/workout_session.dart';
import '../../providers/body_stat_provider.dart';
import '../../providers/plan_provider.dart';
import '../../providers/session_provider.dart';
import '../equipment/equipment_settings_screen.dart';
import '../plans/plan_detail_screen.dart';
import '../workout/quick_start_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlanProvider>().load();
      context.read<SessionProvider>().load();
      context.read<BodyStatProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ASG Fitness'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'My Equipment',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EquipmentSettingsScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final planProvider = context.read<PlanProvider>();
          final sessionProvider = context.read<SessionProvider>();
          final bodyStatProvider = context.read<BodyStatProvider>();
          await planProvider.load();
          await sessionProvider.load();
          await bodyStatProvider.load();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _WeightSummaryCard(),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const QuickStartScreen()),
              ),
              icon: const Icon(Icons.play_arrow),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('Quick Start Workout'),
              ),
            ),
            const SizedBox(height: 24),
            Text('Your Plans', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const _PlansQuickList(),
            const SizedBox(height: 24),
            Text('Recent Workouts', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const _RecentSessionsList(),
          ],
        ),
      ),
    );
  }
}

class _WeightSummaryCard extends StatelessWidget {
  const _WeightSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Consumer<BodyStatProvider>(
      builder: (context, provider, _) {
        final stats = provider.stats;
        final BodyStat? latest = stats.isNotEmpty ? stats.last : null;
        final BodyStat? previous = stats.length > 1 ? stats[stats.length - 2] : null;
        double? delta;
        if (latest?.weightKg != null && previous?.weightKg != null) {
          delta = latest!.weightKg! - previous!.weightKg!;
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(Icons.monitor_weight_outlined, color: Theme.of(context).colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        latest?.weightKg != null ? '${latest!.weightKg!.toStringAsFixed(1)} kg' : 'No weight logged yet',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (delta != null)
                        Text(
                          '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)} kg since last entry',
                          style: TextStyle(
                            color: delta == 0
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : (delta < 0 ? Colors.green : Colors.orange),
                          ),
                        )
                      else
                        Text(
                          'Log your first body stat entry',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlansQuickList extends StatelessWidget {
  const _PlansQuickList();

  @override
  Widget build(BuildContext context) {
    return Consumer<PlanProvider>(
      builder: (context, provider, _) {
        if (provider.plans.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No workout plans yet. Create one from the Plans tab.'),
            ),
          );
        }
        return SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: provider.plans.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final plan = provider.plans[i];
              return SizedBox(
                width: 180,
                child: Card(
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => PlanDetailScreen(planId: plan.id!)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(plan.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 4),
                          const Text('Tap to open', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _RecentSessionsList extends StatelessWidget {
  const _RecentSessionsList();

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, provider, _) {
        final recent = provider.sessions.take(5).toList();
        if (recent.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No workouts logged yet.'),
            ),
          );
        }
        return Column(
          children: [
            for (final s in recent) _SessionTile(session: s),
          ],
        );
      },
    );
  }
}

class _SessionTile extends StatelessWidget {
  final WorkoutSession session;
  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          session.completedAt != null ? Icons.check_circle : Icons.pending_outlined,
          color: session.completedAt != null ? Colors.green : Colors.orange,
        ),
        title: Text(session.name),
        subtitle: Text(session.planName != null ? '${session.date} · ${session.planName}' : session.date),
      ),
    );
  }
}
