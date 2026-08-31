import 'package:get/get.dart';
import '../models/customer_model.dart';

class CustomerService extends GetxService {
  final allCustomers = <CustomerModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadSeedCustomers();
  }

  void _loadSeedCustomers() {
    allCustomers.assignAll([
      CustomerModel(
        id: 'c1',
        name: 'Reena Patel',
        mobileNumber: '9876543210',
        age: 25,
        gender: 'Female',
        otherInfo: 'Needs heavy base, prefers Mansi',
      ),
      CustomerModel(
        id: 'c2',
        name: 'Sonia Shah',
        mobileNumber: '9988776655',
        age: 31,
        gender: 'Female',
        otherInfo: 'Allergies to ammonia-based colors',
      ),
      CustomerModel(
        id: 'c3',
        name: 'Priya Mehra',
        mobileNumber: '9123456789',
        age: 28,
        gender: 'Female',
        otherInfo: 'Regular skin care checkups',
      ),
    ]);
  }

  CustomerModel? getCustomerByMobile(String mobile) {
    final cleanMobile = mobile.trim();
    if (cleanMobile.length < 10) return null;
    return allCustomers.firstWhereOrNull(
      (c) => c.mobileNumber.trim() == cleanMobile,
    );
  }

  void registerCustomer(CustomerModel customer) {
    final index = allCustomers.indexWhere((c) => c.mobileNumber.trim() == customer.mobileNumber.trim());
    if (index != -1) {
      allCustomers[index] = customer;
    } else {
      allCustomers.add(customer);
    }
  }
}
