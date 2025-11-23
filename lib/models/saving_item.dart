class SavingLog {
  final String id;
  final double amount;
  final DateTime date;

  SavingLog({required this.id, required this.amount, required this.date});
}

class SavingItem {
  final String id;
  final String title;
  final double targetAmount;
  double currentAmount;
  List<SavingLog> logs; // <-- Tambahan: Riwayat Nabung

  SavingItem({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0,
    List<SavingLog>? logs,
  }) : logs = logs ?? [];

  double get progress {
    if (targetAmount == 0) return 0;
    return currentAmount / targetAmount;
  }

  bool get isCompleted => currentAmount >= targetAmount;
}
