// lib/provider/sleep_provider.dart

import 'package:flutter/material.dart';
import 'package:capstone/data/local/sleep_storage_service.dart';
import 'package:capstone/data/models/sleep_record.dart';

class SleepProvider extends ChangeNotifier {
  final SleepStorageService _storageService = SleepStorageService.instance;

  TimeOfDay? _jamTidur;
  TimeOfDay? _jamBangun;
  int _stressLevel = 3; 
  SleepRecord? _todayRecord;
  List<SleepRecord> _weeklyRecords = [];
  double _weeklyAverageDuration = 0; // in minutes
  bool _isLoading = false;

  TimeOfDay? get jamTidur => _jamTidur;
  TimeOfDay? get jamBangun => _jamBangun;
  int get stressLevel => _stressLevel; 
  SleepRecord? get todayRecord => _todayRecord;
  List<SleepRecord> get weeklyRecords => List.unmodifiable(_weeklyRecords);
  double get weeklyAverageDuration => _weeklyAverageDuration;
  bool get isLoading => _isLoading;

  SleepProvider() {
    // Optionally: load data on provider creation
    // loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final today = DateTime.now();
      final record = await _storageService.readRecordByDate(today);
      _todayRecord = record;

      if (record != null) {
        final sleepParts = record.sleepTime.split(':');
        final wakeParts = record.wakeTime.split(':');

        _jamTidur = TimeOfDay(
          hour: int.parse(sleepParts[0]),
          minute: int.parse(sleepParts[1]),
        );

        _jamBangun = TimeOfDay(
          hour: int.parse(wakeParts[0]),
          minute: int.parse(wakeParts[1]),
        );
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setJamTidur(TimeOfDay time) async {
    _jamTidur = time;
    if (_jamBangun != null) saveSleepRecord();
    notifyListeners();

    if (_jamBangun != null) {
      saveSleepRecord();
    }
  }

  Future<void> setJamBangun(TimeOfDay time) async {
    _jamBangun = time;
    if (_jamTidur != null) saveSleepRecord();
    notifyListeners();

    if (_jamTidur != null) {
      saveSleepRecord();
    }
  }

  /// Calculates sleep duration (Duration) using current jamTidur and jamBangun.
  /// Returns null if either time is missing.
  Duration? calculateDuration() {
    if (_jamTidur == null || _jamBangun == null) return null;

    final sleepMinutes =
        (_jamBangun!.hour * 60 + _jamBangun!.minute) -
        (_jamTidur!.hour * 60 + _jamTidur!.minute);

    return Duration(
      minutes: sleepMinutes >= 0 ? sleepMinutes : sleepMinutes + 24 * 60,
    );
  }

  /// Returns [0.0 .. 1.0] quality score based on duration heuristics.
  /// Uses the same logic you had earlier.
  double calculateQuality() {
    final duration = calculateDuration();
    if (duration == null) return 0.0;

    final hours = duration.inMinutes / 60;

    if (hours >= 7 && hours <= 9) {
      quality = 0.95;
    } else if (hours >= 6 && hours < 7) {
      quality = 0.75 + ((hours - 6) * 0.20);
    } else if (hours > 9 && hours <= 10) {
      quality = 0.95 - ((hours - 9) * 0.15);
    } else if (hours >= 5 && hours < 6) {
      quality = 0.60 + ((hours - 5) * 0.15);
    } else if (hours < 5) {
      return (0.30 > hours * 0.12) ? 0.30 : hours * 0.12;
    } else {
      return (0.50 > 0.80 - ((hours - 10) * 0.10))
          ? 0.50
          : 0.80 - ((hours - 10) * 0.10);
    }

    
    quality -= (_stressLevel - 3) * 0.05;
    return quality.clamp(0.0, 1.0); 
  }

  Future<bool> saveSleepRecord() async {
    if (_jamTidur == null || _jamBangun == null) return false;

    final duration = calculateDuration();
    if (duration == null) return;

    final quality = calculateQuality();

    // Turn TimeOfDay into "HH:mm" strings
    final sleepStr =
        '${_jamTidur!.hour.toString().padLeft(2, '0')}:${_jamTidur!.minute.toString().padLeft(2, '0')}';
    final wakeStr =
        '${_jamBangun!.hour.toString().padLeft(2, '0')}:${_jamBangun!.minute.toString().padLeft(2, '0')}';

    final newRecord = SleepRecord(
      id: _todayRecord?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      sleepTime: sleepStr,
      wakeTime: wakeStr,
      durationMinutes: duration.inMinutes,
      quality: quality,
      stressLevel: _stressLevel, 
      date: DateTime.now(),
    );

    try {
      await _storageService.save(record);
      _todayRecord = record;

      await loadData();

      return true;
    } catch (e) {
      debugPrint('Error saving record: $e');
      return false;
    }
  }

  Future<bool> deleteRecord(String id) async {
    try {
      final result = await _storageService.delete(id);
      if (result) {
        await loadData();
      }
      return result;
    } catch (e) {
      debugPrint('Error deleting record: $e');
      return false;
    }
  }

  Future<bool> clearAllData() async {
    try {
      final result = await _storageService.deleteAll();
      if (result) {
        _jamTidur = null;
        _jamBangun = null;
        _todayRecord = null;
        _weeklyRecords = [];
        _weeklyAverageDuration = 0;
        notifyListeners();
      }
      return result;
    } catch (e) {
      debugPrint('Error clearing data: $e');
      return false;
    }
  }

  /// Convenience method: force refresh from storage (alias)
  Future<void> refresh() async {
    await loadData();
  }

  /// Get a human-readable duration string for UI (e.g. "7h 15m")
  static String formatDurationHuman(Duration? dur) {
    if (dur == null) return '--';
    final h = dur.inHours;
    final m = dur.inMinutes.remainder(60);
    return '${h}h ${m}m';
  }

  /// Get TimeOfDay formatted like "HH:mm" for display
  static String formatTimeOfDay(TimeOfDay? t) {
    if (t == null) return '--:--';
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
