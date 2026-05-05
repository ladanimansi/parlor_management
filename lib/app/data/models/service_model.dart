class ServiceModel {
  final String id;
  final String name;
  final double price;
  final String duration;
  final String category;
  final String description;
  final String? image;

  ServiceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.category,
    required this.description,
    this.image,
  });
}
