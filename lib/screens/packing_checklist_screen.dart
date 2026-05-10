import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/packing_item.dart';
import '../models/trip.dart';
import '../services/isar_service.dart';
import '../theme.dart';

class PackingChecklistScreen extends StatelessWidget {
  final Trip trip;
  const PackingChecklistScreen({Key? key, required this.trip}) : super(key: key);

  void _showAddItemSheet(BuildContext context) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
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
              Text('Add Packing Item',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'e.g. Passport, Sunscreen...',
                  prefixIcon: const Icon(Icons.luggage_rounded, color: AppColors.primary),
                ),
                onSubmitted: (_) async {
                  if (ctrl.text.trim().isEmpty) return;
                  await IsarService().savePackingItem(
                    PackingItem()
                      ..tripId = trip.id
                      ..name = ctrl.text.trim(),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (ctrl.text.trim().isEmpty) return;
                    await IsarService().savePackingItem(
                      PackingItem()
                        ..tripId = trip.id
                        ..name = ctrl.text.trim(),
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Add',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Packing List',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddItemSheet(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemSheet(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded),
      ),
      body: StreamBuilder<List<PackingItem>>(
        stream: IsarService().watchPackingItems(trip.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.luggage_outlined, size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text('Nothing packed yet.',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text('Tap + to add items.',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textTertiary)),
                ],
              ),
            );
          }

          final packed = items.where((i) => i.isPacked).length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$packed / ${items.length} packed',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary)),
                    Text('${((packed / items.length) * 100).toStringAsFixed(0)}%',
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: items.isEmpty ? 0 : packed / items.length,
                    minHeight: 6,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _PackingTile(item: items[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PackingTile extends StatelessWidget {
  final PackingItem item;
  const _PackingTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
      ),
      onDismissed: (_) => IsarService().deletePackingItem(item.id),
      child: GestureDetector(
        onTap: () => IsarService().togglePackingItem(item.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: item.isPacked
                ? AppColors.success.withOpacity(0.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: item.isPacked
                  ? AppColors.success.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.15),
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: item.isPacked ? AppColors.success : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: item.isPacked ? AppColors.success : AppColors.textTertiary,
                    width: 2,
                  ),
                ),
                child: item.isPacked
                    ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: item.isPacked ? AppColors.textTertiary : AppColors.textMain,
                    decoration: item.isPacked ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
