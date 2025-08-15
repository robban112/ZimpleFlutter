import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zimple/screens/Economy/Offert/OfferPreview/offer_preview_screen.dart';
import 'package:zimple/screens/TimeReporting/Invoice/api/pdf_invoice_api.dart';
import 'package:zimple/screens/TimeReporting/Invoice/model/invoice.dart';
import 'package:zimple/utils/date_utils.dart';
import 'package:zimple/widgets/widgets.dart';

class CreatedOfferScreen extends StatefulWidget {
  final Invoice invoice;

  const CreatedOfferScreen({
    Key? key,
    required this.invoice,
  }) : super(key: key);

  @override
  State<CreatedOfferScreen> createState() => _CreatedOfferScreenState();
}

class _CreatedOfferScreenState extends State<CreatedOfferScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar("Offert ${dateToYearMonthDay(DateTime.now())}", trailing: _buildShareButton()),
      body: OfferPDF(
        invoice: widget.invoice,
      ),
    );
  }

  Widget _buildShareButton() {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: _onPressedShare,
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Icon(
          FeatherIcons.share,
          color: Colors.white,
        ),
      ),
    );
  }

  void _onPressedShare() async {
    File file = await PdfInvoiceApi.generate(widget.invoice);
    SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }
}
