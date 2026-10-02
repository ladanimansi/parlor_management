import 'package:get/get.dart';
import '../../data/models/service_model.dart';

class ServicesController extends GetxController {
  final services = <ServiceModel>[].obs;
  final isLoading = false.obs;
  final selectedCategory = 'All'.obs;

  final List<String> categories = ['All', 'Bridal', 'Hair', 'Skin Care', 'Nail Care'];

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
