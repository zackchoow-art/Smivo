# Report 018: Evidence Photo Upload for Orders

## Files Created
1. `supabase/migrations/00020_order_evidence.sql`
2. `lib/data/models/order_evidence.dart`
3. `lib/data/repositories/order_evidence_repository.dart`
4. `lib/features/orders/providers/order_evidence_provider.dart`
5. `lib/features/orders/widgets/evidence_photo_section.dart`

## Files Modified
1. `lib/core/constants/app_constants.dart`
2. `lib/features/orders/screens/order_detail_screen.dart`

## Changes Implemented
- **Database Schema**: Created the `order_evidence` table with RLS policies and a dedicated `order-evidence` storage bucket for secure image hosting.
- **Data Model**: Implemented the `OrderEvidence` model using Freezed for immutable delivery proof records.
- **Repository Layer**: Developed `OrderEvidenceRepository` to handle binary uploads to Supabase Storage and manage database entries for evidence metadata.
- **State Management**: Created `orderEvidenceProvider` (fetching) and `EvidenceUploader` (upload mutation) to provide reactive access to proof-of-delivery photos.
- **UI Components**:
    - **EvidencePhotoSection**: A new widget that allows users to capture up to 5 photos using the device camera. It displays a horizontal preview of uploaded evidence.
    - **Integration**: Injected the evidence section into the `OrderDetailScreen`, visible only when the order is confirmed or completed.
- **Handover Security**: Both buyers and sellers can now document the condition of items before finalizing delivery, significantly enhancing trust in the marketplace.

## Verification Results
- `dart run build_runner build`: **Success**
- `flutter analyze`: **No issues found!**
