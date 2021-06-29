import 'package:flutter/material.dart';
import 'package:zimple/utils/date_utils.dart';

class AbsenceRequest {
  DateTime startDate;
  DateTime endDate;
  String userId;
  String id;
  AbsenceType absenceType;
  String? notes;
  bool? approved;
  List<String>? eventIds;

  AbsenceRequest(
      {required this.startDate,
      required this.endDate,
      required this.userId,
      required this.id,
      required this.absenceType,
      this.notes,
      this.approved,
      this.eventIds});

  static AbsenceRequest? mapFromJSON(
      String id, String userId, dynamic vacationRequestData) {
    DateTime? start = DateTime.parse(vacationRequestData['startDate']);
    DateTime? end = DateTime.parse(vacationRequestData['endDate']);
    bool? approved = vacationRequestData['approved'];
    List<String>? eventIds;
    AbsenceType absenceType =
        stringToAbsenceType(vacationRequestData['absenceType']);
    if (vacationRequestData['eventIds'] != null) {
      eventIds = List.from(vacationRequestData['eventIds'] ?? []);
    }
    if (start == null || end == null) return null;
    return AbsenceRequest(
        id: id,
        startDate: start,
        endDate: end,
        userId: userId,
        notes: vacationRequestData['notes'],
        approved: approved,
        eventIds: eventIds,
        absenceType: absenceType);
  }

  Map<String, dynamic> toJSON() {
    return {
      'startDate': dateStringVerbose(startDate),
      'endDate': dateStringVerbose(endDate),
      'notes': this.notes,
      'approved': this.approved,
      'eventIds': this.eventIds,
      'absenceType': this.absenceType.toString()
    };
  }
}

enum AbsenceType { vacation, sickness, parental_leave, unknown }

AbsenceType stringToAbsenceType(String? string) {
  return AbsenceType.values.firstWhere((t) => t.toString() == string,
      orElse: () => AbsenceType.unknown);
}

String absenceToString(AbsenceType absenceType) {
  switch (absenceType) {
    case AbsenceType.vacation:
      return "Semester";
    case AbsenceType.sickness:
      return "Sjukdom";
    case AbsenceType.parental_leave:
      return "Föräldraledighet";
    case AbsenceType.unknown:
      return "Okänt";
  }
}

Widget getAbsenceTypeWidget(AbsenceType absenceType) {
  switch (absenceType) {
    case AbsenceType.vacation:
      return CircleAvatar(
          radius: 10,
          backgroundColor: Colors.yellow,
          child: Icon(Icons.wb_sunny, size: 13, color: Colors.black));
    case AbsenceType.sickness:
      return CircleAvatar(
          radius: 10,
          backgroundColor: Colors.red,
          child: Icon(Icons.sick, size: 13, color: Colors.white));
    case AbsenceType.parental_leave:
      return CircleAvatar(
          radius: 10,
          backgroundColor: Colors.green,
          child: Icon(Icons.child_friendly, size: 13, color: Colors.white));
    case AbsenceType.unknown:
      return CircleAvatar(radius: 10, backgroundColor: Colors.black);
  }
}
