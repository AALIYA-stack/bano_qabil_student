extension StringExtensions on String {
  // ============================================================
  // EMPTY / BLANK
  // ============================================================

  bool get isBlank => trim().isEmpty;

  bool get isNotBlank => trim().isNotEmpty;

  // ============================================================
  // CAPITALIZATION
  // ============================================================

  String get capitalizeFirst {
    final value = trim();

    if (value.isEmpty) {
      return this;
    }

    return '${value[0].toUpperCase()}'
        '${value.substring(1)}';
  }

  String get titleCase {
    if (trim().isEmpty) {
      return this;
    }

    return trim()
        .split(RegExp(r'\s+'))
        .map(
          (word) => word.isEmpty
          ? word
          : '${word[0].toUpperCase()}'
          '${word.substring(1).toLowerCase()}',
    )
        .join(' ');
  }

  // ============================================================
  // INITIALS
  // ============================================================

  String get initials {
    final value = trim();

    if (value.isEmpty) {
      return '?';
    }

    final parts = value.split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'
        .toUpperCase();
  }

  // ============================================================
  // NULL-LIKE VALUES
  // ============================================================

  bool get isNullOrEmptyValue {
    final value = trim().toLowerCase();

    return value.isEmpty ||
        value == 'null' ||
        value == 'n/a' ||
        value == 'na';
  }

  // ============================================================
  // SAFE DISPLAY
  // ============================================================

  String get displayValue {
    return isNullOrEmptyValue ? '-' : trim();
  }
}