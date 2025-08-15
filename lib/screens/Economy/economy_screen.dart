import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:zimple/screens/Economy/Offert/SavedProducts/saved_products_screen.dart';
import 'package:zimple/screens/Economy/Offert/create_offer_screen.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/widgets.dart';

class EconomyScreen extends StatefulWidget {
  const EconomyScreen({Key? key}) : super(key: key);

  @override
  _EconomyScreenState createState() => _EconomyScreenState();
}

class _EconomyScreenState extends State<EconomyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(appBarHeight),
          child: StandardAppBar(
            "Ekonomi",
            withBackButton: false,
          )),
      body: BackgroundWidget(
        child: _body(context),
      ),
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
              //ListedItem(text: "Skapa faktura", leadingIcon: FeatherIcons.fileText),
              ListedItem(
                text: "Skapa offert",
                leadingIcon: FeatherIcons.fileText,
                onTap: () => PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: CreateOfferScreen(),
                ),
              ),
              ListedItem(
                text: "Produkter / tjänster",
                leadingWidget: SvgPicture.asset('images/shop.svg', color: Theme.of(context).iconTheme.color),
                onTap: () => PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: SavedProductsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
