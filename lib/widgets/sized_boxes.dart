import 'package:flutter/cupertino.dart';

class HeightBoxes {
  static Widget get small {
    return const SizedBox(height: 6);
  }

  static Widget get medium {
    return const SizedBox(height: 16);
  }

  static Widget get large {
    return const SizedBox(height: 32);
  }
}

class WidthBoxes {
  static Widget get small {
    return const SizedBox(width: 6);
  }

  static Widget get medium {
    return const SizedBox(width: 16);
  }

  static Widget get large {
    return const SizedBox(width: 32);
  }
}
