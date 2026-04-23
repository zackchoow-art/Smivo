import 'dart:io' as io;
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/features/listing/providers/create_listing_provider.dart';

class PhotoPickerSection extends ConsumerWidget {
  const PhotoPickerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(listingPhotosProvider);
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    if (photos.isEmpty) {
      return GestureDetector(
        onTap: () => ref.read(listingPhotosProvider.notifier).addPhoto(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 48),
          decoration: BoxDecoration(color: colors.surfaceContainerLow, borderRadius: BorderRadius.circular(radius.lg)),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: colors.surfaceContainerLowest, shape: BoxShape.circle),
              child: Icon(Icons.camera_alt_outlined, color: colors.primary),
            ),
            const SizedBox(height: 12),
            Text('Add Photos', style: typo.titleMedium.copyWith(fontWeight: FontWeight.bold, color: colors.onSurface)),
            const SizedBox(height: 4),
            Text("Up to 5 images. Make 'em pop.", style: typo.bodyMedium.copyWith(color: colors.onSurface.withValues(alpha: 0.6))),
          ]),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length < 5 ? photos.length + 1 : photos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == photos.length) {
            return GestureDetector(
              onTap: () => ref.read(listingPhotosProvider.notifier).addPhoto(context),
              child: Container(
                width: 120,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(radius.lg),
                  border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
                ),
                child: Center(child: Icon(Icons.add, color: colors.primary, size: 32)),
              ),
            );
          }
          final photo = photos[index];
          return Stack(clipBehavior: Clip.none, children: [
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius.lg),
                image: DecorationImage(
                  image: kIsWeb ? NetworkImage(photo.path) : FileImage(io.File(photo.path)) as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (index == 0)
              Positioned(bottom: 8, left: 8, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(4)),
                child: Text('COVER', style: typo.labelSmall.copyWith(color: Colors.white)),
              )),
            Positioned(top: -8, right: -8, child: GestureDetector(
              onTap: () => ref.read(listingPhotosProvider.notifier).removePhoto(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: colors.error, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            )),
          ]);
        },
      ),
    );
  }
}
