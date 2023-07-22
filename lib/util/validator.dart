
  String? nameValidator(String? value) {
    if (value == null || value.isEmpty || value.trim().length < 3) {
      return 'Invalid Name';
    }
    return null;
  }

  String? quantityValidator(String? value) {
    if (value == null ||
        value.isEmpty ||
        int.tryParse(value) == null ||
        int.tryParse(value)! < 1) {
      return 'Incorrect Quantity';
    }
    return null;
  }

