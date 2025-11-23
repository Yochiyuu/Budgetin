import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
import '../providers/transaction_provider.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          "Analisis Keuangan",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final transactions = provider.transactions;

          // 1. Ambil data pengeluaran 7 hari terakhir
          final weeklyData = _getWeeklySpending(transactions);
          final totalWeeklyExpense = weeklyData.values.fold(
            0.0,
            (prev, element) => prev + element,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- KARTU RINGKASAN ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF009688), Color(0xFF4DB6AC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        // FIX: Ganti withOpacity jadi withValues
                        color: Colors.teal.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pengeluaran 7 Hari Terakhir",
                        style: GoogleFonts.poppins(color: Colors.white70),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        currencyFormat.format(totalWeeklyExpense),
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --- JUDUL GRAFIK ---
                Text(
                  "Grafik Mingguan",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // --- CHART AREA ---
                Container(
                  height: 300,
                  padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      // FIX: Ganti withOpacity jadi withValues
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getMaxY(weeklyData.values.toList()),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          // FIX: HAPUS tooltipRoundedRadius (sudah tidak didukung)
                          // Tambahkan warna background tooltip biar jelas
                          getTooltipColor: (_) => Colors.blueGrey,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              _compactCurrency(rod.toY),
                              GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = [
                                'Sen',
                                'Sel',
                                'Rab',
                                'Kam',
                                'Jum',
                                'Sab',
                                'Min',
                              ];
                              if (value.toInt() >= 0 &&
                                  value.toInt() < days.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    days[value.toInt()],
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: _generateBarGroups(weeklyData),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // --- PENGELUARAN TERBESAR ---
                Text(
                  "Pengeluaran Terbesar",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _buildTopExpenses(transactions, currencyFormat),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- LOGIC HELPERS ---

  Map<int, double> _getWeeklySpending(List<Transaction> transactions) {
    Map<int, double> weekly = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};

    final now = DateTime.now();
    // Cari tanggal hari Senin minggu ini
    // Logika disederhanakan agar tidak error range
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    for (var tx in transactions) {
      // Pastikan hanya pengeluaran dan masuk range minggu ini
      if (tx.isExpense) {
        // Cek tanggal manual (remove time part untuk akurasi)
        final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
        final start = DateTime(
          startOfWeek.year,
          startOfWeek.month,
          startOfWeek.day,
        );
        final end = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day);

        if (txDate.isAtSameMomentAs(start) ||
            (txDate.isAfter(start) && txDate.isBefore(end))) {
          int index = tx.date.weekday - 1;
          weekly[index] = (weekly[index] ?? 0) + tx.amount;
        }
      }
    }
    return weekly;
  }

  List<BarChartGroupData> _generateBarGroups(Map<int, double> data) {
    return List.generate(7, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data[index] ?? 0,
            color: (data[index] ?? 0) > 0 ? Colors.teal : Colors.grey[200],
            width: 16,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxY(data.values.toList()),
              color: Colors.grey[100],
            ),
          ),
        ],
      );
    });
  }

  double _getMaxY(List<double> values) {
    if (values.isEmpty) return 100;
    double max = values.reduce((curr, next) => curr > next ? curr : next);
    return max == 0 ? 100 : max * 1.2;
  }

  String _compactCurrency(double value) {
    if (value >= 1000000) return "${(value / 1000000).toStringAsFixed(1)}jt";
    if (value >= 1000) return "${(value / 1000).toStringAsFixed(0)}rb";
    return value.toStringAsFixed(0);
  }

  Widget _buildTopExpenses(
    List<Transaction> transactions,
    NumberFormat format,
  ) {
    final expenses = transactions.where((tx) => tx.isExpense).toList();
    expenses.sort((a, b) => b.amount.compareTo(a.amount));
    final topExpenses = expenses.take(3).toList();

    if (topExpenses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          "Belum ada pengeluaran minggu ini.",
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: topExpenses.map((tx) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.title,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        DateFormat('d MMM').format(tx.date),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                format.format(tx.amount),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
