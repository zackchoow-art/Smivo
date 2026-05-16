import os
import re

replacements = {
    'lib/features/admin/screens/admin_faqs_screen.dart': [
        ('color: Color(0xFFEA580C)', 'color: colors.warning')
    ],
    'lib/features/admin/screens/admin_schools_screen.dart': [
        ('color: Color(0xFF2563EB)', 'color: colors.primary')
    ],
    'lib/features/admin/screens/admin_pickup_locations_screen.dart': [
        ('color: Color(0xFF059669)', 'color: colors.success')
    ],
    'lib/features/admin/screens/admin_conditions_screen.dart': [
        ('color: Color(0xFF7C3AED)', 'color: colors.primary')
    ],
    'lib/shared/widgets/user_reviews_bottom_sheet.dart': [
        ('color: Colors.amber', 'color: colors.warning')
    ],
    'lib/shared/widgets/order_review_form.dart': [
        ('color: Colors.amber', 'color: colors.warning'),
        ('color: Colors.white', 'color: colors.onPrimary')
    ],
    'lib/shared/widgets/navigation_rail_bar.dart': [
        ('style: TextStyle(fontSize: 9, color: colors.onPrimary)', 'style: typo.labelSmall.copyWith(fontSize: 9, color: colors.onPrimary)')
    ],
    'lib/shared/widgets/action_error_dialog.dart': [
        ('style: TextStyle(color: colors.onPrimary)', 'style: typo.labelLarge.copyWith(color: colors.onPrimary)')
    ],
    'lib/shared/widgets/action_success_dialog.dart': [
        ('style: TextStyle(color: colors.onPrimary)', 'style: typo.labelLarge.copyWith(color: colors.onPrimary)')
    ],
    'lib/shared/widgets/message_badge_icon.dart': [
        ('style: TextStyle(', 'style: typo.labelSmall.copyWith(')
    ],
    'lib/shared/widgets/smivo_user_avatar.dart': [
        ('color: Colors.green', 'color: colors.success')
    ],
    'lib/shared/widgets/moderation_aware_image.dart': [
        ('color: Colors.grey[200]', 'color: colors.surfaceContainerHigh'),
        ('color: Colors.grey[100]', 'color: colors.surfaceContainer'),
        ('color: Colors.grey', 'color: colors.outlineVariant'),
        ('color: Colors.black.withValues(alpha: 0.4)', 'color: colors.shadow.withValues(alpha: 0.4)'),
        ('color: Colors.white', 'color: colors.surfaceContainerLowest'),
        ('style: const TextStyle(', 'style: typo.bodyMedium.copyWith('),
        ('style: const TextStyle(\n', 'style: typo.bodyMedium.copyWith(\n')
    ],
    'lib/shared/widgets/themed_confirm_dialog.dart': [
        ('style: TextStyle(color: colors.onSurfaceVariant)', 'style: typo.bodyMedium.copyWith(color: colors.onSurfaceVariant)'),
        ('style: TextStyle(color: confirmTextColor)', 'style: typo.labelLarge.copyWith(color: confirmTextColor)')
    ],
    'lib/shared/widgets/floating_quick_nav.dart': [
        ('color: Colors.black.withValues(alpha: 0.25)', 'color: colors.shadow.withValues(alpha: 0.25)'),
        ('color: Colors.black.withValues(alpha: 0.15)', 'color: colors.shadow.withValues(alpha: 0.15)')
    ],
    'lib/shared/widgets/fullscreen_image_viewer.dart': [
        ('color: Colors.white', 'color: colors.surfaceContainerLowest'),
        ('color: Colors.grey', 'color: colors.outlineVariant'),
        ('color: Colors.black', 'color: colors.onSurface'),
        ('style: const TextStyle(color: Colors.grey, fontSize: 14)', 'style: typo.bodyMedium.copyWith(color: colors.outlineVariant)'),
        ('style: const TextStyle(', 'style: typo.bodyMedium.copyWith(')
    ]
}

def fix_files():
    base_dir = '/Users/george/smivo/app'
    for rel_path, changes in replacements.items():
        full_path = os.path.join(base_dir, rel_path)
        if not os.path.exists(full_path):
            print(f"File not found: {full_path}")
            continue
        
        with open(full_path, 'r') as f:
            content = f.read()
            
        new_content = content
        for old_str, new_str in changes:
            new_content = new_content.replace(old_str, new_str)
            
        if new_content != content:
            with open(full_path, 'w') as f:
                f.write(new_content)
            print(f"Updated {rel_path}")
        else:
            print(f"No changes needed in {rel_path} (maybe already fixed)")

if __name__ == '__main__':
    fix_files()
