class Category {
  final int? id;
  final String name;
  final String icon;
  final String color;
  final bool isIncome;

  Category({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.isIncome,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'is_income': isIncome ? 1 : 0,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      icon: map['icon'] ?? '',
      color: map['color'] ?? '',
      isIncome: map['is_income'] == 1,
    );
  }

  Category copyWith({
    int? id,
    String? name,
    String? icon,
    String? color,
    bool? isIncome,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isIncome: isIncome ?? this.isIncome,
    );
  }
}