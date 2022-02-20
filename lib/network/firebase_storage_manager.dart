import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:zimple/model/user_parameters.dart';

class FirebaseStorageManager {
  Logger logger = Logger();

  String company;

  late firebase_storage.Reference storageRef;

  static const int maxSize = 10000000;

  FirebaseStorageManager({required this.company}) {
    this.storageRef = firebase_storage.FirebaseStorage.instance.ref().child(company);
  }

  Future<Image?> getImage(String path, {double? height, double? width, BoxFit? fit}) async {
    storageRef.child(path).fullPath;
    logger.log(Level.info, "Downloading image $path");
    return storageRef.child(path).getData(maxSize).then((bytes) {
      return bytes == null ? null : Image.memory(bytes, height: height, width: width, fit: fit);
    }).catchError((error) {
      logger.log(Level.warning, "Error downloading image: $error");
    });
  }

  Future<Uint8List?> getData(String path) async {
    try {
      return await storageRef.child(path).getData(maxSize);
    } catch (error) {
      print("Unable to getData from FirebaseStorage: $error");
      return null;
    }
  }

  Future<String> uploadEventImage(String eventId, File file, String uuid) async {
    var url = "Events/$eventId/$uuid";
    firebase_storage.UploadTask uploadTask = storageRef.child(url).putFile(file);
    await uploadTask.then((snapshot) => snapshot).catchError((error) {
      print("Error uploading event image: $error");
    });
    return url;
  }

  Future<String> uploadTimereportImage(String timereportId, File file, String uuid) async {
    var url = "Timereport/$timereportId/$uuid";
    firebase_storage.UploadTask uploadTask = storageRef.child(url).putFile(file);
    await uploadTask.then((snapshot) => snapshot);
    return url;
  }

  Future<String> uploadUserProfileImage(File file, UserParameters user) async {
    var url = "User/${user.token}/${file.hashCode}";
    print("Uploading user profile image: $user, path: $url");
    firebase_storage.UploadTask uploadTask = storageRef.child(url).putFile(file);
    await uploadTask.then((snapshot) => snapshot);
    return url;
  }

  String _getFullPath(String path) {
    return storageRef.child(path).fullPath;
  }
}
