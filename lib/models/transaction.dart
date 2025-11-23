class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category; // Contoh: Makanan, Transport, Gaji
  final bool isExpense; // true = Pengeluaran, false = Pemasukan

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.isExpense,
  });

  // Konversi ke Map untuk disimpan di Database (SQLite butuh Map)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'isExpense': isExpense ? 1 : 0, // SQLite tidak punya boolean
    };
  }

  // Konversi dari Map (Database) ke Object Dart
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      category: map['category'],
      isExpense: map['isExpense'] == 1,
    );
  }
}
