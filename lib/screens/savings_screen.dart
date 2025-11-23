import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../models/saving_item.dart';
import './savings_detail_screen.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  final List<SavingItem> _savings = [];

  final Color _themeColor = Colors.orange;

  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  void _addNewTarget(String title, double target) {
    final newItem = SavingItem(
      id: const Uuid().v4(),
      title: title,
      targetAmount: target,
    );
    setState(() {
      _savings.add(newItem);
    });
  }

  void _addMoneyToTarget(String id, double amount) {
    final index = _savings.indexWhere((item) => item.id == id);
    if (index != -1) {
      setState(() {
        _savings[index].currentAmount += amount;
        _savings[index].logs.add(
          SavingLog(
            id: const Uuid().v4(),
            amount: amount,
            date: DateTime.now(),
          ),
        );
      });
    }
  }

  void _deleteTarget(String id) {
    setState(() {
      _savings.removeWhere((item) => item.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Target dihapus"),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showAddDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Target Baru 🎯",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Nama Barang",
                hintText: "Contoh: PS5",
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
            const SizedBox(height: 15),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: "Harga Target (Rp)",
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
              final target = double.tryParse(cleanAmount) ?? 0;

              if (title.isNotEmpty && target > 0) {
                _addNewTarget(title, target);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _themeColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDepositDialog(SavingItem item) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Nabung: ${item.title} 💰",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: amountController,
          decoration: InputDecoration(
            labelText: "Nominal (Rp)",
            hintText: "0",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _themeColor, width: 2),
            ),
            prefixIcon: Icon(
              Icons.monetization_on_outlined,
              color: _themeColor,
            ),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            CurrencyInputFormatter(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Batal", style: TextStyle(color: _themeColor)),
          ),
          ElevatedButton(
            onPressed: () {
              final cleanAmount = amountController.text.replaceAll('.', '');
              final amount = double.tryParse(cleanAmount) ?? 0;
              if (amount > 0) {
                _addMoneyToTarget(item.id, amount);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _themeColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Nabung", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          "Target Impian",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: _themeColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: _savings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _themeColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.rocket_launch,
                      size: 60,
                      color: _themeColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Belum ada target.",
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Mulai wujudkan mimpimu sekarang!",
                    style: GoogleFonts.poppins(color: Colors.grey[400]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _savings.length,
              itemBuilder: (ctx, index) {
                final item = _savings[index];

                return Dismissible(
                  key: Key(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 30,
                    ),
                  ),
                  onDismissed: (direction) {
                    _deleteTarget(item.id);
                  },
                  child: _buildPremiumCard(item),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: _themeColor,
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          "Target Baru",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumCard(SavingItem item) {
    final percent = item.progress > 1.0 ? 1.0 : item.progress;
    final remaining = item.targetAmount - item.currentAmount;

    String statusText = "Ayo Mulai!";
    Color statusTextColor = Colors.grey;

    if (percent > 0 && percent < 0.5) {
      statusText = "Semangat! 🔥";
      statusTextColor = Colors.orange;
    } else if (percent >= 0.5 && percent < 1.0) {
      statusText = "Dikit Lagi! 🚀";
      statusTextColor = Colors.blue;
    } else if (percent >= 1.0) {
      statusText = "Lunas! 🎉";
      statusTextColor = Colors.green;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SavingsDetailScreen(item: item),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _themeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    item.isCompleted
                        ? Icons.check_circle
                        : Icons.savings_outlined,
                    color: _themeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusTextColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusText,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: statusTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "${(percent * 100).toStringAsFixed(0)}%",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: _themeColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Stack(
              children: [
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      height: 12,
                      width: constraints.maxWidth * percent,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _themeColor.withValues(alpha: 0.6),
                            _themeColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Terkumpul",
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        _currencyFormat.format(item.currentAmount),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: _themeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.calendar_month_outlined,
                          color: _themeColor,
                          size: 20,
                        ),
                        tooltip: "Lihat Kalender",
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(10),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SavingsDetailScreen(item: item),
                            ),
                          );
                        },
                      ),
                    ),

                    if (!item.isCompleted)
                      ElevatedButton.icon(
                        onPressed: () => _showDepositDialog(item),
                        icon: const Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Nabung",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _themeColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            if (!item.isCompleted)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Kurang ${_currencyFormat.format(remaining)} lagi",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.red[300],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
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
