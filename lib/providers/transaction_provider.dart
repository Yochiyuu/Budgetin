import 'package:flutter/foundation.dart';

import '../models/transaction.dart';
import '../services/db_helper.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];

  List<Transaction> get transactions {
    return [..._transactions]..sort((a, b) => b.date.compareTo(a.date));
  }

  double get totalIncome {
    return _transactions
        .where((tx) => !tx.isExpense)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalExpense {
    return _transactions
        .where((tx) => tx.isExpense)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalBalance {
    return totalIncome - totalExpense;
  }

  // --- FUNGSI BARU: LOAD DATA DARI DB ---
  Future<void> fetchAndSetData() async {
    final dataList = await DBHelper.getData('user_transactions');

    // Konversi List<Map> dari DB menjadi List<Transaction> model kita
    _transactions = dataList
        .map(
          (item) => Transaction(
            id: item['id'],
            title: item['title'],
            amount: item['amount'],
            date: DateTime.parse(item['date']), // String ISO ke DateTime
            category: item['category'],
            isExpense: item['isExpense'] == 1, // Integer 1 jadi True
          ),
        )
        .toList();

    notifyListeners();
  }

  // --- UPDATE: ADD KE DB & MEMORY ---
  Future<void> addTransaction(
    String title,
    double amount,
    DateTime date,
    String category,
    bool isExpense,
  ) async {
    final newTx = Transaction(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      date: date,
      category: category,
      isExpense: isExpense,
    );

    // 1. Simpan ke Memory (biar UI langsung update cepet)
    _transactions.add(newTx);
    notifyListeners();

    // 2. Simpan ke SQLite (Background process)
    DBHelper.insert('user_transactions', {
      'id': newTx.id,
      'title': newTx.title,
      'amount': newTx.amount,
      'date': newTx.date.toIso8601String(), // Simpan tanggal sebagai String ISO
      'category': newTx.category,
      'isExpense': newTx.isExpense ? 1 : 0, // Simpan bool sebagai integer
    });
  }

  // --- UPDATE: HAPUS DARI DB & MEMORY ---
  Future<void> deleteTransaction(String id) async {
    // Hapus dari Memory
    _transactions.removeWhere((tx) => tx.id == id);
    notifyListeners();

    // Hapus dari SQLite
    DBHelper.delete('user_transactions', id);
  }
}
