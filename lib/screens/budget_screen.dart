import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/activity.dart';
import '../models/trip.dart';
import '../services/isar_service.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';

// ── Helpers (file-level) ──────────────────────────────────────────────────────

double _parsePrice(String raw) {
  final s = raw.trim().toLowerCase();
  if (s.isEmpty || s == 'free' || s == 'n/a' || s == 'varies') return 0;

  // Take only the first number in the string (handles ranges like "$20-$50")
  final match = RegExp(r'(\d{1,6}(?:\.\d{1,2})?)').firstMatch(raw);
  if (match == null) return 0;

  final value = double.tryParse(match.group(1)!) ?? 0;
  // Sanity cap: single activity cost should not exceed $9,999
  return value > 9999 ? 0 : value;
}

Map<String, double> _computeTotals(List<Activity> activities) {
  final map = <String, double>{};
  for (final a in activities) {
    final cost = _parsePrice(a.price);
    if (cost <= 0) continue;
    map[a.category] = (map[a.category] ?? 0) + cost;
  }
  return map;
}

Color _categoryColor(String cat) {
  switch (cat) {
    case 'Food':          return AppColors.warning;
    case 'Adventure':     return AppColors.error;
    case 'Transport':     return const Color(0xFF8B5CF6);
    case 'Accommodation': return AppColors.success;
    case 'Sightseeing':   return AppColors.info;
    default:              return AppColors.textSecondary;
  }
}

