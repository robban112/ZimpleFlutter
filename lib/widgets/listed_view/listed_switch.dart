import 'package:zimple/widgets/widgets.dart';

class ListedSwitch extends ListedItem {
  final bool initialValue;
  final Function(bool) onChanged;

  ListedSwitch({
    required String text,
    required this.initialValue,
    required this.onChanged,
    leadingIcon,
  }) : super(
          leadingIcon: leadingIcon,
          text: text,
        );
}
