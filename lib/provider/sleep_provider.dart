import 'package:capstone/data/local/sleep_storage_service.dart';
import 'package:capstone/data/models/sleep_record.dart';
import 'package:flutter/material.dart';

class SleepProvider extends ChangeNotifier {
  final SleepStorageService _storageService = SleepStorageService.instance;

  TimeOfDay? _jamTidur;
  TimeOfDay? _jamBangun;
  SleepRecord? _todayRecord;
  List<SleepRecord> _weeklyRecords = [];
  double _weeklyAverageDuration = 0;
  bool _isLoading = false;

  TimeOfDay? get jamTidur => _jamTidur;
  TimeOfDay? get jamBangun => _jamBangun;
  SleepRecord? get todayRecord => _todayRecord;
  List<SleepRecord> get weeklyRecords => _weeklyRecords;
  double get weeklyAverageDuration => _weeklyAverageDuration;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final today = DateTime.now();
      final record = await _storageService.readRecordByDate(today);
      final weekly = await _storageService.readWeeklyRecords();
      final avgDuration = await _storageService.getWeeklyAverageDuration();

      _todayRecord = record;
      _weeklyRecords = weekly;
      _weeklyAverageDuration = avgDuration;

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

  void setJamTidur(TimeOfDay time) {
    _jamTidur = time;
    notifyListeners();

    if (_jamBangun != null) {
      saveSleepRecord();
    }
  }

  void setJamBangun(TimeOfDay time) {
    _jamBangun = time;
    notifyListeners();

    if (_jamTidur != null) {
      saveSleepRecord();
    }
  }

  Duration? calculateDuration() {
    if (_jamTidur == null || _jamBangun == null) return null;

    final sleepMinutes =
        (_jamBangun!.hour * 60 + _jamBangun!.minute) -
        (_jamTidur!.hour * 60 + _jamTidur!.minute);

    return Duration(
      minutes: sleepMinutes >= 0 ? sleepMinutes : sleepMinutes + 24 * 60,
    );
  }

  double calculateQuality() {
    final duration = calculateDuration();
    if (duration == null) return 0.0;

    final hours = duration.inMinutes / 60;

    if (hours >= 7 && hours <= 9) {
      return 0.95;
    } else if (hours >= 6 && hours < 7) {
      return 0.75 + ((hours - 6) * 0.20);
    } else if (hours > 9 && hours <= 10) {
      return 0.95 - ((hours - 9) * 0.15);
    } else if (hours >= 5 && hours < 6) {
      return 0.60 + ((hours - 5) * 0.15);
    } else if (hours < 5) {
      return (0.30 > hours * 0.12) ? 0.30 : hours * 0.12;
    } else {
      return (0.50 > 0.80 - ((hours - 10) * 0.10))
          ? 0.50
          : 0.80 - ((hours - 10) * 0.10);
    }
  }

  Future<bool> saveSleepRecord() async {
    if (_jamTidur == null || _jamBangun == null) return false;

    final duration = calculateDuration();
    if (duration == null) return false;

    final quality = calculateQuality();

    final record = SleepRecord(
      id: _todayRecord?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      sleepTime:
          '${_jamTidur!.hour.toString().padLeft(2, '0')}:${_jamTidur!.minute.toString().padLeft(2, '0')}',
      wakeTime:
          '${_jamBangun!.hour.toString().padLeft(2, '0')}:${_jamBangun!.minute.toString().padLeft(2, '0')}',
      durationMinutes: duration.inMinutes,
      quality: quality,
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
}
