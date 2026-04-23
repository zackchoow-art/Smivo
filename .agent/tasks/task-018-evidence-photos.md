# Task 018: Evidence Photo Upload for Orders

## Objective
Allow buyers and sellers to upload up to 5 evidence photos before
confirming delivery on an order. Photos are stored in Supabase Storage
and referenced in a new `order_evidence` table.

## Files to create/modify:

### CREATE:
1. `supabase/migrations/00020_order_evidence.sql`
2. `lib/data/models/order_evidence.dart`
3. `lib/data/repositories/order_evidence_repository.dart`
4. `lib/features/orders/providers/order_evidence_provider.dart`
5. `lib/features/orders/widgets/evidence_photo_section.dart`

### MODIFY:
6. `lib/features/orders/screens/order_detail_screen.dart`
7. `lib/core/constants/app_constants.dart` — add table name

### RUN:
8. `dart run build_runner build --delete-conflicting-outputs`

**DO NOT** modify any other files.

---

## Step 1: Create DB migration

Create `supabase/migrations/00020_order_evidence.sql`:

```sql
-- ════════════════════════════════════════════════════════════
-- 00020: Order Evidence Photos
--
-- Storage for delivery evidence photos that buyers/sellers
-- can upload before confirming delivery.
-- ════════════════════════════════════════════════════════════

-- Evidence photos table
CREATE TABLE public.order_evidence (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id    uuid        NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  uploader_id uuid        NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  image_url   text        NOT NULL,
  caption     text,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER order_evidence_updated_at
  BEFORE UPDATE ON public.order_evidence
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE INDEX idx_order_evidence_order ON public.order_evidence(order_id);

ALTER TABLE public.order_evidence ENABLE ROW LEVEL SECURITY;

-- Participants can view evidence for their orders
CREATE POLICY "Order participants can view evidence"
  ON public.order_evidence FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE orders.id = order_evidence.order_id
      AND (orders.buyer_id = auth.uid() OR orders.seller_id = auth.uid())
    )
  );

-- Authenticated users can upload evidence for their orders
CREATE POLICY "Order participants can upload evidence"
  ON public.order_evidence FOR INSERT
  WITH CHECK (
    auth.uid() = uploader_id
    AND EXISTS (
      SELECT 1 FROM public.orders
      WHERE orders.id = order_evidence.order_id
      AND (orders.buyer_id = auth.uid() OR orders.seller_id = auth.uid())
    )
  );

-- Create storage bucket for evidence photos
INSERT INTO storage.buckets (id, name, public)
VALUES ('order-evidence', 'order-evidence', true)
ON CONFLICT (id) DO NOTHING;

-- Public read for evidence photos
CREATE POLICY "Public read for order evidence"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'order-evidence');

-- Authenticated upload to order-evidence
CREATE POLICY "Authenticated upload to order-evidence"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'order-evidence'
    AND auth.role() = 'authenticated'
  );
```

**⚠️ NOTE TO USER**: This SQL must be manually executed in Supabase.

## Step 2: Add constant

In `lib/core/constants/app_constants.dart`, add:

```dart
  static const String tableOrderEvidence = 'order_evidence';
  static const String bucketOrderEvidence = 'order-evidence';
```

## Step 3: Create order_evidence.dart model

Create `lib/data/models/order_evidence.dart`:

```dart
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smivo/data/models/user_profile.dart';

part 'order_evidence.freezed.dart';
part 'order_evidence.g.dart';

/// Represents a photo uploaded as delivery evidence.
@freezed
abstract class OrderEvidence with _$OrderEvidence {
  const factory OrderEvidence({
    required String id,
    @JsonKey(name: 'order_id') required String orderId,
    @JsonKey(name: 'uploader_id') required String uploaderId,
    @JsonKey(name: 'image_url') required String imageUrl,
    String? caption,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    UserProfile? uploader,
  }) = _OrderEvidence;

  factory OrderEvidence.fromJson(Map<String, dynamic> json) =>
      _$OrderEvidenceFromJson(json);
}
```

## Step 4: Create order_evidence_repository.dart

