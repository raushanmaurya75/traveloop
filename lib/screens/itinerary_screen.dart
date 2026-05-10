import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/activity.dart';
import '../models/stop.dart';
import '../models/trip.dart';
import '../services/error_handler.dart';
import '../services/isar_service.dart';
import '../services/share_service.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';
import 'packing_checklist_screen.dart';
import 'trip_notes_screen.dart';

class ItineraryScreen extends StatefulWidget {
  final Trip? trip;
  const ItineraryScreen({Key? key, this.trip}) : super(key: key);

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  final _categoryColors = const {
    'Sightseeing': Color(0xFF3B82F6),
    'Food': Color(0xFFF59E0B),
    'Adventure': Color(0xFFEF4444),
    'Transport': Color(0xFF8B5CF6),
    'Accommodation': Color(0xFF10B981),
    'Other': Color(0xFF64748B),
  };

  Color _colorFor(String category) =>
      _categoryColors[category] ?? const Color(0xFF6366F1);

  void _showAddStopSheet() {
    final cityCtrl = TextEditingController();
    DateTime? date;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => _BottomSheet(
          title: 'Add Stop',
          children: [
            _SheetField(controller: cityCtrl, hint: 'City name', icon: Icons.location_on_outlined),
            const SizedBox(height: 12),
            _SheetDateTile(
              label: date == null ? 'Select date' : _fmt(date!),
              onTap: () async {
                final picked = await showDatePicker(
                  context: ctx,
                  initialDate: widget.trip?.startDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setSheet(() => date = picked);
              },
            ),
          ],
          onSave: () async {
            if (cityCtrl.text.trim().isEmpty || date == null) return;
            final stop = Stop()
              ..tripId = widget.trip!.id
              ..city = cityCtrl.text.trim()
              ..date = date!;
            await IsarService().saveStop(stop);
            if (ctx.mounted) Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  void _showAddActivitySheet(int stopId) {
    final titleCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String category = 'Sightseeing';
    final categories = ['Sightseeing', 'Food', 'Adventure', 'Transport', 'Accommodation', 'Other'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => _BottomSheet(
          title: 'Add Activity',
          children: [
            _SheetField(controller: titleCtrl, hint: 'Activity title', icon: Icons.event_note_outlined),
            const SizedBox(height: 12),
            _SheetField(controller: timeCtrl, hint: 'Time (e.g. 09:00 AM)', icon: Icons.access_time_rounded),
            const SizedBox(height: 12),
            _SheetField(controller: priceCtrl, hint: 'Cost (e.g. \$25)', icon: Icons.attach_money_rounded, keyboardType: TextInputType.text),
            const SizedBox(height: 12),
            _SheetField(controller: descCtrl, hint: 'Description (optional)', icon: Icons.notes_rounded),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final cat = categories[i];
                  final selected = cat == category;
                  return GestureDetector(
                    onTap: () => setSheet(() => category = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.surfaceDim,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? AppColors.primary : Colors.transparent,
                        ),
                      ),
                      child: Text(cat,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : AppColors.textSecondary,
                          )),
                    ),
                  );
                },
              ),
            ),
          ],
          onSave: () async {
            if (titleCtrl.text.trim().isEmpty) return;
            final activity = Activity()
              ..stopId = stopId
              ..title = titleCtrl.text.trim()
              ..time = timeCtrl.text.trim()
              ..price = priceCtrl.text.trim().isEmpty ? 'Free' : priceCtrl.text.trim()
              ..category = category
              ..description = descCtrl.text.trim();
            await IsarService().saveActivity(activity);
            if (ctx.mounted) Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;

    if (trip == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Itinerary', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        ),
        body: Center(
          child: Text('Select a trip from My Trips.',
              style: GoogleFonts.inter(color: AppColors.textSecondary)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(trip.name,
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded),
            tooltip: 'Share Itinerary',
            onPressed: () async {
              try {
                await ShareService.shareItinerary(trip);
              } catch (e) {
                showErrorSnackBar(e);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.checklist_rounded),
            tooltip: 'Packing List',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => PackingChecklistScreen(trip: trip))),
          ),
          IconButton(
            icon: const Icon(Icons.notes_rounded),
            tooltip: 'Trip Notes',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => TripNotesScreen(trip: trip))),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStopSheet,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: Text('Add Stop', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primary,
      ),
      body: StreamBuilder<List<Stop>>(
        stream: IsarService().watchStopsForTrip(trip.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final stops = snapshot.data!;
          if (stops.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_outlined, size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text('No stops yet.',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text('Tap "Add Stop" to build your itinerary.',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textTertiary)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            itemCount: stops.length,
            itemBuilder: (_, i) => _StopSection(
              stop: stops[i],
              colorFor: _colorFor,
              onAddActivity: () => _showAddActivitySheet(stops[i].id),
            ),
          );
        },
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

// ── Stop Section ──────────────────────────────────────────────────────────────

class _StopSection extends StatelessWidget {
  final Stop stop;
  final Color Function(String) colorFor;
  final VoidCallback onAddActivity;

  const _StopSection({
    required this.stop,
    required this.colorFor,
    required this.onAddActivity,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Dismissible(
            key: ValueKey('stop_${stop.id}'),
            direction: DismissDirection.endToStart,
            background: _deleteBg(),
            confirmDismiss: (_) => _confirmDelete(context, 'Delete stop "${stop.city}"?'),
            onDismissed: (_) => IsarService().deleteStop(stop.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceDim,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.calendar_today_rounded,
                        color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stop.city,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: AppColors.textMain)),
                        Text(_fmt(stop.date),
                            style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<Activity>>(
            stream: IsarService().watchActivitiesForStop(stop.id),
            builder: (context, snapshot) {
              final activities = snapshot.data ?? [];
              return Column(
                children: [
                  ...activities.asMap().entries.map((e) {
                    final isLast = e.key == activities.length - 1 && activities.isNotEmpty;
                    return _ActivityTile(
                      activity: e.value,
                      color: colorFor(e.value.category),
                      isLast: isLast,
                    );
                  }),
                  _AddActivityButton(onTap: onAddActivity),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

// ── Activity Tile ─────────────────────────────────────────────────────────────

class _ActivityTile extends StatelessWidget {
  final Activity activity;
  final Color color;
  final bool isLast;

  const _ActivityTile({
    required this.activity,
    required this.color,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('act_${activity.id}'),
      direction: DismissDirection.endToStart,
      background: _deleteBg(),
      confirmDismiss: (_) => _confirmDelete(context, 'Delete "${activity.title}"?'),
      onDismissed: (_) => IsarService().deleteActivity(activity.id),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline dot + line
            Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withOpacity(0.3), width: 3),
                    boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, spreadRadius: 2)],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      color: color.withOpacity(0.2),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GlassCard(
                  padding: const EdgeInsets.all(14),
                  borderColor: color.withOpacity(0.25),
                  blur: 20,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: color.withOpacity(0.3)),
                        ),
                        child: Icon(_iconFor(activity.category), color: color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      // Text content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Time + price on same row
                            Row(
                              children: [
                                if (activity.time.isNotEmpty)
                                  Flexible(
                                    child: Text(
                                      activity.time,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                          color: AppColors.textTertiary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                const Spacer(),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 80),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: color.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      activity.price,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                          color: color,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activity.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColors.textMain),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                activity.category,
                                style: GoogleFonts.inter(
                                    color: color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            if (activity.description.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                activity.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    height: 1.4),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String category) {
    switch (category) {
      case 'Food': return Icons.restaurant_outlined;
      case 'Adventure': return Icons.directions_car_outlined;
      case 'Transport': return Icons.flight_outlined;
      case 'Accommodation': return Icons.hotel_outlined;
      default: return Icons.camera_alt_outlined;
    }
  }
}

class _AddActivityButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddActivityButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30, bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text('Add Activity',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

Widget _deleteBg() => Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
    );

Future<bool> _confirmDelete(BuildContext context, String message) async {
  return await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Confirm Delete',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          content: Text(message, style: GoogleFonts.inter()),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Delete', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ) ??
      false;
}

// ── Bottom Sheet scaffold ─────────────────────────────────────────────────────

class _BottomSheet extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback onSave;

  const _BottomSheet({
    required this.title,
    required this.children,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textMain)),
            const SizedBox(height: 20),
            ...children,
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Save',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;

  const _SheetField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
      ),
    );
  }
}

class _SheetDateTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SheetDateTile({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDim,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(label,
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
