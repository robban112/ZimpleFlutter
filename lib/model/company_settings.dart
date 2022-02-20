import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zimple/widgets/widgets.dart';

class CompanySettings {
  final bool isPrivateEvents;

  final String companyName;

  CompanySettings({
    required this.isPrivateEvents,
    required this.companyName,
  });

  static CompanySettings of(BuildContext context) => context.read<ManagerProvider>().companySettings;

  static bool _kDefaultIsPrivateEvents = false;

  factory CompanySettings.initial() => CompanySettings(isPrivateEvents: _kDefaultIsPrivateEvents, companyName: '');

  factory CompanySettings.fromSnapshot({required DataSnapshot snapshot}) {
    if (snapshot.value == null) return CompanySettings.initial();
    try {
      Map map = Map.from(snapshot.value as Map<dynamic, dynamic>);
      return CompanySettings(
        isPrivateEvents: map['isPrivateEvents'] ?? _kDefaultIsPrivateEvents,
        companyName: map['companyName'] ?? '',
      );
    } catch (error) {
      print("Error trying to parse Company Settings");
      return CompanySettings.initial();
    }
  }

  CompanySettings copyWith({String? companyName, bool? isPrivateEvents}) {
    return CompanySettings(
      isPrivateEvents: isPrivateEvents ?? this.isPrivateEvents,
      companyName: companyName ?? this.companyName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isPrivateEvents': this.isPrivateEvents,
      'companyName': this.companyName,
    };
  }
}