Create `lib/data/repositories/order_evidence_repository.dart`:

```dart
import 'dart:typed_data';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:smivo/core/constants/app_constants.dart';
import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/order_evidence.dart';

part 'order_evidence_repository.g.dart';

class OrderEvidenceRepository {
  const OrderEvidenceRepository(this._client);
  final SupabaseClient _client;

  /// Fetches all evidence photos for an order.
  Future<List<OrderEvidence>> fetchEvidence(String orderId) async {
    try {
      final data = await _client
          .from(AppConstants.tableOrderEvidence)
          .select('*, uploader:user_profiles!uploader_id(*)')
          .eq('order_id', orderId)
          .order('created_at', ascending: true);
      return data.map((json) => OrderEvidence.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Uploads an evidence photo and creates a record.
  Future<OrderEvidence> uploadEvidence({
    required String orderId,
    required String uploaderId,
    required Uint8List imageBytes,
    required String fileName,
    String? caption,
  }) async {
    try {
      // Upload to storage
      final path = '$orderId/$uploaderId/$fileName';
      await _client.storage
          .from(AppConstants.bucketOrderEvidence)
          .uploadBinary(path, imageBytes);

      final imageUrl = _client.storage
          .from(AppConstants.bucketOrderEvidence)
          .getPublicUrl(path);

      // Create DB record
      final data = await _client
          .from(AppConstants.tableOrderEvidence)
          .insert({
            'order_id': orderId,
            'uploader_id': uploaderId,
            'image_url': imageUrl,
            'caption': caption,
          })
          .select()
          .single();
      return OrderEvidence.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    } on StorageException catch (e) {
      throw AppStorageException(e.message, e);
    }
  }
}

@riverpod
OrderEvidenceRepository orderEvidenceRepository(Ref ref) =>
    OrderEvidenceRepository(ref.watch(supabaseClientProvider));
```

## Step 5: Create order_evidence_provider.dart

Create `lib/features/orders/providers/order_evidence_provider.dart`:

```dart
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/order_evidence.dart';
import 'package:smivo/data/repositories/order_evidence_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';

part 'order_evidence_provider.g.dart';

/// Fetches evidence photos for a specific order.
@riverpod
Future<List<OrderEvidence>> orderEvidence(Ref ref, String orderId) async {
  final repo = ref.watch(orderEvidenceRepositoryProvider);
  return repo.fetchEvidence(orderId);
}

/// Mutation provider for uploading evidence.
@riverpod
class EvidenceUploader extends _$EvidenceUploader {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> upload({
    required String orderId,
    required Uint8List imageBytes,
    required String fileName,
    String? caption,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) throw StateError('Must be logged in');

      final repo = ref.read(orderEvidenceRepositoryProvider);
      await repo.uploadEvidence(
        orderId: orderId,
        uploaderId: user.id,
        imageBytes: imageBytes,
        fileName: fileName,
        caption: caption,
      );

      // Refresh the evidence list
      ref.invalidate(orderEvidenceProvider(orderId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
```

## Step 6: Create evidence_photo_section.dart widget

Create `lib/features/orders/widgets/evidence_photo_section.dart`:

```dart
import 'package:flutter/foundation.dart';
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
```

## Step 7: Integrate into order_detail_screen.dart

In the `_buildBody` method, add the evidence section before the action
buttons. Find the line:

```dart
          _buildActions(context, ref, order, isBuyer, isSeller, isActing),
```

Add before it:

```dart
          // Evidence Photos
          if (order.status == 'confirmed' || order.status == 'completed')
            ...[
              EvidencePhotoSection(
                orderId: order.id,
                canUpload: order.status == 'confirmed' &&
                    (isBuyer || isSeller),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
```

Add the import at top:
```dart
import 'package:smivo/features/orders/widgets/evidence_photo_section.dart';
```

## Step 8: Run build_runner

```bash
cd /Users/george/smivo && dart run build_runner build --delete-conflicting-outputs
```

## Step 9: Verify

```bash
cd /Users/george/smivo && flutter analyze
```

Report ONLY errors. Write report to `.agent/reports/report-018.md`.
