import 'dart:io';

//import 'package:generate_pdf_invoice_example/utils.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import 'package:zimple/model/customer.dart';
import 'package:zimple/screens/TimeReporting/Invoice/model/invoice.dart';
import 'package:zimple/screens/TimeReporting/Invoice/model/supplier.dart';
import 'package:zimple/utils/generic_imports.dart';

import 'pdf_api.dart';

class PdfInvoiceApi {
  static formatPrice(double price) => ' ${price.toStringAsFixed(2)} kr';

  static formatDate(DateTime date) => format.format(date);

  static get format => DateFormat('yyyy-MM-dd');

  static Future<File> generate(Invoice invoice) async {
    print("Generating pdf");
    final pdf = Document();

    pdf.addPage(getInvoice(invoice));

    File pdfFile = await PdfApi.saveDocument(name: 'my_invoice.pdf', pdf: pdf);

    print("path: ${pdfFile.path}");
    return pdfFile;
  }

  static MultiPage getInvoice(Invoice invoice) {
    return MultiPage(
      build: (context) => [
        buildHeader(invoice),
        SizedBox(height: 3 * PdfPageFormat.cm),
        buildTitle(invoice),
        buildInvoice(invoice),
        Divider(),
        buildTotal(invoice),
      ],
      footer: (context) => buildFooter(invoice),
    );
  }

  static List<Widget> invoiceChildren(Invoice invoice) => [
        buildHeader(invoice),
        SizedBox(height: 3 * PdfPageFormat.cm),
        buildTitle(invoice),
        buildInvoice(invoice),
        Divider(),
        buildTotal(invoice),
      ];

