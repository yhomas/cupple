// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$timelineCardsHash() => r'fb323f2fe28921ced506e01e27ebe003dc98ab3d';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [timelineCards].
@ProviderFor(timelineCards)
const timelineCardsProvider = TimelineCardsFamily();

/// See also [timelineCards].
class TimelineCardsFamily extends Family<AsyncValue<List<CardModel>>> {
  /// See also [timelineCards].
  const TimelineCardsFamily();

  /// See also [timelineCards].
  TimelineCardsProvider call(String coupleId) {
    return TimelineCardsProvider(coupleId);
  }

  @override
  TimelineCardsProvider getProviderOverride(
    covariant TimelineCardsProvider provider,
  ) {
    return call(provider.coupleId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'timelineCardsProvider';
}

/// See also [timelineCards].
class TimelineCardsProvider extends AutoDisposeStreamProvider<List<CardModel>> {
  /// See also [timelineCards].
  TimelineCardsProvider(String coupleId)
    : this._internal(
        (ref) => timelineCards(ref as TimelineCardsRef, coupleId),
        from: timelineCardsProvider,
        name: r'timelineCardsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$timelineCardsHash,
        dependencies: TimelineCardsFamily._dependencies,
        allTransitiveDependencies:
            TimelineCardsFamily._allTransitiveDependencies,
        coupleId: coupleId,
      );

  TimelineCardsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.coupleId,
  }) : super.internal();

  final String coupleId;

  @override
  Override overrideWith(
    Stream<List<CardModel>> Function(TimelineCardsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TimelineCardsProvider._internal(
        (ref) => create(ref as TimelineCardsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        coupleId: coupleId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<CardModel>> createElement() {
    return _TimelineCardsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TimelineCardsProvider && other.coupleId == coupleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, coupleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TimelineCardsRef on AutoDisposeStreamProviderRef<List<CardModel>> {
  /// The parameter `coupleId` of this provider.
  String get coupleId;
}

class _TimelineCardsProviderElement
    extends AutoDisposeStreamProviderElement<List<CardModel>>
    with TimelineCardsRef {
  _TimelineCardsProviderElement(super.provider);

  @override
  String get coupleId => (origin as TimelineCardsProvider).coupleId;
}

String _$cardControllerHash() => r'2d27a9a341df1d1688322451e03790f526f3652e';

/// See also [CardController].
@ProviderFor(CardController)
final cardControllerProvider =
    AutoDisposeAsyncNotifierProvider<CardController, void>.internal(
      CardController.new,
      name: r'cardControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cardControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CardController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
