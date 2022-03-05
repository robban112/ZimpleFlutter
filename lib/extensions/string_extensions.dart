extension StringExtensions on String? {
  bool isBlank() {
    return this == null || this == "";
  }

  bool isNotBlank() {
    return this != null && this != "";
  }

  String capitalize() {
    if (this?.isEmpty ?? true) return "";
    return "${this?[0].toUpperCase()}${this?.substring(1).toLowerCase()}";
  }
}
