const String tableProductCategory = 'productCategory';

class ProductCategoryFields {
  static final List<String> values = [prodCategId, prodCategName, shopId];

  static final String prodCategId = 'prodCategId';
  static final String prodCategName = 'prodCategName';
  static final String shopId = 'shopId';
}

class ProductCategory {
  final int? prodCategId;
  final String prodCategName;
  final int? shopId;

  ProductCategory({
    this.prodCategId,
    required this.prodCategName,
    this.shopId,
  });
  ProductCategory copy({
    int? prodCategId,
    String? prodCategName,
    int? shopId,
  }) =>
      ProductCategory(
        prodCategId: prodCategId ?? this.prodCategId,
        prodCategName: prodCategName ?? this.prodCategName,
        shopId: shopId ?? this.shopId,
      );
  static ProductCategory fromJson(Map<String, Object?> json) => ProductCategory(
        prodCategId: json[ProductCategoryFields.prodCategId] as int,
        prodCategName: json[ProductCategoryFields.prodCategName] as String,
        shopId: json[ProductCategoryFields.shopId] as int,
      );
  Map<String, Object?> toJson() => {
        ProductCategoryFields.prodCategId: prodCategId,
        ProductCategoryFields.prodCategName: prodCategName,
        ProductCategoryFields.shopId: shopId,
      };
}
