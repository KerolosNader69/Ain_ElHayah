import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import '../models/appointment.dart';
import '../models/appointment_status.dart';
import '../models/time_slot.dart';
import '../screens/doctors_screen.dart';

class AppointmentProvider extends ChangeNotifier {
  final List<Appointment> _appointments = [];
  final _uuid = const Uuid();
  final _random = Random();

  List<Appointment> get appointments => List.unmodifiable(_appointments);

  List<Appointment> get upcomingAppointments {
    return _appointments
        .where((apt) => apt.status == AppointmentStatus.upcoming)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<Appointment> get pastAppointments {
    final now = DateTime.now();
    return _appointments
        .where((apt) =>
            apt.status == AppointmentStatus.completed ||
            apt.status == AppointmentStatus.cancelled ||
            (apt.status == AppointmentStatus.upcoming &&
                apt.dateTime.isBefore(now)))
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  void addAppointment(Appointment appointment) {
    _appointments.add(appointment);
    notifyListeners();
  }

  void cancelAppointment(String appointmentId) {
    final index = _appointments.indexWhere((apt) => apt.id == appointmentId);
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(
        status: AppointmentStatus.cancelled,
      );
      notifyListeners();
    }
  }

  Appointment? getAppointmentById(String id) {
    try {
      return _appointments.firstWhere((apt) => apt.id == id);
    } catch (e) {
      return null;
    }
  }

  String generateBookingReference() {
    return _uuid.v4().substring(0, 8).toUpperCase();
  }

  List<TimeSlot> getAvailableSlots(Doctor doctor, DateTime date) {
    final slots = <TimeSlot>[];
    final startHour = 9; // 9 AM
    final endHour = 17; // 5 PM
    final intervalMinutes = 30;

    // Normalize the date to start of day
    final normalizedDate = DateTime(date.year, date.month, date.day);

    for (int hour = startHour; hour < endHour; hour++) {
      for (int minute = 0; minute < 60; minute += intervalMinutes) {
        final slotTime = normalizedDate.add(
          Duration(hours: hour, minutes: minute),
        );

        // Check if this slot is already booked
        final isBooked = _appointments.any((apt) =>
            apt.doctor.id == doctor.id &&
            apt.status == AppointmentStatus.upcoming &&
            apt.dateTime.year == slotTime.year &&
            apt.dateTime.month == slotTime.month &&
            apt.dateTime.day == slotTime.day &&
            apt.dateTime.hour == slotTime.hour &&
            apt.dateTime.minute == slotTime.minute);

        // Randomly mark some slots as unavailable for realism (30% chance)
        // but only if not already booked
        final isRandomlyUnavailable = !isBooked && _random.nextDouble() < 0.3;

        slots.add(TimeSlot(
          dateTime: slotTime,
          isAvailable: !isBooked && !isRandomlyUnavailable,
        ));
      }
    }

    return slots;
  }

  // Helper method to check if a specific time slot is available
  bool isSlotAvailable(Doctor doctor, DateTime dateTime) {
    return !_appointments.any((apt) =>
        apt.doctor.id == doctor.id &&
        apt.status == AppointmentStatus.upcoming &&
        apt.dateTime.year == dateTime.year &&
        apt.dateTime.month == dateTime.month &&
        apt.dateTime.day == dateTime.day &&
        apt.dateTime.hour == dateTime.hour &&
        apt.dateTime.minute == dateTime.minute);
  }

  // Helper method to get appointments for a specific doctor
  List<Appointment> getAppointmentsByDoctor(int doctorId) {
    return _appointments
        .where((apt) => apt.doctor.id == doctorId)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  // Helper method to get appointments for a specific date
  List<Appointment> getAppointmentsByDate(DateTime date) {
    return _appointments
        .where((apt) =>
            apt.dateTime.year == date.year &&
            apt.dateTime.month == date.month &&
            apt.dateTime.day == date.day)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }
}
