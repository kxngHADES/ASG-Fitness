import 'package:flutter/foundation.dart';

import '../models/exercise.dart';
import '../repositories/exercise_repository.dart';

class ExerciseProvider extends ChangeNotifier {
  final ExerciseRepository _repo = ExerciseRepository();

  List<Exercise> _all = [];
  bool _loading = true;
  bool _onlyAvailable = true;

  bool get loading => _loading;
  bool get onlyAvailable => _onlyAvailable;

  List<Exercise> get exercises =>
      _onlyAvailable ? _all.where((e) => e.equipmentId == null || _availableEquipmentIds.contains(e.equipmentId)).toList() : _all;

  Set<int> _availableEquipmentIds = {};

  Future<void> load(Set<int> ownedEquipmentIds) async {
    _loading = true;
    notifyListeners();
    _availableEquipmentIds = ownedEquipmentIds;
    _all = await _repo.getAll();
    _loading = false;
    notifyListeners();
  }

  void updateOwnedEquipment(Set<int> ownedEquipmentIds) {
    _availableEquipmentIds = ownedEquipmentIds;
    notifyListeners();
  }

  void setOnlyAvailable(bool value) {
    _onlyAvailable = value;
    notifyListeners();
  }

  bool isAvailable(Exercise e) =>
      e.equipmentId == null || _availableEquipmentIds.contains(e.equipmentId);

  Future<void> addCustomExercise(Exercise exercise) async {
    final id = await _repo.createCustom(exercise);
    final created = await _repo.getById(id);
    if (created != null) {
      _all = [..._all, created];
      notifyListeners();
    }
  }

  Future<void> deleteExercise(int id) async {
    await _repo.delete(id);
    _all = _all.where((e) => e.id != id).toList();
    notifyListeners();
  }
}
