import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/faq.dart';
import 'package:smivo/features/admin/providers/admin_auth_provider.dart';
import 'package:smivo/features/admin/providers/admin_faq_provider.dart';
import 'package:smivo/features/admin/providers/admin_school_provider.dart';

/// Admin screen for managing FAQs with optional school scoping.
///
/// "All Schools" shows global FAQs (school_id = null).
/// Selecting a specific school shows school-specific + global FAQs.
class AdminFaqsScreen extends ConsumerStatefulWidget {
  const AdminFaqsScreen({super.key});

  @override
  ConsumerState<AdminFaqsScreen> createState() => _AdminFaqsScreenState();
}

class _AdminFaqsScreenState extends ConsumerState<AdminFaqsScreen> {
  String? _selectedSchoolId;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final schoolsState = ref.watch(adminSchoolControllerProvider);
    final adminCtx = ref.watch(adminContextProvider).valueOrNull;
    final canWrite = adminCtx?.canWrite(AdminModule.faqs) ?? false;

    // NOTE: When no school is selected, show all FAQs (global view).
    // When a school is selected, filter to that school's FAQs.
    final faqsState = ref.watch(adminFaqControllerProvider);

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          'Manage FAQs',
          style: typo.headlineSmall.copyWith(fontWeight: FontWeight.w800),
        ),
        backgroundColor: colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          if (canWrite)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add new FAQ',
              onPressed: () => _showFaqDialog(context, null),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(adminFaqControllerProvider),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // School filter + search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                // School filter chip
                Expanded(
                  flex: 2,
                  child: schoolsState.when(
                    data:
                        (schools) => DropdownButtonFormField<String?>(
                          initialValue: _selectedSchoolId,
                          decoration: InputDecoration(
                            labelText: 'Filter by School',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(radius.sm),
                            ),
                            filled: true,
                            fillColor: colors.surfaceContainerLow,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('All Schools'),
                            ),
                            ...schools.map(
                              (s) => DropdownMenuItem(
                                value: s.id,
                                child: Text(s.name),
                              ),
                            ),
                          ],
                          onChanged:
                              (v) => setState(() => _selectedSchoolId = v),
                        ),
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Error: $e'),
                  ),
                ),
                const SizedBox(width: 12),
                // Search
                Expanded(
                  flex: 3,
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search questions…',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(radius.sm),
                      ),
                      filled: true,
                      fillColor: colors.surfaceContainerLow,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // FAQ list
          Expanded(
            child: faqsState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (e, _) => Center(
                    child: Text(
                      'Error: $e',
                      style: TextStyle(color: colors.error),
                    ),
                  ),
              data: (allFaqs) {
                // Filter by school
                var faqs = allFaqs;
                if (_selectedSchoolId != null) {
                  faqs =
                      faqs
                          .where(
                            (f) =>
                                f.schoolId == _selectedSchoolId ||
                                f.schoolId == null,
                          )
                          .toList();
                }

                // Filter by search
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  faqs =
                      faqs
                          .where(
                            (f) =>
                                f.question.toLowerCase().contains(q) ||
                                f.answer.toLowerCase().contains(q) ||
                                f.category.toLowerCase().contains(q),
                          )
                          .toList();
                }

                if (faqs.isEmpty) {
                  return Center(
                    child: Text(
                      'No FAQs found.',
                      style: typo.bodyLarge.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  itemCount: faqs.length,
                  itemBuilder: (context, index) {
                    final faq = faqs[index];
                    final isGlobal = faq.schoolId == null;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(radius.sm),
                        border: Border.all(
                          color: colors.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFEA580C,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.help_outline,
                            color: Color(0xFFEA580C),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          faq.question,
                          style: typo.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              '${faq.category} • #${faq.displayOrder}',
                              style: typo.bodySmall.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            if (isGlobal) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Global',
                                  style: typo.labelSmall.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing:
                            canWrite
                                ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        size: 20,
                                        color: colors.primary,
                                      ),
                                      onPressed:
                                          () => _showFaqDialog(context, faq),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        size: 20,
                                        color: colors.error,
                                      ),
                                      onPressed:
                                          () => _confirmDelete(context, faq),
                                    ),
                                  ],
                                )
                                : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFaqDialog(BuildContext context, Faq? faq) {
    showDialog(
      context: context,
      builder:
          (context) => _FaqDialog(
            faq: faq,
            selectedSchoolId: _selectedSchoolId,
            onSaved: () => ref.invalidate(adminFaqControllerProvider),
          ),
    );
  }

  void _confirmDelete(BuildContext context, Faq faq) {
    final colors = context.smivoColors;
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete FAQ'),
            content: Text('Delete "${faq.question}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  ref
                      .read(adminFaqControllerProvider.notifier)
                      .deleteFaq(faq.id);
                  Navigator.of(ctx).pop();
                },
                style: FilledButton.styleFrom(backgroundColor: colors.error),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}

class _FaqDialog extends ConsumerStatefulWidget {
  final Faq? faq;
  final String? selectedSchoolId;
  final VoidCallback onSaved;

  const _FaqDialog({this.faq, this.selectedSchoolId, required this.onSaved});

  @override
  ConsumerState<_FaqDialog> createState() => _FaqDialogState();
}

class _FaqDialogState extends ConsumerState<_FaqDialog> {
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _questionCtrl;
  late final TextEditingController _answerCtrl;
  late final TextEditingController _orderCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _categoryCtrl = TextEditingController(text: widget.faq?.category ?? '');
    _questionCtrl = TextEditingController(text: widget.faq?.question ?? '');
    _answerCtrl = TextEditingController(text: widget.faq?.answer ?? '');
    _orderCtrl = TextEditingController(
      text: widget.faq?.displayOrder.toString() ?? '0',
    );
  }

  @override
  void dispose() {
    _categoryCtrl.dispose();
    _questionCtrl.dispose();
    _answerCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // NOTE: When creating, use the selected school's ID.
    // When editing, preserve the original school_id.
    final newFaq = Faq(
      id: widget.faq?.id ?? '',
      schoolId: widget.faq?.schoolId ?? widget.selectedSchoolId,
      category: _categoryCtrl.text.trim(),
      question: _questionCtrl.text.trim(),
      answer: _answerCtrl.text.trim(),
      displayOrder: int.tryParse(_orderCtrl.text.trim()) ?? 0,
      createdAt: widget.faq?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.faq == null) {
      ref.read(adminFaqControllerProvider.notifier).addFaq(newFaq);
    } else {
      ref.read(adminFaqControllerProvider.notifier).updateFaq(newFaq);
    }
    widget.onSaved();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.faq != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit FAQ' : 'New FAQ'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _categoryCtrl,
                  decoration: const InputDecoration(labelText: 'Category'),
                  validator:
                      (val) =>
                          val != null && val.trim().isNotEmpty
                              ? null
                              : 'Required',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _questionCtrl,
                  decoration: const InputDecoration(labelText: 'Question'),
                  validator:
                      (val) =>
                          val != null && val.trim().isNotEmpty
                              ? null
                              : 'Required',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _answerCtrl,
                  decoration: const InputDecoration(labelText: 'Answer'),
                  maxLines: 4,
                  validator:
                      (val) =>
                          val != null && val.trim().isNotEmpty
                              ? null
                              : 'Required',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _orderCtrl,
                  decoration: const InputDecoration(labelText: 'Display Order'),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Required';
                    }
                    if (int.tryParse(val.trim()) == null) {
                      return 'Must be a number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
