import 'package:flutter/material.dart';
import 'package:zimple/utils/utils.dart';

extension FutureExtension on Future {
  Future syncLoader(BuildContext context) {
    Utils.setLoading(context, true);
    return this.then((value) {
      Utils.setLoading(context, false);
      return this;
    });
  }
}
