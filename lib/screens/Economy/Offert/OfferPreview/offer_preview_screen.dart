import 'package:flutter/material.dart';
import 'package:zimple/model/product.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:zimple/widgets/widgets.dart';

class OfferPreviewScreen extends StatelessWidget {
  const OfferPreviewScreen({Key? key}) : super(key: key);

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
              child: OfferPage(),
            ),
          ),
        ],
      ),
    );
  }
}

class OfferPage extends StatelessWidget {
  final double aspectRatio;

  OfferPage({
    Key? key,
    this.aspectRatio = 1.0,
  }) : super(key: key);

  late TextStyle bodyStyle = TextStyle(fontSize: aspectRatio * 14, fontWeight: FontWeight.normal, color: Colors.black);

  List<Product> products = [
    Product(id: "", name: "Test", unit: Unit.hours, pricePerUnit: 150),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: aspectRatio * width(context),
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFirstRow(bodyStyle),
            divider(),
            divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTitledColumn("Avsändare", "Hejsan", fontSize: 18),
                _buildTitledColumn("Mottagare", "Hejsan", fontSize: 18),
              ],
            ),
            divider(),
            divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitledColumn("Vår referens", "Nils karlsson"),
                divider(),
                _buildTitledColumn("Er referens", "Nils karlsson"),
                divider(),
                _buildTitledColumn("Betalningsvillkor", "Nils karlsson"),
              ],
            ),
            divider(),
            _buildArticlesHeader(context),
            Row(
              children: [],
            )
          ],
        ),
      ),
    );
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
