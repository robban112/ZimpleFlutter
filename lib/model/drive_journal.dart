import 'package:zimple/managers/person_manager.dart';
import 'package:zimple/model/model.dart';
import 'package:zimple/utils/generic_imports.dart';

class DriveJournal implements Model {
  final String id;
  final String regNr;
  final String year;
  final String name;
  final double measurement;
  final List<Person> drivers;
  final String createdBy;
  final DateTime createdAt;

  const DriveJournal({
    this.id = "",
    required this.measurement,
    required this.regNr,
    required this.year,
    required this.name,
    required this.createdBy,
    required this.createdAt,
    required this.drivers,
  });

  @override
  Map<String, dynamic> toJson() => {
        "regNr": regNr,
        "year": year,
        "name": name,
        "createdBy": createdBy,
        "createdAt": dateStringVerbose(createdAt),
        "measurement": measurement,
        "drivers": drivers.map((e) => e.id).toList(),
      };

  static DriveJournal fromJson(Map<Object?, Object?> map, String id, PersonManager personManager) {
    return DriveJournal(
      id: id,
      regNr: map["regNr"] as String,
      year: map["year"] as String,
      name: map["name"] as String,
      createdBy: map["createdBy"] as String,
      createdAt: DateTime.parse(map["createdAt"] as String),
      drivers: personManager.getPersonsByIds(List.from(map["drivers"] as List)),
      measurement: map["measurement"] as double? ?? 0,
    );
  }
}
