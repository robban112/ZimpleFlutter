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
      'breakTime': breakTime,
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
    Map<String, Map<String, dynamic>> map = {};
    costs.forEach((cost) {
      var uid = Uuid().v4().toString();
      map[uid] = {'description': cost.a, 'cost': cost.b};
    });
    return map;
  }

  static TimeReport mapFromSnapshot(dynamic timereportData) {
    DateTime startDate = DateTime.parse(timereportData['startDate']);
    DateTime endDate = DateTime.parse(timereportData['endDate']);
    int breakTime = timereportData['breakTime'] ?? 0;
    int totalTime = timereportData['totalTime'];
    List<String> imagesStoragePaths = _getImagesFromEventData(timereportData);
    print("Came here");
    List<Cost> costs = _getCostsFromTimereportData(timereportData);
    String comment = timereportData['comment'];
    String eventId = timereportData['eventId'];
    return TimeReport(
        startDate: startDate,
        endDate: endDate,
        breakTime: breakTime,
        totalTime: totalTime,
        comment: comment,
        imagesList: imagesStoragePaths,
        eventId: eventId,
        costs: costs);
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

  static List<Cost> _getCostsFromTimereportData(dynamic timereportData) {
    dynamic costData = timereportData['costs'];
    if (costData == null) {
      return null;
    }
    Map<String, dynamic> costMap = Map.from(costData);

    return costMap.keys.map((key) {
      var data = costMap[key];
      var description = data['description'];
      var cost = data['cost'];
      if (description is String && cost is int) {
        return Cost<String, int>(description, cost);
      }
    }).toList();
  }
}
