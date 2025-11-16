import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'doctors_screen.dart';
import 'appointment_booking_screen.dart';

class DoctorProfileScreen extends StatelessWidget {
  final Doctor doctor;

  const DoctorProfileScreen({
    super.key,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isPhone = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with back button
          SliverAppBar(
            floating: false,
            pinned: true,
            expandedHeight: 0,
            backgroundColor: AppTheme.darkBackground,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: AppTheme.getTextColor(context),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(isPhone ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor Header Card
                  _buildDoctorHeader(context, theme, l10n, isPhone),
                  
                  const SizedBox(height: 24),
                  
                  // About Section
                  _buildAboutSection(context, theme, l10n),
                  
                  const SizedBox(height: 24),
                  
                  // Specialties Section
                  _buildSpecialtiesSection(context, theme, l10n),
                  
                  const SizedBox(height: 24),
                  
                  // Education Section
                  _buildEducationSection(context, theme, l10n),
                  
                  const SizedBox(height: 24),
                  
                  // Experience Section
                  _buildExperienceSection(context, theme, l10n),
                  
                  const SizedBox(height: 24),
                  
                  // Languages Section
                  _buildLanguagesSection(context, theme, l10n),
                  
                  const SizedBox(height: 24),
                  
                  // Reviews Section
                  _buildReviewsSection(context, theme, l10n),
                  
                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AppointmentBookingScreen(
                doctor: doctor,
              ),
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.calendar_today),
        label: Text(l10n.bookAppointment),
      ),
    );
  }

  Widget _buildDoctorHeader(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    bool isPhone,
  ) {
    return Container(
      decoration: AppTheme.getCardDecoration(context),
      padding: EdgeInsets.all(isPhone ? 16 : 24),
      child: Column(
        children: [
          // Doctor Image
          Container(
            width: isPhone ? 120 : 140,
            height: isPhone ? 120 : 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.3),
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.network(
                doctor.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 64,
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Doctor Name
          Text(
            doctor.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.getTextColor(context),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Specialty
          Text(
            doctor.specialty,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Rating and Reviews
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.star,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                doctor.rating.toString(),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.getTextColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${doctor.reviews} ${l10n.reviews})',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.getTextColor(context, isDescription: true),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Location
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                size: 18,
                color: AppTheme.getTextColor(context, isDescription: true),
              ),
              const SizedBox(width: 4),
              Text(
                doctor.location,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.getTextColor(context, isDescription: true),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '• ${doctor.distance}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Availability
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time,
                size: 18,
                color: AppTheme.accentColor,
              ),
              const SizedBox(width: 4),
              Text(
                doctor.availability,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.getTextColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return _buildSection(
      context,
      theme,
      title: 'About',
      child: Text(
        '${doctor.name} is a highly experienced ${doctor.specialty.toLowerCase()} with over 15 years of practice. '
        'Dedicated to providing exceptional eye care and improving patients\' vision and quality of life. '
        'Known for a compassionate approach and staying current with the latest advancements in ophthalmology.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppTheme.getTextColor(context, isDescription: true),
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildSpecialtiesSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return _buildSection(
      context,
      theme,
      title: 'Specialties',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: doctor.specialties.map((specialty) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              specialty,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEducationSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return _buildSection(
      context,
      theme,
      title: 'Education',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoItem(
            context,
            theme,
            icon: Icons.school,
            title: 'Medical Degree',
            subtitle: 'Harvard Medical School, 2005',
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            context,
            theme,
            icon: Icons.local_hospital,
            title: 'Residency',
            subtitle: 'Johns Hopkins Hospital, Ophthalmology, 2005-2009',
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            context,
            theme,
            icon: Icons.workspace_premium,
            title: 'Fellowship',
            subtitle: 'Retinal Surgery, Massachusetts Eye and Ear, 2009-2011',
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return _buildSection(
      context,
      theme,
      title: 'Experience',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoItem(
            context,
            theme,
            icon: Icons.work,
            title: '15+ Years',
            subtitle: 'Practicing Ophthalmologist',
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            context,
            theme,
            icon: Icons.people,
            title: '10,000+ Patients',
            subtitle: 'Successfully treated',
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            context,
            theme,
            icon: Icons.verified,
            title: 'Board Certified',
            subtitle: 'American Board of Ophthalmology',
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagesSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final languages = ['English', 'Spanish', 'French'];
    
    return _buildSection(
      context,
      theme,
      title: 'Languages',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: languages.map((language) {
          return Chip(
            label: Text(language),
            backgroundColor: AppTheme.getMutedBackgroundColor(context),
            side: BorderSide(
              color: AppTheme.getBorderColor(context),
            ),
            labelStyle: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.getTextColor(context),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewsSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final reviews = _getMockReviews();
    
    return _buildSection(
      context,
      theme,
      title: 'Patient Reviews',
      child: Column(
        children: reviews.map((review) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildReviewCard(context, theme, review),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewCard(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> review,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getMutedBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                child: Text(
                  review['patientName'][0],
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['patientName'],
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.getTextColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review['rating']
                                ? Icons.star
                                : Icons.star_border,
                            size: 14,
                            color: Colors.amber,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          review['date'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.getTextColor(context,
                                isDescription: true),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review['comment'],
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.getTextColor(context, isDescription: true),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    ThemeData theme, {
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: AppTheme.getCardDecoration(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppTheme.getTextColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.getTextColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.getTextColor(context, isDescription: true),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getMockReviews() {
    return [
      {
        'patientName': 'John Smith',
        'rating': 5,
        'date': '2 weeks ago',
        'comment':
            'Excellent doctor! Very thorough examination and took time to explain everything. Highly recommend.',
      },
      {
        'patientName': 'Maria Garcia',
        'rating': 5,
        'date': '1 month ago',
        'comment':
            '${doctor.name} is amazing! Professional, caring, and really knows their stuff. My vision has improved significantly.',
      },
      {
        'patientName': 'David Lee',
        'rating': 4,
        'date': '2 months ago',
        'comment':
            'Great experience overall. The doctor was knowledgeable and the staff was friendly. Wait time was a bit long but worth it.',
      },
      {
        'patientName': 'Sarah Williams',
        'rating': 5,
        'date': '3 months ago',
        'comment':
            'Best ophthalmologist I\'ve ever been to. Very patient and answered all my questions. The treatment plan worked perfectly.',
      },
      {
        'patientName': 'Michael Brown',
        'rating': 5,
        'date': '4 months ago',
        'comment':
            'Highly skilled and compassionate. Made me feel comfortable throughout the entire process. Excellent results!',
      },
    ];
  }
}
