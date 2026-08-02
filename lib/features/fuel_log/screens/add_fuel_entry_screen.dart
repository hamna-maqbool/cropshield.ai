// add_fuel_entry_screen.dart
//
// Fast entry form for a single fill-up. Designed to be quick to fill
// standing at a pump: liters + price/liter auto-calculates total,
// field/tractor are free-text with suggestions from past entries so
// the same names get reused (avoids "Field A" vs "field a" mismatches).

import 'package:flutter/material.dart';

import '../models/fuel_entry.dart';
import '../services/fuel_log_db.dart';

class AddFuelEntryScreen extends StatefulWidget {
  const AddFuelEntryScreen({super.key, this.presetFieldName});

  /// If opened from a specific field's history screen, pre-fill it.
  final String? presetFieldName;

  @override
  State<AddFuelEntryScreen> createState() => _AddFuelEntryScreenState();
}

class _AddFuelEntryScreenState extends State<AddFuelEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fieldController;
  final _tractorController = TextEditingController();
  final _litersController = TextEditingController();
  final _priceController = TextEditingController();
  final _workerController = TextEditingController();
  final _stationController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _date = DateTime.now();
  bool _saving = false;

  List<String> _fieldSuggestions = [];
  List<String> _tractorSuggestions = [];

  @override
  void initState() {
    super.initState();
    _fieldController =
        TextEditingController(text: widget.presetFieldName ?? '');
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    final entries = await FuelLogDb.instance.getAllEntries();
    setState(() {
      _fieldSuggestions =
          entries.map((e) => e.fieldName).toSet().toList();
      _tractorSuggestions =
          entries.map((e) => e.tractorName).toSet().toList();
    });
  }

  double get _liters => double.tryParse(_litersController.text) ?? 0;
  double get _price => double.tryParse(_priceController.text) ?? 0;
  double get _total => _liters * _price;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final entry = FuelEntry(
      fieldName: _fieldController.text.trim(),
      tractorName: _tractorController.text.trim(),
      liters: _liters,
      pricePerLiter: _price,
      date: _date,
      workerName:
          _workerController.text.trim().isEmpty ? null : _workerController.text.trim(),
      stationName:
          _stationController.text.trim().isEmpty ? null : _stationController.text.trim(),
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    await FuelLogDb.instance.insertEntry(entry);

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pop(true); // true = "an entry was added"
  }

  @override
  void dispose() {
    _fieldController.dispose();
    _tractorController.dispose();
    _litersController.dispose();
    _priceController.dispose();
    _workerController.dispose();
    _stationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Diesel Fill-up')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _AutocompleteField(
              label: 'Field',
              controller: _fieldController,
              suggestions: _fieldSuggestions,
              icon: Icons.grass_rounded,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter field name' : null,
            ),
            const SizedBox(height: 14),
            _AutocompleteField(
              label: 'Tractor',
              controller: _tractorController,
              suggestions: _tractorSuggestions,
              icon: Icons.agriculture_rounded,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter tractor name' : null,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _litersController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Liters',
                      prefixIcon: Icon(Icons.local_gas_station_rounded),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final n = double.tryParse(v ?? '');
                      if (n == null || n <= 0) return 'Enter valid liters';
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Price / Liter',
                      prefixText: 'Rs ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final n = double.tryParse(v ?? '');
                      if (n == null || n <= 0) return 'Enter valid price';
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total cost',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    'Rs ${_total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_rounded),
              title: const Text('Date'),
              subtitle: Text(
                  '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}'),
              trailing: TextButton(
                onPressed: _pickDate,
                child: const Text('Change'),
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _workerController,
              decoration: const InputDecoration(
                labelText: 'Worker name (optional)',
                prefixIcon: Icon(Icons.person_rounded),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _stationController,
              decoration: const InputDecoration(
                labelText: 'Fuel station (optional)',
                prefixIcon: Icon(Icons.local_gas_station_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                prefixIcon: Icon(Icons.note_alt_rounded),
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
                    : const Text('Save Entry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Text field with tap-to-fill suggestion chips below it, built from
/// past entries. Not a full Autocomplete widget on purpose — chips are
/// easier to tap with dirty/gloved hands than a dropdown search list.
class _AutocompleteField extends StatelessWidget {
  const _AutocompleteField({
    required this.label,
    required this.controller,
    required this.suggestions,
    required this.icon,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final List<String> suggestions;
  final IconData icon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            border: const OutlineInputBorder(),
          ),
          validator: validator,
        ),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((s) {
              return ActionChip(
                label: Text(s),
                onPressed: () => controller.text = s,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
