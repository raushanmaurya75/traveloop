import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trip.dart';
import '../services/isar_service.dart';
import '../theme.dart';
import 'itinerary_screen.dart';

class MyTripsScreen extends StatelessWidget {
  const MyTripsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Trips',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
      ),
      body: StreamBuilder<List<Trip>>(
        stream: IsarService().watchTrips(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final trips = snapshot.data!;
          if (trips.isEmpty) {
            return Center(
              child: Text(
                'No trips yet.\nTap + to create one!',
                textAlign: TextAlign.center,
                style:
                    GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 16),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: trips.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _TripTile(trip: trips[index]),
          );
        },
      ),
    );
  }
}

class _TripTile extends StatefulWidget {
  final Trip trip;
  const _TripTile({required this.trip});

  @override
  State<_TripTile> createState() => _TripTileState();
}

class _TripTileState extends State<_TripTile> {
  bool _copying = false;

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Trip',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text('Delete "${widget.trip.name}"? This cannot be undone.',
            style: GoogleFonts.inter()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Delete', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed == true) {
      await IsarService().deleteTrip(widget.trip.id);
    }
  }

  Future<void> _copyTrip() async {
    setState(() => _copying = true);
    try {
      final copied = await IsarService().copyTrip(widget.trip.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${copied.name}" created.',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ItineraryScreen(trip: copied)),
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Copy failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _copying = false);
    }
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(widget.trip.name,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.textMain)),
            const SizedBox(height: 4),
            Text(widget.trip.destination,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            _OptionTile(
              icon: Icons.copy_rounded,
              label: 'Copy Trip',
              subtitle: 'Duplicate all stops, activities & packing list',
              color: AppColors.primary,
              loading: _copying,
              onTap: () {
                Navigator.pop(ctx);
                _copyTrip();
              },
            ),
            const SizedBox(height: 8),
            _OptionTile(
              icon: Icons.open_in_new_rounded,
              label: 'Open Itinerary',
              subtitle: 'View and edit this trip',
              color: AppColors.info,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ItineraryScreen(trip: widget.trip)),
                );
              },
            ),
            const SizedBox(height: 8),
            _OptionTile(
              icon: Icons.delete_outline_rounded,
              label: 'Delete Trip',
              subtitle: 'This action cannot be undone',
              color: AppColors.error,
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ItineraryScreen(trip: widget.trip)),
      ),
      onLongPress: _showOptions,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.flight_takeoff_rounded,
                  color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.trip.name,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.trip.destination}  •  ${_fmt(widget.trip.startDate)} – ${_fmt(widget.trip.endDate)}',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (_copying)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary),
              )
            else
              GestureDetector(
                onTap: _showOptions,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.more_vert_rounded,
                      color: AppColors.textTertiary, size: 20),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool loading;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: loading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: color),
                    )
                  : Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textMain)),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }
}
