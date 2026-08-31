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
        id: 's1',
        name: 'Pooja Sharma',
        mobileNumber: '9898989891',
        specialties: ['Skin Care', 'Facial', 'General'],
        status: true,
      ),
      StaffModel(
        id: 's2',
        name: 'Neha Gupta',
        mobileNumber: '9898989892',
        specialties: ['Hair', 'Hair Care', 'Spa'],
        status: true,
      ),
      StaffModel(
        id: 's3',
        name: 'Ananya Roy',
        mobileNumber: '9898989893',
        specialties: ['Makeup', 'Bridal'],
        status: true,
      ),
      StaffModel(
        id: 's4',
        name: 'Kavita Verma',
        mobileNumber: '9898989894',
        specialties: ['Nail Care', 'Pedicure', 'Manicure'],
        status: true,
      ),
      StaffModel(
        id: 's5',
        name: 'Mansi Ladani',
        mobileNumber: '9898989895',
        specialties: ['Master Stylist', 'Facial', 'Hair Care', 'Skin Care'],
        status: true,
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
