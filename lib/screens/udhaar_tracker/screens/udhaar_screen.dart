// udhaar_screen.dart
//
// Entry point. Shows total outstanding debt across all dealers, then
// one card per dealer with their individual outstanding balance.
// Tapping a dealer opens their full ledger. A dealer with an upcoming
// due date is flagged so the farmer notices it before it's overdue.

import 'package:flutter/material.dart';

import '../models/udhaar_models.dart';
import '../services/udhaar_db.dart';
import 'add_dealer_dialog.dart';
import 'dealer_detail_screen.dart';

class UdhaarScreen extends StatefulWidget {
  const UdhaarScreen({super.key});

  @override
  State<UdhaarScreen> createState() => _UdhaarScreenState();
}

class _UdhaarScreenState extends State<UdhaarScreen> {
  late Future<List<DealerSummary>> _summariesFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _summariesFuture = UdhaarDb.instance.getAllDealerSummaries();
  }

  Future<void> _addDealer() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => const AddDealerDialog(),
    );
    if (created == true) setState(_refresh);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Input Credit (Udhaar) Tracker')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDealer,
        icon: const Icon(Icons.add),
        label: const Text('Add Dealer'),
      ),
      body: FutureBuilder<List<DealerSummary>>(
        future: _summariesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final summaries = snapshot.data ?? [];
          if (summaries.isEmpty) {
            return _EmptyState(onAdd: _addDealer);
          }

          final totalOutstanding = summaries.fold<double>(
              0, (sum, s) => sum + s.outstandingBalance);
          final dealersWithDebt =
              summaries.where((s) => s.outstandingBalance > 0).length;

          // Dealers you owe money to first, largest debt first; fully
          // settled dealers sink to the bottom.
          final sorted = [...summaries]
            ..sort((a, b) =>
                b.outstandingBalance.compareTo(a.outstandingBalance));

          return RefreshIndicator(
            onRefresh: () async => setState(_refresh),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _OverallDebtCard(
                  totalOutstanding: totalOutstanding,
                  dealerCount: dealersWithDebt,
                ),
                const SizedBox(height: 20),
                Text('Dealers', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                ...sorted.map((s) => _DealerCard(
                      summary: s,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                DealerDetailScreen(dealer: s.dealer),
                          ),
                        );
                        setState(_refresh);
                      },
                    )),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OverallDebtCard extends StatelessWidget {
  const _OverallDebtCard({
    required this.totalOutstanding,
    required this.dealerCount,
  });

  final double totalOutstanding;
  final int dealerCount;

  @override
  Widget build(BuildContext context) {
    final isClear = totalOutstanding <= 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isClear
              ? [Colors.green.shade600, Colors.green.shade400]
              : [Colors.deepOrange.shade700, Colors.deepOrange.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isClear ? 'No outstanding credit' : 'Total you owe',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            'Rs ${totalOutstanding.toStringAsFixed(0)}',
            style: const TextStyle(
                color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
          ),
          if (!isClear) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.store_rounded, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text('across $dealerCount dealer${dealerCount == 1 ? '' : 's'}',
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DealerCard extends StatelessWidget {
  const _DealerCard({required this.summary, required this.onTap});

  final DealerSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final balance = summary.outstandingBalance;
    final isSettled = balance <= 0;

    final dueSoon = summary.nearestDueDate != null &&
        summary.nearestDueDate!.difference(DateTime.now()).inDays <= 7;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isSettled
                      ? Colors.green.withOpacity(0.12)
                      : Colors.deepOrange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.store_rounded,
                    color: isSettled ? Colors.green : Colors.deepOrange),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(summary.dealer.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                      '${summary.entryCount} purchase${summary.entryCount == 1 ? '' : 's'}'
                      '${dueSoon ? ' · due soon' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: dueSoon
                            ? Colors.deepOrange
                            : Theme.of(context).hintColor,
                        fontWeight: dueSoon ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isSettled ? 'Settled' : 'Rs ${balance.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isSettled ? Colors.green : Colors.deepOrange,
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 18),
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
            Icon(Icons.receipt_long_rounded,
                size: 56, color: Theme.of(context).hintColor),
            const SizedBox(height: 16),
            Text('No dealers yet', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Add a dealer to start tracking seed, fertilizer, or pesticide bought on credit.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add First Dealer'),
            ),
          ],
        ),
      ),
    );
  }
}
