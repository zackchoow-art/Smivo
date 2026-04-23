import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/features/settings/providers/profile_provider.dart';
import 'package:smivo/shared/widgets/custom_app_bar.dart';

class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileFormProvider);
    final notifier = ref.read(profileFormProvider.notifier);
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Profile', style: typo.headlineLarge.copyWith(color: colors.settingsText, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('Manage your campus identity.', style: typo.bodyMedium.copyWith(color: colors.settingsTextSecondary)),
              const SizedBox(height: 32),
              // Top Card: Avatar & Verification
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(radius.xl),
                  boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(children: [
                  Stack(children: [
                    const CircleAvatar(radius: 50, backgroundImage: NetworkImage('https://i.pravatar.cc/300?u=alex')),
                    Positioned(right: 0, bottom: 0, child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: colors.surfaceContainerLowest, shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 4, offset: const Offset(0, 2))]),
                      child: Icon(Icons.edit, size: 16, color: colors.settingsIcon),
                    )),
                  ]),
                  const SizedBox(height: 24),
                  Text('Student Verification', style: typo.titleMedium.copyWith(color: colors.settingsText, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text('Verify your .edu email to access exclusive\ncampus features.',
                    textAlign: TextAlign.center, style: typo.bodySmall.copyWith(color: colors.settingsTextSecondary, height: 1.3)),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: colors.successContainer, borderRadius: BorderRadius.circular(16)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.verified, color: colors.success, size: 16),
                        const SizedBox(width: 4),
                        Text('Verified', style: typo.labelSmall.copyWith(color: colors.success, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                    const SizedBox(width: 8),
                    Text('alex.smith@university.edu', style: typo.bodySmall.copyWith(color: colors.settingsText.withValues(alpha: 0.8))),
                  ]),
                  const SizedBox(height: 16),
                  TextButton(onPressed: () {},
                    child: Text('Change Email', style: typo.labelLarge.copyWith(color: colors.settingsIcon, fontWeight: FontWeight.w700))),
                ]),
              ),
              const SizedBox(height: 24),
              // Form Fields Card
              Container(
                width: double.infinity, padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(radius.xl),
                  boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildFieldLabel(context, 'Full Name'),
                  _buildTextField(context, initialValue: profile['fullName'], onChanged: (val) => notifier.updateField('fullName', val)),
                  const SizedBox(height: 20),
                  _buildFieldLabel(context, 'Display Name'),
                  _buildTextField(context, initialValue: profile['displayName'], prefixText: '@ ', onChanged: (val) => notifier.updateField('displayName', val)),
                  const SizedBox(height: 8),
                  Text('This is how you will appear to other\nstudents.', style: typo.bodySmall.copyWith(color: colors.settingsTextSecondary, height: 1.3)),
                  const SizedBox(height: 20),
                  _buildFieldLabel(context, 'Major'),
                  _buildTextField(context, initialValue: profile['major'], onChanged: (val) => notifier.updateField('major', val)),
                  const SizedBox(height: 20),
                  _buildFieldLabel(context, 'Graduation Year'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: colors.settingsIconBg, borderRadius: BorderRadius.circular(radius.card)),
                    child: DropdownButtonHideUnderline(child: DropdownButton<String>(
                      value: profile['gradYear'], isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down, color: colors.settingsText),
                      items: ['2024', '2025', '2026', '2027'].map((year) =>
                        DropdownMenuItem(value: year, child: Text(year, style: typo.bodyLarge.copyWith(color: colors.settingsText)))).toList(),
                      onChanged: (val) { if (val != null) notifier.updateField('gradYear', val); },
                    )),
                  ),
                  const SizedBox(height: 32),
                  Divider(color: colors.dividerColor),
                  const SizedBox(height: 24),
                  Row(children: [
                    Expanded(child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: colors.dividerColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius.md)),
                      ),
                      child: Text('Cancel', style: typo.labelLarge.copyWith(color: colors.settingsIcon, fontWeight: FontWeight.w700)),
                    )),
                    const SizedBox(width: 16),
                    Expanded(child: ElevatedButton(
                      onPressed: () { notifier.save(); context.pop(); },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16), elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius.md)),
                      ),
                      child: Text('Save', style: typo.labelLarge.copyWith(color: colors.onPrimary, fontWeight: FontWeight.w700)),
                    )),
                  ]),
                ]),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(BuildContext context, String label) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    return Padding(padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: typo.bodyMedium.copyWith(color: colors.settingsText, fontWeight: FontWeight.w700)));
  }

  Widget _buildTextField(BuildContext context, {required String? initialValue, required ValueChanged<String> onChanged, String? prefixText}) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    return TextFormField(
      initialValue: initialValue, onChanged: onChanged,
      style: typo.bodyLarge.copyWith(color: colors.settingsText),
      decoration: InputDecoration(
        prefixText: prefixText,
        prefixStyle: typo.bodyLarge.copyWith(color: colors.settingsText.withValues(alpha: 0.5)),
        filled: true, fillColor: colors.settingsIconBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius.card), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
