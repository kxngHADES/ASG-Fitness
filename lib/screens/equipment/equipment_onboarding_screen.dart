import 'package:flutter/material.dart';

import 'equipment_picker_list.dart';

class EquipmentOnboardingScreen extends StatelessWidget {
  final VoidCallback onDone;

  const EquipmentOnboardingScreen({super.key, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to ASG Fitness')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What equipment do you have?',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select everything available to you (e.g. flat bench, treadmill). '
                    'We\'ll only suggest exercises and workouts you can actually do. '
                    'You can change this any time in Settings.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const Expanded(child: EquipmentPickerList()),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onDone,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Continue'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
