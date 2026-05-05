import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'en.dart';
import 'hi.dart';
import 'gu.dart';

class TranslationService extends Translations {
  static Locale? get locale => Get.deviceLocale;
  static const fallbackLocale = Locale('en', 'US');

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': en,
        'hi_IN': hi,
        'gu_IN': gu,
      };

  static void changeLocale(String langCode) {
    Locale locale;
    switch (langCode) {
      case 'en':
        locale = const Locale('en', 'US');
        break;
      case 'hi':
        locale = const Locale('hi', 'IN');
        break;
      case 'gu':
        locale = const Locale('gu', 'IN');
        break;
      default:
        locale = const Locale('en', 'US');
    }
    Get.updateLocale(locale);
  }
}
