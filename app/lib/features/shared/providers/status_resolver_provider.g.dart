// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status_resolver_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Cached provider that loads ALL system dictionaries once and
/// exposes a [StatusResolver] for looking up labels and colors.

@ProviderFor(statusResolver)
final statusResolverProvider = StatusResolverProvider._();

/// Cached provider that loads ALL system dictionaries once and
/// exposes a [StatusResolver] for looking up labels and colors.

final class StatusResolverProvider
    extends
        $FunctionalProvider<
          AsyncValue<StatusResolver>,
          StatusResolver,
          FutureOr<StatusResolver>
        >
    with $FutureModifier<StatusResolver>, $FutureProvider<StatusResolver> {
  /// Cached provider that loads ALL system dictionaries once and
  /// exposes a [StatusResolver] for looking up labels and colors.
  StatusResolverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statusResolverProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statusResolverHash();

  @$internal
  @override
  $FutureProviderElement<StatusResolver> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<StatusResolver> create(Ref ref) {
    return statusResolver(ref);
  }
}

String _$statusResolverHash() => r'4dccd6d7c5e79e92b924b73819df15a403f9be60';
