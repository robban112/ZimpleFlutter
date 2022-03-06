import 'package:zimple/model/customer.dart';

import 'supplier.dart';

class Invoice {
  final String title;
  final InvoiceInfo info;
  final Supplier supplier;
  final Customer customer;
  final BankInfo? bankInfo;
  final CompanyInfo? companyInfo;
  final List<InvoiceItem> items;

  const Invoice({
    this.title = "Faktura",
    required this.info,
    required this.supplier,
    required this.customer,
    required this.items,
    this.bankInfo,
    this.companyInfo,
  });
}

class BankInfo {
  final String bankgiro;
  final String plusgiro;
  final String iban;
  BankInfo({
    required this.bankgiro,
    required this.plusgiro,
    required this.iban,
  });
}

class CompanyInfo {
  final String orgNr;
  final String vatNr;
  final String website;
  CompanyInfo({
    required this.orgNr,
    required this.vatNr,
    required this.website,
  });
}

class InvoiceInfo {
  final String description;
  final String number;
  final DateTime date;
  final DateTime dueDate;

  const InvoiceInfo({
    required this.description,
    required this.number,
    required this.date,
    required this.dueDate,
  });
}

class InvoiceItem {
  final String description;
  final DateTime date;
  final int quantity;
  final double vat;
  final double unitPrice;

  const InvoiceItem({
    required this.description,
    required this.date,
    required this.quantity,
    required this.vat,
    required this.unitPrice,
  });
}
