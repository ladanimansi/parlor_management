import 'package:get/get.dart';
import '../product_category/product_category_controller.dart';
import '../product_item/product_item_controller.dart';
import '../../data/services/appointment_service.dart';
import '../../data/models/appointment_model.dart';
import '../../routes/app_routes.dart';

class OrderPreparationController extends GetxController {
  final ProductCategoryController _categoryController = Get.find<ProductCategoryController>();
  final ProductItemController _itemController = Get.isRegistered<ProductItemController>()
      ? Get.find<ProductItemController>()
      : Get.put(ProductItemController());

  final selectedCategory = 'All'.obs;
  final searchQuery = ''.obs;
  final selectedItemIds = <String>{}.obs;
  String? appointmentId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      if (args is String) {
        selectedCategory.value = args;
      } else if (args is Map<String, dynamic>) {
        selectedCategory.value = args['category'] ?? 'All';
        appointmentId = args['appointmentId'];
        
        // Optionally pre-select items if the appointment already has selected items saved in serviceName
        if (appointmentId != null) {
          final appointmentService = Get.find<AppointmentService>();
          final index = appointmentService.allAppointments.indexWhere((app) => app.id == appointmentId);
          if (index != -1) {
            final app = appointmentService.allAppointments[index];
            final services = app.serviceName.split(',').map((s) => s.trim()).toList();
            for (final item in _itemController.items) {
              final itemName = item['name']?.toString() ?? '';
              if (services.contains(itemName)) {
                selectedItemIds.add(item['id']?.toString() ?? '');
              }
            }
          }
        }
      }
    }
  }

  List<String> get categories {
    final list = _categoryController.categories
        .where((cat) => cat['status'] == true)
        .map<String>((cat) => cat['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
    return ['All', ...list];
  }

  List<Map<String, dynamic>> get filteredItems {
    final allItems = _itemController.items
        .where((item) => item['status'] == true)
        .toList();

    return allItems.where((item) {
      final matchesCategory = selectedCategory.value == 'All' ||
          item['category'] == selectedCategory.value;
      final matchesSearch = searchQuery.value.isEmpty ||
          (item['name']?.toString() ?? '')
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  void toggleItemSelection(String itemId) {
    if (selectedItemIds.contains(itemId)) {
      selectedItemIds.remove(itemId);
    } else {
      selectedItemIds.add(itemId);
    }
  }

  bool isItemSelected(String itemId) {
    return selectedItemIds.contains(itemId);
  }

  void savePreparedItems({bool goToAllocation = false}) {
    final selectedItemObjects = _itemController.items
        .where((item) => selectedItemIds.contains(item['id']))
        .toList();

    final selectedItems = selectedItemObjects
        .map((item) => item['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    double calculatedAmount = 0.0;
    final List<ServiceItemAllocation> allocations = [];

    for (final itemObj in selectedItemObjects) {
      final name = itemObj['name']?.toString() ?? '';
      final price = double.tryParse(itemObj['price']?.toString() ?? '0') ?? 0.0;
      final itemId = itemObj['id']?.toString() ?? '';
      calculatedAmount += price;
      allocations.add(ServiceItemAllocation(
        serviceId: itemId,
        serviceName: name,
        price: price,
        status: 'Waiting',
      ));
    }

    if (appointmentId != null) {
      final appointmentService = Get.find<AppointmentService>();
      final index = appointmentService.allAppointments.indexWhere((app) => app.id == appointmentId);
      if (index != -1) {
        final currentApp = appointmentService.allAppointments[index];
        final updatedApp = currentApp.copyWith(
          serviceName: selectedItems.isNotEmpty ? selectedItems.join(', ') : currentApp.serviceName,
          amount: calculatedAmount > 0 ? calculatedAmount : currentApp.amount,
          serviceAllocations: allocations.isNotEmpty ? allocations : currentApp.serviceAllocations,
        );
        appointmentService.updateAppointment(updatedApp);
        Get.back();
        Get.snackbar("success".tr, "Prepared items saved. Total Bill Amount: ₹${updatedApp.amount.toStringAsFixed(0)}");
        if (goToAllocation) {
          Get.toNamed(Routes.ORDER_ALLOCATION, arguments: {
            'appointmentId': appointmentId,
          });
        }
        return;
      }
    }
    
    Get.back();
    Get.snackbar("success".tr, "order_preparation_saved".tr);
    if (goToAllocation) {
      Get.toNamed(Routes.ORDER_ALLOCATION, arguments: {
        'appointmentId': appointmentId,
      });
    }
  }
}
