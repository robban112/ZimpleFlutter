import 'package:zimple/model/model.dart';

class Driving implements Model {
  final String id;
  final String startAddress;
  final String endAddress;
  final String startMeasure;
  final String endMeasure;
  final String length;
  final String driverNotesPurpose;
  final DateTime date;
  final bool isPrivateDrive;

  const Driving({
    this.id = "",
    required this.startAddress,
    required this.endAddress,
    required this.startMeasure,
    required this.endMeasure,
    required this.driverNotesPurpose,
    this.isPrivateDrive = false,
    this.length = "",
    required this.date,
  });

  Driving copyWith({
    String? startAddress,
    String? endAddress,
    String? startMeasure,
    String? endMeasure,
    String? driverNotesPurpose,
    String? length,
    bool? isPrivateDrive,
    DateTime? date,
  }) {
    return Driving(
      id: id,
      startAddress: startAddress ?? this.startAddress,
      endAddress: endAddress ?? this.endAddress,
      startMeasure: startMeasure ?? this.startMeasure,
      endMeasure: endMeasure ?? this.endMeasure,
      driverNotesPurpose: driverNotesPurpose ?? this.driverNotesPurpose,
      length: length ?? this.length,
      isPrivateDrive: isPrivateDrive ?? this.isPrivateDrive,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startAddress': startAddress,
      'endAddress': endAddress,
      'startMeasure': startMeasure,
      'endMeasure': endMeasure,
      'driverNotesPurpose': driverNotesPurpose,
      'length': length,
      'isPrivateDrive': isPrivateDrive,
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory Driving.fromJson(Map<Object?, Object?> map, String id) {
    return Driving(
      id: id,
      startAddress: map['startAddress'] as String? ?? "",
      endAddress: map['endAddress'] as String? ?? "",
      startMeasure: map['startMeasure'] as String? ?? "",
      endMeasure: map['endMeasure'] as String? ?? "",
      driverNotesPurpose: map['driverNotesPurpose'] as String? ?? "",
      length: map['length'] as String? ?? "",
      isPrivateDrive: map['isPrivateDrive'] as bool? ?? false,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
    );
  }

  @override
  String toString() {
    return 'Driving(startAddress: $startAddress, endAddress: $endAddress, startMeasure: $startMeasure, endMeasure: $endMeasure, driverNotesPurpose: $driverNotesPurpose, length: $length, isPrivateDrive: $isPrivateDrive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Driving &&
        other.startAddress == startAddress &&
        other.endAddress == endAddress &&
        other.startMeasure == startMeasure &&
        other.endMeasure == endMeasure &&
        other.driverNotesPurpose == driverNotesPurpose &&
        other.length == length &&
        other.isPrivateDrive == isPrivateDrive;
  }

  @override
  int get hashCode {
    return startAddress.hashCode ^
        endAddress.hashCode ^
        startMeasure.hashCode ^
        endMeasure.hashCode ^
        driverNotesPurpose.hashCode ^
        length.hashCode ^
        isPrivateDrive.hashCode;
  }
}
