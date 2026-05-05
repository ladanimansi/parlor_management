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
      page: () => const AppointmentsView(),
      binding: AppointmentsBinding(),
    ),
    GetPage(
      name: _Paths.BOOK_APPOINTMENT,
      page: () => const BookAppointmentView(),
      binding: BookAppointmentBinding(),
    ),
  ];
}

abstract class _Paths {
  static const HOME = '/home';
  static const DASHBOARD = '/dashboard';
  static const SERVICES = '/services';
  static const APPOINTMENTS = '/appointments';
  static const BOOK_APPOINTMENT = '/book-appointment';
}
