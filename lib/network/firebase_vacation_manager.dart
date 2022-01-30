import 'package:firebase_database/firebase_database.dart' as fb;
import 'package:zimple/model/user_parameters.dart';
import 'package:zimple/model/absence_request.dart';

class FirebaseVacationManager {
  String company;

  late fb.DatabaseReference database;
  late fb.DatabaseReference absenceRef;

  FirebaseVacationManager({required this.company}) {
    database = fb.FirebaseDatabase.instance.ref();
    absenceRef = database.ref.child(company).child('Absence');
  }

  Future<void> addVacationRequest(
      UserParameters user, DateTime startDate, DateTime endDate, String? notes, AbsenceType absenceType) {
    AbsenceRequest vacationRequest =
        AbsenceRequest(id: '', startDate: startDate, userId: '', endDate: endDate, notes: notes, absenceType: absenceType);
    return absenceRef.child(user.token).push().set(vacationRequest.toJSON());
  }

  Future<List<AbsenceRequest>> getVacationRequests(String userId) {
    return absenceRef.child(userId).once().then((snapshot) {
      return _parseAbsenceRequestList(snapshot.snapshot.value, userId);
    });
  }

  List<AbsenceRequest> _parseAbsenceRequestList(dynamic absenceData, String userId) {
    Map<String, dynamic> map = Map.from(absenceData);
    return map.keys
        .map((key) => AbsenceRequest.mapFromJSON(key, userId, map[key]))
        .whereType<AbsenceRequest>()
        .toList()
        .reversed
        .toList();
  }

  Future<void> changeVacationRequest(AbsenceRequest vacationRequest) {
    return absenceRef
        .child(vacationRequest.userId)
        .child(vacationRequest.id)
        .update(vacationRequest.toJSON())
        .then((value) => value);
  }

  Future<Map<String, int>> getUnreadAbsenceRequests() async {
    Map<String, int> unreadMap = {};
    absenceRef.once().then((databaseEvent) {
      var snapshot = databaseEvent.snapshot;
      if (snapshot.value == null) return unreadMap;
      Map<String, dynamic> userMap = Map.from(snapshot.value as Map<dynamic, dynamic>);
      userMap.keys.forEach((userKey) {
        int numUnread = _parseAbsenceRequestList(userMap[userKey], userKey).fold<int>(0, (prev, absenceRequest) {
          if (absenceRequest.approved == null) prev += 1;
          return prev;
        });
        unreadMap[userKey] = numUnread;
      });
    });
    return unreadMap;
  }

  static int getTotalUnreadAbsenceRequests(Map<String, int> unreadMap) {
    return unreadMap.values.fold<int>(0, (prev, next) => prev + next);
  }
}
