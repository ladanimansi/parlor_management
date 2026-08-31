import 'package:get/get.dart';
import '../../data/models/staff_model.dart';
import '../../data/services/staff_service.dart';

class StaffController extends GetxController {
  final StaffService _staffService = Get.find<StaffService>();
  final searchQuery = ''.obs;
  final activeFilter = 'All'.obs; // 'All', 'Available', 'Busy', 'Facial', 'Hair', 'Makeup'

  List<StaffModel> get allStaff => _staffService.allStaff;

  List<StaffModel> get filteredStaff {
    final query = searchQuery.value.toLowerCase().trim();
    final filter = activeFilter.value;
    var list = List<StaffModel>.from(_staffService.allStaff);

    if (filter == 'Available') {
      list = list.where((s) => s.isAvailable).toList();
    } else if (filter == 'Busy') {
      list = list.where((s) => !s.isAvailable).toList();
    } else if (filter != 'All') {
      list = list.where((s) => s.specialties.any((sp) => sp.toLowerCase().contains(filter.toLowerCase()))).toList();
    }

    if (query.isEmpty) {
      return list;
    }
    return list.where((s) {
      final matchesName = s.name.toLowerCase().contains(query);
      final matchesMobile = s.mobileNumber.contains(query);
      final matchesSpecialty = s.specialties.any((spec) => spec.toLowerCase().contains(query));
      return matchesName || matchesMobile || matchesSpecialty;
    }).toList();
  }

  void toggleStaffStatus(StaffModel staff) {
    final updated = staff.copyWith(status: !staff.status);
    _staffService.updateStaff(updated);
  }

  void deleteStaff(String id) {
    _staffService.deleteStaff(id);
  }
}
