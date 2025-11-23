import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart'; // <--- INI WAJIB ADA

import '../models/saving_item.dart';

class SavingsDetailScreen extends StatefulWidget {
  final SavingItem item;
  const SavingsDetailScreen({super.key, required this.item});

  @override
  State<SavingsDetailScreen> createState() => _SavingsDetailScreenState();
}

class _SavingsDetailScreenState extends State<SavingsDetailScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Cek tanggal mana yang ada transaksinya buat dikasih titik oranye
  List<SavingLog> _getEventsForDay(DateTime day) {
    return widget.item.logs.where((log) {
      return isSameDay(log.date, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text("Kalender Menabung", style: GoogleFonts.poppins()),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- BAGIAN KALENDER ---
            Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2023, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                // Ini logika untuk menampilkan titik di tanggal
                eventLoader: _getEventsForDay,

                // Styling Kalender biar kelihatan
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.tealAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ), // Titik oranye
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // --- LIST RIWAYAT DI BAWAHNYA ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Riwayat: ${item.title}",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // List item
            item.logs.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("Belum ada data nabung."),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: item.logs.length,
                    itemBuilder: (ctx, index) {
                      final log = item.logs[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('dd MMM yyyy').format(log.date)),
                            Text(
                              "Rp ${NumberFormat('#,###', 'id_ID').format(log.amount)}",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
