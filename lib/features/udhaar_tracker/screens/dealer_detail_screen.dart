// dealer_detail_screen.dart
//
// Full ledger for one dealer: purchases and repayments interleaved,
// newest first, like a bank statement — with a running balance
// computed for display (recomputed from full history each time, not
// stored, to guarantee correctness even after deletions).

import 'package:crop_shield_ai/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../models/udhaar_models.dart';
import '../services/udhaar_db.dart';
import 'add_credit_entry_screen.dart';
import 'add_repayment_screen.dart';

class DealerDetailScreen extends StatefulWidget {
  const DealerDetailScreen({super.key, required this.dealer});

  final Dealer dealer;

  @override
  State<DealerDetailScreen> createState() => _DealerDetailScreenState();
}

class _DealerDetailScreenState extends State<DealerDetailScreen> {
  late Future<List<LedgerRow>> _ledgerFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _ledgerFuture = UdhaarDb.instance.getLedgerForDealer(widget.dealer.id!);
  }

  double _currentBalance(List<LedgerRow> rows) {
    return rows.fold<double>(
        0, (sum, r) => sum + (r.isCredit ? r.amount : -r.amount));
  }

  Future<void> _addPurchase() async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddCreditEntryScreen(dealer: widget.dealer),
      ),
    );
    if (added == true) setState(_refresh);
  }

  Future<void> _addRepayment(double currentBalance) async {
    if (currentBalance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This dealer has no outstanding balance')),
      );
      return;
    }
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddRepaymentScreen(
          dealer: widget.dealer,
          currentBalance: currentBalance,
        ),
      ),
    );
    if (added == true) setState(_refresh);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.dealer.name)),
      body: FutureBuilder<List<LedgerRow>>(
        future: _ledgerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final rows = snapshot.data ?? [];
          final balance = _currentBalance(rows);

          return Column(
            children: [
              _BalanceHeader(balance: balance),
              Expanded(
                child: rows.isEmpty
                    ? const Center(child: Text('No transactions yet'))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                        itemCount: rows.length,
                        itemBuilder: (context, i) =>
                            _LedgerTile(row: rows[i]),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FutureBuilder<List<LedgerRow>>(
        future: _ledgerFuture,
        builder: (context, snapshot) {
          final balance =
              snapshot.hasData ? _currentBalance(snapshot.data!) : 0.0;
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                heroTag: 'repay',
                onPressed: () => _addRepayment(balance),
                icon: const Icon(Icons.payments_rounded),
                label: const Text('Repay'),
                backgroundColor: AppColors.success,
              ),
              const SizedBox(width: 12),
              FloatingActionButton.extended(
                heroTag: 'purchase',
                onPressed: _addPurchase,
                icon: const Icon(Icons.add_shopping_cart_rounded),
                label: const Text('Purchase'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader({required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    final isSettled = balance <= 0;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isSettled
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.soil.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSettled ? AppColors.success : AppColors.soil,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Outstanding balance',
              style: TextStyle(fontWeight: FontWeight.w600)),
          Text(
            isSettled ? 'Settled' : balance.toStringAsFixed(0),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: isSettled ? AppColors.success : AppColors.soil,
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerTile extends StatelessWidget {
  const _LedgerTile({required this.row});

  final LedgerRow row;

  @override
  Widget build(BuildContext context) {
    final d = row.date;
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
        leading: Icon(
          row.isCredit
              ? Icons.add_shopping_cart_rounded
              : Icons.payments_rounded,
          color: row.isCredit ? AppColors.soil : AppColors.success,
        ),
        title: Text(row.title),
        subtitle: Text('$dateStr · ${row.subtitle}'
            '${row.note != null ? ' · ${row.note}' : ''}'),
        trailing: Text(
          '${row.isCredit ? '+' : '-'}${row.amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: row.isCredit ? AppColors.soil : AppColors.success,
          ),
        ),
      ),
    );
  }
}
