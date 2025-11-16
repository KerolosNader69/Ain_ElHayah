import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/doctor_provider.dart';
import '../theme/app_theme.dart';
import '../models/patient_models.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoctorProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final doctorProvider = Provider.of<DoctorProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        title: Text(
          'Doctor Dashboard',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppTheme.getTextColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await auth.logout();
              if (mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboardTab(doctorProvider, theme),
          _buildPatientsTab(doctorProvider, theme),
          _buildNotesTab(doctorProvider, theme),
          _buildProfileTab(auth, theme),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.getMutedBackgroundColor(context),
          border: Border(
            top: BorderSide(
              color: AppTheme.getBorderColor(context),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.getTextColor(context, isDescription: true),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Patients',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.note_outlined),
              activeIcon: Icon(Icons.note),
              label: 'Notes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab(DoctorProvider doctorProvider, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, Doctor!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your patients and medical records efficiently',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Statistics Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Patients',
                  doctorProvider.totalPatients.toString(),
                  Icons.people,
                  theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Total Notes',
                  doctorProvider.totalNotes.toString(),
                  Icons.note,
                  theme,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Reports',
                  doctorProvider.totalReports.toString(),
                  Icons.description,
                  theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Prescriptions',
                  doctorProvider.totalPrescriptions.toString(),
                  Icons.medication,
                  theme,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Quick Actions
          Text(
            'Quick Actions',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppTheme.getTextColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Add Patient',
                  Icons.person_add,
                  () => context.go('/doctor/add-patient'),
                  theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionCard(
                  'View Patients',
                  Icons.people,
                  () => setState(() => _selectedIndex = 1),
                  theme,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Add Note',
                  Icons.note_add,
                  () => context.go('/doctor/add-note'),
                  theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionCard(
                  'View Notes',
                  Icons.note,
                  () => setState(() => _selectedIndex = 2),
                  theme,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'AI Chatbot',
                  Icons.chat,
                  () => context.go('/chat'),
                  theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionCard(
                  'Diagnosis',
                  Icons.medical_services,
                  () => context.go('/diagnosis'),
                  theme,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Home Page',
                  Icons.home,
                  () => context.go('/'),
                  theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(), // Empty space for symmetry
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Recent Activity
          Text(
            'Recent Activity',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppTheme.getTextColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Container(
            decoration: BoxDecoration(
              color: AppTheme.getMutedBackgroundColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.getBorderColor(context),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                ...doctorProvider.getRecentNotes(limit: 3).map((note) {
                  final patient = doctorProvider.getPatientById(note.patientId);
                  return _buildActivityItem(note, patient, theme);
                }),
                if (doctorProvider.getRecentNotes(limit: 3).isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No recent activity',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.getTextColor(context, isDescription: true),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getMutedBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppTheme.getTextColor(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.getTextColor(context, isDescription: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, VoidCallback onTap, ThemeData theme) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.getMutedBackgroundColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.getBorderColor(context),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppTheme.getTextColor(context),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(PatientNote note, Patient? patient, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getNoteIcon(note.type),
              color: AppTheme.primaryColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.getTextColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  patient?.fullName ?? 'Unknown Patient',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.getTextColor(context, isDescription: true),
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatDate(note.createdAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.getTextColor(context, isDescription: true),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getNoteIcon(String type) {
    switch (type) {
      case 'report':
        return Icons.description;
      case 'prescription':
        return Icons.medication;
      case 'diagnosis':
        return Icons.medical_services;
      default:
        return Icons.note;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildPatientsTab(DoctorProvider doctorProvider, ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'My Patients',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.getTextColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => context.go('/doctor/add-patient'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Patient'),
                style: AppTheme.getPrimaryButtonStyle(context),
              ),
            ],
          ),
        ),
        Expanded(
          child: doctorProvider.patients.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: AppTheme.getTextColor(context, isDescription: true),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No patients yet',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.getTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first patient to get started',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.getTextColor(context, isDescription: true),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: doctorProvider.patients.length,
                  itemBuilder: (context, index) {
                    final patient = doctorProvider.patients[index];
                    return _buildPatientCard(patient, doctorProvider, theme);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPatientCard(Patient patient, DoctorProvider doctorProvider, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.getMutedBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => context.go('/doctor/patient/${patient.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  Icons.person,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.fullName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.getTextColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${patient.age} years • ${patient.gender}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.getTextColor(context, isDescription: true),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      patient.email,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.getTextColor(context, isDescription: true),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    '${doctorProvider.getNotesForPatient(patient.id).length}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'notes',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.getTextColor(context, isDescription: true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesTab(DoctorProvider doctorProvider, ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Medical Notes',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.getTextColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => context.go('/doctor/add-note'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Note'),
                style: AppTheme.getPrimaryButtonStyle(context),
              ),
            ],
          ),
        ),
        Expanded(
          child: doctorProvider.notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.note_outlined,
                        size: 64,
                        color: AppTheme.getTextColor(context, isDescription: true),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notes yet',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.getTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first medical note',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.getTextColor(context, isDescription: true),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: doctorProvider.notes.length,
                  itemBuilder: (context, index) {
                    final note = doctorProvider.notes[index];
                    final patient = doctorProvider.getPatientById(note.patientId);
                    return _buildNoteCard(note, patient, theme);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildNoteCard(PatientNote note, Patient? patient, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.getMutedBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => context.go('/doctor/note/${note.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getNoteIcon(note.type),
                      color: AppTheme.primaryColor,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      note.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.getTextColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    _formatDate(note.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.getTextColor(context, isDescription: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                patient?.fullName ?? 'Unknown Patient',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                note.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.getTextColor(context, isDescription: true),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab(AuthProvider auth, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.getMutedBackgroundColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.getBorderColor(context),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Icon(
                    Icons.medical_services,
                    color: AppTheme.primaryColor,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Dr. ${auth.email?.split('@')[0] ?? 'User'}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.getTextColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  auth.email ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.getTextColor(context, isDescription: true),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Doctor',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          _buildProfileAction(
            'AI Chatbot',
            Icons.chat,
            () => context.go('/chat'),
            theme,
          ),
          
          _buildProfileAction(
            'Diagnosis Tools',
            Icons.medical_services,
            () => context.go('/diagnosis'),
            theme,
          ),
          
          _buildProfileAction(
            'Home Page',
            Icons.home,
            () => context.go('/'),
            theme,
          ),
          
          _buildProfileAction(
            'Account Settings',
            Icons.settings,
            () => context.go('/settings'),
            theme,
          ),
          
          _buildProfileAction(
            'Help & Support',
            Icons.help_outline,
            () {},
            theme,
          ),
          
          _buildProfileAction(
            'About',
            Icons.info_outline,
            () {},
            theme,
          ),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await auth.logout();
                if (mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red),
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAction(String title, IconData icon, VoidCallback onTap, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.getMutedBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppTheme.getTextColor(context, isDescription: true),
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.getTextColor(context),
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.getTextColor(context, isDescription: true),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
