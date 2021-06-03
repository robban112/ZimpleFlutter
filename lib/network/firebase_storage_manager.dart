import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:zimple/model/user_parameters.dart';

class FirebaseStorageManager {
  String company;
  firebase_storage.Reference storageRef;
  FirebaseStorageManager({@required this.company}) {
    storageRef = firebase_storage.FirebaseStorage.instance.ref().child(company);
  }

  Future<Image> getImage(String path) {
    storageRef.child(path).fullPath;
    print("Downloading Image");
    return storageRef.child(path).getData(10000000000).then((bytes) {
      return bytes == null ? null : Image.memory(bytes, fit: BoxFit.fill);
    });
  }

  Future<String> uploadEventImage(
      String eventId, File file, String uuid) async {
    var url = "Events/$eventId/$uuid";
    firebase_storage.UploadTask uploadTask =
        storageRef.child(url).putFile(file);
    await uploadTask.then((snapshot) => snapshot);
    return url;
  }

  Future<String> uploadTimereportImage(
      String timereportId, File file, String uuid) async {
    var url = "Timereport/$timereportId/$uuid";
    firebase_storage.UploadTask uploadTask =
        storageRef.child(url).putFile(file);
    await uploadTask.then((snapshot) => snapshot);
    return url;
  }

  Future<String> uploadUserProfileImage(File file, UserParameters user) async {
    var url = "User/${user.token}/${file.hashCode}";
    firebase_storage.UploadTask uploadTask =
        storageRef.child(url).putFile(file);
    await uploadTask.then((snapshot) => snapshot);
    return url;
  }

  String _getFullPath(String path) {
    return storageRef.child(path).fullPath;
  }
}
