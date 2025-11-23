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

  final Color _themeColor = Colors.purple;

  final List<BillItem> _bills = [];

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

  void _deleteBill(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          "Hapus Tagihan?",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Yakin mau menghapus tagihan ini?",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _bills.removeWhere((item) => item.id == id);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Tagihan dihapus")));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              "Tagihan Baru",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: "Nama Tagihan",
                    hintText: "Misal: Kostan",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _themeColor, width: 2),
                    ),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: "Nominal (Rp)",
                    hintText: "0",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _themeColor, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CurrencyInputFormatter(),
                  ],
                ),
                const SizedBox(height: 20),

                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: _themeColor,
                            ),
                          ),
                          child: child!,
                        );
                      },
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
                        Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: _themeColor,
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
                child: Text("Batal", style: TextStyle(color: _themeColor)),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: _themeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Simpan",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unpaidBills = _bills.where((b) => !b.isPaid).toList();
    unpaidBills.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final paidBills = _bills.where((b) => b.isPaid).toList();
    paidBills.sort((a, b) => b.dueDate.compareTo(a.dueDate));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          "Catat Tagihan",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: _themeColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.poppins(),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Belum Bayar"),
            Tab(text: "Riwayat Lunas"),
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
        backgroundColor: _themeColor,
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

        Color iconBgColor = _themeColor.withValues(alpha: 0.1);
        Color iconTextColor = _themeColor;

        if (isHistory) {
          iconBgColor = Colors.green.withValues(alpha: 0.1);
          iconTextColor = Colors.green;
        } else if (isOverdue) {
          iconBgColor = Colors.red.withValues(alpha: 0.1);
          iconTextColor = Colors.red;
        }

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
                color: Colors.grey.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('MMM').format(bill.dueDate).toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: iconTextColor,
                      ),
                    ),
                    Text(
                      DateFormat('d').format(bill.dueDate),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: iconTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),

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

              if (!isHistory)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _deleteBill(bill.id),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Hapus',
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _markAsPaid(bill.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isOverdue ? Colors.red : _themeColor,
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
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _deleteBill(bill.id),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.grey,
                      ),
                      tooltip: 'Hapus Riwayat',
                    ),
                    const Icon(Icons.check_circle, color: Colors.green),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

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
