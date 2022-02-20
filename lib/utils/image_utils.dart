

// class ImageUtils {
//   static Future<File> imageToFile({required Image image}) async {
    
//     var bytes = await image.readAsBytes();
//     String tempPath = (await getTemporaryDirectory()).path;
//     File file = File('$tempPath/profile.$ext');
//     await file.writeAsBytes(bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
//     return file;
//   }
// }
