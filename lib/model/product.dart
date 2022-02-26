import 'dart:convert';

enum Unit {
  hours,
  amount,
}

extension UnitExt on Unit {
  String toMap() => this.name;
}

Unit unitFromMap(dynamic value) => value == "hours" ? Unit.hours : Unit.amount;

class Product {
  final String name;
  final Unit unit;
  final double pricePerUnit;
  Product({
    required this.name,
    required this.unit,
    required this.pricePerUnit,
  });

  Product copyWith({
    String? name,
    Unit? unit,
    double? pricePerUnit,
  }) {
    return Product(
      name: name ?? this.name,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'unit': unit.toMap(),
      'pricePerUnit': pricePerUnit,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      name: map['name'] ?? '',
      unit: unitFromMap(map['unit']),
      pricePerUnit: map['pricePerUnit']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) => Product.fromMap(json.decode(source));

  @override
  String toString() => 'Product(name: $name, unit: $unit, pricePerUnit: $pricePerUnit)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Product && other.name == name && other.unit == unit && other.pricePerUnit == pricePerUnit;
  }

  @override
  int get hashCode => name.hashCode ^ unit.hashCode ^ pricePerUnit.hashCode;
}
