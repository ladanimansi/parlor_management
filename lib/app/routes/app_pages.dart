import 'package:get/get.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/services/services_binding.dart';
import '../modules/services/services_view.dart';
import '../modules/appointments/appointments_binding.dart';
import '../modules/appointments/appointments_view.dart';
import '../modules/book_appointment/book_appointment_binding.dart';
import '../modules/book_appointment/book_appointment_view.dart';
import '../modules/dashboard/dashboard_binding.dart';
import '../modules/dashboard/dashboard_view.dart';
import '../modules/product_category/product_category_binding.dart';
import '../modules/product_category/product_category_view.dart';
import '../modules/product_item/product_item_binding.dart';
import '../modules/product_item/product_item_view.dart';
import '../modules/product_category/add_product_category_view.dart';
import '../modules/product_item/add_product_item_view.dart';
import '../modules/order_preparation/order_preparation_binding.dart';
import '../modules/order_preparation/order_preparation_view.dart';
import '../modules/orders/orders_binding.dart';
import '../modules/orders/orders_view.dart';
import '../modules/staff/staff_binding.dart';
import '../modules/staff/staff_view.dart';
import '../modules/staff/add_staff_binding.dart';
import '../modules/staff/add_staff_view.dart';
import '../modules/order_allocation/order_allocation_binding.dart';
import '../modules/order_allocation/order_allocation_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.SERVICES,
      page: () => const ServicesView(),
      binding: ServicesBinding(),
    ),
    GetPage(
      name: _Paths.APPOINTMENTS,
      page: () => const MenuView(),
      binding: MenuBinding(),
    ),
    GetPage(
      name: _Paths.BOOK_APPOINTMENT,
      page: () => const BookAppointmentView(),
      binding: BookAppointmentBinding(),
    ),
    GetPage(
      name: _Paths.PRODUCT_CATEGORY,
      page: () => const ProductCategoryView(),
      binding: ProductCategoryBinding(),
    ),
    GetPage(
      name: _Paths.PRODUCT_ITEM,
      page: () => const ProductItemView(),
      binding: ProductItemBinding(),
    ),
    GetPage(
      name: _Paths.ADD_PRODUCT_CATEGORY,
      page: () => const AddProductCategoryView(),
    ),
    GetPage(
      name: _Paths.ADD_PRODUCT_ITEM,
      page: () => const AddProductItemView(),
    ),
    GetPage(
      name: _Paths.ORDER_PREPARATION,
      page: () => const OrderPreparationView(),
      binding: OrderPreparationBinding(),
    ),
    GetPage(
      name: _Paths.ORDERS,
      page: () => const OrdersView(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: _Paths.STAFF,
      page: () => const StaffView(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: _Paths.ADD_STAFF,
      page: () => const AddStaffView(),
      binding: AddStaffBinding(),
    ),
    GetPage(
      name: _Paths.ORDER_ALLOCATION,
      page: () => const OrderAllocationView(),
      binding: OrderAllocationBinding(),
    ),
  ];
}

abstract class _Paths {
  static const HOME = '/home';
  static const DASHBOARD = '/dashboard';
  static const SERVICES = '/services';
  static const APPOINTMENTS = '/appointments';
  static const BOOK_APPOINTMENT = '/book-appointment';
  static const PRODUCT_CATEGORY = '/product-category';
  static const PRODUCT_ITEM = '/product-item';
  static const ADD_PRODUCT_CATEGORY = '/add-product-category';
  static const ADD_PRODUCT_ITEM = '/add-product-item';
  static const ORDER_PREPARATION = '/order-preparation';
  static const ORDERS = '/orders';
  static const STAFF = '/staff';
  static const ADD_STAFF = '/add-staff';
  static const ORDER_ALLOCATION = '/order-allocation';
}
