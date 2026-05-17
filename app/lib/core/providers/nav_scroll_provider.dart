import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'nav_scroll_provider.g.dart';

// NOTE: Counter-based scroll triggers. Each time the user taps a nav button
// while already on that branch, the counter increments. The target screen
// listens via ref.listen and animates its list to the top when the value
// changes.
//
// Using an int counter (not a boolean) avoids the "same value, no rebuild"
// problem — every tap always produces a new, unique value.

/// Triggers scroll-to-top on the Home feed when [trigger] is called.
@Riverpod(keepAlive: true)
class HomeScrollTrigger extends _$HomeScrollTrigger {
  @override
  int build() => 0;

  // Increment so ref.listen callbacks always fire even on rapid taps.
  void trigger() => state = state + 1;
}

/// Triggers scroll-to-top on the Chat list when [trigger] is called.
@Riverpod(keepAlive: true)
class ChatScrollTrigger extends _$ChatScrollTrigger {
  @override
  int build() => 0;

  // Increment so ref.listen callbacks always fire even on rapid taps.
  void trigger() => state = state + 1;
}

/// Triggers scroll-to-top on the Carpool list when [trigger] is called.
@Riverpod(keepAlive: true)
class CarpoolScrollTrigger extends _$CarpoolScrollTrigger {
  @override
  int build() => 0;

  // Increment so ref.listen callbacks always fire even on rapid taps.
  void trigger() => state = state + 1;
}
