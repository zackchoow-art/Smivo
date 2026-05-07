import re

file_path = 'app/lib/features/listing/screens/create_listing_form_screen.dart'

with open(file_path, 'r') as f:
    content = f.read()

# 1. CustomTextFields
content = content.replace(
    "CustomTextField(\n                        label: 'Item Title',",
    "CustomTextField(\n                        label: 'Item Title',\n                        icon: Icons.title_outlined,"
)
content = content.replace(
    "CustomTextField(\n                        label: 'Item Description',",
    "CustomTextField(\n                        label: 'Item Description',\n                        icon: Icons.description_outlined,"
)
content = content.replace(
    "CustomTextField(\n                          label: 'Price',",
    "CustomTextField(\n                          label: 'Price',\n                          icon: Icons.sell_outlined,"
)

# Helper function to replace Text blocks
def replace_text_with_row(text, icon):
    pattern = r"Text\(\n\s*'" + text + r"',\n\s*style: typo\.labelLarge\.copyWith\(\n\s*fontWeight: FontWeight\.bold,\n\s*color: colors\.onSurface,\n\s*\),\n\s*\),"
    replacement = f"""Row(
                        children: [
                          Icon({icon}, size: 18, color: colors.onSurface),
                          const SizedBox(width: 6),
                          Text(
                            '{text}',
                            style: typo.labelLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.onSurface,
                            ),
                          ),
                        ],
                      ),"""
    return re.sub(pattern, replacement, content)

content = replace_text_with_row('Category', 'Icons.category_outlined')
content = replace_text_with_row('Condition', 'Icons.verified_outlined')
content = replace_text_with_row('Rental Pricing', 'Icons.request_quote_outlined')
content = replace_text_with_row('Security Deposit', 'Icons.shield_outlined')
content = replace_text_with_row('Pickup Location', 'Icons.location_on_outlined')
content = replace_text_with_row('Available Date', 'Icons.calendar_today_outlined')

# 2. Campus header inside Consumer
campus_pattern = r"Text\(\n\s*'Campus: \$\{school\.name\}',\n\s*style: typo\.labelLarge\.copyWith\(\n\s*fontWeight: FontWeight\.bold,\n\s*color: colors\.onSurface,\n\s*\),\n\s*\),"
campus_replacement = """Row(
                                  children: [
                                    Icon(Icons.school_outlined, size: 18, color: colors.onSurface),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Campus: ${school.name}',
                                      style: typo.labelLarge.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colors.onSurface,
                                      ),
                                    ),
                                  ],
                                ),"""
content = re.sub(campus_pattern, campus_replacement, content)

with open(file_path, 'w') as f:
    f.write(content)

# Now apply similar changes to listing_detail_screen.dart
file_path2 = 'app/lib/features/listing/screens/listing_detail_screen.dart'
with open(file_path2, 'r') as f:
    content2 = f.read()

def replace_text_with_row2(text, icon):
    pattern = r"Text\(\n\s*'" + text + r"',\n\s*style: typo\.labelLarge\.copyWith\(\n\s*fontWeight: FontWeight\.bold,\n\s*color: colors\.onSurface,\n\s*\),\n\s*\),"
    replacement = f"""Row(
                                            children: [
                                              Icon({icon}, size: 18, color: colors.onSurface),
                                              const SizedBox(width: 6),
                                              Text(
                                                '{text}',
                                                style: typo.labelLarge.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: colors.onSurface,
                                                ),
                                              ),
                                            ],
                                          ),"""
    return re.sub(pattern, replacement, content2)

content2 = replace_text_with_row2('Description', 'Icons.description_outlined')
content2 = replace_text_with_row2('Pickup Location', 'Icons.location_on_outlined')

campus_pattern2 = r"Text\(\n\s*'Campus: \$schoolName',\n\s*style: typo\.labelLarge\.copyWith\(\n\s*fontWeight: FontWeight\.bold,\n\s*color: colors\.onSurface,\n\s*\),\n\s*\),"
campus_replacement2 = """Row(
                                                children: [
                                                  Icon(Icons.school_outlined, size: 18, color: colors.onSurface),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'Campus: $schoolName',
                                                    style: typo.labelLarge.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                      color: colors.onSurface,
                                                    ),
                                                  ),
                                                ],
                                              ),"""
content2 = re.sub(campus_pattern2, campus_replacement2, content2)

change_pattern = r"Text\(\n\s*_showChangeAddress\n\s*\? 'Cancel address change'\n\s*: 'Change pickup address',\n\s*style: typo\.labelLarge\.copyWith\(\n\s*fontWeight: FontWeight\.bold,\n\s*color: colors\.onSurface,\n\s*\),\n\s*\),"
change_replacement = """Row(
                                                    children: [
                                                      Icon(
                                                        _showChangeAddress
                                                            ? Icons.expand_less
                                                            : Icons.edit_location_alt_outlined,
                                                        size: 18,
                                                        color: colors.onSurface,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        _showChangeAddress
                                                            ? 'Cancel address change'
                                                            : 'Change pickup address',
                                                        style: typo.labelLarge.copyWith(
                                                          fontWeight: FontWeight.bold,
                                                          color: colors.onSurface,
                                                        ),
                                                      ),
                                                    ],
                                                  ),"""
content2 = re.sub(change_pattern, change_replacement, content2)

buyer_campus_pattern = r"Text\(\n\s*'Campus: \$\{school\.name\}',\n\s*style: typo\.labelLarge\.copyWith\(\n\s*fontWeight: FontWeight\.bold,\n\s*color: colors\.onSurface,\n\s*\),\n\s*\),"
buyer_campus_replacement = """Row(
                                                          children: [
                                                            Icon(Icons.school_outlined, size: 18, color: colors.onSurface),
                                                            const SizedBox(width: 6),
                                                            Text(
                                                              'Campus: ${school.name}',
                                                              style: typo.labelLarge.copyWith(
                                                                fontWeight: FontWeight.bold,
                                                                color: colors.onSurface,
                                                              ),
                                                            ),
                                                          ],
                                                        ),"""
content2 = re.sub(buyer_campus_pattern, buyer_campus_replacement, content2)

# Also remove the existing Icon that is next to "Pickup Location" in listing_detail_screen.dart
# The existing layout is:
# Row(
#   crossAxisAlignment: CrossAxisAlignment.start,
#   children: [
#     Icon(Icons.location_on_outlined, color: colors.priceAccent),
#     const SizedBox(width: 8),
#     Expanded( Column( ... Text('Pickup Location') ... ) )
#   ]
# )
# And similarly for Change pickup address:
# Row(children: [ Icon(_showChangeAddress ? ... ), SizedBox, Text(...) ])
# Let's write a targeted replace for these:
old_pickup_icon_pattern = r"Icon\(\n\s*Icons\.location_on_outlined,\n\s*color: colors\.priceAccent,\n\s*\),\n\s*const SizedBox\(width: 8\),\n\s*"
content2 = re.sub(old_pickup_icon_pattern, "", content2)

old_change_icon_pattern = r"Icon\(\n\s*_showChangeAddress\n\s*\? Icons\.expand_less\n\s*: Icons\n\s*\.edit_location_alt_outlined,\n\s*size: 16,\n\s*color: colors\.primary,\n\s*\),\n\s*const SizedBox\(width: 4\),\n\s*"
content2 = re.sub(old_change_icon_pattern, "", content2)

with open(file_path2, 'w') as f:
    f.write(content2)

print("done")
