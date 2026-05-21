import 'package:shoplux/features/product_detail/data/datasources/product_detail_remote_data_source.dart';
import 'package:shoplux/features/product_detail/domain/models/product_extras.dart';
import 'package:shoplux/features/product_detail/domain/repositories/product_detail_repository.dart';

class ProductDetailRepositoryImpl implements ProductDetailRepository {
  const ProductDetailRepositoryImpl({required this.dataSource});

  final ProductDetailRemoteDataSource dataSource;

  @override
  Future<ProductExtras> getProductExtras(String productId) =>
      dataSource.getProductExtras(productId);

  @override
  Future<void> toggleWishlist({
    required String productId,
    required bool isWishlisted,
  }) => dataSource.toggleWishlist(
        productId: productId,
        isWishlisted: isWishlisted,
      );
}
