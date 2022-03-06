extension DoubleExtensions on double {
  String parseToTwoDigits() {
    String round = this.toStringAsFixed(2);
    List<String> splits = round.split('.');
    if (splits.length < 2) return splits[0];
    String decimals = splits[1];
    if (decimals == '00')
      return splits[0];
    else if (decimals.endsWith('0')) {
      return '${splits[0]}.${splits[1].substring(0, 1)}';
    } else
      return round;
  }
}
