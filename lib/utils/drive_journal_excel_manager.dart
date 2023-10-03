import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zimple/model/drive_journal.dart';
import 'package:zimple/model/driving.dart';
import 'package:zimple/utils/date_utils.dart';

class DriveJournalExcelManager {
  final DriveJournal driveJournal;

  final List<Driving> drivings;

  DriveJournalExcelManager({
    required this.driveJournal,
    required this.drivings,
  });

  static const List<String> headers = [
    "Datum",
    "Start (km)",
    "Slut (km)",
    "Reslängd (km)",
    "StartAdress",
    "SlutAdress",
    "Förare, syfte och anteckningar",
  ];

  Excel createExcel() {
    var excel = Excel.createExcel();
    var headerStyle = CellStyle(fontSize: 12, fontColorHex: "#FF000000", bold: true);
    excel.updateCell("Sheet1", CellIndex.indexByString("A1"), "Körjournal", cellStyle: headerStyle.copyWith(fontSizeVal: 20));
    excel.updateCell("Sheet1", CellIndex.indexByString("A2"), "Registreringsnummer: ${driveJournal.regNr}",
        cellStyle: headerStyle);
    excel.updateCell("Sheet1", CellIndex.indexByString("A3"), "År: ${driveJournal.year}", cellStyle: headerStyle);
    excel.updateCell("Sheet1", CellIndex.indexByString("A4"), "Datum", cellStyle: headerStyle);
    excel.updateCell("Sheet1", CellIndex.indexByString("B4"), "Start (km)", cellStyle: headerStyle);
    excel.updateCell("Sheet1", CellIndex.indexByString("C4"), "Slut (km)", cellStyle: headerStyle);
    excel.updateCell("Sheet1", CellIndex.indexByString("D4"), "Reslängd (km)", cellStyle: headerStyle);
    excel.updateCell("Sheet1", CellIndex.indexByString("E4"), "StartAdress", cellStyle: headerStyle);
    excel.updateCell("Sheet1", CellIndex.indexByString("F4"), "SlutAdress", cellStyle: headerStyle);
    excel.updateCell("Sheet1", CellIndex.indexByString("G4"), "Förare, syfte och anteckningar", cellStyle: headerStyle);
    for (Driving driving in drivings) {
      excel.appendRow('Sheet1', [
        dateStringVerbose(driving.date),
        driving.startMeasure,
        driving.endMeasure,
        driving.length,
        driving.startAddress,
        driving.endAddress,
        driving.driverNotesPurpose,
      ]);
    }
    return excel;
  }

  Future<String> saveExcel() async {
    Excel excel = createExcel();
    String fileName = "${driveJournal.name}-körjournal.xlsx";
    List<int>? fileBytes = excel.save(fileName: fileName);
    if (fileBytes == null) {
      print("UNABLE TO SAVE EXCEL -- BYTES ARE NULL");
      throw Error();
    }
    Directory directory = await getApplicationDocumentsDirectory();

    String path = directory.path;

    String filePath = "$path/$fileName";

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
