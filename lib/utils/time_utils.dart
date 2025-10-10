import 'package:flutter/material.dart';

String formatTime(TimeOfDay? time) {
  if (time == null) return "--:--";
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return "$hour:$minute";
}

String formatDuration(Duration? duration) {
  if (duration == null) return "--h --m";
  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  return "${hours}h ${minutes}m";
}

String formatDurationFromMinutes(double minutes) {
  if (minutes == 0) return "--h --m";
  final hours = (minutes / 60).floor();
  final mins = (minutes % 60).round();
  return "${hours}h ${mins}m";
}
