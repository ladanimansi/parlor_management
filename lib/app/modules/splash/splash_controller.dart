import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    FlutterNativeSplash.remove();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Show smooth animated branding for 2.4 seconds
    await Future.delayed(const Duration(milliseconds: 2400));
    Get.offNamed(Routes.HOME);
  }
}
