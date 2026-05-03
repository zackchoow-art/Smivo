import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

class AvatarCustomizationDialog extends StatefulWidget {
  const AvatarCustomizationDialog({super.key, required this.initialSeed});
  final String initialSeed;

  @override
  State<AvatarCustomizationDialog> createState() =>
      _AvatarCustomizationDialogState();
}

class _AvatarCustomizationDialogState extends State<AvatarCustomizationDialog> {
  late String _currentSeed;
  String _currentStyle = 'open-peeps';

  final Map<String, String> _styles = {
    'open-peeps': 'Open Peeps',
    'avataaars': 'Avataaars',
    'micah': 'Micah',
    'bottts': 'Bots',
    'adventurer': 'Adventurer',
    'fun-emoji': 'Emojis',
  };

  @override
  void initState() {
    super.initState();
    _currentSeed = widget.initialSeed;
  }

  void _randomize() {
    setState(() {
      _currentSeed = DateTime.now().millisecondsSinceEpoch.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final url =
        'https://api.dicebear.com/9.x/$_currentStyle/png?seed=$_currentSeed&backgroundColor=transparent';

    return AlertDialog(
      backgroundColor: colors.surfaceContainerLowest,
      title: Text('Customize Avatar', style: typo.headlineSmall),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder:
                    (context, error, stackTrace) => const Icon(Icons.error),
              ),
            ),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            initialValue: _currentStyle,
            decoration: InputDecoration(
              labelText: 'Avatar Style',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items:
                _styles.entries
                    .map(
                      (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _currentStyle = val);
              }
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _randomize,
            icon: const Icon(Icons.casino),
            label: const Text('Randomize'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.secondaryContainer,
              foregroundColor: colors.onSecondaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep rolling until you find the perfect one!',
            style: typo.bodySmall.copyWith(color: colors.outlineVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: colors.outlineVariant)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, url),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
          ),
          child: const Text('Save Avatar'),
        ),
      ],
    );
  }
}
