import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/user_parameters.dart';

class FirebaseUserManager {
  String? userToken;
  User? user;
  FirebaseUserManager();

  Future<UserParameters>? getUser() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    } else {
      return _getUserParameters(user.uid);
    }
  }

  Future<UserParameters> _getUserParameters(String userToken) async {
    final database = FirebaseDatabase.instance.reference();
    print('USER TOKEN: $userToken');
    var snapshot = await database.reference().child('Users').child(userToken).once();

    return UserParameters(
        company: snapshot.value['company'],
        isAdmin: snapshot.value['isAdmin'] ?? false,
        token: userToken,
        email: user?.email ?? "",
        name: snapshot.value['name'],
        profilePicturePath: snapshot.value['profilePicturePath'],
        fcmToken: snapshot.value['fcmToken']);
  }

  Future<void> setUserProfileImage(UserParameters user, String filePath) async {
    final ref = FirebaseDatabase.instance.reference().child('Users').child(user.token);
    return ref.child("profilePicturePath").set(filePath);
  }

  Future<void> setUserFCMToken(UserParameters user, String fcmToken) async {
    final ref = FirebaseDatabase.instance.reference().child('Users').child(user.token);
    return ref.child('fcmToken').set(fcmToken);
  }

  Future<void> inviteUser({
    required String companyId,
    required String name,
    required String token,
    required String email,
    required String iOSLink,
    required String androidLink,
  }) {
    final ref = FirebaseDatabase.instance.reference().child('Invited');
    return ref.push().set({
      'companyId': companyId,
      'name': name,
      'email': email,
      'token': token,
      'iOSLink': iOSLink,
      'androidLink': androidLink,
    });
  }
}
