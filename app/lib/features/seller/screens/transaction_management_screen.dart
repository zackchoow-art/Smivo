import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smivo/core/constants/app_constants.dart';
import 'package:smivo/core/theme/breakpoints.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/utils/image_upload_service.dart';
import 'package:smivo/core/utils/price_format.dart';
import 'package:smivo/data/models/listing.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/data/repositories/chat_repository.dart';
import 'package:smivo/data/repositories/listing_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/features/orders/providers/orders_provider.dart';
import 'package:smivo/features/seller/providers/transaction_stats_provider.dart';
import 'package:smivo/features/seller/providers/listing_views_provider.dart';
import 'package:smivo/features/chat/widgets/chat_popup.dart';
import 'package:smivo/features/listing/providers/listing_detail_provider.dart';
import 'package:smivo/features/shared/providers/status_resolver_provider.dart';
import 'package:smivo/shared/widgets/action_error_dialog.dart';
import 'package:smivo/shared/widgets/action_success_dialog.dart';
import 'package:smivo/shared/widgets/content_width_constraint.dart';
import 'package:smivo/shared/widgets/pickup_address_selector.dart';
import 'package:smivo/shared/widgets/smivo_user_avatar.dart';
import 'package:smivo/shared/widgets/themed_confirm_dialog.dart';

class TransactionManagementScreen extends ConsumerStatefulWidget {
  const TransactionManagementScreen({
    super.key,
    required this.listingId,
    this.initialTab = 0,
    // NOTE: 'edit' auto-expands the Edit Listing section on screen open.
    this.initialSection = '',
  });
  final String listingId;
  final int initialTab;
  final String initialSection;

  @override
  ConsumerState<TransactionManagementScreen> createState() =>
      _TransactionManagementScreenState();
}

