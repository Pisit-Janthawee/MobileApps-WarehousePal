const String tableProductModel_ndProperty = 'productModel_ndProperty';

class ProductModel_ndPropertyFields {
  static final List<String> values = [pmndPropId, pmndPropName, prodModelId];

  static final String pmndPropId = 'pmndPropId';
  static final String pmndPropName = 'pmndPropName';
  static final String prodModelId = 'prodModelId';
}

class ProductModel_ndProperty {
  final int? pmndPropId;
  final String pmndPropName;
  final int? prodModelId;

  ProductModel_ndProperty({
    this.pmndPropId,
    required this.pmndPropName,
    this.prodModelId,
  });
  ProductModel_ndProperty copy({
    int? pmndPropId,
    String? pmndPropName,
    int? prodModelId,
  }) =>
      ProductModel_ndProperty(
        pmndPropId: pmndPropId ?? this.pmndPropId,
        pmndPropName: pmndPropName ?? this.pmndPropName,
        prodModelId: prodModelId ?? this.prodModelId,
      );
  static ProductModel_ndProperty fromJson(Map<String, Object?> json) =>
      ProductModel_ndProperty(
        pmndPropId: json[ProductModel_ndPropertyFields.pmndPropId] as int,
        pmndPropName:
            json[ProductModel_ndPropertyFields.pmndPropName] as String,
        prodModelId: json[ProductModel_ndPropertyFields.prodModelId] as int,
      );
  Map<String, Object?> toJson() => {
        ProductModel_ndPropertyFields.pmndPropId: pmndPropId,
        ProductModel_ndPropertyFields.pmndPropName: pmndPropName,
        ProductModel_ndPropertyFields.prodModelId: prodModelId,
      };
}
