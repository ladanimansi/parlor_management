import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/flow_type_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/parlor_model.dart';
import '../../routes/app_routes.dart';
import 'admin_controller.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Parlor Management',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Go to Salon App',
            icon: const Icon(Icons.storefront_outlined, color: AppColors.textPrimaryLight),
            onPressed: () => Get.toNamed(Routes.HOME),
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            onPressed: () => controller.logout(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.clearForm();
          Get.toNamed(Routes.ADD_PARLOR);
        },
        backgroundColor: AppColors.primary,
        elevation: 3,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
        label: const Text(
          'Add Parlor',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => controller.bindParlorsStream(),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Metrics / Statistics Cards
                Obx(() {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Total',
                          value: '${controller.parlors.length}',
                          icon: Icons.store_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Active',
                          value: '${controller.activeCount}',
                          icon: Icons.check_circle_rounded,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Inactive',
                          value: '${controller.inactiveCount}',
                          icon: Icons.pause_circle_rounded,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 20),

                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (val) => controller.searchQuery.value = val,
                    decoration: InputDecoration(
                      hintText: 'Search by parlor name, owner or phone...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 20),
                      suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                              onPressed: () => controller.searchQuery.value = '',
                            )
                          : const SizedBox.shrink()),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Section Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() {
                      final count = controller.filteredParlors.length;
                      return Text(
                        'Registered Parlors ($count)',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryLight,
                        ),
                      );
                    }),
                    Obx(() {
                      if (controller.isParlorsLoading.value) {
                        return const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
                const SizedBox(height: 12),

                // Parlor Cards List
                Obx(() {
                  final list = controller.filteredParlors;

                  if (controller.isParlorsLoading.value && controller.parlors.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (list.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: list.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _buildProfessionalParlorCard(context, list[index]);
                    },
                  );
                }),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, color: color, size: 15),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalParlorCard(BuildContext context, ParlorModel parlor) {
    final initials = parlor.parlorName.trim().isNotEmpty
        ? parlor.parlorName.trim().substring(0, 1).toUpperCase()
        : 'P';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: parlor.isActive
              ? AppColors.primary.withValues(alpha: 0.2)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Parlor Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and Owner
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          parlor.parlorName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 13, color: Colors.grey),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                parlor.ownerName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Active Toggle Switch
                  Transform.scale(
                    scale: 0.8,
                    child: Switch.adaptive(
                      value: parlor.isActive,
                      activeTrackColor: AppColors.primary,
                      activeThumbColor: Colors.white,
                      onChanged: (val) => controller.toggleParlorStatus(parlor),
                    ),
                  ),
                  // Options Menu
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                    onSelected: (val) {
                      if (val == 'delete') {
                        _confirmDelete(parlor);
                      } else if (val == 'rights') {
                        _showManageRightsDialog(context, parlor);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'rights',
                        child: Row(
                          children: [
                            Icon(Icons.security_outlined, size: 18, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text('Flow Rights', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Delete Parlor', style: TextStyle(color: AppColors.error, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 10),

              // Credentials & Location Badges
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildPill(
                    icon: Icons.email_outlined,
                    label: parlor.email,
                  ),
                  _buildPill(
                    icon: Icons.phone_outlined,
                    label: parlor.phone,
                  ),
                  if (parlor.city.isNotEmpty)
                    _buildPill(
                      icon: Icons.location_on_outlined,
                      label: parlor.city,
                    ),
                ],
              ),

              if (parlor.address.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  parlor.address,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 10),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 8),

              // Flow Rights Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.tune_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 5),
                  const Text(
                    'Flow Rights:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => _showManageRightsDialog(context, parlor),
                    borderRadius: BorderRadius.circular(6),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 12, color: AppColors.primary),
                          SizedBox(width: 3),
                          Text(
                            'Edit Rights',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: FlowTypeConstants.allFlowTypes.map((flowItem) {
                  final hasRight = FlowTypeConstants.isAllowed(parlor.allowedFlowTypes, flowItem.name);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: hasRight
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: hasRight
                            ? AppColors.primary.withValues(alpha: 0.3)
                            : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          flowItem.icon,
                          size: 11,
                          color: hasRight ? AppColors.primary : Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          flowItem.labelKey.tr,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: hasRight ? FontWeight.w600 : FontWeight.normal,
                            color: hasRight ? AppColors.primary : Colors.grey.shade400,
                            decoration: hasRight ? null : TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPill({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.store_mall_directory_outlined,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No Parlors Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add client salons with login credentials to manage them here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              controller.clearForm();
              Get.toNamed(Routes.ADD_PARLOR);
            },
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Parlor Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(ParlorModel parlor) {
    Get.defaultDialog(
      title: 'Delete Parlor',
      titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      middleText: 'Are you sure you want to delete "${parlor.parlorName}"?',
      middleTextStyle: const TextStyle(fontSize: 13),
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      radius: 12,
      onConfirm: () {
        controller.deleteParlor(parlor.id, parlor.parlorName);
        Get.back();
      },
    );
  }

  void _showManageRightsDialog(BuildContext context, ParlorModel parlor) {
    // Local state for dialog
    final RxList<String> tempRights = <String>[].obs;
    tempRights.assignAll(parlor.allowedFlowTypes);
    final RxBool isSaving = false.obs;

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.security_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Flow Rights: ${parlor.parlorName}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Toggle which booking flows this parlor can see & use',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // Select All action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text(
                        '${tempRights.length} of ${FlowTypeConstants.allFlowTypes.length} Allowed',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      )),
                  TextButton(
                    onPressed: () {
                      if (tempRights.length == FlowTypeConstants.allFlowTypes.length) {
                        tempRights.assignAll([FlowTypeConstants.walkInOrders]);
                      } else {
                        tempRights.assignAll(FlowTypeConstants.allFlowTypeNames);
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Obx(() => Text(
                          tempRights.length == FlowTypeConstants.allFlowTypes.length
                              ? 'Reset to Walk-in only'
                              : 'Select All',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Flow Items List
              Flexible(
                child: SingleChildScrollView(
                  child: Obx(() {
                    return Column(
                      children: FlowTypeConstants.allFlowTypes.map((flowItem) {
                        final isEnabled = FlowTypeConstants.isAllowed(tempRights, flowItem.name);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: isEnabled
                                ? AppColors.primary.withValues(alpha: 0.05)
                                : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isEnabled
                                  ? AppColors.primary.withValues(alpha: 0.3)
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: SwitchListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            dense: true,
                            activeTrackColor: AppColors.primary,
                            activeThumbColor: Colors.white,
                            value: isEnabled,
                            onChanged: (val) {
                              if (!val) {
                                if (tempRights.length <= 1) {
                                  Get.snackbar(
                                    'Warning',
                                    'At least one flow type right must remain enabled',
                                    snackPosition: SnackPosition.BOTTOM,
                                    duration: const Duration(seconds: 2),
                                  );
                                  return;
                                }
                                tempRights.removeWhere((item) =>
                                    item.trim().toLowerCase() == flowItem.name.trim().toLowerCase() ||
                                    (item.toLowerCase().contains('advance') && flowItem.name.toLowerCase().contains('advance')));
                              } else {
                                if (!FlowTypeConstants.isAllowed(tempRights, flowItem.name)) {
                                  tempRights.add(flowItem.name);
                                }
                              }
                            },
                            secondary: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: isEnabled
                                    ? AppColors.primary.withValues(alpha: 0.12)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                flowItem.icon,
                                size: 18,
                                color: isEnabled ? AppColors.primary : Colors.grey.shade500,
                              ),
                            ),
                            title: Text(
                              flowItem.labelKey.tr,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isEnabled ? AppColors.textPrimaryLight : Colors.grey.shade600,
                              ),
                            ),
                            subtitle: Text(
                              flowItem.description,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 14),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Obx(() => ElevatedButton(
                          onPressed: isSaving.value
                              ? null
                              : () async {
                                  isSaving.value = true;
                                  final ok = await controller.updateParlorFlowRights(
                                    parlor.id,
                                    List<String>.from(tempRights),
                                  );
                                  isSaving.value = false;
                                  if (ok) {
                                    Get.back();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: isSaving.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Save Rights',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                ),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
