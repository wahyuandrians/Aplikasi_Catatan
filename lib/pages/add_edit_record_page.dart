import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import '../models/milk_record.dart';
import '../services/supabase_service.dart';

class AddEditRecordPage extends StatefulWidget {
  final MilkRecord? record;

  const AddEditRecordPage({super.key, this.record});

  @override
  State<AddEditRecordPage> createState() => _AddEditRecordPageState();
}

class _AddEditRecordPageState extends State<AddEditRecordPage> {
  final _formKey = GlobalKey<FormState>();
  final SupabaseService _supabaseService = SupabaseService();

  late TextEditingController _farmerNameController;
  late TextEditingController _milkQuantityController;
  late DateTime _selectedDate;

  bool get _isEditing => widget.record != null;

  @override
  void initState() {
    super.initState();
    _farmerNameController = TextEditingController(
      text: _isEditing ? widget.record!.farmerName : '',
    );
    _milkQuantityController = TextEditingController(
      text: _isEditing ? widget.record!.milkQuantity.toString() : '',
    );
    _selectedDate = _isEditing ? widget.record!.setorDate : DateTime.now();
  }

  @override
  void dispose() {
    _farmerNameController.dispose();
    _milkQuantityController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final String farmerName = _farmerNameController.text;
      final double milkQuantity = double.parse(_milkQuantityController.text);

      if (_isEditing) {
        final updatedRecord = MilkRecord(
          id: widget.record!.id,
          setorDate: _selectedDate,
          farmerName: farmerName,
          milkQuantity: milkQuantity,
          createdAt: widget.record!.createdAt,
        );
        await _supabaseService.updateMilkRecord(updatedRecord);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catatan berhasil diperbarui!')),
        );
      } else {
        final newRecord = MilkRecord(
          id: '',
          setorDate: _selectedDate,
          farmerName: farmerName,
          milkQuantity: milkQuantity,
        );
        await _supabaseService.addMilkRecord(newRecord);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catatan berhasil ditambahkan!')),
        );
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Catatan Susu' : 'Tambah Catatan Susu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _farmerNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Peternak',
                  hintText: 'Masukkan nama peternak',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama peternak tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _milkQuantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Susu (liter)',
                  hintText: 'Masukkan jumlah susu',
                  prefixIcon: Icon(Icons.water_drop),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah susu tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  picker.DatePicker.showDatePicker(
                    context,
                    showTitleActions: true,
                    minTime: DateTime(2020, 1, 1),
                    maxTime: DateTime.now().add(const Duration(days: 365)),
                    onConfirm: (date) {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                    currentTime: _selectedDate,
                    locale: picker.LocaleType.id,
                  );
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Setor',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat('dd MMMM yyyy').format(_selectedDate),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(_isEditing ? 'Simpan Perubahan' : 'Tambah Catatan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
