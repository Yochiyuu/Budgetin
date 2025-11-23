class BillItem {
  final String id;
  final String title;
  final double amount;
  final DateTime dueDate;
  bool isPaid;

  BillItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    this.isPaid = false,
  });
}
