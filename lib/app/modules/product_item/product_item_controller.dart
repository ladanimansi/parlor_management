import 'package:get/get.dart';

class ProductItemController extends GetxController {
  // In-memory list for product items
  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[
    {"id": "1", "name": "Gold Facial", "price": "1500", "category": "Facial", "status": true},
    {"id": "2", "name": "Hair Spa", "price": "800", "category": "Hair Care", "status": true},
  ].obs;

  void addItem(String name, String price, String category) {
    if (name.trim().isEmpty || price.trim().isEmpty || category.isEmpty) return;
    final newItem = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "name": name.trim(),
      "price": price.trim(),
      "category": category,
      "status": true,
    };
    items.add(newItem);
  }

  void editItem(String id, String newName, String newPrice, String newCategory) {
    if (newName.trim().isEmpty || newPrice.trim().isEmpty || newCategory.isEmpty) return;
    final index = items.indexWhere((item) => item["id"] == id);
    if (index != -1) {
      items[index]["name"] = newName.trim();
      items[index]["price"] = newPrice.trim();
      items[index]["category"] = newCategory;
      items.refresh();
    }
  }

  void deleteItem(String id) {
    items.removeWhere((item) => item["id"] == id);
  }
}
