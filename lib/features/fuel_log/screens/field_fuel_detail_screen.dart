// field_fuel_detail_screen.dart
//
// Full fill-up history for one field: every entry, newest first, with
// a summary header. Long-press (or swipe, if you add it) to delete a
// wrong entry — kept simple as a confirm dialog for now.

import 'package:crop_shield_ai/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../models/fuel_entry.dart';
import '../services/fuel_log_db.dart';
import 'add_fuel_entry_screen.dart';

class FieldFuelDetailScreen extends StatefulWidget {
  const FieldFuelDetailScreen({super.key, required this.fieldName});

  final String fieldName;

  @override
  State<FieldFuelDetailScreen> createState() =>
      _FieldFuelDetailScreenState();
}

class _FieldFuelDetailScreenState extends State<FieldFuelDetailScreen> {
  late Future<List<FuelEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _entriesFuture = FuelLogDb.instance.getEntriesForField(widget.fieldName);
  }

  Future<void> _addMore() async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddFuelEntryScreen(presetFieldName: widget.fieldName),
      ),
    );
    if (added == true) setState(_refresh);
  }

  Future<void> _confirmDelete(FuelEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete entry?'),
        content: Text(
          '${entry.liters.toStringAsFixed(1)} L on '
          '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}-${entry.date.day.toString().padLeft(2, '0')} '
          'will be removed permanently.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true && entry.id != null) {
      await FuelLogDb.instance.deleteEntry(entry.id!);
      setState(_refresh);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.fieldName)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMore,
        icon: const Icon(Icons.add),
        label: const Text('Add Fill-up'),
      ),
      body: FutureBuilder<List<FuelEntry>>(
        future: _entriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final entries = snapshot.data ?? [];
          if (entries.isEmpty) {
            return const Center(child: Text('No entries for this field yet'));
          }

          final totalLiters =
              entries.fold<double>(0, (sum, e) => sum + e.liters);
          final totalCost =
              entries.fold<double>(0, (sum, e) => sum + e.totalCost);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.moss.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatColumn(
                        label: 'Total Liters',
                        value: totalLiters.toStringAsFixed(1)),
                    _StatColumn(
                        label: 'Total Cost',
                        value: 'Rs ${totalCost.toStringAsFixed(0)}'),
                    _StatColumn(
                        label: 'Fill-ups',
                        value: entries.length.toString()),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...entries.map((e) => _EntryTile(
                    entry: e,
                    onDelete: () => _confirmDelete(e),
                  )),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor)),
      ],
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry, required this.onDelete});

  final FuelEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final d = entry.date;
    final dateStr =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        leading: const Icon(Icons.local_gas_station_rounded),
        title: Text(
            '${entry.liters.toStringAsFixed(1)} L · ${entry.tractorName}'),
        subtitle: Text(
          '$dateStr · ${entry.pricePerLiter.toStringAsFixed(1)}/L'
          '${entry.workerName != null ? ' · by ${entry.workerName}' : ''}'
          '${entry.stationName != null ? ' · ${entry.stationName}' : ''}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Rs ${entry.totalCost.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
