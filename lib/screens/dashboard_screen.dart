import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trip.dart';
import '../services/auth_service.dart';
import '../services/isar_service.dart';
import '../theme.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/glass_card.dart';
import 'create_trip_screen.dart';
import 'itinerary_screen.dart';
import 'my_trips_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // ── Header ──────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const MyTripsScreen())),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDim,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3), width: 1),
                      ),
                      child: const Icon(Icons.menu_rounded,
                          size: 24, color: AppColors.textMain),
                    ),
                  ),
                  Text(
                    'Traveloop',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                      letterSpacing: -0.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen())),
                    child: user != null
                        ? UserAvatar(
                            name: user.name,
                            colorValue: user.avatarColorValue,
                            radius: 22,
                          )
                        : const SizedBox(width: 44),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ── Recent Trips ─────────────────────────────────────────────
              _buildSectionTitle('Recent Trips',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const MyTripsScreen()))),
              const SizedBox(height: 16),
              _buildRecentTripsCarousel(),

              const SizedBox(height: 40),

              // ── Recommended ──────────────────────────────────────────────
              _buildSectionTitle('Recommended Destinations'),
              const SizedBox(height: 16),
              _buildRecommendedGrid(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateTripScreen()),
        ),
        label: Text('Plan New Trip',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        icon: const Icon(Icons.add_rounded, size: 24),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                  letterSpacing: -0.3)),
          if (onTap != null)
            Text('See all',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Live recent trips carousel ─────────────────────────────────────────────
  Widget _buildRecentTripsCarousel() {
    return StreamBuilder<List<Trip>>(
      stream: IsarService().watchTrips(),
      builder: (context, snapshot) {
        final trips = snapshot.data ?? [];

        if (trips.isEmpty) {
          return Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surfaceDim,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.flight_takeoff_rounded,
                      size: 32, color: AppColors.textTertiary),
                  const SizedBox(height: 8),
                  Text('No trips yet. Tap + to create one!',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
          );
        }

        // Show up to 5 most recent
        final recent = trips.reversed.take(5).toList();

        return SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recent.length,
            clipBehavior: Clip.none,
            itemBuilder: (context, index) {
              final trip = recent[index];
              // Cycle through destination images based on name hash
              final imgUrls = [
                'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=500&h=300&fit=crop',
                'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=500&h=300&fit=crop',
                'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=500&h=300&fit=crop',
                'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=500&h=300&fit=crop',
                'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=500&h=300&fit=crop',
              ];
              final img = imgUrls[trip.name.hashCode.abs() % imgUrls.length];

              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ItineraryScreen(trip: trip)),
                ),
                child: Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 16),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(img,
                            width: 280,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                color: AppColors.surfaceDim,
                                child: const Icon(Icons.image_not_supported_outlined,
                                    color: AppColors.textTertiary))),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.55),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 14,
                        left: 14,
                        right: 14,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trip.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${trip.destination}  •  ${_fmt(trip.startDate)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRecommendedGrid() {
    final destinations = [
      {
        'name': 'Kyoto',
        'popularity': '9.8',
        'img': 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=300&h=300&fit=crop'
      },
      {
        'name': 'Rome',
        'popularity': '9.5',
        'img': 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=300&h=300&fit=crop'
      },
      {
        'name': 'Cape Town',
        'popularity': '9.2',
        'img': 'https://images.unsplash.com/photo-1580619305218-8423a7ef79b4?w=300&h=300&fit=crop'
      },
      {
        'name': 'New York',
        'popularity': '9.7',
        'img': 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=300&h=300&fit=crop'
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: destinations.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateTripScreen()),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Image.network(
                  destinations[index]['img']!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) =>
                      Container(color: AppColors.surfaceDim),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GlassCard(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    borderRadius: 12,
                    blur: 15,
                    opacity: 0.85,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 14, color: Color(0xFFFBBF24)),
                        const SizedBox(width: 3),
                        Text(
                          destinations[index]['popularity']!,
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      destinations[index]['name']!,
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
}
