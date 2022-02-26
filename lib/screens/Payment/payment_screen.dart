import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:zimple/screens/Payment/Offert/create_offer_screen.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/app_bar_widget.dart';
import 'package:zimple/widgets/widgets.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(appBarHeight),
          child: StandardAppBar(
            "Ekonomi",
            withBackButton: false,
          )),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text("Senaste offerter", style: titleStyle),
          // const SizedBox(height: 16),
          // Text("Senaste fakturor", style: titleStyle),
          // const SizedBox(height: 16),
          ListedTitle(text: "FUNKTIONER", padding: EdgeInsets.zero),
          const SizedBox(height: 4),
          ListedView(
            rowInset: EdgeInsets.symmetric(vertical: 12),
            items: [
              ListedItem(text: "Skapa faktura", leadingIcon: FontAwesomeIcons.fileInvoice),
              ListedItem(
                text: "Skapa offert",
                leadingIcon: FontAwesomeIcons.fileInvoice,
                onTap: () => pushNewScreen(
                  context,
                  screen: CreateOfferScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
