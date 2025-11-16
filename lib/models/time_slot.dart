import 'package:intl/intl.dart';

class TimeSlot {
  final DateTime dateTime;
  final bool isAvailable;

  TimeSlot({
    required this.dateTime,
    this.isAvailable = true,
  });

  String get displayTime {
    return DateFormat('h:mm a').format(dateTime);
  }

  String get displayDate {
    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  TimeSlot copyWith({
    DateTime? dateTime,
    bool? isAvailable,
  }) {
    return TimeSlot(
      dateTime: dateTime ?? this.dateTime,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateTime': dateTime.toIso8601String(),
      'isAvailable': isAvailable,
    };
  }

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      dateTime: DateTime.parse(json['dateTime'] as String),
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }
}