  static Widget buildHeader(Invoice invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 1 * PdfPageFormat.cm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildSupplierAddress(invoice.supplier),
              Container(
                height: 50,
                width: 50,
                child: BarcodeWidget(
                  barcode: Barcode.qrCode(),
                  data: invoice.info.number,
                ),
              ),
            ],
          ),
          SizedBox(height: 1 * PdfPageFormat.cm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildCustomerAddress(invoice.customer),
              buildInvoiceInfo(invoice.info),
            ],
          ),
        ],
      );

  static Widget buildCustomerAddress(Customer customer) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Er referens", style: TextStyle(fontWeight: FontWeight.bold)),
          Text(customer.name),
          Text(customer.address ?? ""),
        ],
      );

  static Widget buildInvoiceInfo(InvoiceInfo info) {
    final paymentTerms = '${info.dueDate.difference(info.date).inDays} dagar';
    final titles = <String>['Offertnummer:', 'Datum:', 'Betalningsvillkor:', 'Förfallodatum:'];
    final data = <String>[
      info.number,
      format.format(info.date),
      paymentTerms,
      format.format(info.dueDate),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(titles.length, (index) {
        final title = titles[index];
        final value = data[index];

        return buildText(title: title, value: value, width: 200);
      }),
    );
  }

  static Widget buildSupplierAddress(Supplier supplier) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Vår referens", style: TextStyle(fontWeight: FontWeight.bold)),
          Text(supplier.name),
          SizedBox(height: 1 * PdfPageFormat.mm),
          Text(supplier.address),
        ],
      );

  static Widget buildTitle(Invoice invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            invoice.title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 0.8 * PdfPageFormat.cm),
          Text(invoice.info.description),
          SizedBox(height: 0.8 * PdfPageFormat.cm),
        ],
      );

  static Widget buildInvoice(Invoice invoice) {
    final headers = ['Beskrivning', 'Datum', 'Antal', 'Á-pris', 'Moms', 'Total'];
    final data = invoice.items.map((item) {
      final total = item.unitPrice * item.quantity;

      return [
        item.description,
        format.format(item.date),
        '${item.quantity}',
        '${item.unitPrice} kr',
        '${item.vat} %',
        '${total.toStringAsFixed(2)} kr',
      ];
    }).toList();

    return Table.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: TextStyle(fontWeight: FontWeight.bold),
      headerDecoration: BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.centerRight,
        2: Alignment.centerRight,
        3: Alignment.centerRight,
        4: Alignment.centerRight,
        5: Alignment.centerRight,
      },
    );
  }

  static Widget buildTotal(Invoice invoice) {
    final total = invoice.items.map((item) => item.unitPrice * item.quantity).reduce((item1, item2) => item1 + item2);
    final vatPercent = invoice.items.first.vat;
    final vat = total * (vatPercent / 100);
    final netTotal = total - vat;

    return Container(
      alignment: Alignment.centerRight,
      child: Row(
        children: [
          Spacer(flex: 6),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildText(
                  title: 'Belopp före moms',
                  value: formatPrice(netTotal),
                  unite: true,
                ),
                buildText(
                  title: 'Moms $vatPercent %',
                  value: formatPrice(vat),
                  unite: true,
                ),
                Divider(),
                buildText(
                  title: 'Att betala (SEK)',
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  value: formatPrice(total),
                  unite: true,
                ),
                SizedBox(height: 2 * PdfPageFormat.mm),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildFooter(Invoice invoice) {
    double width = 150;
    return Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildText(title: 'Tel.nr', value: invoice.supplier.phonenumber ?? "", width: width),
            buildText(title: 'E-post', value: invoice.supplier.email ?? "", width: width),
            buildText(title: 'Hemsida', value: invoice.companyInfo?.website ?? "", width: width),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildText(title: 'Org.nr', value: invoice.companyInfo?.orgNr ?? "", width: 120),
            buildText(title: 'VAT.nr', value: invoice.companyInfo?.vatNr ?? "", width: 120),
            buildText(title: 'iban', value: invoice.bankInfo?.iban ?? "", width: 120),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buildText(title: 'Bankgiro', value: invoice.bankInfo?.bankgiro ?? "", width: 120),
            buildText(title: 'Plusgiro', value: invoice.bankInfo?.plusgiro ?? "", width: 120),
          ],
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        SizedBox(height: 2 * PdfPageFormat.mm),
        Table.fromTextArray(
            border: null,
            headerStyle: TextStyle(fontWeight: FontWeight.bold),
            headerDecoration: null,
            cellHeight: 5,
            headerHeight: 5,
            cellPadding: EdgeInsets.zero,
            cellAlignments: {
              0: Alignment.centerLeft,
              1: Alignment.centerLeft,
              2: Alignment.centerRight,
            },
            headers: [
              "Tel.nr",
              "Org.nr",
              "Bankgiro"
            ],
            data: [
              [
                "${invoice.supplier.phonenumber ?? ""}",
                "${invoice.companyInfo?.orgNr ?? ""}",
                "${invoice.bankInfo?.bankgiro ?? ""}",
              ]
            ]),
        pw.SizedBox(height: 2 * PdfPageFormat.mm),
        Table.fromTextArray(
            border: null,
            headerStyle: TextStyle(fontWeight: FontWeight.bold),
            headerDecoration: null,
            cellHeight: 5,
            headerHeight: 5,
            cellPadding: EdgeInsets.zero,
            cellAlignments: {
              0: Alignment.centerLeft,
              1: Alignment.centerLeft,
              2: Alignment.centerRight,
            },
            headers: [
              "E-post",
              "VAT.nr",
              "Plusgiro"
            ],
            data: [
              [
                "${invoice.supplier.email ?? ""}",
                "${invoice.companyInfo?.vatNr ?? ""}",
                "${invoice.bankInfo?.plusgiro ?? ""}",
              ]
            ]),
        // pw.Row(
        //   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        //   children: [
        //     buildSimpleText(title: 'Tel.nr', value: settings.orgNr ?? ""),
        //     buildSimpleText(title: 'Org.nr', value: settings.orgNr ?? ""),
        //     buildSimpleText(title: 'Bankgiro', value: settings.bankgiro ?? ""),
        //   ],
        // ),
        // pw.Row(
        //   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        //   children: [
        //     buildSimpleText(title: 'Hemsida', value: settings.website ?? ""),
        //     buildSimpleText(title: 'VAT.nr', value: settings.vatNr ?? ""),
        //     buildSimpleText(title: 'Bankgiro', value: settings.plusgiro ?? ""),
        //   ],
        // ),
        // pw.Row(
        //   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        //   children: [
        //     buildSimpleText(title: 'E-post', value: settings.website ?? ""),
        //     buildSimpleText(title: 'VAT.nr', value: settings.vatNr ?? ""),
        //   ],
        // ),
        //buildSimpleText(title: 'Hemsida', value: settings.website ?? ""),
        //buildSimpleText(title: 'E-post', value: settings.orgNr ?? ""),
        //buildSimpleText(title: 'Address', value: invoice.supplier.address),
      ],
    );
  }

  static buildSimpleText({
    required String title,
    required String value,
  }) {
    final style = TextStyle(fontWeight: FontWeight.bold);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        Text(title, style: style),
        SizedBox(width: 2 * PdfPageFormat.mm),
        Text(value),
      ],
    );
  }

  static buildText({
    required String title,
    required String value,
    double width = double.infinity,
    TextStyle? titleStyle,
    bool unite = false,
  }) {
    final style = titleStyle ?? TextStyle(fontWeight: FontWeight.bold);

    return Container(
      width: width,
      child: Row(
        children: [
          Expanded(child: Text(title, style: style)),
          Text(value, style: unite ? style : null),
        ],
      ),
    );
  }
}
