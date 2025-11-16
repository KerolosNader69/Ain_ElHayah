import 'package:flutter/material.dart';

class Patient {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final int age;
  final String gender;
  final DateTime dateAdded;
  final String doctorId;
  final String? medicalHistory;
  final String? allergies;
  final String? currentMedications;

  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.age,
    required this.gender,
    required this.dateAdded,
    required this.doctorId,
    this.medicalHistory,
    this.allergies,
    this.currentMedications,
  });

  String get fullName => '$firstName $lastName';

  Patient copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    int? age,
    String? gender,
    DateTime? dateAdded,
    String? doctorId,
    String? medicalHistory,
    String? allergies,
    String? currentMedications,
  }) {
    return Patient(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      dateAdded: dateAdded ?? this.dateAdded,
      doctorId: doctorId ?? this.doctorId,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      allergies: allergies ?? this.allergies,
      currentMedications: currentMedications ?? this.currentMedications,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'age': age,
      'gender': gender,
      'dateAdded': dateAdded.toIso8601String(),
      'doctorId': doctorId,
      'medicalHistory': medicalHistory,
      'allergies': allergies,
      'currentMedications': currentMedications,
    };
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      age: json['age'],
      gender: json['gender'],
      dateAdded: DateTime.parse(json['dateAdded']),
      doctorId: json['doctorId'],
      medicalHistory: json['medicalHistory'],
      allergies: json['allergies'],
      currentMedications: json['currentMedications'],
    );
  }
}

class PatientNote {
  final String id;
  final String patientId;
  final String doctorId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String type; // 'note', 'report', 'prescription', 'diagnosis'
  final List<NoteAttachment> attachments;

  PatientNote({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.type = 'note',
    this.attachments = const [],
  });

  PatientNote copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? type,
    List<NoteAttachment>? attachments,
  }) {
    return PatientNote(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      attachments: attachments ?? this.attachments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'type': type,
      'attachments': attachments.map((a) => a.toJson()).toList(),
    };
  }

  factory PatientNote.fromJson(Map<String, dynamic> json) {
    return PatientNote(
      id: json['id'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      type: json['type'] ?? 'note',
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((a) => NoteAttachment.fromJson(a))
          .toList() ?? [],
    );
  }
}

class NoteAttachment {
  final String id;
  final String fileName;
  final String filePath;
  final String fileType;
  final int fileSize;
  final DateTime uploadedAt;

  NoteAttachment({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
    required this.uploadedAt,
  });

  NoteAttachment copyWith({
    String? id,
    String? fileName,
    String? filePath,
    String? fileType,
    int? fileSize,
    DateTime? uploadedAt,
  }) {
    return NoteAttachment(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'filePath': filePath,
      'fileType': fileType,
      'fileSize': fileSize,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  factory NoteAttachment.fromJson(Map<String, dynamic> json) {
    return NoteAttachment(
      id: json['id'],
      fileName: json['fileName'],
      filePath: json['filePath'],
      fileType: json['fileType'],
      fileSize: json['fileSize'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }

  String get fileSizeFormatted {
    if (fileSize < 1024) {
      return '${fileSize}B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  IconData get fileIcon {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.attach_file;
    }
  }
}
