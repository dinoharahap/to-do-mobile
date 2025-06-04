import 'package:flutter/material.dart';

class TodoForm extends StatefulWidget {
  final DateTime? initialDate;
  final String? initialNama;
  final String? initialDeskripsi;
  final void Function(DateTime tanggal, String nama, String deskripsi) onSubmit;

  const TodoForm({
    super.key,
    this.initialDate,
    this.initialNama,
    this.initialDeskripsi,
    required this.onSubmit,
  });

  @override
  State<TodoForm> createState() => _TodoFormState();
}

class _TodoFormState extends State<TodoForm> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late TextEditingController _namaController;
  late TextEditingController _deskripsiController;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _namaController = TextEditingController(text: widget.initialNama ?? '');
    _deskripsiController = TextEditingController(text: widget.initialDeskripsi ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF24243e),
      title: Text(widget.initialNama == null ? 'Tambah Kegiatan' : 'Edit Kegiatan',
          style: const TextStyle(color: Colors.cyanAccent)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(color: Colors.cyanAccent),
                ),
                trailing: const Icon(Icons.calendar_today, color: Colors.pinkAccent),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaController,
                style: const TextStyle(color: Colors.cyanAccent),
                decoration: InputDecoration(
                  labelText: "Nama Kegiatan",
                  labelStyle: const TextStyle(color: Colors.cyanAccent),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.cyanAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.pinkAccent, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Masukkan nama kegiatan" : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _deskripsiController,
                style: const TextStyle(color: Colors.pinkAccent),
                decoration: InputDecoration(
                  labelText: "Deskripsi",
                  labelStyle: const TextStyle(color: Colors.pinkAccent),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.pinkAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.cyanAccent, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Masukkan deskripsi" : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Batal', style: TextStyle(color: Colors.cyanAccent)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pinkAccent,
            foregroundColor: Colors.white,
          ),
          child: Text(widget.initialNama == null ? 'Tambah' : 'Simpan'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSubmit(_selectedDate, _namaController.text.trim(), _deskripsiController.text.trim());
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}