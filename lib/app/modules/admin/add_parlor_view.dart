import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/flow_type_constants.dart';
import '../../core/theme/app_colors.dart';
import 'admin_controller.dart';

class AddParlorView extends GetView<AdminController> {
  const AddParlorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Add New Parlor',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimaryLight),
          onPressed: () {
            controller.clearForm();
            Get.back();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section 1: Credentials
              _buildSectionCard(
                title: 'Client Login Credentials',
                icon: Icons.lock_outline,
                children: [
                  _buildTextField(
                    controller: controller.emailController,
                    label: 'Login Email Address',
                    hint: 'e.g. blossom@gmail.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  Obx(
                    () => _buildTextField(
                      controller: controller.passwordController,
                      label: 'Password',
                      hint: 'Min. 6 characters',
                      icon: Icons.vpn_key_outlined,
                      obscureText: !controller.isPasswordVisible.value,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey,
                          size: 18,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Section 2: Parlor Details
              _buildSectionCard(
                title: 'Parlor Information',
                icon: Icons.storefront_outlined,
                children: [
                  _buildTextField(
                    controller: controller.parlorNameController,
                    label: 'Parlor / Business Name',
                    hint: 'e.g. Blossom Beauty Lounge',
                    icon: Icons.spa_outlined,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: controller.ownerNameController,
                    label: 'Owner / Contact Person',
                    hint: 'e.g. Sunita Sharma',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: controller.phoneController,
                    label: 'Contact Phone Number',
                    hint: 'e.g. 9876543210',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: controller.cityController,
                    label: 'City',
                    hint: 'e.g. Surat, Mumbai, Delhi',
                    icon: Icons.location_city_outlined,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: controller.addressController,
                    label: 'Full Address',
                    hint: 'Shop No., Complex, Area',
                    icon: Icons.location_on_outlined,
                    maxLines: 2,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Section 3: Flow Type Permissions
              _buildSectionCard(
                title: 'Flow Type Rights / Permissions',
                icon: Icons.security_rounded,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Select booking flows allowed for this parlor:',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => controller.selectAllFlowRights(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('Select All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    return Column(
                      children: FlowTypeConstants.allFlowTypes.map((flowItem) {
                        final isChecked = controller.selectedFlowRights.contains(flowItem.name);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isChecked
                                ? AppColors.primary.withValues(alpha: 0.05)
                                : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isChecked
                                  ? AppColors.primary.withValues(alpha: 0.3)
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: CheckboxListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            dense: true,
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            value: isChecked,
                            onChanged: (_) => controller.toggleFlowRight(flowItem.name),
                            secondary: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: isChecked
                                    ? AppColors.primary.withValues(alpha: 0.12)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                flowItem.icon,
                                size: 18,
                                color: isChecked ? AppColors.primary : Colors.grey.shade600,
                              ),
                            ),
                            title: Text(
                              flowItem.labelKey.tr,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isChecked ? AppColors.textPrimaryLight : Colors.grey.shade700,
                              ),
                            ),
                            subtitle: Text(
                              flowItem.description,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 24),

              // Save Button
              Obx(() {
                return SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.isAddingParlor.value
                        ? null
                        : () async {
                            final success = await controller.addParlor();
                            if (success) {
                              Get.back();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isAddingParlor.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.2,
                            ),
                          )
                        : const Text(
                            'Save & Register Parlor',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
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
              Icon(icon, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 18),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFFBFBFB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
