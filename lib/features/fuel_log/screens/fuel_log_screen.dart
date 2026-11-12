// fuel_log_screen.dart
//
// Entry point for the feature. Shows one summary card per field
// (total liters, total cost, avg price/liter, fill-up count). Tapping
// a card drills into that field's full entry list. FAB adds a new
// fill-up.

import 'package:crop_shield_ai/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../models/fuel_entry.dart';
import '../services/fuel_log_db.dart';
import 'add_fuel_entry_screen.dart';
import 'field_fuel_detail_screen.dart';

class FuelLogScreen extends StatefulWidget {
  const FuelLogScreen({super.key});

  @override
  State<FuelLogScreen> createState() => _FuelLogScreenState();
}

class _FuelLogScreenState extends State<FuelLogScreen> {
  late Future<List<FieldFuelSummary>> _summariesFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _summariesFuture = FuelLogDb.instance.getFieldSummaries();
  }

  Future<void> _openAddEntry() async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddFuelEntryScreen()),
    );
    if (added == true) setState(_refresh);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tractor Fuel Log')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddEntry,
        icon: const Icon(Icons.add),
        label: const Text('Add Fill-up'),
      ),
      body: FutureBuilder<List<FieldFuelSummary>>(
        future: _summariesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final summaries = snapshot.data ?? [];

          if (summaries.isEmpty) {
            return _EmptyState(onAdd: _openAddEntry);
          }

          final grandTotalCost =
              summaries.fold<double>(0, (sum, s) => sum + s.totalCost);
          final grandTotalLiters =
              summaries.fold<double>(0, (sum, s) => sum + s.totalLiters);

          return RefreshIndicator(
            onRefresh: () async => setState(_refresh),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _OverallSummaryCard(
                  totalLiters: grandTotalLiters,
                  totalCost: grandTotalCost,
                  fieldCount: summaries.length,
                ),
                const SizedBox(height: 20),
                Text('By field',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                ...summaries.map((s) => _FieldSummaryCard(
                      summary: s,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                FieldFuelDetailScreen(fieldName: s.fieldName),
                          ),
                        );
                        setState(_refresh);
                      },
                    )),
                const SizedBox(height: 80), // room for FAB
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OverallSummaryCard extends StatelessWidget {
  const _OverallSummaryCard({
    required this.totalLiters,
    required this.totalCost,
    required this.fieldCount,
  });

  final double totalLiters;
  final double totalCost;
  final int fieldCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.parchment),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total fuel spend',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            'Rs ${totalCost.toStringAsFixed(0)}',
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 30,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.local_gas_station_rounded,
                  color: AppColors.stone, size: 16),
              const SizedBox(width: 6),
              Text('${totalLiters.toStringAsFixed(1)} L total',
                  style: const TextStyle(color: AppColors.textMuted)),
              const SizedBox(width: 16),
              const Icon(Icons.grass_rounded,
                  color: AppColors.stone, size: 16),
              const SizedBox(width: 6),
              Text('$fieldCount field${fieldCount == 1 ? '' : 's'}',
                  style: const TextStyle(color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FieldSummaryCard extends StatelessWidget {
  const _FieldSummaryCard({required this.summary, required this.onTap});

  final FieldFuelSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: AppColors.parchment,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.parchment),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.grass_rounded, color: AppColors.moss, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(summary.fieldName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                      '${summary.totalLiters.toStringAsFixed(1)} L, '
                      '${summary.entryCount} fill up${summary.entryCount == 1 ? '' : 's'}, '
                      'avg ${summary.averagePricePerLiter.toStringAsFixed(1)}/L',
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).hintColor),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rs ${summary.totalCost.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Icon(Icons.chevron_right, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_gas_station_outlined,
                size: 56, color: Theme.of(context).hintColor),
            const SizedBox(height: 16),
            Text('No fuel entries yet',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Log every diesel fill-up to track cost per field and per season.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Log First Fill-up'),
            ),
          ],
        ),
      ),
    );
  }
}
