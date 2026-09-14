import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/equipment.dart';
import '../../providers/equipment_provider.dart';
import '../../providers/exercise_provider.dart';

/// Grid of equipment filter chips grouped by category. Toggling a chip
/// persists ownership immediately and refreshes exercise availability.
class EquipmentPickerList extends StatelessWidget {
  const EquipmentPickerList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EquipmentProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final byCategory = <String, List<Equipment>>{};
        for (final e in provider.equipment) {
          if (e.name == 'Bodyweight') continue; // always owned, not a real choice
          byCategory.putIfAbsent(e.category, () => []).add(e);
        }
        final categories = byCategory.keys.toList()..sort();

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          children: [
            for (final category in categories) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
                child: Text(
                  category,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final item in byCategory[category]!)
                    FilterChip(
                      label: Text(item.name),
                      selected: item.owned,
                      onSelected: (_) async {
                        await provider.toggleOwned(item);
                        if (!context.mounted) return;
                        final ownedIds = provider.owned.map((e) => e.id!).toSet();
                        context.read<ExerciseProvider>().updateOwnedEquipment(ownedIds);
                      },
                    ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
