import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/exercise.dart';
import '../../models/workout_session.dart';
import '../../providers/session_provider.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final int sessionId;
  const ActiveWorkoutScreen({super.key, required this.sessionId});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  late Future<List<SessionExercise>> _exercisesFuture;

  @override
  void initState() {
    super.initState();
    _exercisesFuture = context.read<SessionProvider>().getSessionExercises(widget.sessionId);
  }

  Future<void> _finish() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish workout?'),
        content: const Text('This marks the session as complete.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Not yet')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Finish')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<SessionProvider>().completeSession(widget.sessionId);
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout'),
        actions: [
          TextButton(
            onPressed: _finish,
            child: const Text('Finish', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: FutureBuilder<List<SessionExercise>>(
        future: _exercisesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final exercises = snapshot.data!;
          if (exercises.isEmpty) {
            return const Center(child: Text('No exercises in this session.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
            itemCount: exercises.length,
            itemBuilder: (context, i) => _ExerciseLogCard(sessionExercise: exercises[i]),
          );
        },
      ),
    );
  }
}

class _ExerciseLogCard extends StatefulWidget {
  final SessionExercise sessionExercise;
  const _ExerciseLogCard({required this.sessionExercise});

  @override
  State<_ExerciseLogCard> createState() => _ExerciseLogCardState();
}

class _ExerciseLogCardState extends State<_ExerciseLogCard> {
  List<SetLog> _sets = [];
  bool _loading = true;

  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  final _durationController = TextEditingController();
  final _distanceController = TextEditingController();

  TrackingType get _tracking => trackingTypeFromString(widget.sessionExercise.trackingType ?? 'weightReps');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sets = await context.read<SessionProvider>().getSetLogs(widget.sessionExercise.id!);
    if (!mounted) return;
    setState(() {
      _sets = sets;
      _loading = false;
    });
  }

  Future<void> _logSet() async {
    final setNumber = _sets.length + 1;
    final log = SetLog(
      sessionExerciseId: widget.sessionExercise.id!,
      setNumber: setNumber,
      weightKg: double.tryParse(_weightController.text.trim()),
      reps: int.tryParse(_repsController.text.trim()),
      durationSeconds: int.tryParse(_durationController.text.trim()),
      distanceKm: double.tryParse(_distanceController.text.trim()),
      completed: true,
    );
    await context.read<SessionProvider>().addSetLog(log);
    await _load();
  }

  Future<void> _deleteSet(SetLog log) async {
    await context.read<SessionProvider>().deleteSetLog(log.id!);
    await _load();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _durationController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.sessionExercise.exerciseName ?? 'Exercise',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()))
            else ...[
              for (final s in _sets) _LoggedSetRow(log: s, tracking: _tracking, onDelete: () => _deleteSet(s)),
              const SizedBox(height: 8),
              _buildInputRow(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow() {
    final fields = <Widget>[];
    switch (_tracking) {
      case TrackingType.weightReps:
        fields.add(_numField(_weightController, 'kg'));
        fields.add(_numField(_repsController, 'reps'));
        break;
      case TrackingType.bodyweightReps:
        fields.add(_numField(_repsController, 'reps'));
        break;
      case TrackingType.time:
        fields.add(_numField(_durationController, 'seconds'));
        break;
      case TrackingType.distanceTime:
        fields.add(_numField(_distanceController, 'km'));
        fields.add(_numField(_durationController, 'seconds'));
        break;
    }

    return Row(
      children: [
        Text('Set ${_sets.length + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        ...fields.map((f) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: f))),
        IconButton.filled(
          icon: const Icon(Icons.check),
          onPressed: _logSet,
        ),
      ],
    );
  }

  Widget _numField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, isDense: true, border: const OutlineInputBorder()),
    );
  }
}

class _LoggedSetRow extends StatelessWidget {
  final SetLog log;
  final TrackingType tracking;
  final VoidCallback onDelete;

  const _LoggedSetRow({required this.log, required this.tracking, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    String summary;
    switch (tracking) {
      case TrackingType.weightReps:
        summary = '${log.weightKg ?? '-'} kg × ${log.reps ?? '-'} reps';
        break;
      case TrackingType.bodyweightReps:
        summary = '${log.reps ?? '-'} reps';
        break;
      case TrackingType.time:
        summary = '${log.durationSeconds ?? '-'} sec';
        break;
      case TrackingType.distanceTime:
        summary = '${log.distanceKm ?? '-'} km in ${log.durationSeconds ?? '-'} sec';
        break;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Text('Set ${log.setNumber}: $summary'),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
