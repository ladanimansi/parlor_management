import 'package:get/get.dart';
import '../../core/utils/parlor_session.dart';
import '../../data/models/service_model.dart';

class ServicesController extends GetxController {
  final services = <ServiceModel>[].obs;
  final isLoading = false.obs;
  final selectedCategory = 'All'.obs;

  List<String> get categories {
    if (ParlorSession.isMale) {
      return ['All', 'Groom', 'Hair', 'Beard & Shave', 'Skin Care'];
    } else if (ParlorSession.isUnisex) {
      return ['All', 'Women', 'Men', 'Bridal & Groom', 'Hair', 'Skin Care'];
    } else {
      return ['All', 'Bridal', 'Hair', 'Skin Care', 'Nail Care'];
    }
  }

  void setCategory(String category) {
    selectedCategory.value = category;
    _filterServices();
  }

  void _filterServices() {
    if (selectedCategory.value == 'All') {
      services.assignAll(allServices);
    } else {
      services.assignAll(
        allServices.where((s) => s.category == selectedCategory.value).toList(),
      );
    }
  }

  // --- CRUD Operations ---
  void addService(ServiceModel service) {
    allServices.add(service);
    _filterServices();
  }

  void updateService(ServiceModel updatedService) {
    final index = allServices.indexWhere((s) => s.id == updatedService.id);
    if (index != -1) {
      allServices[index] = updatedService;
      _filterServices();
    }
  }

  void deleteService(String id) {
    allServices.removeWhere((s) => s.id == id);
    _filterServices();
  }

  // Helper for all services to persist state during session
  final allServices = <ServiceModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _filterServices();
  }
}
