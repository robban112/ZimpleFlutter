import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zimple/widgets/widgets.dart';

class CompanySettings {
  final bool isPrivateEvents;

  final String companyName;

  final String? orgNr;

  final String? vatNr;

  final String? website;

  final String? bankgiro;

  final String? plusgiro;

  final String? iban;

  final bool? approvedForFTax;

  CompanySettings({
    required this.isPrivateEvents,
    required this.companyName,
    this.orgNr,
    this.vatNr,
    this.website,
    this.bankgiro,
    this.plusgiro,
    this.iban,
    this.approvedForFTax,
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
        orgNr: map['orgNr'],
        vatNr: map['vatNr'],
        website: map['website'],
        bankgiro: map['bankgiro'],
        plusgiro: map['plusgiro'],
        iban: map['iban'],
        approvedForFTax: map['approvedForFTax'],
      );
    } catch (error) {
      print("Error trying to parse Company Settings");
      return CompanySettings.initial();
    }
  }

  CompanySettings copyWith({
    String? companyName,
    bool? isPrivateEvents,
    String? orgNr,
    String? vatNr,
    String? website,
    String? bankgiro,
    String? plusgiro,
    String? iban,
    bool? approvedForFTax,
  }) {
    return CompanySettings(
      isPrivateEvents: isPrivateEvents ?? this.isPrivateEvents,
      companyName: companyName ?? this.companyName,
      orgNr: orgNr ?? this.orgNr,
      vatNr: vatNr ?? this.vatNr,
      website: website ?? this.website,
      bankgiro: bankgiro ?? this.bankgiro,
      plusgiro: plusgiro ?? this.plusgiro,
      iban: iban ?? this.iban,
      approvedForFTax: approvedForFTax ?? this.approvedForFTax,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isPrivateEvents': this.isPrivateEvents,
      'companyName': this.companyName,
      'orgNr': this.orgNr,
      'vatNr': this.vatNr,
      'website': this.website,
      'bankgiro': this.bankgiro,
      'plusgiro': this.plusgiro,
      'iban': this.iban,
      'approvedForFTax': this.approvedForFTax,
    };
  }
}
