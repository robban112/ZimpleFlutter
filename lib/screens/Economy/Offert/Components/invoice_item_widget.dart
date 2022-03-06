import 'package:flutter/material.dart';
import 'package:zimple/screens/TimeReporting/Invoice/model/invoice.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:zimple/widgets/widgets.dart';

class ProductAmountItem extends StatelessWidget {
  final InvoiceItem productAmount;

  final VoidCallback onTapDeleteProduct;

  const ProductAmountItem({
    Key? key,
    required this.productAmount,
    required this.onTapDeleteProduct,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeNotifier.of(context).textColor.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productAmount.description,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${productAmount.quantity.toString()} st x ${productAmount.unitPrice.toInt().toString()} kr / h = ${(productAmount.quantity * productAmount.unitPrice)} kr",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            DeleteButton(onTapDelete: onTapDeleteProduct),
          ],
        ),
      ),
    );
  }
}
