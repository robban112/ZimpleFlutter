import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:zimple/widgets/widgets.dart';

class SelectVATPage extends StatelessWidget {
  final int selectedVat;
  const SelectVATPage({
    Key? key,
    required this.selectedVat,
  }) : super(key: key);

  static const List<int> vats = [6, 12, 25];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar("Välj moms"),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Column(children: List.generate(vats.length, (index) => _buildVatSelect(context, vats[index])));
  }

  Widget _buildVatSelect(BuildContext context, int vat) {
    bool selected = selectedVat == vat;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _onSelectVAT(context, vat),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? ThemeNotifier.of(context).green : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                vat.toString(),
                style: textStyle(context).copyWith(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              if (selected) Icon(FeatherIcons.check, color: Colors.white, size: 32)
            ],
          ),
        ),
      ),
    );
  }

  void _onSelectVAT(BuildContext context, int vat) => Navigator.of(context).pop(vat);
}
