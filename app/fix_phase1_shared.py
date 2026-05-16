import os

replacements = {
    'lib/features/shared/widgets/user_reviews_bottom_sheet.dart': [
        ('color: Colors.amber', 'color: colors.warning')
    ],
    'lib/features/shared/widgets/order_review_form.dart': [
        ('color: Colors.amber', 'color: colors.warning'),
        ('color: Colors.white', 'color: colors.onPrimary')
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
