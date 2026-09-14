import 'package:flutter/foundation.dart';

import '../models/body_stat.dart';
import '../repositories/body_stat_repository.dart';

class BodyStatProvider extends ChangeNotifier {
  final BodyStatRepository _repo = BodyStatRepository();

  List<BodyStat> _stats = [];
  bool _loading = true;

  List<BodyStat> get stats => _stats;
  BodyStat? get latest => _stats.isEmpty ? null : _stats.last;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _stats = await _repo.getAll();
    _loading = false;
    notifyListeners();
  }

  Future<void> save(BodyStat stat) async {
    await _repo.upsert(stat);
    await load();
  }

  Future<void> delete(int id) async {
    await _repo.delete(id);
    _stats = _stats.where((s) => s.id != id).toList();
    notifyListeners();
  }
}
