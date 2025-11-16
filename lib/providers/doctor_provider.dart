import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/patient_models.dart';

class DoctorProvider extends ChangeNotifier {
  static const String _keyPatients = 'doctor.patients';
  static const String _keyNotes = 'doctor.notes';

  List<Patient> _patients = [];
  List<PatientNote> _notes = [];
  bool _isLoading = false;

  List<Patient> get patients => _patients;
  List<PatientNote> get notes => _notes;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load patients
      final patientsJson = prefs.getString(_keyPatients);
      if (patientsJson != null) {
        final List<dynamic> patientsList = json.decode(patientsJson);
        _patients = patientsList.map((json) => Patient.fromJson(json)).toList();
      }

      // Load notes
      final notesJson = prefs.getString(_keyNotes);
      if (notesJson != null) {
        final List<dynamic> notesList = json.decode(notesJson);
        _notes = notesList.map((json) => PatientNote.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error loading doctor data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addPatient(Patient patient) async {
    _patients.add(patient);
    await _savePatients();
    notifyListeners();
  }

  Future<void> updatePatient(Patient updatedPatient) async {
    final index = _patients.indexWhere((p) => p.id == updatedPatient.id);
    if (index != -1) {
      _patients[index] = updatedPatient;
      await _savePatients();
      notifyListeners();
    }
  }

  Future<void> deletePatient(String patientId) async {
    _patients.removeWhere((p) => p.id == patientId);
    _notes.removeWhere((n) => n.patientId == patientId);
    await _savePatients();
    await _saveNotes();
    notifyListeners();
  }

  Future<void> addNote(PatientNote note) async {
    _notes.add(note);
    await _saveNotes();
    notifyListeners();
  }

  Future<void> updateNote(PatientNote updatedNote) async {
    final index = _notes.indexWhere((n) => n.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote.copyWith(updatedAt: DateTime.now());
      await _saveNotes();
      notifyListeners();
    }
  }

  Future<void> deleteNote(String noteId) async {
    _notes.removeWhere((n) => n.id == noteId);
    await _saveNotes();
    notifyListeners();
  }

  List<PatientNote> getNotesForPatient(String patientId) {
    return _notes.where((n) => n.patientId == patientId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<PatientNote> getNotesByType(String type) {
    return _notes.where((n) => n.type == type).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Patient? getPatientById(String patientId) {
    try {
      return _patients.firstWhere((p) => p.id == patientId);
    } catch (e) {
      return null;
    }
  }

  Future<void> _savePatients() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final patientsJson = json.encode(_patients.map((p) => p.toJson()).toList());
      await prefs.setString(_keyPatients, patientsJson);
    } catch (e) {
      debugPrint('Error saving patients: $e');
    }
  }

  Future<void> _saveNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = json.encode(_notes.map((n) => n.toJson()).toList());
      await prefs.setString(_keyNotes, notesJson);
    } catch (e) {
      debugPrint('Error saving notes: $e');
    }
  }

  // Statistics
  int get totalPatients => _patients.length;
  int get totalNotes => _notes.length;
  int get totalReports => _notes.where((n) => n.type == 'report').length;
  int get totalPrescriptions => _notes.where((n) => n.type == 'prescription').length;

  List<Patient> getRecentPatients({int limit = 5}) {
    final sortedPatients = List<Patient>.from(_patients)
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    return sortedPatients.take(limit).toList();
  }

  List<PatientNote> getRecentNotes({int limit = 5}) {
    final sortedNotes = List<PatientNote>.from(_notes)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedNotes.take(limit).toList();
  }
}
