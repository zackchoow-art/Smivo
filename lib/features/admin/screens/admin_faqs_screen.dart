import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/faq.dart';
import 'package:smivo/features/admin/providers/admin_faq_provider.dart';

class AdminFaqsScreen extends ConsumerWidget {
  const AdminFaqsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final faqsState = ref.watch(adminFaqControllerProvider);

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Manage FAQs'),
        backgroundColor: colors.surfaceContainerLowest,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add new FAQ',
            onPressed: () => _showFaqDialog(context, ref, null),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: faqsState.when(
        data: (faqs) {
          if (faqs.isEmpty) {
            return const Center(child: Text('No FAQs found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: faqs.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final faq = faqs[index];
              return ListTile(
                title: Text(faq.question, style: typo.titleMedium),
                subtitle: Text(
                  '${faq.category} • Order: ${faq.displayOrder}',
                  style: typo.bodyMedium.copyWith(color: colors.onSurfaceVariant),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      color: colors.primary,
                      onPressed: () => _showFaqDialog(context, ref, faq),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, size: 20, color: colors.error),
                      onPressed: () => _confirmDelete(context, ref, faq),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error loading FAQs: $err', style: TextStyle(color: colors.error)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFaqDialog(context, ref, null),
        backgroundColor: colors.primary,
        child: Icon(Icons.add, color: colors.onPrimary),
      ),
    );
  }

  void _showFaqDialog(BuildContext context, WidgetRef ref, Faq? faq) {
    showDialog(
      context: context,
      builder: (context) => _FaqDialog(faq: faq),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Faq faq) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete FAQ'),
        content: Text('Are you sure you want to delete "${faq.question}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(adminFaqControllerProvider.notifier).deleteFaq(faq.id);
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: context.smivoColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _FaqDialog extends ConsumerStatefulWidget {
  final Faq? faq;
  const _FaqDialog({this.faq});

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
    _orderCtrl = TextEditingController(text: widget.faq?.displayOrder.toString() ?? '0');
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

    final newFaq = Faq(
      id: widget.faq?.id ?? '',
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

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.faq != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit FAQ' : 'New FAQ'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _categoryCtrl,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (val) => val != null && val.trim().isNotEmpty ? null : 'Required',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _questionCtrl,
                decoration: const InputDecoration(labelText: 'Question'),
                validator: (val) => val != null && val.trim().isNotEmpty ? null : 'Required',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _answerCtrl,
                decoration: const InputDecoration(labelText: 'Answer'),
                maxLines: 4,
                validator: (val) => val != null && val.trim().isNotEmpty ? null : 'Required',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _orderCtrl,
                decoration: const InputDecoration(labelText: 'Display Order'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Required';
                  if (int.tryParse(val.trim()) == null) return 'Must be a number';
                  return null;
                },
              ),
            ],
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
