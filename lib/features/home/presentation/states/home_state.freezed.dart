// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$HomeState {
  HomeStatus get status => throw _privateConstructorUsedError;
  List<HomeCategory> get categories => throw _privateConstructorUsedError;
  List<HomeProduct> get trendingProducts => throw _privateConstructorUsedError;
  FeaturedBanner? get featuredBanner => throw _privateConstructorUsedError;
  bool get isLoadingMoreProducts => throw _privateConstructorUsedError;
  bool get hasMoreProducts => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  String? get wishlistError => throw _privateConstructorUsedError;
  String? get loadMoreError => throw _privateConstructorUsedError;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HomeStateCopyWith<HomeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeStateCopyWith<$Res> {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) then) =
      _$HomeStateCopyWithImpl<$Res, HomeState>;
  @useResult
  $Res call({
    HomeStatus status,
    List<HomeCategory> categories,
    List<HomeProduct> trendingProducts,
    FeaturedBanner? featuredBanner,
    bool isLoadingMoreProducts,
    bool hasMoreProducts,
    int currentPage,
    String? errorMessage,
    String? wishlistError,
    String? loadMoreError,
  });

  $FeaturedBannerCopyWith<$Res>? get featuredBanner;
}

/// @nodoc
class _$HomeStateCopyWithImpl<$Res, $Val extends HomeState>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? categories = null,
    Object? trendingProducts = null,
    Object? featuredBanner = freezed,
    Object? isLoadingMoreProducts = null,
    Object? hasMoreProducts = null,
    Object? currentPage = null,
    Object? errorMessage = freezed,
    Object? wishlistError = freezed,
    Object? loadMoreError = freezed,
  }) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as HomeStatus,
            categories: null == categories
                ? _value.categories
                : categories // ignore: cast_nullable_to_non_nullable
                      as List<HomeCategory>,
            trendingProducts: null == trendingProducts
                ? _value.trendingProducts
                : trendingProducts // ignore: cast_nullable_to_non_nullable
                      as List<HomeProduct>,
            featuredBanner: freezed == featuredBanner
                ? _value.featuredBanner
                : featuredBanner // ignore: cast_nullable_to_non_nullable
                      as FeaturedBanner?,
            isLoadingMoreProducts: null == isLoadingMoreProducts
                ? _value.isLoadingMoreProducts
                : isLoadingMoreProducts // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasMoreProducts: null == hasMoreProducts
                ? _value.hasMoreProducts
                : hasMoreProducts // ignore: cast_nullable_to_non_nullable
                      as bool,
            currentPage: null == currentPage
                ? _value.currentPage
                : currentPage // ignore: cast_nullable_to_non_nullable
                      as int,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            wishlistError: freezed == wishlistError
                ? _value.wishlistError
                : wishlistError // ignore: cast_nullable_to_non_nullable
                      as String?,
            loadMoreError: freezed == loadMoreError
                ? _value.loadMoreError
                : loadMoreError // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FeaturedBannerCopyWith<$Res>? get featuredBanner {
    if (_value.featuredBanner == null) {
      return null;
    }

    return $FeaturedBannerCopyWith<$Res>(_value.featuredBanner!, (value) {
      return _then(_value.copyWith(featuredBanner: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HomeStateImplCopyWith<$Res>
    implements $HomeStateCopyWith<$Res> {
  factory _$$HomeStateImplCopyWith(
    _$HomeStateImpl value,
    $Res Function(_$HomeStateImpl) then,
  ) = __$$HomeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    HomeStatus status,
    List<HomeCategory> categories,
    List<HomeProduct> trendingProducts,
    FeaturedBanner? featuredBanner,
    bool isLoadingMoreProducts,
    bool hasMoreProducts,
    int currentPage,
    String? errorMessage,
    String? wishlistError,
    String? loadMoreError,
  });

  @override
  $FeaturedBannerCopyWith<$Res>? get featuredBanner;
}

/// @nodoc
class __$$HomeStateImplCopyWithImpl<$Res>
    extends _$HomeStateCopyWithImpl<$Res, _$HomeStateImpl>
    implements _$$HomeStateImplCopyWith<$Res> {
  __$$HomeStateImplCopyWithImpl(
    _$HomeStateImpl _value,
    $Res Function(_$HomeStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? categories = null,
    Object? trendingProducts = null,
    Object? featuredBanner = freezed,
    Object? isLoadingMoreProducts = null,
    Object? hasMoreProducts = null,
    Object? currentPage = null,
    Object? errorMessage = freezed,
    Object? wishlistError = freezed,
    Object? loadMoreError = freezed,
  }) {
    return _then(
      _$HomeStateImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as HomeStatus,
        categories: null == categories
            ? _value._categories
            : categories // ignore: cast_nullable_to_non_nullable
                  as List<HomeCategory>,
        trendingProducts: null == trendingProducts
            ? _value._trendingProducts
            : trendingProducts // ignore: cast_nullable_to_non_nullable
                  as List<HomeProduct>,
        featuredBanner: freezed == featuredBanner
            ? _value.featuredBanner
            : featuredBanner // ignore: cast_nullable_to_non_nullable
                  as FeaturedBanner?,
        isLoadingMoreProducts: null == isLoadingMoreProducts
            ? _value.isLoadingMoreProducts
            : isLoadingMoreProducts // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasMoreProducts: null == hasMoreProducts
            ? _value.hasMoreProducts
            : hasMoreProducts // ignore: cast_nullable_to_non_nullable
                  as bool,
        currentPage: null == currentPage
            ? _value.currentPage
            : currentPage // ignore: cast_nullable_to_non_nullable
                  as int,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        wishlistError: freezed == wishlistError
            ? _value.wishlistError
            : wishlistError // ignore: cast_nullable_to_non_nullable
                  as String?,
        loadMoreError: freezed == loadMoreError
            ? _value.loadMoreError
            : loadMoreError // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$HomeStateImpl extends _HomeState {
  const _$HomeStateImpl({
    this.status = HomeStatus.initial,
    final List<HomeCategory> categories = const [],
    final List<HomeProduct> trendingProducts = const [],
    this.featuredBanner,
    this.isLoadingMoreProducts = false,
    this.hasMoreProducts = true,
    this.currentPage = 0,
    this.errorMessage,
    this.wishlistError,
    this.loadMoreError,
  }) : _categories = categories,
       _trendingProducts = trendingProducts,
       super._();

  @override
  @JsonKey()
  final HomeStatus status;
  final List<HomeCategory> _categories;
  @override
  @JsonKey()
  List<HomeCategory> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  final List<HomeProduct> _trendingProducts;
  @override
  @JsonKey()
  List<HomeProduct> get trendingProducts {
    if (_trendingProducts is EqualUnmodifiableListView)
      return _trendingProducts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_trendingProducts);
  }

  @override
  final FeaturedBanner? featuredBanner;
  @override
  @JsonKey()
  final bool isLoadingMoreProducts;
  @override
  @JsonKey()
  final bool hasMoreProducts;
  @override
  @JsonKey()
  final int currentPage;
  @override
  final String? errorMessage;
  @override
  final String? wishlistError;
  @override
  final String? loadMoreError;

  @override
  String toString() {
    return 'HomeState(status: $status, categories: $categories, trendingProducts: $trendingProducts, featuredBanner: $featuredBanner, isLoadingMoreProducts: $isLoadingMoreProducts, hasMoreProducts: $hasMoreProducts, currentPage: $currentPage, errorMessage: $errorMessage, wishlistError: $wishlistError, loadMoreError: $loadMoreError)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(
              other._categories,
              _categories,
            ) &&
            const DeepCollectionEquality().equals(
              other._trendingProducts,
              _trendingProducts,
            ) &&
            (identical(other.featuredBanner, featuredBanner) ||
                other.featuredBanner == featuredBanner) &&
            (identical(other.isLoadingMoreProducts, isLoadingMoreProducts) ||
                other.isLoadingMoreProducts == isLoadingMoreProducts) &&
            (identical(other.hasMoreProducts, hasMoreProducts) ||
                other.hasMoreProducts == hasMoreProducts) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.wishlistError, wishlistError) ||
                other.wishlistError == wishlistError) &&
            (identical(other.loadMoreError, loadMoreError) ||
                other.loadMoreError == loadMoreError));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    const DeepCollectionEquality().hash(_categories),
    const DeepCollectionEquality().hash(_trendingProducts),
    featuredBanner,
    isLoadingMoreProducts,
    hasMoreProducts,
    currentPage,
    errorMessage,
    wishlistError,
    loadMoreError,
  );

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      __$$HomeStateImplCopyWithImpl<_$HomeStateImpl>(this, _$identity);
}

abstract class _HomeState extends HomeState {
  const factory _HomeState({
    final HomeStatus status,
    final List<HomeCategory> categories,
    final List<HomeProduct> trendingProducts,
    final FeaturedBanner? featuredBanner,
    final bool isLoadingMoreProducts,
    final bool hasMoreProducts,
    final int currentPage,
    final String? errorMessage,
    final String? wishlistError,
    final String? loadMoreError,
  }) = _$HomeStateImpl;
  const _HomeState._() : super._();

  @override
  HomeStatus get status;
  @override
  List<HomeCategory> get categories;
  @override
  List<HomeProduct> get trendingProducts;
  @override
  FeaturedBanner? get featuredBanner;
  @override
  bool get isLoadingMoreProducts;
  @override
  bool get hasMoreProducts;
  @override
  int get currentPage;
  @override
  String? get errorMessage;
  @override
  String? get wishlistError;
  @override
  String? get loadMoreError;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
