import 'package:firebase_database/firebase_database.dart' as fb;
import 'package:zimple/utils/date_utils.dart';

class FirebaseSignupManager {
  late fb.DatabaseReference ref;

  FirebaseSignupManager() {
    fb.DatabaseReference database = fb.FirebaseDatabase.instance.ref();
    this.ref = database.ref;
  }

  Future<void> trackNewUser(
      {required String calendarId, required String userId, required String userEmail, required String userPhone}) {
    return this.ref.child("NewUsers").push().set({
      'id': userId,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'createdDate': dateStringVerbose(DateTime.now()),
      'companyId': calendarId,
    });
  }

  Future<String> createCompany({
    required String calendarName,
    required String userId,
    required String userEmail,
    required String userPhone,
  }) async {
    fb.DatabaseReference newref = this.ref.push();
    if (newref.key == null) throw Error();
    await newref.set({
      'name': calendarName,
      'createdDate': dateStringVerbose(DateTime.now()),
      'Persons': {
        userId: {
          'email': userEmail,
          'name': userEmail,
          'isAdmin': true,
          'isSuperAdmin': true,
          'color': '66CC99',
          'id': userId,
          'phonenumber': userPhone,
        }
      },
      'calendarMemberType': 'free',
      'version': 2,
    });
    return newref.key!;
  }

  Future<void> addUserToUserDatabase({required String userId, required String email, required String companyId}) async {
    return this.ref.child("Users").child(userId).set({
      'company': companyId,
      'email': email,
      'name': email,
      'registered': dateStringVerbose(DateTime.now()),
      'isAdmin': true,
    });
  }
}
