import 'package:get_storage/get_storage.dart';

class ParlorSession {
  static final GetStorage _storage = GetStorage();

  /// Returns the current parlor's gender type: 'Female', 'Male', or 'Unisex'
  static String get parlorGender {
    final g = _storage.read('parlorGender');
    if (g != null && g.toString().trim().isNotEmpty) {
      return g.toString().trim();
    }
    return 'Female';
  }

  static bool get isFemale => parlorGender.toLowerCase() == 'female';
  static bool get isMale => parlorGender.toLowerCase() == 'male';
  static bool get isUnisex => parlorGender.toLowerCase() == 'unisex';

  /// Returns the dynamic translation key for bridal/groom orders flow
  static String get bridalFlowKey {
    if (isMale) return 'groom_orders';
    if (isUnisex) return 'bridal_and_groom_orders';
    return 'bridal_orders';
  }

  /// Returns readable display title for bridal/groom flow
  static String get bridalFlowDefaultTitle {
    if (isMale) return 'Groom Orders';
    if (isUnisex) return 'Bridal & Groom Orders';
    return 'Bridal Orders';
  }

  /// Returns localized badge title for profile & status
  static String get parlorTypeBadgeText {
    if (isMale) return '💈 Gents Salon';
    if (isUnisex) return '✂️ Unisex Salon';
    return '🌸 Ladies Parlor';
  }

  /// Dynamic hint for adding new services
  static String get serviceNameHint {
    if (isMale) return 'E.g., Hair Cut, Beard Trim, Shave, De-Tan...';
    if (isUnisex) return 'E.g., Hair Cut, Shave, Facial, Hair Spa...';
    return 'E.g., Hair Cut, Facial, Eyebrow, Waxing...';
  }

  /// Dynamic subtitle for services menu
  static String get serviceSubtitle {
    if (isMale) return 'Hair Cut, Beard Trim, Shave, etc.';
    if (isUnisex) return 'Hair Cut, Shave, Facial, etc.';
    return 'Hair Cut, Facial, Eyebrow, etc.';
  }
}
