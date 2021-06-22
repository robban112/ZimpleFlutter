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
    var snapshot =
        await database.reference().child('Users').child(userToken).once();

    return UserParameters(
        company: snapshot.value['company'],
        isAdmin: snapshot.value['isAdmin'],
        token: userToken,
        email: user?.email ?? "",
        name: snapshot.value['name'],
        profilePicturePath: snapshot.value['profilePicturePath']);
  }

  Future<void> setUserProfileImage(UserParameters user, String filePath) async {
    final ref =
        FirebaseDatabase.instance.reference().child('Users').child(user.token);
    return ref.child("profilePicturePath").set(filePath);
  }
}
