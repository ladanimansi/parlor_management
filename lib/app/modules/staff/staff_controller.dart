import 'package:get/get.dart';
import '../../data/models/staff_model.dart';
import '../../data/services/staff_service.dart';

class StaffController extends GetxController {
  final StaffService _staffService = Get.find<StaffService>();
  final searchQuery = ''.obs;

  List<StaffModel> get allStaff => _staffService.allStaff;

  List<StaffModel> get filteredStaff {
    final query = searchQuery.value.toLowerCase().trim();
    if (query.isEmpty) {
      return _staffService.allStaff;
    }
    return _staffService.allStaff.where((s) {
      final matchesName = s.name.toLowerCase().contains(query);
      final matchesMobile = s.mobileNumber.contains(query);
      final matchesSpecialty = s.specialties.any((spec) => spec.toLowerCase().contains(query));
      return matchesName || matchesMobile || matchesSpecialty;
    }).toList();
  }

  void deleteStaff(String id) {
    _staffService.deleteStaff(id);
  }
}
