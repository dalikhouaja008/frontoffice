class FormValidators {
  bool validateBasicInfo(String title, String? landType, String surface) {
    if (title.isEmpty) return false;
    if (landType == null) return false;
    if (surface.isEmpty) return false;
    
    final surfaceValue = double.tryParse(surface);
    if (surfaceValue == null || surfaceValue <= 0) return false;
    
    return true;
  }
  
  bool validateLocation(String location, dynamic position) {
    if (location.isEmpty) return false;
    if (position == null) return false;
    return true;
  }
  
  bool validateDocuments(List<dynamic> documents) {
    return documents.isNotEmpty;
  }
  
  String? titleValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a property title';
    }
    return null;
  }
  
  String? surfaceValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the surface area';
    }
    if (double.tryParse(value) == null || double.parse(value) <= 0) {
      return 'Please enter a valid surface area';
    }
    return null;
  }
  
  String? landTypeValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a land type';
    }
    return null;
  }
  
  String? locationValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a location address';
    }
    return null;
  }
  
  String? tokensValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the total number of tokens';
    }
    if (int.tryParse(value) == null || int.parse(value) <= 0) {
      return 'Please enter a valid number of tokens';
    }
    return null;
  }
}