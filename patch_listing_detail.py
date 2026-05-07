import re

with open('app/lib/features/listing/screens/listing_detail_screen.dart', 'r') as f:
    content = f.read()

# 1. DESCRIPTION
content = content.replace(
'''                                  Text(
                                    'DESCRIPTION',
                                    style: typo.labelSmall.copyWith(
                                      color: colors.onSurface.withValues(
                                        alpha: 0.5,
                                      ),
                                      letterSpacing: 0.5,
                                    ),
                                  ),''',
'''                                  Text(
                                    'Description',
                                    style: typo.labelLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colors.onSurface,
                                    ),
                                  ),'''
)

# 2. PICKUP LOCATION
content = content.replace(
'''                                          Text(
                                            'PICKUP LOCATION',
                                            style: typo.labelSmall.copyWith(
                                              color: colors.onSurface
                                                  .withValues(alpha: 0.5),
                                              letterSpacing: 0.5,
                                            ),
                                          ),''',
'''                                          Text(
                                            'Pickup Location',
                                            style: typo.labelLarge.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colors.onSurface,
                                            ),
                                          ),'''
)

# 3. Listing's campus name
content = content.replace(
'''                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 4),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.school_outlined,
                                                    size: 13,
                                                    color:
                                                        colors.onSurfaceVariant,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '校园：$schoolName',
                                                    style:
                                                        typo.bodySmall.copyWith(
                                                      color: colors
                                                          .onSurfaceVariant,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );''',
'''                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 4),
                                              child: Text(
                                                'Campus: $schoolName',
                                                style: typo.labelLarge.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: colors.onSurface,
                                                ),
                                              ),
                                            );'''
)

# 4. Change pickup address
content = content.replace(
'''                                                  Text(
                                                    _showChangeAddress
                                                        ? 'Cancel address change'
                                                        : 'Change pickup address',
                                                    style: typo.labelSmall
                                                        .copyWith(
                                                      color: colors.primary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),''',
'''                                                  Text(
                                                    _showChangeAddress
                                                        ? 'Cancel address change'
                                                        : 'Change pickup address',
                                                    style: typo.labelLarge.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                      color: colors.onSurface,
                                                    ),
                                                  ),'''
)

# 5. Buyer's campus name
content = content.replace(
'''                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 6),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .school_outlined,
                                                              size: 13,
                                                              color: colors
                                                                  .onSurfaceVariant,
                                                            ),
                                                            const SizedBox(
                                                                width: 4),
                                                            Text(
                                                              '校园：${school.name}',
                                                              style: typo
                                                                  .bodySmall
                                                                  .copyWith(
                                                                color: colors
                                                                    .onSurfaceVariant,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );''',
'''                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 6),
                                                        child: Text(
                                                          'Campus: ${school.name}',
                                                          style: typo.labelLarge.copyWith(
                                                            fontWeight: FontWeight.bold,
                                                            color: colors.onSurface,
                                                          ),
                                                        ),
                                                      );'''
)

with open('app/lib/features/listing/screens/listing_detail_screen.dart', 'w') as f:
    f.write(content)

print("listing detail patched successfully")
