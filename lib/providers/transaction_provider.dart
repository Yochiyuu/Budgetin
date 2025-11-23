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

  Future<void> fetchAndSetData() async {
    final dataList = await DBHelper.getData('user_transactions');

    _transactions = dataList
        .map(
          (item) => Transaction(
            id: item['id'],
            title: item['title'],
            amount: item['amount'],
            date: DateTime.parse(item['date']),
            category: item['category'],
            isExpense: item['isExpense'] == 1,
          ),
        )
        .toList();

    notifyListeners();
  }

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

    _transactions.add(newTx);
    notifyListeners();

    DBHelper.insert('user_transactions', {
      'id': newTx.id,
      'title': newTx.title,
      'amount': newTx.amount,
      'date': newTx.date.toIso8601String(),
      'category': newTx.category,
      'isExpense': newTx.isExpense ? 1 : 0,
    });
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((tx) => tx.id == id);
    notifyListeners();

    DBHelper.delete('user_transactions', id);
  }
}