IconData _categoryIcon(String cat) {
  switch (cat) {
    case 'Food':          return Icons.restaurant_outlined;
    case 'Adventure':     return Icons.directions_car_outlined;
    case 'Transport':     return Icons.flight_outlined;
    case 'Accommodation': return Icons.hotel_outlined;
    case 'Sightseeing':   return Icons.camera_alt_outlined;
    default:              return Icons.attach_money_rounded;
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  Trip? _selectedTrip;
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Trip Budget',
            style: GoogleFonts.poppins(
                fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
      ),
      body: StreamBuilder<List<Trip>>(
        stream: IsarService().watchTrips(),
        builder: (context, tripSnap) {
          if (!tripSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final trips = tripSnap.data!;
          if (trips.isEmpty) {
            return Center(
              child: Text('No trips yet.',
                  style: GoogleFonts.inter(color: AppColors.textSecondary)),
            );
          }

          // Auto-select first trip if none selected or selection was deleted
          final selectedId = _selectedTrip?.id;
          final matchedTrip = selectedId != null
              ? trips.firstWhere((t) => t.id == selectedId,
                  orElse: () => trips.first)
              : trips.first;
          if (_selectedTrip?.id != matchedTrip.id) {
            WidgetsBinding.instance.addPostFrameCallback(
                (_) { if (mounted) setState(() => _selectedTrip = matchedTrip); });
          }
          _selectedTrip = matchedTrip;

          return StreamBuilder<List<Activity>>(
            stream: IsarService().watchActivitiesForTrip(_selectedTrip!.id),
            builder: (context, actSnap) {
              final activities = actSnap.data ?? [];
              final totals = _computeTotals(activities);
              final grandTotal = totals.values.fold(0.0, (a, b) => a + b);
              final budget = _selectedTrip!.budget;
              final isOverBudget = budget > 0 && grandTotal > budget;
              final days = activities.map((a) => a.stopId).toSet().length;

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                children: [
                  // ── Trip selector ──────────────────────────────────────────
                  _TripSelector(
                    trips: trips,
                    selected: _selectedTrip!,
                    onChanged: (t) => setState(() {
                      _selectedTrip = t;
                      _touchedIndex = null;
                    }),
                  ),
                  const SizedBox(height: 16),

                  // ── Over-budget alert ──────────────────────────────────────
                  if (isOverBudget) ...[
                    _OverBudgetBanner(
                        spent: grandTotal, budget: budget),
                    const SizedBox(height: 16),
                  ],

                  // ── Pie chart ──────────────────────────────────────────────
                  _PieCard(
                    grandTotal: grandTotal,
                    budget: budget,
                    totals: totals,
                    touchedIndex: _touchedIndex,
                    onTouch: (i) => setState(() =>
                        _touchedIndex = (_touchedIndex == i) ? null : i),
                  ),
                  const SizedBox(height: 16),

                  // ── Budget limit row ───────────────────────────────────────
                  _BudgetLimitRow(
                    trip: _selectedTrip!,
                    onSaved: (t) => setState(() => _selectedTrip = t),
                  ),
                  const SizedBox(height: 28),

                  // ── Category breakdown ─────────────────────────────────────
                  if (totals.isNotEmpty) ...[
                    Text('Cost Breakdown',
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMain)),
                    const SizedBox(height: 14),
                    ...totals.entries.toList().asMap().entries.map((e) {
                      final touched = _touchedIndex == e.key;
                      return _CategoryTile(
                        category: e.value.key,
                        amount: e.value.value,
                        total: grandTotal,
                        highlighted: touched,
                        onTap: () => setState(() =>
                            _touchedIndex = touched ? null : e.key),
                      );
                    }),
                  ] else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text('No costs recorded yet.',
                            style: GoogleFonts.inter(
                                color: AppColors.textSecondary)),
                      ),
                    ),

                  // ── Daily average ──────────────────────────────────────────
                  if (grandTotal > 0 && days > 0) ...[
                    const SizedBox(height: 8),
                    _DailyCard(daily: grandTotal / days),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// ── Trip selector ─────────────────────────────────────────────────────────────

class _TripSelector extends StatelessWidget {
  final List<Trip> trips;
  final Trip selected;
  final ValueChanged<Trip> onChanged;

  const _TripSelector(
      {required this.trips, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selected.id,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.primary),
          style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textMain),
          items: trips
              .map((t) => DropdownMenuItem<int>(
                    value: t.id,
                    child: Text(t.name, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: (id) {
            if (id != null) {
              final trip = trips.firstWhere((t) => t.id == id);
              onChanged(trip);
            }
          },
        ),
      ),
    );
  }
}

// ── Over-budget banner ────────────────────────────────────────────────────────

class _OverBudgetBanner extends StatelessWidget {
  final double spent;
  final double budget;

  const _OverBudgetBanner({required this.spent, required this.budget});

  @override
  Widget build(BuildContext context) {
    final over = spent - budget;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: AppColors.error, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Over Budget!',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.error)),
                Text(
                    'You\'ve exceeded your limit by \$${over.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.error.withValues(alpha: 0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pie chart card ────────────────────────────────────────────────────────────

class _PieCard extends StatelessWidget {
  final double grandTotal;
  final double budget;
  final Map<String, double> totals;
  final int? touchedIndex;
  final ValueChanged<int> onTouch;

  const _PieCard({
    required this.grandTotal,
    required this.budget,
    required this.totals,
    required this.touchedIndex,
    required this.onTouch,
  });

  @override
  Widget build(BuildContext context) {
    final entries = totals.entries.toList();
    final isOverBudget = budget > 0 && grandTotal > budget;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      showGradient: true,
      borderColor: (isOverBudget ? AppColors.error : AppColors.primary)
          .withValues(alpha: 0.2),
      blur: 25,
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 68,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        if (event is FlTapUpEvent &&
                            response?.touchedSection != null) {
                          onTouch(response!
                              .touchedSection!.touchedSectionIndex);
                        }
                      },
                    ),
                    sections: entries.isEmpty
                        ? [
                            PieChartSectionData(
                              color: AppColors.surfaceDim,
                              value: 1,
                              title: '',
                              radius: 22,
                            )
                          ]
                        : entries.asMap().entries.map((e) {
                            final isTouched = touchedIndex == e.key;
                            final color = _categoryColor(e.value.key);
                            return PieChartSectionData(
                              color: color,
                              value: e.value.value,
                              title: isTouched
                                  ? '${((e.value.value / grandTotal) * 100).toStringAsFixed(0)}%'
                                  : '',
                              titleStyle: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                              radius: isTouched ? 32 : 24,
                            );
                          }).toList(),
                  ),
                ),
                // Centre label
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (touchedIndex != null &&
                        touchedIndex! < entries.length) ...[
                      Text(entries[touchedIndex!].key,
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500)),
                      Text(
                          '\$${entries[touchedIndex!].value.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: _categoryColor(entries[touchedIndex!].key),
                              letterSpacing: -0.5)),
                    ] else ...[
                      Text('\$${grandTotal.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: isOverBudget
                                  ? AppColors.error
                                  : AppColors.textMain,
                              letterSpacing: -0.5)),
                      Text('total spent',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500)),
                      if (budget > 0) ...[
                        const SizedBox(height: 4),
                        Text('of \$${budget.toStringAsFixed(0)}',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                color: isOverBudget
                                    ? AppColors.error
                                    : AppColors.textTertiary,
                                fontWeight: FontWeight.w600)),
                      ],
                    ],
                  ],
                ),
              ],
            ),
          ),
          // ── Legend ─────────────────────────────────────────────────────────
          if (entries.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: entries.asMap().entries.map((e) {
                final isTouched = touchedIndex == e.key;
                final color = _categoryColor(e.value.key);
                return GestureDetector(
                  onTap: () => onTouch(e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isTouched
                          ? color.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isTouched
                            ? color
                            : color.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(e.value.key,
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isTouched
                                    ? color
                                    : AppColors.textSecondary)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Budget limit row ──────────────────────────────────────────────────────────

class _BudgetLimitRow extends StatefulWidget {
  final Trip trip;
  final ValueChanged<Trip> onSaved;

  const _BudgetLimitRow({required this.trip, required this.onSaved});

  @override
  State<_BudgetLimitRow> createState() => _BudgetLimitRowState();
}

class _BudgetLimitRowState extends State<_BudgetLimitRow> {
  late final TextEditingController _ctrl;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.trip.budget > 0
            ? widget.trip.budget.toStringAsFixed(0)
            : '');
  }

  @override
  void didUpdateWidget(_BudgetLimitRow old) {
    super.didUpdateWidget(old);
    if (old.trip.id != widget.trip.id) {
      _ctrl.text = widget.trip.budget > 0
          ? widget.trip.budget.toStringAsFixed(0)
          : '';
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final parsed = double.tryParse(val) ?? 0;
      await IsarService().saveBudget(widget.trip.id, parsed);
      final updated = await IsarService().getTrip(widget.trip.id);
      if (updated != null && mounted) widget.onSaved(updated);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            onChanged: _onChanged,
            decoration: InputDecoration(
              hintText: 'Set budget limit (optional)',
              prefixIcon:
                  const Icon(Icons.savings_outlined, color: AppColors.primary),
              prefixText: '\$ ',
              prefixStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, color: AppColors.textMain),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Category tile ─────────────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  final String category;
  final double amount;
  final double total;
  final bool highlighted;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    required this.amount,
    required this.total,
    required this.highlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(category);
    final pct = total > 0 ? amount / total : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: highlighted ? color.withValues(alpha: 0.06) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: highlighted
                  ? color.withValues(alpha: 0.4)
                  : Colors.grey.withValues(alpha: 0.12),
              width: highlighted ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_categoryIcon(category), color: color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(category,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppColors.textMain)),
                        Text(
                            '${(pct * 100).toStringAsFixed(0)}% of total',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Text('\$${amount.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          color: color)),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 5,
                  backgroundColor: color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Daily card ────────────────────────────────────────────────────────────────

class _DailyCard extends StatelessWidget {
  final double daily;
  const _DailyCard({required this.daily});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      showGradient: true,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      borderColor: AppColors.info.withValues(alpha: 0.3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Average Daily Spend',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textMain)),
              const SizedBox(height: 2),
              Text('Across all stops',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${daily.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -0.3)),
              Text('per day',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
