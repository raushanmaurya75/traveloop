import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trip.dart';
import '../services/isar_service.dart';
import '../theme.dart';

class TripNotesScreen extends StatefulWidget {
  final Trip trip;
  const TripNotesScreen({Key? key, required this.trip}) : super(key: key);

  @override
  State<TripNotesScreen> createState() => _TripNotesScreenState();
}

class _TripNotesScreenState extends State<TripNotesScreen> {
  late final TextEditingController _ctrl;
  Timer? _debounce;
  bool _saved = true;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.trip.notes);
    _ctrl.addListener(_onChanged);
  }

  void _onChanged() {
    setState(() => _saved = false);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), _save);
  }

  Future<void> _save() async {
    await IsarService().saveNote(widget.trip.id, _ctrl.text);
    if (mounted) setState(() => _saved = true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    // Flush any pending save synchronously on exit
    IsarService().saveNote(widget.trip.id, _ctrl.text);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Trip Notes',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _saved
                  ? Row(
                      key: const ValueKey('saved'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded,
                            size: 16, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text('Saved',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.success,
                                fontWeight: FontWeight.w600)),
                      ],
                    )
                  : Row(
                      key: const ValueKey('saving'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text('Saving...',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.12)),
          ),
          child: TextField(
            controller: _ctrl,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.textMain,
              height: 1.7,
            ),
            decoration: InputDecoration(
              hintText: 'Write your trip notes here...\n\nIdeas, reminders, things to pack, places to visit...',
              hintStyle: GoogleFonts.inter(
                  color: AppColors.textTertiary, fontSize: 14, height: 1.7),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
      ),
    );
  }
}
