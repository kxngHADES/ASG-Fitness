import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/plan_provider.dart';
import 'plan_detail_screen.dart';

class PlanListScreen extends StatefulWidget {
  const PlanListScreen({super.key});

  @override
  State<PlanListScreen> createState() => _PlanListScreenState();
}

class _PlanListScreenState extends State<PlanListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlanProvider>().load();
    });
  }

  Future<void> _createPlan() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Workout Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Plan name'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Create')),
        ],
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty && mounted) {
      final planProvider = context.read<PlanProvider>();
      final id = await planProvider.createPlan(
        nameController.text.trim(),
        descController.text.trim().isEmpty ? null : descController.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlanDetailScreen(planId: id)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Plans')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createPlan,
        icon: const Icon(Icons.add),
        label: const Text('New Plan'),
      ),
      body: Consumer<PlanProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.plans.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No workout plans yet. Tap "New Plan" to build one from your available exercises.', textAlign: TextAlign.center),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: provider.plans.length,
            itemBuilder: (context, i) {
              final plan = provider.plans[i];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.fitness_center)),
                title: Text(plan.name),
                subtitle: plan.description != null ? Text(plan.description!) : null,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final planProvider = context.read<PlanProvider>();
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete plan?'),
                        content: Text('This will delete "${plan.name}" and its exercises.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await planProvider.deletePlan(plan.id!);
                    }
                  },
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PlanDetailScreen(planId: plan.id!)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
