import 'package:flutter/material.dart';

import 'equipment_picker_list.dart';

class EquipmentSettingsScreen extends StatelessWidget {
  const EquipmentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Equipment')),
      body: const EquipmentPickerList(),
    );
  }
}
