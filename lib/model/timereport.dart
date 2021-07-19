import 'package:zimple/utils/date_utils.dart';
import 'package:uuid/uuid.dart';

import 'cost.dart';

class TimeReport {
  String id;
  String? userId;

  final DateTime startDate;
  final DateTime endDate;
  final int breakTime;
  final int totalTime;
  final String? comment;
  final String? eventId;

  final List<Cost>? costs;
  bool isCompleted;
  List<String>? imagesList;
  String? customerKey;

  Map<String, dynamic>? imageStoragePaths;

  TimeReport(
      {required this.id,
      this.userId,
      required this.startDate,
      required this.endDate,
      required this.breakTime,
      required this.totalTime,
      required this.comment,
      this.eventId,
      required this.costs,
      this.imagesList,
      this.imageStoragePaths,
      this.isCompleted = false,
      this.customerKey});

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
      'isCompleted': this.isCompleted,
      'customerKey': this.customerKey
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
    costs?.forEach((cost) {
      var uid = Uuid().v4().toString();
      map[uid] = {
        'description': cost.description,
        'cost': cost.cost,
        'amount': cost.amount
      };
    });
    return map;
  }

  static TimeReport mapFromSnapshot(String key, dynamic timereportData) {
    DateTime startDate = DateTime.parse(timereportData['startDate']);
    DateTime endDate = DateTime.parse(timereportData['endDate']);
    int breakTime = timereportData['breakTime'] ?? 0;
    int totalTime = timereportData['totalTime'] ?? 0;
    List<String> imagesStoragePaths =
        _getImagesFromEventData(timereportData) ?? [];
    print("Came here");
    List<Cost> costs = _getCostsFromTimereportData(timereportData) ?? [];
    String? comment = timereportData['comment'];
    String? eventId = timereportData['eventId'];
    String? customerKey = timereportData['customerKey'];
    bool isCompleted = timereportData['isCompleted'] ?? false;
    return TimeReport(
        id: key,
        startDate: startDate,
        endDate: endDate,
        breakTime: breakTime,
        totalTime: totalTime,
        comment: comment,
        imagesList: imagesStoragePaths,
        eventId: eventId,
        costs: costs,
        isCompleted: isCompleted,
        customerKey: customerKey);
  }

  static List<String>? _getImagesFromEventData(dynamic eventData) {
    dynamic? imageData = eventData['images'];
    if (imageData == null) {
      return null;
    }
    Map<String, dynamic> imageMap = Map.from(imageData);
    var imageKeys = imageMap.keys;
    List<String> storagePaths = imageKeys
        .map((key) => imageMap[key]['storagePath'].toString())
        .toList();
    return storagePaths;
  }

  static List<Cost>? _getCostsFromTimereportData(dynamic timereportData) {
    dynamic costData = timereportData['costs'];
    if (costData == null) {
      return null;
    }
    Map<String, dynamic> costMap = Map.from(costData);
    List<Cost> costs = [];
    costMap.keys.forEach((key) {
      var data = costMap[key];
      var description = data['description'];
      var cost = data['cost'];
      var amount = data['amount'] ?? 1;
      if (description is String && cost is int) {
        costs.add(Cost(description: description, cost: cost, amount: amount));
      }
    });
    return costs;
  }
}
