import 'package:get/get.dart';
import '../models/staff_model.dart';

class StaffService extends GetxService {
  final allStaff = <StaffModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialStaff();
  }

  void loadInitialStaff() {
    allStaff.assignAll([
      StaffModel(
        id: '1',
        name: 'Mansi Ladani',
        mobileNumber: '9898989898',
        specialties: ['Facial', 'Hair Care'],
      ),
      StaffModel(
        id: '2',
        name: 'Pooja Patel',
        mobileNumber: '9797979797',
        specialties: ['Hair Care', 'Makeup'],
      ),
    ]);
  }

  void addStaff(StaffModel staff) {
    allStaff.add(staff);
  }

  void updateStaff(StaffModel updatedStaff) {
    final index = allStaff.indexWhere((s) => s.id == updatedStaff.id);
    if (index != -1) {
      allStaff[index] = updatedStaff;
    }
  }

  void deleteStaff(String id) {
    allStaff.removeWhere((s) => s.id == id);
  }
}
