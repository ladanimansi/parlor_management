import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class MenuController extends GetxController {
  final GetStorage _storage = GetStorage();

  String get parlorName => _storage.read('parlorName') ?? 'MannS Parlor';
  String get userRole => _storage.read('userRole') ?? 'parlor';
  bool get isAdmin => userRole == 'admin';
}
