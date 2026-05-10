import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/error_handler.dart';
import '../services/groq_api_service.dart';
import '../services/trip_parser.dart';
import '../theme.dart';
import 'itinerary_screen.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({Key? key}) : super(key: key);

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _destCtrl.dispose();
    super.dispose();
  }

  int get _days {
    if (_startDate == null || _endDate == null) return 1;
    final diff = _endDate!.difference(_startDate!).inDays;
    return diff < 1 ? 1 : diff;
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => isStart ? _startDate = picked : _endDate = picked);
    }
  }

  Future<void> _generate() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates.')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final json = await GroqApiService().generateItinerary(
        destination: _destCtrl.text.trim(),
        days: _days,
      );

      final trip = await TripParser.parseAndSave(
        json: json,
        tripName: _nameCtrl.text.trim(),
        destination: _destCtrl.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ItineraryScreen(trip: trip)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      showErrorSnackBar(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('Plan New Trip',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _field(_nameCtrl, 'Trip Name', Icons.luggage_rounded),
                const SizedBox(height: 16),
                _field(_destCtrl, 'Destination', Icons.location_on_outlined),
                const SizedBox(height: 16),
                _dateTile(
                  label: _startDate == null ? 'Start Date' : _fmt(_startDate!),
                  icon: Icons.calendar_today_rounded,
                  onTap: () => _pickDate(isStart: true),
                ),
                const SizedBox(height: 12),
                _dateTile(
                  label: _endDate == null ? 'End Date' : _fmt(_endDate!),
                  icon: Icons.event_rounded,
                  onTap: () => _pickDate(isStart: false),
                ),
                if (_startDate != null && _endDate != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    '$_days day${_days == 1 ? '' : 's'}',
                    style: GoogleFonts.inter(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                ],
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _loading ? null : _generate,
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: Text('Generate with AI',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 16)),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_loading) _buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.55),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.15),
                blurRadius: 40,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Generating your\ndream trip...',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Our AI is crafting a personalized\nitinerary just for you.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
    );
  }

  Widget _dateTile(
      {required String label,
      required IconData icon,
      required VoidCallback onTap}) {
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
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
}
