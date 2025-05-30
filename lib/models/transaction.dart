class Transaction {
  final int? id;
  final String name;
  final double amount;
  final DateTime date;
  final String category;
  final String paymentMethod;
  final bool isIncome;
  final String? description;

  Transaction({
    this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.category,
    required this.paymentMethod,
    required this.isIncome,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'category': category,
      'payment_method': paymentMethod,
      'is_income': isIncome ? 1 : 0,
      'description': description,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      category: map['category'] ?? '',
      paymentMethod: map['payment_method'] ?? '',
      isIncome: map['is_income'] == 1,
      description: map['description'],
    );
  }

  Transaction copyWith({
    int? id,
    String? name,
    double? amount,
    DateTime? date,
    String? category,
    String? paymentMethod,
    bool? isIncome,
    String? description,
  }) {
    return Transaction(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isIncome: isIncome ?? this.isIncome,
      description: description ?? this.description,
    );
  }
}