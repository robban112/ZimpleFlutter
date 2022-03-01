import 'dart:convert';

enum Unit {
  hours,
  amount,
}

extension UnitExt on Unit {
  String toMap() => this.name;
}

Unit unitFromString(dynamic value) => value == "enhet" ? Unit.amount : Unit.hours;

String unitToString(Unit unit) => unit == Unit.hours ? "timme" : "enhet";

class Product {
  final String id;

  final String name;

  final Unit unit;

  final double pricePerUnit;

  Product({
    required this.id,
    required this.name,
    required this.unit,
    required this.pricePerUnit,
  });

  Product copyWith({
    String? id,
    String? name,
    Unit? unit,
    double? pricePerUnit,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'unit': unit.toMap(),
      'pricePerUnit': pricePerUnit,
    };
  }

  factory Product.fromMap(String key, Map<String, dynamic> map) {
    return Product(
      id: key,
      name: map['name'] ?? '',
      unit: unitFromString(map['unit']),
      pricePerUnit: map['pricePerUnit']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Product(id: $id, name: $name, unit: $unit, pricePerUnit: $pricePerUnit)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Product && other.id == id && other.name == name && other.unit == unit && other.pricePerUnit == pricePerUnit;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ unit.hashCode ^ pricePerUnit.hashCode;
  }
}
