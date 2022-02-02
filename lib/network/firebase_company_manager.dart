import 'package:firebase_database/firebase_database.dart' as fb;
import 'package:zimple/model/company_settings.dart';

class FirebaseCompanyManager {
  final String company;

  late fb.DatabaseReference companyRef;

  FirebaseCompanyManager({
    required this.company,
  }) {
    fb.DatabaseReference database = fb.FirebaseDatabase.instance.ref();
    this.companyRef = database.ref.child(company).child("CompanySettings");
  }

  Future<void> updateCompanySettings({required CompanySettings companySettings}) {
    return this.companyRef.set(companySettings.toJson());
  }

  Stream<CompanySettings> streamCompanySettings() {
    return this.companyRef.onValue.map((event) {
      CompanySettings companySettings = CompanySettings.fromSnapshot(snapshot: event.snapshot);
      print("----- New Company Settings -----");
      print("Company: ${companySettings.companyName}");
      print("IsPrivateEvents: ${companySettings.isPrivateEvents}");
      print("--------------------------------");
      return companySettings;
    });
  }
}
