import '../models/service_model.dart';

class ServiceRepository {
  static List<ServiceModel> getStaticServices() {
    return [
      ServiceModel(
        id: '1',
        name: 'Bridal Makeup',
        price: 15000,
        duration: '3-4 Hours',
        category: 'Bridal',
        description: 'Complete bridal transformation including hair styling and saree draping.',
      ),
      ServiceModel(
        id: '2',
        name: 'Royal Facial',
        price: 2500,
        duration: '1 Hour',
        category: 'Skin Care',
        description: 'Premium gold facial for a long-lasting glow and refreshments.',
        requiredProductIds: const ['1'],
      ),
      ServiceModel(
        id: '3',
        name: 'Hair Coloring',
        price: 3500,
        duration: '2 Hours',
        category: 'Hair',
        description: 'Global hair coloring with premium ammonia-free products.',
      ),
      ServiceModel(
        id: '4',
        name: 'Keratin Treatment',
        price: 8000,
        duration: '3 Hours',
        category: 'Hair',
        description: 'Deep conditioning treatment for smooth and frizz-free hair.',
      ),
      ServiceModel(
        id: '5',
        name: 'Manicure & Pedicure',
        price: 1200,
        duration: '1.5 Hours',
        category: 'Nail Care',
        description: 'Relaxes your hands and feet with our spa-grade treatment.',
      ),
    ];
  }
}
