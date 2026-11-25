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

  final searchQuery = ''.obs;

  void setCategory(String category) {
    selectedCategory.value = category;
    _filterServices();
  }

  void setSearchQuery(String q) {
    searchQuery.value = q;
    _filterServices();
  }

  void _filterServices() {
    var list = allServices.toList();
    if (selectedCategory.value != 'All') {
      list = list.where((s) => s.category == selectedCategory.value).toList();
    }
    if (searchQuery.value.trim().isNotEmpty) {
      final q = searchQuery.value.toLowerCase().trim();
      list = list.where((s) => s.name.toLowerCase().contains(q) || s.category.toLowerCase().contains(q)).toList();
    }
    services.assignAll(list);
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
    _loadInitialServices();
    _filterServices();
  }

  void _loadInitialServices() {
    if (allServices.isNotEmpty) return;

    if (ParlorSession.isMale) {
      allServices.assignAll([
        ServiceModel(id: '1', name: 'Hair Cut & Styling', price: 150, duration: '25 min', category: 'Hair', description: 'Classic & modern haircut with styling'),
        ServiceModel(id: '2', name: 'Beard Trim & Shape', price: 100, duration: '20 min', category: 'Beard & Shave', description: 'Beard grooming & sharp line shaping'),
        ServiceModel(id: '3', name: 'Royal Hot Towel Shave', price: 80, duration: '15 min', category: 'Beard & Shave', description: 'Smooth shave with soothing aftershave'),
        ServiceModel(id: '4', name: 'Head Massage with Oil', price: 180, duration: '20 min', category: 'Hair', description: 'Relaxing herbal & almond scalp massage'),
        ServiceModel(id: '5', name: 'D-Tan Face Glow Pack', price: 250, duration: '30 min', category: 'Skin Care', description: 'Instant tan removal & skin brightening'),
        ServiceModel(id: '6', name: 'Gold Radiance Facial', price: 550, duration: '45 min', category: 'Skin Care', description: 'Deep cleansing and rejuvenating gold glow'),
        ServiceModel(id: '7', name: 'Hair Color & Highlights', price: 350, duration: '40 min', category: 'Hair', description: 'Ammonia-free premium hair coloring'),
        ServiceModel(id: '8', name: 'Groom Special Royal Package', price: 1500, duration: '90 min', category: 'Groom', description: 'Complete grooming package for special occasions'),
      ]);
    } else if (ParlorSession.isUnisex) {
      allServices.assignAll([
        ServiceModel(id: '1', name: 'Classic Haircut & Blow Dry', price: 250, duration: '30 min', category: 'Hair', description: 'Professional haircut and styling finish'),
        ServiceModel(id: '2', name: 'Hair Spa & Deep Conditioning', price: 650, duration: '45 min', category: 'Hair', description: 'Intensive nourishing care for smooth hair'),
        ServiceModel(id: '3', name: 'Fruit Glow Cleanup', price: 350, duration: '30 min', category: 'Skin Care', description: 'Gentle fruit-infused deep facial cleanse'),
        ServiceModel(id: '4', name: 'Gold Radiance Facial', price: 750, duration: '50 min', category: 'Skin Care', description: 'Luxury gold treatment for glowing complexion'),
        ServiceModel(id: '5', name: 'Full Face D-Tan & Bleach', price: 400, duration: '30 min', category: 'Skin Care', description: 'Effective tan removal and skin tone evening'),
        ServiceModel(id: '6', name: 'Hair Coloring / Highlights', price: 1800, duration: '90 min', category: 'Hair', description: 'Trendy salon color with rich pigments'),
        ServiceModel(id: '7', name: 'Bridal & Groom Complete Combo', price: 3500, duration: '150 min', category: 'Bridal & Groom', description: 'All-in-one head-to-toe beauty makeover'),
      ]);
    } else {
      allServices.assignAll([
        ServiceModel(id: '1', name: 'Hair Cut & Blow Dry', price: 250, duration: '30 min', category: 'Hair', description: 'Custom layered cut with blow-dry styling'),
        ServiceModel(id: '2', name: 'Eyebrow & Upper Lip Threading', price: 60, duration: '15 min', category: 'Hair', description: 'Precise shape threading for clean look'),
        ServiceModel(id: '3', name: 'Full Arms & Legs Waxing', price: 450, duration: '40 min', category: 'Skin Care', description: 'Gentle honey wax for silky smooth skin'),
        ServiceModel(id: '4', name: 'Fruit Glow Cleanup', price: 350, duration: '30 min', category: 'Skin Care', description: 'Refreshing natural fruit extract cleanup'),
        ServiceModel(id: '5', name: 'Gold Radiance Facial', price: 750, duration: '50 min', category: 'Skin Care', description: 'Radiant glow with 24k gold essence'),
        ServiceModel(id: '6', name: 'Diamond Bleach & D-Tan', price: 400, duration: '30 min', category: 'Skin Care', description: 'Instant glow brightening skin treatment'),
        ServiceModel(id: '7', name: 'Hair Spa & Scalp Massage', price: 650, duration: '45 min', category: 'Hair', description: 'Damage repair and scalp stress relief'),
        ServiceModel(id: '8', name: 'Nail Art & Gel Extensions', price: 500, duration: '40 min', category: 'Nail Care', description: 'Trendy gel nail art and glossy finish'),
        ServiceModel(id: '9', name: 'Bridal Pre-Wedding Package', price: 3500, duration: '180 min', category: 'Bridal', description: 'Complete bridal radiance ritual package'),
      ]);
    }
  }
}
