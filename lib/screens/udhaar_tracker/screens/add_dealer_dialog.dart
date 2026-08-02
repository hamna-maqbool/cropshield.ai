// add_dealer_dialog.dart
//
// Minimal dialog to register a new dealer before logging purchases
// against them. Kept as a dialog rather than a full screen since it's
// only two fields and is usually a quick, one-time setup step.

import 'package:flutter/material.dart';

import '../models/udhaar_models.dart';
import '../services/udhaar_db.dart';

class AddDealerDialog extends StatefulWidget {
  const AddDealerDialog({super.key});

  @override
  State<AddDealerDialog> createState() => _AddDealerDialogState();
}

class _AddDealerDialogState extends State<AddDealerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  bool _saving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    await UdhaarDb.instance.insertDealer(Dealer(
      name: _nameController.text.trim(),
      contact: _contactController.text.trim().isEmpty
          ? null
          : _contactController.text.trim(),
    ));

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Dealer'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Dealer / shop name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contactController,
              decoration:
                  const InputDecoration(labelText: 'Phone number (optional)'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
