import 'package:get/get.dart';

class ProductCategoryController extends GetxController {
  // In-memory list for categories
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[
    {"id": "1", "name": "Facial", "status": true},
    {"id": "2", "name": "Hair Care", "status": true},
  ].obs;

  void addCategory(String name) {
    if (name.trim().isEmpty) return;
    final newCategory = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "name": name.trim(),
      "status": true,
    };
    categories.add(newCategory);
  }

  void editCategory(String id, String newName) {
    if (newName.trim().isEmpty) return;
    final index = categories.indexWhere((cat) => cat["id"] == id);
    if (index != -1) {
      categories[index]["name"] = newName.trim();
      categories.refresh();
    }
  }

  void deleteCategory(String id) {
    categories.removeWhere((cat) => cat["id"] == id);
  }

  void toggleStatus(String id) {
    final index = categories.indexWhere((cat) => cat["id"] == id);
    if (index != -1) {
      categories[index]["status"] = !categories[index]["status"];
      categories.refresh();
    }
  }
}
