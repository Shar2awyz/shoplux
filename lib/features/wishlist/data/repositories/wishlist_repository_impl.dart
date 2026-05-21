import 'package:shoplux/features/home/domain/models/home_product.dart';
import 'package:shoplux/features/wishlist/data/datasources/wishlist_remote_data_source.dart';
import 'package:shoplux/features/wishlist/domain/repositories/wishlist_repository.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  const WishlistRepositoryImpl({required WishlistRemoteDataSource dataSource})
      : _dataSource = dataSource;

  final WishlistRemoteDataSource _dataSource;

  @override
  Future<List<HomeProduct>> getWishlistItems() => _dataSource.getWishlistItems();

  @override
  Future<void> removeFromWishlist({required String productId}) =>
      _dataSource.removeFromWishlist(productId: productId);
}
