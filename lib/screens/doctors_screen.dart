import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/app_header.dart';
import '../theme/app_theme.dart';

class Doctor {
  final int id;
  final String name;
  final String specialty;
  final double rating;
  final int reviews;
  final String location;
  final String distance;
  final String availability;
  final String image;
  final List<String> specialties;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviews,
    required this.location,
    required this.distance,
    required this.availability,
    required this.image,
    required this.specialties,
  });
}

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final List<Doctor> _doctors = [
    Doctor(
      id: 1,
      name: "Dr. Sarah Johnson",
      specialty: "Ophthalmologist",
      rating: 4.9,
      reviews: 127,
      location: "New York, NY",
      distance: "2.3 miles",
      availability: "Available Today",
      image: "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=300&h=300&fit=crop&crop=face",
      specialties: ["Retinal Disorders", "Glaucoma", "Diabetic Eye Care"],
    ),
    Doctor(
      id: 2,
      name: "Dr. Michael Chen",
      specialty: "Retinal Specialist",
      rating: 4.8,
      reviews: 89,
      location: "Brooklyn, NY",
      distance: "4.1 miles",
      availability: "Next Available: Tomorrow",
      image: "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=300&h=300&fit=crop&crop=face",
      specialties: ["Macular Degeneration", "Retinal Detachment", "Diabetic Retinopathy"],
    ),
    Doctor(
      id: 3,
      name: "Dr. Emily Rodriguez",
      specialty: "Corneal Specialist",
      rating: 4.7,
      reviews: 156,
      location: "Manhattan, NY",
      distance: "1.8 miles",
      availability: "Available Today",
      image: "https://images.unsplash.com/photo-1594824609258-2c3f40348d6a?w=300&h=300&fit=crop&crop=face",
      specialties: ["Corneal Transplant", "Dry Eye Treatment", "Keratoconus"],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            toolbarHeight: 72,
            collapsedHeight: 72,
            expandedHeight: 72,
            flexibleSpace: const SizedBox.expand(child: AppHeader()),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 48),
                  _buildSearchSection(context),
                  const SizedBox(height: 32),
                  _buildDoctorsGrid(context),
                  const SizedBox(height: 48),
                  _buildLoadMoreButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        Text(
          l10n.findEyeCareSpecialists,
          style: theme.textTheme.displayMedium?.copyWith(
            color: AppTheme.getTextColor(context),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.connectWithQualifiedOphthalmologists,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.getTextColor(context, isDescription: true),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      decoration: AppTheme.getSurfaceDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 768;
            
            return isDesktop
                ? Row(
                    children: [
                      Expanded(
                        child: _buildSearchField(
                          context,
                          controller: _searchController,
                          hintText: l10n.searchByNameOrSpecialty,
                          icon: Icons.search,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSearchField(
                          context,
                          controller: _locationController,
                          hintText: l10n.locationOrZipCode,
                          icon: Icons.location_on,
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.filter_list),
                        label: Text(l10n.filterResults),
                        style: AppTheme.getPrimaryButtonStyle(context),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildSearchField(
                        context,
                        controller: _searchController,
                        hintText: l10n.searchByNameOrSpecialty,
                        icon: Icons.search,
                      ),
                      const SizedBox(height: 16),
                      _buildSearchField(
                        context,
                        controller: _locationController,
                        hintText: l10n.locationOrZipCode,
                        icon: Icons.location_on,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.filter_list),
                          label: Text(l10n.filterResults),
                          style: AppTheme.getPrimaryButtonStyle(context),
                        ),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _buildSearchField(
    BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppTheme.getTextColor(context, isDescription: true),
        ),
        prefixIcon: Icon(
          icon, 
          color: AppTheme.getTextColor(context, isDescription: true),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.getBorderColor(context),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.getBorderColor(context),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.primaryColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: AppTheme.getMutedBackgroundColor(context),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildDoctorsGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;
        final isTablet = constraints.maxWidth >= 768;
        
        int crossAxisCount;
        if (isDesktop) {
          crossAxisCount = 3;
        } else if (isTablet) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }
        
        double aspectRatio;
        if (crossAxisCount == 1) {
          aspectRatio = 0.56; // give more vertical room on phones
        } else if (crossAxisCount == 2) {
          aspectRatio = 0.7;
        } else {
          aspectRatio = 0.8;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: aspectRatio,
          ),
          itemCount: _doctors.length,
          itemBuilder: (context, index) {
            return _buildDoctorCard(context, _doctors[index]);
          },
        );
      },
    );
  }

  Widget _buildDoctorCard(BuildContext context, Doctor doctor) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    final isPhone = MediaQuery.of(context).size.width < 600;
    return Container(
      decoration: AppTheme.getCardDecoration(context),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(isPhone ? 16 : 20),
          child: Column(
            children: [
              // Doctor Image
              Container(
                width: isPhone ? 84 : 96,
                height: isPhone ? 84 : 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      blurRadius: 12,
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
                          size: 48,
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              SizedBox(height: isPhone ? 12 : 16),
              
              // Doctor Name
              Text(
                doctor.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.getTextColor(context),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 4),
              
              // Specialty
              Text(
                doctor.specialty,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: isPhone ? 12 : 16),
              
              // Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    doctor.rating.toString(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.getTextColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${doctor.reviews} ${l10n.reviews})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.getTextColor(context, isDescription: true),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: isPhone ? 8 : 12),
              
              // Location
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppTheme.getTextColor(context, isDescription: true),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    doctor.location,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.getTextColor(context, isDescription: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '• ${doctor.distance}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: isPhone ? 6 : 8),
              
              // Availability
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppTheme.accentColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    doctor.availability,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.getTextColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: isPhone ? 12 : 16),
              
              // Specialties
              Wrap(
                spacing: 8,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: doctor.specialties.map((specialty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.getMutedBackgroundColor(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.getBorderColor(context),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      specialty,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: AppTheme.getTextColor(context, isDescription: true),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 12),
              
              // Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(l10n.bookAppointment),
                      ),
                      style: AppTheme.getPrimaryButtonStyle(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: AppTheme.getSecondaryButtonStyle(context),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(l10n.viewProfile),
                      ),
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

  Widget _buildLoadMoreButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: OutlinedButton(
        onPressed: () {},
        style: AppTheme.getSecondaryButtonStyle(context).copyWith(
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
        child: Text(l10n.loadMoreDoctors),
      ),
    );
  }
}