class _TransactionManagementScreenState
    extends ConsumerState<TransactionManagementScreen> {
  // ── Edit section state ────────────────────────────────────────
  bool _editExpanded = false;
  bool _statsExpanded = false;
  int _selectedStatsTab = 0; // 0=Views 1=Saves 2=Offers
  bool _isSaving = false;

  // Form controllers — initialised in _initEditForm()
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _depositController = TextEditingController();
  final _dailyController = TextEditingController();
  final _weeklyController = TextEditingController();
  final _monthlyController = TextEditingController();

  bool _dailyEnabled = true;
  bool _weeklyEnabled = false;
  bool _monthlyEnabled = false;
  String _selectedCondition = 'good';
  String _selectedCategory = 'other';
  String _transactionType = 'sale';
  DateTime? _availableDate;

  // NOTE: Images are split into two lists:
  //   _existingImageUrls — URLs the seller keeps (already uploaded)
  //   _newPhotos         — newly picked XFiles to upload on save
  List<String> _existingImageUrls = [];
  List<XFile> _newPhotos = [];

  // Pickup address state
  String? _selectedPickupId;
  String _customLocationNote = '';
  bool _allowPickupChange = true;
  final GlobalKey<PickupAddressSelectorState> _addressSelectorKey =
      GlobalKey<PickupAddressSelectorState>();

  // NOTE: Track whether the form has been initialised from the listing data.
  // Prevents resetting user edits on every rebuild.
  bool _formInitialised = false;

  @override
  void initState() {
    super.initState();
    // NOTE: Auto-expand the edit section when navigated with section=edit.
    _editExpanded = widget.initialSection == 'edit';
    // NOTE: If a specific tab was requested (e.g. from Listing Detail "Offers"
    // shortcut), auto-expand stats and pre-select the correct tab.
    if (widget.initialTab > 0) {
      _statsExpanded = true;
      _selectedStatsTab = widget.initialTab.clamp(0, 2);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _depositController.dispose();
    _dailyController.dispose();
    _weeklyController.dispose();
    _monthlyController.dispose();
    super.dispose();
  }

  /// Populate form fields from the loaded listing (called once on first data).
  void _initEditForm(Listing listing) {
    if (_formInitialised) return;
    _formInitialised = true;

    _titleController.text = listing.title;
    _descriptionController.text = listing.description ?? '';
    _selectedCondition = listing.condition;
    _selectedCategory = listing.category;
    _transactionType = listing.transactionType;
    _availableDate = listing.availableDate;
    _selectedPickupId = listing.pickupLocationId;
    _customLocationNote = listing.customPickupNote ?? '';
    _allowPickupChange = listing.allowPickupChange;
    _existingImageUrls =
        listing.images.map((img) => img.imageUrl).toList();

    if (listing.transactionType == 'sale') {
      // NOTE: Always pre-fill the field, even when price is 0 (free items).
      // An empty field is treated as 'user forgot to enter' and will fail validation.
      _priceController.text = listing.price.toStringAsFixed(0);
    } else {
      if (listing.rentalDailyPrice != null) {
        _dailyEnabled = true;
        _dailyController.text =
            listing.rentalDailyPrice!.toStringAsFixed(0);
      }
      if (listing.rentalWeeklyPrice != null) {
        _weeklyEnabled = true;
        _weeklyController.text =
            listing.rentalWeeklyPrice!.toStringAsFixed(0);
      }
      if (listing.rentalMonthlyPrice != null) {
        _monthlyEnabled = true;
        _monthlyController.text =
            listing.rentalMonthlyPrice!.toStringAsFixed(0);
      }
      _depositController.text =
          listing.depositAmount > 0
              ? listing.depositAmount.toStringAsFixed(0)
              : '';
    }
  }

  Future<void> _pickNewPhoto() async {
    if (_existingImageUrls.length + _newPhotos.length >= 5) return;
    final source = await ImageUploadService.showSourcePicker(context);
    if (source == null) return;
    if (!mounted) return;
    final service = ImageUploadService();
    XFile? xFile;
    if (source == ImageSource.camera) {
      xFile = await service.takePhotoAndCrop(context);
    } else {
      xFile = await service.pickAndCropImage(context);
    }
    if (xFile != null) setState(() => _newPhotos = [..._newPhotos, xFile!]);
  }

  Future<void> _saveChanges(Listing listing) async {
    final userId = ref.read(authStateProvider).value?.id;
    if (userId == null) return;

    // Basic validation
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Title is required.')),
        );
      }
      return;
    }

    final allImages = _existingImageUrls.length + _newPhotos.length;
    if (allImages == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('At least one photo is required.')),
        );
      }
      return;
    }

    // NOTE: price = 0 is valid (free/give-away). Only reject blank or non-numeric.
    if (_transactionType == 'sale') {
      final priceText = _priceController.text.trim();
      if (priceText.isEmpty || double.tryParse(priceText) == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a sale price (\$0 is allowed).'),
            ),
          );
        }
        return;
      }
    }

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(listingRepositoryProvider);

      // Build updated listing from form values.
      final updated = listing.copyWith(
        title: title,
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        condition: _selectedCondition,
        transactionType: _transactionType,
        price: _transactionType == 'sale'
            ? (double.tryParse(_priceController.text) ?? listing.price)
            : 0.0,
        rentalDailyPrice: _dailyEnabled && _dailyController.text.isNotEmpty
            ? double.tryParse(_dailyController.text)
            : null,
        rentalWeeklyPrice:
            _weeklyEnabled && _weeklyController.text.isNotEmpty
                ? double.tryParse(_weeklyController.text)
                : null,
        rentalMonthlyPrice:
            _monthlyEnabled && _monthlyController.text.isNotEmpty
                ? double.tryParse(_monthlyController.text)
                : null,
        depositAmount: double.tryParse(_depositController.text) ?? 0.0,
        pickupLocationId: _selectedPickupId,
        customPickupNote:
            _customLocationNote.isNotEmpty ? _customLocationNote : null,
        allowPickupChange: _allowPickupChange,
        availableDate: _availableDate,
      );

      // 1. Update listing fields + replace images
      await repo.updateListingWithImages(
        listing: updated,
        userId: userId,
        existingImageUrls: _existingImageUrls,
        newPhotos: _newPhotos,
      );

      // 2. Invalidate pending orders (soft-invalidate, buyers can re-submit).
      // NOTE: Pass the listing's CURRENT (pre-edit) field values as the
      // snapshot so buyers see what they originally agreed to vs. what changed.
      // `listing` still holds the old data here; `updated` has the new values.
      await repo.invalidatePendingOrders(
        widget.listingId,
        title: listing.title,
        price: listing.price,
        description: listing.description,
        condition: listing.condition,
        transactionType: listing.transactionType,
        // Rental pricing snapshot — preserves what the buyer originally agreed to
        rentalDailyPrice: listing.rentalDailyPrice,
        rentalWeeklyPrice: listing.rentalWeeklyPrice,
        rentalMonthlyPrice: listing.rentalMonthlyPrice,
        depositAmount: listing.depositAmount > 0 ? listing.depositAmount : null,
        // Logistics fields — allow buyer to see if pickup details changed
        availableDate: listing.availableDate,
        pickupLocationName: listing.pickupLocation?.name,
        allowPickupChange: listing.allowPickupChange,
      );

      // 3. Notify affected buyers and savers
      await repo.notifyListingUpdated(
        listingId: widget.listingId,
        listingTitle: title,
      );

      // Refresh providers
      ref.invalidate(listingDetailProvider(widget.listingId));
      ref.invalidate(listingOrdersProvider(widget.listingId));
      _newPhotos = [];
      _formInitialised = false; // allow re-init from refreshed listing

      if (!mounted) return;
      setState(() => _editExpanded = false);
      showDialog(
        context: context,
        builder: (_) => const ActionSuccessDialog(
          title: 'Listing Updated',
          message:
              'Your listing has been updated. Affected buyers have been notified.',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => ActionErrorDialog(
          title: 'Update Failed',
          message: e.toString(),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = Breakpoints.isDesktop(screenWidth);

    final listingAsync = ref.watch(listingDetailProvider(widget.listingId));

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: colors.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Manage Transactions',
          style: typo.headlineSmall.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      // NOTE: SingleChildScrollView lets all sections (preview, edit,
      // stats) scroll together. Tab lists use shrinkWrap so they render
      // inline without a second scroll context.
      body: SingleChildScrollView(
        child: isDesktop
            ? ContentWidthConstraint(
                maxWidth: 960,
                child: _buildPageContent(context, ref, listingAsync),
              )
            : _buildPageContent(context, ref, listingAsync),
      ),
    );
  }

  /// Full page content: preview card + Edit Listing + Listing Stats.
  Widget _buildPageContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<Listing> listingAsync,
  ) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Listing preview card ────────────────
        listingAsync.when(
          loading: () => const SizedBox(height: 64),
          error: (_, __) => const SizedBox(height: 64),
          data: (listing) {
            _initEditForm(listing);
            final imageUrl = listing.images.firstOrNull?.imageUrl;
            final isRental = listing.transactionType == 'rental';
            return Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(radius.card),
              ),
              child: Row(
                children: [
                  if (imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(radius.sm),
                      child: Image.network(
                        imageUrl,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(radius.sm),
                      ),
                      child: Icon(
                        Icons.image_not_supported,
                        size: 20,
                        color: colors.outlineVariant,
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.title,
                          style: typo.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!isRental)
                          Text(
                            '\$${listing.price.toStringAsFixed(0)}',
                            style: typo.bodyMedium.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            children: [
                              if (listing.rentalDailyPrice != null)
                                Text(
                                  '\$${listing.rentalDailyPrice!.toStringAsFixed(0)}/day',
                                  style: typo.bodySmall.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              if (listing.rentalWeeklyPrice != null)
                                Text(
                                  '\$${listing.rentalWeeklyPrice!.toStringAsFixed(0)}/wk',
                                  style: typo.bodySmall.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              if (listing.rentalMonthlyPrice != null)
                                Text(
                                  '\$${listing.rentalMonthlyPrice!.toStringAsFixed(0)}/mo',
                                  style: typo.bodySmall.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        // ── Edit Listing collapsible ─────────────────
        listingAsync.maybeWhen(
          data: (listing) {
            final hasAccepted = ref.watch(
              listingHasConfirmedOrderProvider(listing.id),
            );
            final isLocked = hasAccepted.when(
              data: (v) => v,
              loading: () => false,
              error: (_, __) => false,
            );
            return _buildEditListingSection(
              context,
              listing,
              isLocked: isLocked,
            );
          },
          orElse: () => const SizedBox.shrink(),
        ),
        // ── Listing Stats collapsible ────────────────
        _buildStatsSection(context),
        // Bottom padding so last card is not clipped
        const SizedBox(height: 24),
      ],
    );
  }

  /// Collapsible Listing Stats section.
  /// Contains a TabBar (Views / Saves / Offers) that renders tab content
  /// inline (shrinkWrap) so it fits inside the parent SingleChildScrollView.
  Widget _buildStatsSection(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    // NOTE: Tab labels map to 0=Views, 1=Saves, 2=Offers.
    const tabs = ['Views', 'Saves', 'Offers'];

    // Build the active tab content widget inline.
    Widget tabContent;
    switch (_selectedStatsTab) {
      case 0:
        tabContent = _ViewsTab(listingId: widget.listingId);
        break;
      case 1:
        tabContent = _SavesTab(listingId: widget.listingId);
        break;
      case 2:
      default:
        tabContent = _OffersTab(listingId: widget.listingId);
        break;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(radius.card),
        border: Border.all(
          color: _statsExpanded
              ? colors.primary.withValues(alpha: 0.4)
              : colors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // ── Collapsible header ──────────────────────────────
          InkWell(
            borderRadius: BorderRadius.circular(radius.card),
            onTap: () => setState(() => _statsExpanded = !_statsExpanded),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    size: 18,
                    color: _statsExpanded
                        ? colors.primary
                        : colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Listing Stats',
                      style: typo.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _statsExpanded
                            ? colors.primary
                            : colors.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    _statsExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          // ── Collapsible tab content ───────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tab selector row
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Row(
                    children: List.generate(tabs.length, (i) {
                      final selected = _selectedStatsTab == i;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedStatsTab = i),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? colors.primary.withValues(alpha: 0.12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(radius.sm),
                              border: selected
                                  ? Border.all(
                                      color: colors.primary,
                                      width: 1,
                                    )
                                  : null,
                            ),
                            child: Text(
                              tabs[i],
                              textAlign: TextAlign.center,
                              style: typo.labelLarge.copyWith(
                                color: selected
                                    ? colors.primary
                                    : colors.onSurfaceVariant,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const Divider(height: 1),
                // Active tab content (shrinkWrap renders inline)
                tabContent,
              ],
            ),
            crossFadeState: _statsExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  /// Collapsible Edit Listing section above the TabBarView.
  /// When [isLocked] is true (seller has accepted an offer), the section
  /// is displayed as disabled (greyed out) and cannot be edited.
  Widget _buildEditListingSection(
    BuildContext context,
    Listing listing, {
    bool isLocked = false,
  }) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final totalImages = _existingImageUrls.length + _newPhotos.length;

    // NOTE: Use IgnorePointer + Opacity to visually and functionally
    // disable the entire section once an offer is accepted.
    final card = Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(radius.card),
        border: Border.all(
          color: _editExpanded
              ? colors.primary.withValues(alpha: 0.4)
              : colors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // ── Collapsible header ────────────────────────────────
          // NOTE: When isLocked, tap is disabled and label changes to show why.
          InkWell(
            borderRadius: BorderRadius.circular(radius.card),
            onTap: isLocked ? null : () => setState(() => _editExpanded = !_editExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    isLocked ? Icons.lock_outline : Icons.edit_outlined,
                    size: 18,
                    color: isLocked
                        ? colors.outlineVariant
                        : (_editExpanded
                            ? colors.primary
                            : colors.onSurfaceVariant),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Listing',
                          style: typo.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isLocked
                                ? colors.outlineVariant
                                : (_editExpanded
                                    ? colors.primary
                                    : colors.onSurface),
                          ),
                        ),
                        // NOTE: Shown only after seller accepts an offer
                        if (isLocked)
                          Text(
                            'Locked after offer accepted',
                            style: typo.bodySmall.copyWith(
                              color: colors.outlineVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!isLocked)
                    Icon(
                      _editExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: colors.onSurfaceVariant,
                    )
                  else
                    Icon(
                      Icons.lock,
                      size: 16,
                      color: colors.outlineVariant,
                    ),
                ],
              ),
            ),
          ),
          // ── Collapsible form body ─────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // ── Photo picker ──────────────────────────────
                  Text('Photos', style: typo.labelSmall.copyWith(color: colors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // Existing uploaded images
                        ..._existingImageUrls.asMap().entries.map((entry) {
                          return _buildImageThumb(
                            context,
                            NetworkImage(entry.value),
                            entry.key == 0,
                            onRemove: () => setState(() {
                              final list = List<String>.from(_existingImageUrls);
                              list.removeAt(entry.key);
                              _existingImageUrls = list;
                            }),
                          );
                        }),
                        // Newly picked photos
                        ..._newPhotos.asMap().entries.map((entry) {
                          final imgProvider = kIsWeb
                              ? NetworkImage(entry.value.path) as ImageProvider
                              : FileImage(io.File(entry.value.path));
                          return _buildImageThumb(
                            context,
                            imgProvider,
                            _existingImageUrls.isEmpty && entry.key == 0,
                            onRemove: () => setState(() {
                              final list = List<XFile>.from(_newPhotos);
                              list.removeAt(entry.key);
                              _newPhotos = list;
                            }),
                          );
                        }),
                        // Add photo button
                        if (totalImages < 5)
                          GestureDetector(
                            onTap: _pickNewPhoto,
                            child: Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(radius.md),
                                border: Border.all(
                                  color: colors.primary.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_outlined,
                                      color: colors.primary),
                                  const SizedBox(height: 4),
                                  Text('Add',
                                      style: typo.labelSmall
                                          .copyWith(color: colors.primary)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Title ─────────────────────────────────────
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(radius.input),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Description ───────────────────────────────
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(radius.input),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Category ──────────────────────────────────
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(radius.input),
                      ),
                    ),
                    items: AppConstants.categories.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(
                          c[0].toUpperCase() + c.substring(1).replaceAll('_', ' '),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v!),
                  ),
                  const SizedBox(height: 12),

                  // ── Condition ─────────────────────────────────
                  DropdownButtonFormField<String>(
                    value: _selectedCondition,
                    decoration: InputDecoration(
                      labelText: 'Condition',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(radius.input),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'new', child: Text('New')),
                      DropdownMenuItem(value: 'like_new', child: Text('Like New')),
                      DropdownMenuItem(value: 'good', child: Text('Good')),
                      DropdownMenuItem(value: 'fair', child: Text('Fair')),
                      DropdownMenuItem(value: 'poor', child: Text('Poor')),
                    ],
                    onChanged: (v) => setState(() => _selectedCondition = v!),
                  ),
                  const SizedBox(height: 12),

                  // ── Price / Rental rates ───────────────────────
                  if (_transactionType == 'sale') ...[  
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Sale Price (\$)',
                        prefixText: '\$',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(radius.input),
                        ),
                      ),
                    ),
                  ] else ...[  
                    // Rental rates with toggle checkboxes
                    _buildRentalRateRow(
                      context,
                      label: 'Daily Rate',
                      enabled: _dailyEnabled,
                      controller: _dailyController,
                      onToggle: (v) => setState(() => _dailyEnabled = v),
                    ),
                    const SizedBox(height: 8),
                    _buildRentalRateRow(
                      context,
                      label: 'Weekly Rate',
                      enabled: _weeklyEnabled,
                      controller: _weeklyController,
                      onToggle: (v) => setState(() => _weeklyEnabled = v),
                    ),
                    const SizedBox(height: 8),
                    _buildRentalRateRow(
                      context,
                      label: 'Monthly Rate',
                      enabled: _monthlyEnabled,
                      controller: _monthlyController,
                      onToggle: (v) => setState(() => _monthlyEnabled = v),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _depositController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Deposit (\$)',
                        prefixText: '\$',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(radius.input),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // ── Pickup address selector ────────────────────
                  PickupAddressSelector(
                    key: _addressSelectorKey,
                    initialPickupId: _selectedPickupId,
                    initialAddress: _customLocationNote.isNotEmpty
                        ? _customLocationNote
                        : null,
                    onPickupIdChanged: (id) => _selectedPickupId = id,
                    onAddressChanged: (addr) => _customLocationNote = addr,
                  ),
                  const SizedBox(height: 20),

                  // ── Save button ───────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : () => _saveChanges(listing),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(radius.button),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Save Changes',
                              style: typo.labelLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.onPrimary,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: _editExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
    // NOTE: Wrap in Opacity + IgnorePointer when locked so that
    // ALL interactive elements (buttons, fields, dropdown) are disabled.
    if (isLocked) {
      return IgnorePointer(
        child: Opacity(opacity: 0.45, child: card),
      );
    }
    return card;
  }

  /// Single rental rate row with an enable/disable checkbox.
  Widget _buildRentalRateRow(
    BuildContext context, {
    required String label,
    required bool enabled,
    required TextEditingController controller,
    required ValueChanged<bool> onToggle,
  }) {
    final colors = context.smivoColors;
    final radius = context.smivoRadius;
    return Row(
      children: [
        Checkbox(
          value: enabled,
          onChanged: (v) => onToggle(v ?? false),
          activeColor: colors.primary,
        ),
        Expanded(
          child: TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: label,
              prefixText: '\$',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius.input),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Thumbnail card used in the photo strip inside the edit form.
  Widget _buildImageThumb(
    BuildContext context,
    ImageProvider image,
    bool isCover, {
    required VoidCallback onRemove,
  }) {
    final colors = context.smivoColors;
    final radius = context.smivoRadius;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius.md),
            image: DecorationImage(image: image, fit: BoxFit.cover),
          ),
        ),
        if (isCover)
          Positioned(
            bottom: 6,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'COVER',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
        Positioned(
          top: -6,
          right: 2,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: colors.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}

/// Views tab — shows individual viewer details.
class _ViewsTab extends ConsumerWidget {
  const _ViewsTab({required this.listingId});
  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewsAsync = ref.watch(listingViewsProvider(listingId));
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(listingViewsProvider(listingId));
        await ref.read(listingViewsProvider(listingId).future);
      },
      child: viewsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (e, _) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: 300,
                alignment: Alignment.center,
                child: Text('Error: $e'),
              ),
            ),
        data: (views) {
          if (views.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: 300,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      size: 48,
                      color: colors.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No views yet',
                      style: typo.bodyMedium.copyWith(
                        color: colors.outlineVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          // NOTE: shrinkWrap so the list renders inline inside the
          // parent SingleChildScrollView without its own scroll context.
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: views.length,
            itemBuilder: (context, index) {
              final view = views[index];
              final timeStr = DateFormat(
                'MMM d, h:mm a',
              ).format(view.viewedAt.toLocal());
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(radius.md),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: colors.surfaceContainerHigh,
                      backgroundImage:
                          view.viewerAvatarUrl != null &&
                                  view.viewerAvatarUrl!.trim().isNotEmpty
                              ? NetworkImage(view.viewerAvatarUrl!)
                              : null,
                      child:
                          view.viewerAvatarUrl == null ||
                                  view.viewerAvatarUrl!.trim().isEmpty
                              ? Icon(
                                Icons.person,
                                color: colors.onSurface.withValues(alpha: 0.5),
                              )
                              : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      view.viewerName ?? 'Anonymous Guest',
                                      style: typo.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      view.viewerEmail ?? '',
                                      style: typo.labelSmall.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.chat_outlined, size: 16),
                                label: const Text('Chat'),
                                // NOTE: Only enable chat if the viewer has a userId (not anonymous)
                                onPressed:
                                    view.viewerId == null
                                        ? null
                                        : () async {
                                          final currentUserId =
                                              ref
                                                  .read(authStateProvider)
                                                  .value
                                                  ?.id;
                                          if (currentUserId == null) return;
                                          final chatRepo = ref.read(
                                            chatRepositoryProvider,
                                          );
                                          final room = await chatRepo
                                              .getOrCreateChatRoom(
                                                listingId: listingId,
                                                buyerId: view.viewerId!,
                                                sellerId: currentUserId,
                                              );
                                          final listingData =
                                              ref
                                                  .read(
                                                    listingDetailProvider(
                                                      listingId,
                                                    ),
                                                  )
                                                  .value;
                                          if (!context.mounted) return;
                                          showChatPopup(
                                            context,
                                            chatRoomId: room.id,
                                            otherUserName:
                                                view.viewerName ?? 'Viewer',
                                            otherUserAvatar:
                                                view.viewerAvatarUrl,
                                            otherUserEmail: view.viewerEmail,
                                            listingTitle:
                                                listingData?.title ?? '',
                                            listingPrice:
                                                listingData?.price ?? 0,
                                            listingImageUrl:
                                                listingData
                                                    ?.images
                                                    .firstOrNull
                                                    ?.imageUrl,
                                          );
                                        },
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '★★★★☆ 4.0',
                                style: typo.bodySmall.copyWith(
                                  color: colors.priceAccent,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Viewed on $timeStr',
                                style: typo.bodySmall.copyWith(
                                  color: colors.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Saves tab — shows users who saved this listing.
class _SavesTab extends ConsumerWidget {
  const _SavesTab({required this.listingId});
  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savesAsync = ref.watch(listingSavesProvider(listingId));
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(listingSavesProvider(listingId));
        await ref.read(listingSavesProvider(listingId).future);
      },
      child: savesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (e, _) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: 300,
                alignment: Alignment.center,
                child: Text('Error: $e'),
              ),
            ),
        data: (saves) {
          if (saves.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: 300,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: 48,
                      color: colors.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No saves yet',
                      style: typo.bodyMedium.copyWith(
                        color: colors.outlineVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: saves.length,
            itemBuilder: (context, index) {
              final save = saves[index];
              final dateStr = DateFormat('MMM d, yyyy').format(save.createdAt);
              // NOTE: fetchSavedByListing joins user profiles but SavedListing model doesn't have it yet.
              // For now use placeholder but the design matches.
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(radius.md),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (save.user != null)
                      SmivoUserAvatar(user: save.user!, radius: 20)
                    else
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: colors.surfaceContainerHigh,
                        child: Icon(
                          Icons.person,
                          color: colors.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      save.user?.displayName ??
                                          'Anonymous User',
                                      style: typo.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      save.user?.email ?? '',
                                      style: typo.labelSmall.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.chat_outlined, size: 16),
                                label: const Text('Chat'),
                                onPressed: () async {
                                  final currentUserId =
                                      ref.read(authStateProvider).value?.id;
                                  if (currentUserId == null ||
                                      save.userId.isEmpty) {
                                    return;
                                  }
                                  final chatRepo = ref.read(
                                    chatRepositoryProvider,
                                  );
                                  final room = await chatRepo
                                      .getOrCreateChatRoom(
                                        listingId: listingId,
                                        buyerId: save.userId,
                                        sellerId: currentUserId,
                                      );
                                  final listingData =
                                      ref
                                          .read(
                                            listingDetailProvider(listingId),
                                          )
                                          .value;
                                  if (!context.mounted) return;
                                  showChatPopup(
                                    context,
                                    chatRoomId: room.id,
                                    otherUserName:
                                        save.user?.displayName ?? 'User',
                                    otherUserAvatar: save.user?.avatarUrl,
                                    otherUserEmail: save.user?.email,
                                    otherUserProfile: save.user,
                                    listingTitle: listingData?.title ?? '',
                                    listingPrice: listingData?.price ?? 0,
                                    listingImageUrl:
                                        listingData
                                            ?.images
                                            .firstOrNull
                                            ?.imageUrl,
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '★★★★☆ 4.0',
                                style: typo.bodySmall.copyWith(
                                  color: colors.priceAccent,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Saved on $dateStr',
                                style: typo.bodySmall.copyWith(
                                  color: colors.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Offers tab — shows all orders with Accept buttons.
class _OffersTab extends ConsumerWidget {
  const _OffersTab({required this.listingId});
  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(listingOrdersProvider(listingId));
    final actionsState = ref.watch(orderActionsProvider);
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(listingOrdersProvider(listingId));
        await ref.read(listingOrdersProvider(listingId).future);
      },
      child: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (e, _) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: 300,
                alignment: Alignment.center,
                child: Text('Error: $e'),
              ),
            ),
        data: (orders) {
          if (orders.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: 300,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: colors.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No offers yet',
                      style: typo.bodyMedium.copyWith(
                        color: colors.outlineVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(
                context,
                ref,
                order,
                actionsState.isLoading,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    WidgetRef ref,
    Order order,
    bool isActing,
  ) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final buyerName = order.buyer?.displayName ?? 'Unknown Buyer';
    final dateStr = DateFormat(
      'MMM d, h:mm a',
    ).format(order.createdAt.toLocal());
    final isPending = order.status == 'pending';

    // NOTE: Use DB-driven status labels and colors via StatusResolver
    final resolver = ref.watch(statusResolverProvider).value;
    final statusColor =
        resolver?.orderColor(order.status) ?? colors.outlineVariant;
    final statusLabel = resolver?.orderLabel(order.status) ?? order.status;

    return GestureDetector(
      onTap:
          () => context.pushNamed(
            AppRoutes.orderDetail,
            pathParameters: {'id': order.id},
          ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(radius.md),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (order.buyer != null)
                  SmivoUserAvatar(user: order.buyer!, radius: 20)
                else
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colors.surfaceContainerHigh,
                    child: Icon(
                      Icons.person,
                      color: colors.onSurface.withValues(alpha: 0.5),
                      size: 20,
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  buyerName,
                                  style: typo.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  order.buyer?.email ?? '',
                                  style: typo.labelSmall.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            formatOrderPrice(order),
                            style: typo.titleMedium.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '★★★★☆ 4.0',
                            style: typo.bodySmall.copyWith(
                              color: colors.priceAccent,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Submitted on $dateStr',
                            style: typo.bodySmall.copyWith(
                              color: colors.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(
              height: 1,
              thickness: 0.5,
              color: colors.outlineVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildInfoItem(
                  context,
                  Icons.calendar_today_outlined,
                  order.orderType == 'rental' &&
                          order.rentalStartDate != null &&
                          order.rentalEndDate != null
                      ? '${DateFormat('MM/dd').format(order.rentalStartDate!)} - ${DateFormat('MM/dd/yyyy').format(order.rentalEndDate!)}'
                      : DateFormat('MM/dd/yyyy').format(order.createdAt),
                ),
                if (order.pickupLocationName != null &&
                    order.pickupLocationName!.isNotEmpty)
                  _buildInfoItem(
                    context,
                    Icons.location_on_outlined,
                    order.pickupLocationName!,
                  ),
                _buildInfoItem(
                  context,
                  Icons.school_outlined,
                  order.school,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(radius.xl),
                  ),
                  child: Text(
                    statusLabel,
                    style: typo.labelSmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.chat_outlined, size: 16),
                      label: const Text('Chat'),
                      onPressed: () async {
                        final currentUserId =
                            ref.read(authStateProvider).value?.id;
                        if (currentUserId == null) return;
                        final chatRepo = ref.read(chatRepositoryProvider);
                        final room = await chatRepo.getOrCreateChatRoom(
                          listingId: order.listingId,
                          buyerId: order.buyerId,
                          sellerId: order.sellerId,
                        );
                        if (!context.mounted) return;
                        showChatPopup(
                          context,
                          chatRoomId: room.id,
                          otherUserName: order.buyer?.displayName ?? 'Buyer',
                          otherUserAvatar: order.buyer?.avatarUrl,
                          otherUserEmail: order.buyer?.email,
                          otherUserProfile: order.buyer,
                          listingTitle: order.listing?.title ?? '',
                          listingPrice: order.totalPrice,
                          priceLabel:
                              formatOrderPriceLabel(order) ??
                              (order.orderType == 'rental'
                                  ? _formatRentalSummary(order)
                                  : null),
                          listingImageUrl:
                              order.listing?.images.firstOrNull?.imageUrl,
                        );
                      },
                    ),
                    if (isPending) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap:
                            isActing
                                ? null
                                : () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (ctx) => ThemedConfirmDialog(
                                          title: 'Accept Offer',
                                          message:
                                              'Accept this offer from $buyerName? Other pending offers will be cancelled.',
                                          confirmText: 'Accept',
                                          cancelText: 'Cancel',
                                        ),
                                  );

                                  if (confirmed == true) {
                                    try {
                                      await ref
                                          .read(orderActionsProvider.notifier)
                                          .acceptOrder(order.id);
                                      // NOTE: Refresh the offers list so accepted/missed statuses show
                                      ref.invalidate(
                                        listingOrdersProvider(listingId),
                                      );
                                      if (!context.mounted) return;
                                      showDialog(
                                        context: context,
                                        builder:
                                            (ctx) => const ActionSuccessDialog(
                                              title: 'Offer Accepted',
                                              message: 'Offer accepted successfully.',
                                            ),
                                      ).then((_) {
                                        if (context.mounted) {
                                          context.pushNamed(
                                            AppRoutes.orderDetail,
                                            pathParameters: {'id': order.id},
                                          );
                                        }
                                      });
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      showDialog(
                                        context: context,
                                        builder:
                                            (ctx) => ActionErrorDialog(
                                              title: 'Failed to Accept',
                                              message: e.toString(),
                                            ),
                                      );
                                    }
                                  }
                                },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(radius.button),
                          ),
                          child: Text(
                            isActing ? '...' : 'Accept',
                            style: typo.labelLarge.copyWith(
                              color: colors.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String label,
  ) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: colors.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: typo.bodySmall.copyWith(
              color: colors.onSurface.withValues(alpha: 0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

String _formatRentalSummary(Order order) {
  if (order.totalPrice == 0) return formatOrderPrice(order);
  if (order.rentalStartDate == null || order.rentalEndDate == null) {
    return 'Total: \$${order.totalPrice.toStringAsFixed(0)}';
  }
  final days = order.rentalEndDate!.difference(order.rentalStartDate!).inDays;
  final duration = days > 0 ? days : 1;
  final unitLabel = duration == 1 ? 'Day' : 'Days';
  return '$duration $unitLabel, Total: \$${order.totalPrice.toStringAsFixed(0)}';
}
