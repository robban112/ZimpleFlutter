import 'package:zimple/utils/date_utils.dart';
import 'package:uuid/uuid.dart';

import 'cost.dart';

class TimeReport {
  final String id;

  final DateTime startDate;
  final DateTime endDate;
  final int breakTime;
  final int totalTime;
  final String comment;
  final String eventId;
  final String userId;
  final List<Cost<String, int>> costs;
  final List<String> imagesList;

  Map<String, dynamic> imageStoragePaths;

  TimeReport(
      {this.id,
      this.userId,
      this.startDate,
      this.endDate,
      this.breakTime,
      this.totalTime,
      this.comment,
      this.eventId,
      this.costs,
      this.imagesList,
      this.imageStoragePaths});

  Map<String, dynamic> toJson() {
    return {
      'startDate': dateStringVerbose(this.startDate),
      'endDate': dateStringVerbose(this.endDate),
      'breakTime': breakTime.toString(),
      'totalTime': this.totalTime,
      'eventId': eventId,
      'costs': costsToJson(),
      'comment': this.comment,
      'images': this.imageStoragePaths,
    };
  }

  void setImagesStoragePaths(String key, List<String> filenames) {
    Map<String, Map<String, String>> map = {};
    filenames.forEach((fileName) {
      Map<String, String> inner_map = {
        'storagePath': "/Timereport/$key/$fileName"
      };
      map[fileName] = inner_map;
    });
    this.imageStoragePaths = map;
  }

  Map<String, dynamic> costsToJson() {
    Map<String, Map<String, String>> map = {};
    costs.forEach((cost) {
      var uid = Uuid().v4().toString();
      map[uid] = {'description': cost.a, 'cost': cost.b.toString()};
    });
    return map;
  }

  static TimeReport mapFromSnapshot(dynamic timereportData) {
    DateTime startDate = DateTime.parse(timereportData['startDate']);
    DateTime endDate = DateTime.parse(timereportData['endDate']);
    int breakTime = int.parse(timereportData['breakTime'] ?? 0);
    int totalTime = timereportData['totalTime'];
    List<String> imagesStoragePaths = _getImagesFromEventData(timereportData);
    String comment = timereportData['comment'];
    return TimeReport(
        startDate: startDate,
        endDate: endDate,
        breakTime: breakTime,
        totalTime: totalTime,
        comment: comment,
        imagesList: imagesStoragePaths);
  }

  static List<String> _getImagesFromEventData(dynamic eventData) {
    dynamic imageData = eventData['images'];
    if (imageData == null) {
      return null;
    }
    Map<String, dynamic> imageMap = Map.from(imageData);
    var imageKeys = imageMap?.keys;
    List<String> storagePaths = imageKeys
        ?.map((key) => imageMap[key]['storagePath'].toString())
        ?.toList();
    return storagePaths;
  }
}
