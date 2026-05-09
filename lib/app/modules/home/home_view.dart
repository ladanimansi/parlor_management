import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../dashboard/dashboard_view.dart';
import '../services/services_view.dart';
import '../appointments/appointments_view.dart';
import 'home_controller.dart';
import 'profile_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const DashboardView(),
      const ServicesView(),
      const MenuView(),
      const ProfileView(),
    ];

    return Scaffold(
      body: Obx(
        () =>
            IndexedStack(index: controller.currentIndex.value, children: pages),
      ),
      bottomNavigationBar: Obx(() {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changePage,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.calendar_today),
                label: "home".tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.spa),
                label: "services".tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.list_alt),
                label: "Menu".tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: "profile".tr,
              ),
            ],
          ),
        );
      }),
    );
  }
}
