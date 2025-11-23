import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../models/bill_item.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Data Dummy Awal (Bisa dihapus nanti)
  final List<BillItem> _bills = [
    BillItem(
      id: '1',
      title: 'Listrik Token',
      amount: 200000,
      dueDate: DateTime.now().add(const Duration(days: 2)),
    ),
    BillItem(
      id: '2',
      title: 'WiFi IndiHome',
      amount: 350000,
      dueDate: DateTime.now().subtract(
        const Duration(days: 1),
      ), // Ceritanya telat bayar
    ),
  ];

  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- LOGIC TAMBAH TAGIHAN ---
  void _addNewBill(String title, double amount, DateTime date) {
    setState(() {
      _bills.add(
        BillItem(
          id: const Uuid().v4(),
          title: title,
          amount: amount,
          dueDate: date,
        ),
      );
    });
  }

  // --- LOGIC BAYAR TAGIHAN ---
  void _markAsPaid(String id) {
    setState(() {
      final index = _bills.indexWhere((item) => item.id == id);
      if (index != -1) {
        _bills[index].isPaid = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Tagihan lunas! Mantap!", style: GoogleFonts.poppins()),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // --- DIALOG INPUT ---
  void _showAddDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        // Pakai StatefulBuilder biar DatePicker update text
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              "Tagihan Baru",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Nama Tagihan",
                    hintText: "Misal: Kostan",
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: "Nominal (Rp)",
                    hintText: "0",
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CurrencyInputFormatter(),
                  ],
                ),
                const SizedBox(height: 20),

                // Pilihan Tanggal
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedDate == null
                              ? "Pilih Tanggal Jatuh Tempo"
                              : DateFormat(
                                  'EEEE, d MMM yyyy',
                                  'id_ID',
                                ).format(selectedDate!),
                          style: GoogleFonts.poppins(
                            color: selectedDate == null
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: Colors.teal,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () {
                  final title = titleController.text;
                  final cleanAmount = amountController.text.replaceAll('.', '');
                  final amount = double.tryParse(cleanAmount) ?? 0;

                  if (title.isNotEmpty && amount > 0 && selectedDate != null) {
                    _addNewBill(title, amount, selectedDate!);
                    Navigator.pop(ctx);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Lengkapi semua data dulu ya!"),
                      ),
                    );
                  }
                },
                child: const Text("Simpan"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pisahkan List Lunas & Belum
    final unpaidBills = _bills.where((b) => !b.isPaid).toList();
    // Sort biar yang jatuh temponya dekat ada diatas
    unpaidBills.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final paidBills = _bills.where((b) => b.isPaid).toList();
    // Sort history biar yang baru dibayar ada diatas
    paidBills.sort((a, b) => b.dueDate.compareTo(a.dueDate));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          "Catat Tagihan",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.purple, // Warna beda (Ungu) sesuai icon home
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.poppins(),
          labelColor: Colors.white, // Text active
          unselectedLabelColor: Colors.white70, // Text inactive
          tabs: [
            const Tab(text: "Belum Bayar"),
            const Tab(text: "Riwayat Lunas"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBillList(unpaidBills, isHistory: false),
          _buildBillList(paidBills, isHistory: true),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: Colors.purple,
        icon: const Icon(Icons.add_task, color: Colors.white),
        label: Text(
          "Tambah Tagihan",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBillList(List<BillItem> bills, {required bool isHistory}) {
    if (bills.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isHistory ? Icons.check_circle_outline : Icons.receipt_long,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 10),
            Text(
              isHistory ? "Belum ada tagihan lunas" : "Hore! Tidak ada tagihan",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: bills.length,
      itemBuilder: (ctx, index) {
        final bill = bills[index];
        final isOverdue = !bill.isPaid && bill.dueDate.isBefore(DateTime.now());

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: isOverdue
                ? Border.all(color: Colors.red.shade200, width: 1)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // 1. Icon Tanggal (Kiri)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isHistory
                      ? Colors.green.withOpacity(0.1)
                      : (isOverdue
                            ? Colors.red.withOpacity(0.1)
                            : Colors.purple.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('MMM').format(bill.dueDate).toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isHistory
                            ? Colors.green
                            : (isOverdue ? Colors.red : Colors.purple),
                      ),
                    ),
                    Text(
                      DateFormat('d').format(bill.dueDate),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isHistory
                            ? Colors.green
                            : (isOverdue ? Colors.red : Colors.purple),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),

              // 2. Info Tagihan (Tengah)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: isHistory
                            ? TextDecoration.lineThrough
                            : null,
                        color: isHistory ? Colors.grey : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currencyFormat.format(bill.amount),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isHistory ? Colors.grey : Colors.black54,
                      ),
                    ),
                    if (isOverdue && !isHistory)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "Lewat Jatuh Tempo!",
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // 3. Tombol Aksi (Kanan)
              if (!isHistory)
                ElevatedButton(
                  onPressed: () => _markAsPaid(bill.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOverdue ? Colors.red : Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Bayar",
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                )
              else
                const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
        );
      },
    );
  }
}

// Formatter Rupiah (Sama kayak sebelumnya, copy aja biar ga error)
class CurrencyInputFormatter extends TextInputFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue.copyWith(text: '');
    if (newValue.selection.baseOffset == 0) return newValue;
    String newText = newValue.text.replaceAll('.', '');
    int value = int.tryParse(newText) ?? 0;
    final newString = _formatter.format(value);
    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}
