extension StringExtensions on String? {
  bool isBlank() {
    return this == null || this == "";
  }

  bool isNotBlank() {
    return this != null && this != "";
  }
}
