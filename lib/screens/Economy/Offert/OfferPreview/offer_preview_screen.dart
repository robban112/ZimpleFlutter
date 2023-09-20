import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
//import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:zimple/screens/TimeReporting/Invoice/api/pdf_invoice_api.dart';
import 'package:zimple/screens/TimeReporting/Invoice/model/invoice.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:zimple/widgets/widgets.dart';

class OfferPreviewScreen extends StatelessWidget {
  final Invoice invoice;

  const OfferPreviewScreen({
    Key? key,
    required this.invoice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(context),
    );
  }

  Widget body(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Align(alignment: Alignment.topRight, child: ZCloseButton(color: ThemeNotifier.of(context).red)),
          Container(
            height: height(context) - 100,
            width: width(context),
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16, top: 80),
              child: OfferPDF(invoice: invoice),
            ),
          ),
        ],
      ),
    );
  }
}

class OfferPDF extends StatelessWidget {
  final Invoice invoice;

  final double aspectRatio;

  final VoidCallback? onTap;

  OfferPDF({
    Key? key,
    this.aspectRatio = 1.0,
    required this.invoice,
    this.onTap,
  }) : super(key: key);

  late TextStyle bodyStyle = TextStyle(fontSize: aspectRatio * 14, fontWeight: FontWeight.normal, color: Colors.black);

  @override
  Widget build(BuildContext context) {
    // return PdfInvoiceApi.buildHeader(invoice);
    // return Column(
    //   children: PdfInvoiceApi.invoiceChildren(invoice),
    // );
    return FutureBuilder<File>(
      future: PdfInvoiceApi.generate(invoice),
      builder: ((context, snapshot) {
        if (!snapshot.hasData) return Container(height: 200, width: 200);
        return PDFView(
          filePath: snapshot.data!.path,
        );
        return Container();
      }),
    );
    // return Container(
    //   width: aspectRatio * width(context),
    //   padding: EdgeInsets.all(16),
    //   color: Colors.white,
    //   child: SingleChildScrollView(
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         _buildFirstRow(bodyStyle),
    //         divider(),
    //         divider(),
    //         Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             _buildTitledColumn("Avsändare", "Hejsan", fontSize: 18),
    //             _buildTitledColumn("Mottagare", "Hejsan", fontSize: 18),
    //           ],
    //         ),
    //         divider(),
    //         divider(),
    //         Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             _buildTitledColumn("Vår referens", "Nils karlsson"),
    //             divider(),
    //             _buildTitledColumn("Er referens", "Nils karlsson"),
    //             divider(),
    //             _buildTitledColumn("Betalningsvillkor", "Nils karlsson"),
    //           ],
    //         ),
    //         divider(),
    //         _buildArticlesHeader(context),
    //         Column(
    //           children: List.generate(selectedProducts.length, (index) {
    //             ProductAmount productAmount = selectedProducts[index];
    //             return Row(
    //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //               children: [
    //                 Text(productAmount.product.name, style: bodyStyle),
    //                 Text(productAmount.amount.toString(), style: bodyStyle),
    //                 Text(productAmount.product.pricePerUnit.toString(), style: bodyStyle),
    //                 Text((productAmount.product.pricePerUnit * productAmount.amount).toString(), style: bodyStyle)
    //               ],
    //             );
    //           }),
    //         ),
    //         DataTable(
    //           horizontalMargin: 0,
    //           showCheckboxColumn: false,
    //           columns: [
    //             DataColumn(label: Text('Produkt', style: bodyStyle)),
    //             DataColumn(label: Text('Antal', style: bodyStyle)),
    //             DataColumn(label: Text('Á-pris', style: bodyStyle)),
    //             DataColumn(label: Text('Belopp', style: bodyStyle)),
    //           ],
    //           rows: selectedProducts
    //               .map(
    //                 (selectedProduct) => DataRow(
    //                   cells: [
    //                     DataCell(Text(selectedProduct.product.name, style: bodyStyle)),
    //                     DataCell(Text(selectedProduct.amount.toString(), style: bodyStyle)),
    //                     DataCell(Text(selectedProduct.product.pricePerUnit.toString(), style: bodyStyle)),
    //                     DataCell(
    //                         Text((selectedProduct.product.pricePerUnit * selectedProduct.amount).toString(), style: bodyStyle))
    //                   ],
    //                 ),
    //               )
    //               .toList(),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }

  Widget _buildArticlesHeader(BuildContext context) {
    TextStyle headerTextStyle = bodyStyle.copyWith(color: Colors.white, fontSize: 12 * aspectRatio);
    return Container(
      height: aspectRatio * 35,
      width: aspectRatio * width(context),
      padding: EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Produkt / Tjänst", style: headerTextStyle),
          Text("Antal", style: headerTextStyle),
          Text("Á-pris", style: headerTextStyle),
          Text("Belopp", style: headerTextStyle),
        ],
      ),
    );
  }

  SizedBox divider() => SizedBox(height: aspectRatio * 16);

  Column _buildTitledColumn(String title, String subtitle, {double? fontSize}) {
    double _fontSize = fontSize ?? 16;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: aspectRatio * _fontSize, color: Colors.black),
        ),
        Text(
          subtitle,
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: aspectRatio * _fontSize, color: Colors.black),
        ),
      ],
    );
  }

  Row _buildFirstRow(TextStyle bodyStyle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Offert",
          style: TextStyle(fontSize: aspectRatio * 30, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "Offertnr 22",
              style: bodyStyle,
            ),
            divider(),
            Text(
              "Offertdatum 2022-01-22",
              style: bodyStyle,
            ),
            divider(),
            Text(
              "Förfallodatum",
              style: bodyStyle,
            ),
          ],
        )
      ],
    );
  }
}
