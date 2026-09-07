class AppValidators {
  AppValidators._();

  // ============================================================
  // REQUIRED
  // ============================================================

  static String? required(
      String? value, {
        String field = 'This field',
      }) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required.';
    }

    return null;
  }

  // ============================================================
  // NAME
  // ============================================================

  static String? name(String? value) {
    final requiredError = required(
      value,
      field: 'Name',
    );

    if (requiredError != null) {
      return requiredError;
    }

    final clean = value!.trim();

    if (clean.length < 2) {
      return 'Name must be at least 2 characters.';
    }

    if (clean.length > 60) {
      return 'Name cannot exceed 60 characters.';
    }

    return null;
  }

  // ============================================================
  // EMAIL
  // ============================================================

  static String? email(String? value) {
    final requiredError = required(
      value,
      field: 'Email',
    );

    if (requiredError != null) {
      return requiredError;
    }

    final email = value!.trim();

    final valid = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);

    if (!valid) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  // ============================================================
  // PASSWORD
  // ============================================================

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }

    return null;
  }

  // ============================================================
  // CONFIRM PASSWORD
  // ============================================================

  static String? confirmPassword(
      String? value,
      String password,
      ) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password.';
    }

    if (value != password) {
      return 'Passwords do not match.';
    }

    return null;
  }

  // ============================================================
  // PHONE
  // ============================================================

  static String? phone(String? value) {
    final requiredError = required(
      value,
      field: 'Phone',
    );

    if (requiredError != null) {
      return requiredError;
    }

    final digits = value!.replaceAll(
      RegExp(r'\D'),
      '',
    );

    if (digits.length < 10 || digits.length > 13) {
      return 'Enter a valid phone number.';
    }

    return null;
  }

  // ============================================================
  // PAKISTANI CNIC
  // ============================================================

  static String? cnic(String? value) {
    final requiredError = required(
      value,
      field: 'CNIC',
    );

    if (requiredError != null) {
      return requiredError;
    }

    final valid = RegExp(
      r'^\d{5}-\d{7}-\d$',
    ).hasMatch(value!.trim());

    if (!valid) {
      return 'Use CNIC format 00000-0000000-0.';
    }

    return null;
  }

  // ============================================================
  // MINIMUM LENGTH
  // ============================================================

  static String? minLength(
      String? value,
      int minimum, {
        String field = 'Field',
      }) {
    final requiredError = required(
      value,
      field: field,
    );

    if (requiredError != null) {
      return requiredError;
    }

    if (value!.trim().length < minimum) {
      return '$field must be at least '
          '$minimum characters.';
    }

    return null;
  }

  // ============================================================
  // MAXIMUM LENGTH
  // ============================================================

  static String? maxLength(
      String? value,
      int maximum, {
        String field = 'Field',
      }) {
    if (value == null) {
      return null;
    }

    if (value.trim().length > maximum) {
      return '$field cannot exceed '
          '$maximum characters.';
    }

    return null;
  }
}