with open('app/lib/features/listing/screens/create_listing_form_screen.dart', 'r') as f:
    content = f.read()

old_block = '''                      CheckboxListTile(
                        title: const Text('Allow buyer to change pickup address'),
                        value: _allowBuyerToSuggest,
                        onChanged: (v) =>
                            setState(() => _allowBuyerToSuggest = v ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      // Display current user's school — always visible below
                      // the address selector, separate from the address text.
                      // This is intentionally read-only context for the seller.
                      Consumer(
                        builder: (context, ref, _) {
                          final schoolAsync = ref.watch(mySchoolProvider);
                          return schoolAsync.when(
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                            data: (school) {
                              if (school == null) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 4, bottom: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.school_outlined,
                                      size: 14,
                                      color: colors.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '校园：${school.name}',
                                      style: typo.bodySmall.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),'''

new_block = '''                      // Display current user's school — always visible below
                      // the address selector, separate from the address text.
                      // This is intentionally read-only context for the seller.
                      Consumer(
                        builder: (context, ref, _) {
                          final schoolAsync = ref.watch(mySchoolProvider);
                          return schoolAsync.when(
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                            data: (school) {
                              if (school == null) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 8, bottom: 4),
                                child: Text(
                                  'Campus: ${school.name}',
                                  style: typo.labelLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.onSurface,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('Allow buyer to change pickup address'),
                        value: _allowBuyerToSuggest,
                        onChanged: (v) =>
                            setState(() => _allowBuyerToSuggest = v ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),'''

if old_block in content:
    content = content.replace(old_block, new_block)
    with open('app/lib/features/listing/screens/create_listing_form_screen.dart', 'w') as f:
        f.write(content)
    print("create_form patched successfully")
else:
    print("Could not find old_block in create_form")
