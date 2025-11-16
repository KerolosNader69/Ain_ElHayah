import '../screens/doctors_screen.dart';
import 'appointment_status.dart';

class Appointment {
  final String id;
  final Doctor doctor;
  final DateTime dateTime;
  final String patientName;
  final String patientEmail;
  final String patientPhone;
  final String reasonForVisit;
  final String? notes;
  final AppointmentStatus status;
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.doctor,
    required this.dateTime,
    required this.patientName,
    required this.patientEmail,
    required this.patientPhone,
    required this.reasonForVisit,
    this.notes,
    required this.status,
    required this.createdAt,
  });

  Appointment copyWith({
    String? id,
    Doctor? doctor,
    DateTime? dateTime,
    String? patientName,
    String? patientEmail,
    String? patientPhone,
    String? reasonForVisit,
    String? notes,
    AppointmentStatus? status,
    DateTime? createdAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      doctor: doctor ?? this.doctor,
      dateTime: dateTime ?? this.dateTime,
      patientName: patientName ?? this.patientName,
      patientEmail: patientEmail ?? this.patientEmail,
      patientPhone: patientPhone ?? this.patientPhone,
      reasonForVisit: reasonForVisit ?? this.reasonForVisit,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor': {
        'id': doctor.id,
        'name': doctor.name,
        'specialty': doctor.specialty,
        'rating': doctor.rating,
        'reviews': doctor.reviews,
        'location': doctor.location,
        'distance': doctor.distance,
        'availability': doctor.availability,
        'image': doctor.image,
        'specialties': doctor.specialties,
      },
      'dateTime': dateTime.toIso8601String(),
      'patientName': patientName,
      'patientEmail': patientEmail,
      'patientPhone': patientPhone,
      'reasonForVisit': reasonForVisit,
      'notes': notes,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final doctorData = json['doctor'] as Map<String, dynamic>;
    return Appointment(
      id: json['id'] as String,
      doctor: Doctor(
        id: doctorData['id'] as int,
        name: doctorData['name'] as String,
        specialty: doctorData['specialty'] as String,
        rating: (doctorData['rating'] as num).toDouble(),
        reviews: doctorData['reviews'] as int,
        location: doctorData['location'] as String,
        distance: doctorData['distance'] as String,
        availability: doctorData['availability'] as String,
        image: doctorData['image'] as String,
        specialties: List<String>.from(doctorData['specialties'] as List),
      ),
      dateTime: DateTime.parse(json['dateTime'] as String),
      patientName: json['patientName'] as String,
      patientEmail: json['patientEmail'] as String,
      patientPhone: json['patientPhone'] as String,
      reasonForVisit: json['reasonForVisit'] as String,
      notes: json['notes'] as String?,
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AppointmentStatus.upcoming,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
