import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as dartUI;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zimple/network/firebase_storage_manager.dart';
import 'package:zimple/utils/zpreferences.dart';

typedef ImageDescriptor = dartUI.ImageDescriptor;
typedef ImmutableBuffer = dartUI.ImmutableBuffer;
typedef UIImage = dartUI.Image;

class ProfilePictureService {
  final List<String> profilePicturePaths;

  final FirebaseStorageManager firebaseStorageManager;

  late final List<String> cachedImages;

  late final String path;

  Map<String, Image> profilePictures = {};

  ProfilePictureService({
    required this.profilePicturePaths,
    required this.firebaseStorageManager,
  });

  init() async {
    Directory directory = await getApplicationDocumentsDirectory();
    path = directory.path;
    print("-- INIT PROFILE PICS --");
    await initCachedImages();
    await initProfilePictures();
    print("-- END INIT PROFILE PICS --");
  }

  Future<void> initProfilePictures() async {
    for (String path in profilePicturePaths) {
      Image? image = isCached(path) ? await getCachedImage(path) : await fetchImage(path);
      if (image != null) {
        print("Loaded image: $path");
        profilePictures[path] = image;
      }
    }
  }

  Future<void> initCachedImages() async {
    try {
      List<String>? _cached = await ZPreferences.getCachedImages();
      print("Cached Images: $_cached");
      if (_cached == null)
        this.cachedImages = [];
      else
        this.cachedImages = _cached;
    } catch (error) {
      print("ERROR: Unable to init cached images: $error");
      this.cachedImages = [];
    }
  }

  bool isCached(String profilePicturePath) => this.cachedImages.contains(profilePicturePath);

  Future<Image?> getCachedImage(String profilePicturePath) async {
    print("CACHED: Getting image: $path");
    try {
      Image image = Image.file(File("$path/${replacedPath(profilePicturePath)}"), height: 100, width: 100, fit: BoxFit.fitWidth);
      return image;
    } catch (error) {
      print("Unable to get cached image for $profilePicturePath: $error");
      return null;
    }
  }

  Future<void> cacheImage(Uint8List bytes, String profilePicturePath) async {
    print("Caching image at path: $path/$profilePicturePath");
    // Binary -> File

    File file = File('$path/${replacedPath(profilePicturePath)}');
    File _file = await file.create();
    _file.writeAsBytes(bytes);

    // Add to Preferences cache list of paths
    cachedImages.add(profilePicturePath);
    ZPreferences.saveCachedImages(cachedImages);
  }

  String replacedPath(String path) => path.replaceAll("/", "");

  Future<Image?> fetchImage(String profilePicturePath) async {
    print("NOT CACHED: Getting image: $profilePicturePath");
    try {
      Uint8List? bytes = await firebaseStorageManager.getData(profilePicturePath);

      if (bytes != null) {
        await cacheImage(bytes, profilePicturePath);
        return Image.memory(bytes, height: 100, width: 100, fit: BoxFit.fitWidth);
      }
      return null;
    } catch (error) {
      print("Unable to fetch image: $profilePicturePaths: $error");
      return null;
    }
  }

  Image? getProfilePicture(String? profilePicturePath) {
    if (profilePicturePath == null) return null;
    if (profilePictures.containsKey(profilePicturePath)) {
      return profilePictures[profilePicturePath];
    }
    return null;
  }
}
