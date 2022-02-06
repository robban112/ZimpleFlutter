import 'package:zimple/utils/misc/intersperse.dart' as _intersperse;

extension ListExtension<T> on List<T> {
  /// Puts [element] between every element in [list].
  ///
  /// Example:
  ///
  ///     final list1 = <int>[].intersperse(2); // [];
  ///     final list2 = [0].intersperse(2); // [0];
  ///     final list3 = [0, 0].intersperse(2); // [0, 2, 0];
  ///
  List<T> intersperse(T element) {
    return _intersperse.intersperse(element, this).toList();
  }

  /// Puts [element] between every element in [list] and at the bounds of [list].
  ///
  /// Example:
  ///
  ///     final list1 = <int>[].intersperseOuter(2); // [];
  ///     final list2 = [0].intersperseOuter(2); // [2, 0, 2];
  ///     final list3 = [0, 0].intersperseOuter(2); // [2, 0, 2, 0, 2];
  ///
  List<T> intersperseOuter(T element) {
    return _intersperse.intersperseOuter(element, this).toList();
  }

  List<T> intersperseIf(bool Function(T, T) shouldIntersperse, T element) {
    return _intersperse.intersperseIf((T p0, T p1) => shouldIntersperse(p0, p1), element, this).toList();
  }
}

extension IterableExtension<T> on Iterable<T> {
  /// Puts [element] between every element in [list].
  ///
  /// Example:
  ///
  ///     final list1 = <int>[].intersperse(2); // [];
  ///     final list2 = [0].intersperse(2); // [0];
  ///     final list3 = [0, 0].intersperse(2); // [0, 2, 0];
  ///
  Iterable<T> intersperse(T element) {
    return _intersperse.intersperse(element, this);
  }

  /// Puts [element] between every element in [list] and at the bounds of [list].
  ///
  /// Example:
  ///
  ///     final list1 = <int>[].intersperseOuter(2); // [];
  ///     final list2 = [0].intersperseOuter(2); // [2, 0, 2];
  ///     final list3 = [0, 0].intersperseOuter(2); // [2, 0, 2, 0, 2];
  ///
  Iterable<T> intersperseOuter(T element) {
    return _intersperse.intersperseOuter(element, this);
  }
}
