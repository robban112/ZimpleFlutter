import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class FirebaseStorageManager {
  String company;
  firebase_storage.Reference storageRef;
  FirebaseStorageManager({@required this.company}) {
    storageRef = firebase_storage.FirebaseStorage.instance.ref().child(company);
  }

  Future<Image> getImage(String path) {
    return storageRef.child(path).getData(1000000).then((bytes) {
      print("Downloading Image");
      return bytes == null ? null : Image.memory(bytes, fit: BoxFit.cover);
    });
  }
}
