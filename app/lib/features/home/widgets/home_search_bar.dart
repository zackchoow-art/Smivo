import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/theme/breakpoints.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'dart:math';
import 'package:smivo/features/home/providers/home_provider.dart';

class HomeSearchBar extends ConsumerStatefulWidget {
  const HomeSearchBar({super.key});

  @override
  ConsumerState<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends ConsumerState<HomeSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitSearch() {
    ref.read(searchQueryProvider.notifier).setQuery(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = Breakpoints.isDesktop(width);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? min(width * 0.4, 480) : double.infinity,
              ),
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _submitSearch(),
                textInputAction: TextInputAction.search,
                style: typo.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Search textbooks, tech, clothes...',
                  hintStyle: typo.bodyMedium.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: colors.surfaceContainerLow,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    color: colors.onSurface,
                    onPressed: _submitSearch,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(radius.input),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(radius.input),
                    borderSide: BorderSide(color: colors.primary, width: 1),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
