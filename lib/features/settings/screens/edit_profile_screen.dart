import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/features/settings/providers/profile_provider.dart';
import 'package:smivo/shared/widgets/custom_app_bar.dart';

class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileFormProvider);
    final notifier = ref.read(profileFormProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Profile',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: const Color(0xFF2B2A51),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your campus identity.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: const Color(0xFF2B2A51).withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),
              
              // Top Card: Avatar & Verification
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar with edit badge
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage('https://i.pravatar.cc/300?u=alex'),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.edit, size: 16, color: Color(0xFF013DFD)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Student Verification',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: const Color(0xFF2B2A51),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Verify your .edu email to access exclusive\ncampus features.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF2B2A51).withOpacity(0.7),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCCF7E5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified, color: Color(0xFF00A86B), size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: const Color(0xFF00A86B),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'alex.smith@university.edu',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFF2B2A51).withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Change Email',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: const Color(0xFF013DFD),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Form Fields Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Full Name'),
                    _buildTextField(
                      initialValue: profile['fullName'],
                      onChanged: (val) => notifier.updateField('fullName', val),
                    ),
                    const SizedBox(height: 20),
                    
                    _buildFieldLabel('Display Name'),
                    _buildTextField(
                      initialValue: profile['displayName'],
                      prefixText: '@ ',
                      onChanged: (val) => notifier.updateField('displayName', val),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This is how you will appear to other\nstudents.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF2B2A51).withOpacity(0.6),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    _buildFieldLabel('Major'),
                    _buildTextField(
                      initialValue: profile['major'],
                      onChanged: (val) => notifier.updateField('major', val),
                    ),
                    const SizedBox(height: 20),
                    
                    _buildFieldLabel('Graduation Year'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2EFFF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: profile['gradYear'],
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF2B2A51)),
                          items: ['2024', '2025', '2026', '2027']
                              .map((year) => DropdownMenuItem(
                                    value: year,
                                    child: Text(
                                      year,
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: const Color(0xFF2B2A51),
                                      ),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              notifier.updateField('gradYear', val);
                            }
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    const Divider(color: Color(0xFFE2DFFF)),
                    const SizedBox(height: 24),
                    
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Color(0xFFE2DFFF)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: const Color(0xFF013DFD),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              notifier.save();
                              context.pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF436BFF),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Save',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: const Color(0xFF2B2A51),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String? initialValue,
    required ValueChanged<String> onChanged,
    String? prefixText,
  }) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      style: AppTextStyles.bodyLarge.copyWith(
        color: const Color(0xFF2B2A51),
      ),
      decoration: InputDecoration(
        prefixText: prefixText,
        prefixStyle: AppTextStyles.bodyLarge.copyWith(
          color: const Color(0xFF2B2A51).withOpacity(0.5),
        ),
        filled: true,
        fillColor: const Color(0xFFF2EFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
