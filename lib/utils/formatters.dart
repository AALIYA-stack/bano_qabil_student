class AppFormatters {
  AppFormatters._();

  // ============================================================
  // INITIALS
  // ============================================================

  static String initials(String name) {
    final clean = name.trim();

    if (clean.isEmpty) {
      return '?';
    }

    final parts = clean.split(
      RegExp(r'\s+'),
    );

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'
        .toUpperCase();
  }

  // ============================================================
  // SHORT NAME
  // ============================================================

  static String compactName(
      String name, {
        int maxLength = 20,
      }) {
    final clean = name.trim();

    if (clean.length <= maxLength) {
      return clean;
    }

    return '${clean.substring(0, maxLength - 1)}…';
  }

  // ============================================================
  // NUMBER
  // ============================================================

  static String percentage(
      double value, {
        int decimalPlaces = 0,
      }) {
    return '${value.toStringAsFixed(decimalPlaces)}%';
  }

  // ============================================================
  // SEATS
  // ============================================================

  static String seats(int seats) {
    if (seats <= 0) {
      return 'No seats available';
    }

    if (seats == 1) {
      return '1 seat left';
    }

    return '$seats seats left';
  }
}