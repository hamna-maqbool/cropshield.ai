// add_credit_entry_screen.dart
//
// Logs a purchase made on credit against a specific dealer. Category
// is a fixed dropdown (not free text) so reports can reliably group
// spend by seed/fertilizer/pesticide/diesel later.

import 'package:flutter/material.dart';

import '../models/udhaar_models.dart';
import '../services/udhaar_db.dart';

class AddCreditEntryScreen extends StatefulWidget {
  const AddCreditEntryScreen({super.key, required this.dealer});

  final Dealer dealer;

  @override
  State<AddCreditEntryScreen> createState() => _AddCreditEntryScreenState();
}

class _AddCreditEntryScreenState extends State<AddCreditEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController(text: 'kg');
  final _amountController = TextEditingController();
  final _fieldController = TextEditingController();
  final _noteController = TextEditingController();

  CreditCategory _category = CreditCategory.fertilizer;
  DateTime _date = DateTime.now();
  DateTime? _dueDate;
  bool _saving = false;

  Future<void> _pickDate({required bool isDueDate}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isDueDate ? (_dueDate ?? DateTime.now()) : _date,
      firstDate: isDueDate
          ? DateTime.now()
          : DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isDueDate) {
        _dueDate = picked;
      } else {
        _date = picked;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final entry = CreditEntry(
      dealerId: widget.dealer.id!,
      itemName: _itemController.text.trim(),
      category: _category,
      quantity: double.tryParse(_quantityController.text) ?? 0,
      unit: _unitController.text.trim(),
      totalAmount: double.tryParse(_amountController.text) ?? 0,
      date: _date,
      dueDate: _dueDate,
      fieldName: _fieldController.text.trim().isEmpty
          ? null
          : _fieldController.text.trim(),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    await UdhaarDb.instance.insertCreditEntry(entry);

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _itemController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _amountController.dispose();
    _fieldController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Log Purchase — ${widget.dealer.name}')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DropdownButtonFormField<CreditCategory>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: CreditCategory.values
                  .map((c) =>
                      DropdownMenuItem(value: c, child: Text(c.label)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _itemController,
              decoration: const InputDecoration(
                labelText: 'Item name (e.g. Urea, DAP, Cypermethrin)',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter item name' : null,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final n = double.tryParse(v ?? '');
                      if (n == null || n <= 0) return 'Invalid';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(
                      labelText: 'Unit (kg, bags...)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Total amount owed for this purchase',
                prefixIcon: Icon(Icons.attach_money_rounded),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final n = double.tryParse(v ?? '');
                if (n == null || n <= 0) return 'Enter valid amount';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _fieldController,
              decoration: const InputDecoration(
                labelText: 'Field this was used for (optional)',
                prefixIcon: Icon(Icons.grass_rounded),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_rounded),
              title: const Text('Purchase date'),
              subtitle: Text(_fmt(_date)),
              trailing: TextButton(
                onPressed: () => _pickDate(isDueDate: false),
                child: const Text('Change'),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_available_rounded),
              title: const Text('Repayment due date (optional)'),
              subtitle: Text(_dueDate != null ? _fmt(_dueDate!) : 'Not set'),
              trailing: Wrap(
                children: [
                  TextButton(
                    onPressed: () => _pickDate(isDueDate: true),
                    child: const Text('Set'),
                  ),
                  if (_dueDate != null)
                    TextButton(
                      onPressed: () => setState(() => _dueDate = null),
                      child: const Text('Clear'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Save Purchase'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
