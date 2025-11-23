import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import ini PENTING buat Formatter
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isExpense = true;
  String _selectedCategory = 'Makanan';

  final List<String> _categories = [
    'Makanan',
    'Transport',
    'Belanja',
    'Hiburan',
    'Kesehatan',
    'Gaji',
    'Hadiah',
    'Lainnya',
  ];

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  void _submitData() {
    final enteredTitle = _titleController.text;

    // --- BAGIAN PENTING: BERSIHKAN TITIK SEBELUM DISIMPAN ---
    // Kita hapus semua titik ('.') dari string, misal "10.000" jadi "10000"
    // Karena tipe data double gabisa baca titik ribuan
    String cleanAmount = _amountController.text.replaceAll('.', '');
    final enteredAmount = double.tryParse(cleanAmount) ?? 0;

    if (enteredTitle.isEmpty || enteredAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon isi judul dan nominal dengan benar!'),
        ),
      );
      return;
    }

    Provider.of<TransactionProvider>(context, listen: false).addTransaction(
      enteredTitle,
      enteredAmount,
      _selectedDate,
      _selectedCategory,
      _isExpense,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Transaksi'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _submitData),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Switch Tipe
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Pemasukan"),
                  Switch(
                    value: _isExpense,
                    activeColor: Colors.red,
                    inactiveThumbColor: Colors.green,
                    inactiveTrackColor: Colors.green[200],
                    onChanged: (val) {
                      setState(() {
                        _isExpense = val;
                      });
                    },
                  ),
                  const Text(
                    "Pengeluaran",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Input Judul
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Transaksi',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              // 3. Input Nominal DENGAN FORMATTER
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Nominal (Rp)',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ', // Tambahan visual "Rp" di depan
                ),
                keyboardType: TextInputType.number,
                // Masukkan formatter di sini
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Cuma boleh angka
                  CurrencyInputFormatter(), // Formatter buatan kita (ada di bawah)
                ],
              ),

              const SizedBox(height: 20),

              // 4. Tanggal & Kategori
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tanggal: ${DateFormat('dd MMM yyyy').format(_selectedDate)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: _presentDatePicker,
                    child: const Text(
                      'Pilih Tanggal',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  const Text("Kategori: "),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _selectedCategory,
                    items: _categories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isExpense ? Colors.redAccent : Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _submitData,
                child: const Text(
                  'Simpan Transaksi',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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

// --- KELAS FORMATTER MATA UANG ---
// Taruh ini di paling bawah file, di luar class AddTransactionScreen
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Jika kosong, biarkan kosong
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Hapus semua karakter non-angka (jaga-jaga)
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Parse ke integer
    double value = double.parse(newText);

    // Format ulang jadi Rupiah (ID locale pakai titik sebagai pemisah ribuan)
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );
    String newString = formatter.format(value);

    return newValue.copyWith(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}
