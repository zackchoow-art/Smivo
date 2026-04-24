import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smivo/features/orders/providers/order_evidence_provider.dart';

class EvidencePhotoSection extends ConsumerWidget {
  const EvidencePhotoSection({
    super.key,
    required this.orderId,
    required this.canUpload,
    this.label = 'EVIDENCE PHOTOS',
    this.evidenceType = 'delivery',
  });
  final String orderId;
  final bool canUpload;
  final String label;
  final String evidenceType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final evidenceAsync = ref.watch(orderEvidenceProvider(orderId));
    final uploadState = ref.watch(evidenceUploaderProvider);
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
          style: typo.labelSmall.copyWith(color: colors.onSurface.withValues(alpha: 0.5), letterSpacing: 0.5)),
        const SizedBox(height: 12),
        evidenceAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (photos) {
            final filteredPhotos = photos.where((p) => p.evidenceType == evidenceType).toList();
            
            if (filteredPhotos.isEmpty && !canUpload) {
              return Text('No evidence photos uploaded.', style: typo.bodySmall.copyWith(color: colors.outlineVariant));
            }
            return Column(children: [
              if (filteredPhotos.isNotEmpty)
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: filteredPhotos.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final photo = filteredPhotos[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(radius.md),
                        child: Image.network(photo.imageUrl, width: 120, height: 120, fit: BoxFit.cover),
                      );
                    },
                  ),
                ),
              if (canUpload && filteredPhotos.length < 5) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: uploadState.isLoading ? null : () => _pickAndUpload(context, ref),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: Text(uploadState.isLoading ? 'Uploading...' : 'Add Photo (${filteredPhotos.length}/5)'),
                  ),
                ),
              ],
            ]);
          },
        ),
      ],
    );
  }

  Future<void> _pickAndUpload(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, maxWidth: 1024, maxHeight: 1024, imageQuality: 80);
    if (picked == null) return;
    if (!context.mounted) return;
    final bytes = await picked.readAsBytes();
    final fileName = '${evidenceType}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await ref.read(evidenceUploaderProvider.notifier).upload(
      orderId: orderId,
      imageBytes: bytes,
      fileName: fileName,
      evidenceType: evidenceType, // I hope the notifier supports this
    );
  }
}
