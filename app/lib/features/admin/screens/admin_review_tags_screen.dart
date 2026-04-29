import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/features/admin/providers/admin_review_tags_provider.dart';

class AdminReviewTagsScreen extends ConsumerStatefulWidget {
  const AdminReviewTagsScreen({super.key});

  @override
  ConsumerState<AdminReviewTagsScreen> createState() =>
      _AdminReviewTagsScreenState();
}

class _AdminReviewTagsScreenState extends ConsumerState<AdminReviewTagsScreen> {
  final _nameCtrl = TextEditingController();
  String _selectedType = 'buyer';

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _addTag() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    try {
      await ref
          .read(adminReviewTagsProvider.notifier)
          .createTag(name, _selectedType);
      _nameCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tag added successfully')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding tag: $e')));
      }
    }
  }

  void _deleteTag(String id) async {
    final colors = context.smivoColors;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Tag'),
            content: const Text('Are you sure you want to delete this tag?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: TextButton.styleFrom(foregroundColor: colors.error),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      await ref.read(adminReviewTagsProvider.notifier).deleteTag(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tag deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting tag: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final state = ref.watch(adminReviewTagsProvider);

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Review Tags',
          style: typo.headlineSmall.copyWith(fontWeight: FontWeight.w800),
        ),
        backgroundColor: colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add Form
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: colors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add New Tag',
                    style: typo.headlineSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Tag Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    decoration: InputDecoration(
                      labelText: 'Tag Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'buyer',
                        child: Text('Buyer Tag'),
                      ),
                      DropdownMenuItem(
                        value: 'seller',
                        child: Text('Seller Tag'),
                      ),
                      DropdownMenuItem(
                        value: 'general',
                        child: Text('General Tag'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedType = v);
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _addTag,
                      child: const Text('Add Tag'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // List
          Expanded(
            flex: 2,
            child: state.when(
              data: (tags) {
                if (tags.isEmpty) {
                  return const Center(child: Text('No tags found.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: tags.length,
                  itemBuilder: (context, index) {
                    final tag = tags[index];
                    final type = tag['type'] as String;

                    Color typeColor;
                    if (type == 'buyer')
                      typeColor = const Color(0xFF0891B2);
                    else if (type == 'seller')
                      typeColor = const Color(0xFF059669);
                    else
                      typeColor = const Color(0xFF7C3AED);

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: colors.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          tag['name'],
                          style: typo.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                type.toUpperCase(),
                                style: typo.labelSmall.copyWith(
                                  color: typeColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline, color: colors.error),
                          onPressed: () => _deleteTag(tag['id']),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
