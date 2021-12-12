import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zimple/managers/customer_manager.dart';
import 'package:zimple/managers/event_manager.dart';
import 'package:zimple/managers/person_manager.dart';
import 'package:zimple/model/models.dart';
import 'package:zimple/model/timereport.dart';
import 'package:path/path.dart';
import 'package:zimple/utils/date_utils.dart';

class ExcelManager {
  final String month;

  final List<TimeReport> timereports;

  final PersonManager personManager;

  final EventManager eventManager;

  final CustomerManager customerManager;

  ExcelManager({
    required this.month,
    required this.timereports,
    required this.personManager,
    required this.eventManager,
    required this.customerManager,
  });

  static const List<String> headers = [
    "Personnr",
    "Namn",
    "Kund",
    "Datum",
    "Arbetad tid",
    "Rast",
    "Övertid",
    "Utfört arbete",
    "Address utfört arbete"
  ];

  Excel createExcel() {
    var excel = Excel.createExcel();
    excel.appendRow(
      'Sheet1',
      headers,
    );
    for (TimeReport timereport in timereports) {
      Person? person = personManager.getPersonById(timereport.userId ?? "");
      Event? event = eventManager.getEventForKey(key: timereport.eventId);
      String customerString = _getCustomerString(timereport, event);

      excel.appendRow('Sheet1', [
        person.ssn,
        person.name,
        customerString,
        dateToYearMonthDay(timereport.startDate),
        getHourDiff(timereport.startDate, timereport.endDate),
        (timereport.breakTime / 60).toStringAsFixed(2),
        "",
        timereport.comment,
        event?.location ?? ""
      ]);
    }
    return excel;
  }

  String _getCustomerString(TimeReport timereport, Event? event) {
    Customer? customer = customerManager.getCustomer(timereport.customerKey ?? "");
    if (customer == null) {
      String? customer = event?.customer;
      return customer ?? "";
    } else {
      return customer.name;
    }
  }

  Future<String> saveExcel() async {
    Excel excel = createExcel();
    String _month = month.replaceAll(" ", "-");
    String fileName = "$_month-tidrapporter.xlsx";
    List<int>? fileBytes = excel.save(fileName: fileName);
    if (fileBytes == null) {
      print("UNABLE TO SAVE EXCEL -- BYTES ARE NULL");
      throw Error();
    }
    Directory directory = await getApplicationDocumentsDirectory();

    String path = directory.path;

    String filePath = "$path/$_month-tidrapporter.xlsx";

    try {
      File(join("$path/$fileName"))
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    } catch (error) {
      print(error.toString());
      throw error;
    }

    return filePath;
  }
}
