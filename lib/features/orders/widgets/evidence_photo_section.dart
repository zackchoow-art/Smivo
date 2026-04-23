import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_spacing.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/features/orders/providers/order_evidence_provider.dart';

class EvidencePhotoSection extends ConsumerWidget {
  const EvidencePhotoSection({
    super.key,
    required this.orderId,
    required this.canUpload,
  });

  final String orderId;
  final bool canUpload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final evidenceAsync = ref.watch(orderEvidenceProvider(orderId));
    final uploadState = ref.watch(evidenceUploaderProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('EVIDENCE PHOTOS',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.5),
              letterSpacing: 0.5,
            )),
        const SizedBox(height: AppSpacing.md),

        evidenceAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (photos) {
            if (photos.isEmpty && !canUpload) {
              return Text(
                'No evidence photos uploaded.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.outlineVariant),
              );
            }

            return Column(
              children: [
                if (photos.isNotEmpty)
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: photos.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final photo = photos[index];
                        return ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                          child: Image.network(
                            photo.imageUrl,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                if (canUpload && photos.length < 5) ...[
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: uploadState.isLoading
                          ? null
                          : () => _pickAndUpload(context, ref),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: Text(
                        uploadState.isLoading
                            ? 'Uploading...'
                            : 'Add Evidence Photo (${photos.length}/5)',
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _pickAndUpload(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (picked == null) return;
    if (!context.mounted) return;

    final bytes = await picked.readAsBytes();
    final fileName =
        'evidence_${DateTime.now().millisecondsSinceEpoch}.jpg';

    await ref.read(evidenceUploaderProvider.notifier).upload(
          orderId: orderId,
          imageBytes: bytes,
          fileName: fileName,
        );
  }
}
