import 'package:flutter/foundation.dart';

import '../models/equipment.dart';
import '../repositories/equipment_repository.dart';

class EquipmentProvider extends ChangeNotifier {
  final EquipmentRepository _repo = EquipmentRepository();

  List<Equipment> _equipment = [];
  bool _loading = true;

  List<Equipment> get equipment => _equipment;
  bool get loading => _loading;
  List<Equipment> get owned => _equipment.where((e) => e.owned).toList();

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _equipment = await _repo.getAll();
    _loading = false;
    notifyListeners();
  }

  Future<void> toggleOwned(Equipment item) async {
    final newOwned = !item.owned;
    await _repo.setOwned(item.id!, newOwned);
    _equipment = _equipment
        .map((e) => e.id == item.id ? e.copyWith(owned: newOwned) : e)
        .toList();
    notifyListeners();
  }
}
