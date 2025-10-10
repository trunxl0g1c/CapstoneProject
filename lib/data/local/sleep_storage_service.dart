import 'dart:convert';
import 'package:capstone/data/models/sleep_record.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SleepStorageService {
  static final SleepStorageService instance = SleepStorageService._init();
  static const String _recordsKey = 'sleep_records';

  SleepStorageService._init();

  Future<SleepRecord> save(SleepRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await readAllRecords();

    final existingIndex = records.indexWhere(
      (r) =>
          r.date.year == record.date.year &&
          r.date.month == record.date.month &&
          r.date.day == record.date.day,
    );

    if (existingIndex != -1) {
      records[existingIndex] = record;
    } else {
      records.add(record);
    }

    final jsonList = records.map((r) => r.toJson()).toList();
    await prefs.setString(_recordsKey, json.encode(jsonList));

    return record;
  }

  Future<List<SleepRecord>> readAllRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_recordsKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => SleepRecord.fromJson(json)).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      return [];
    }
  }

  Future<SleepRecord?> readRecordByDate(DateTime date) async {
    final records = await readAllRecords();

    try {
      return records.firstWhere(
        (record) =>
            record.date.year == date.year &&
            record.date.month == date.month &&
            record.date.day == date.day,
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<SleepRecord>> readWeeklyRecords() async {
    final records = await readAllRecords();
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return records
        .where(
          (record) =>
              record.date.isAfter(weekAgo) ||
              record.date.isAtSameMomentAs(weekAgo),
        )
        .toList();
  }

  Future<bool> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await readAllRecords();

    records.removeWhere((record) => record.id == id);

    final jsonList = records.map((r) => r.toJson()).toList();
    return await prefs.setString(_recordsKey, json.encode(jsonList));
  }

  Future<bool> deleteAll() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_recordsKey);
  }

  Future<double> getWeeklyAverageDuration() async {
    final records = await readWeeklyRecords();
    if (records.isEmpty) return 0;

    final totalMinutes = records.fold<int>(
      0,
      (sum, record) => sum + record.durationMinutes,
    );

    return totalMinutes / records.length;
  }

  Future<double> getWeeklyAverageQuality() async {
    final records = await readWeeklyRecords();
    if (records.isEmpty) return 0;

    final totalQuality = records.fold<double>(
      0,
      (sum, record) => sum + record.quality,
    );

    return totalQuality / records.length;
  }

  Future<int> getRecordsCount() async {
    final records = await readAllRecords();
    return records.length;
  }
}
