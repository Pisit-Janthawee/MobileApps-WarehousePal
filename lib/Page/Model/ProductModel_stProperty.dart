const String tableProductModel_stProperty = 'productModel_stProperty';

class ProductModel_stPropertyFields {
  static final List<String> values = [pmstPropId, pmstPropName, prodModelId];

  static final String pmstPropId = 'pmstPropId';
  static final String pmstPropName = 'pmstPropName';
  static final String prodModelId = 'prodModelId';
}

class ProductModel_stProperty {
  final int? pmstPropId;
  final String pmstPropName;
  final int? prodModelId;

  ProductModel_stProperty({
    this.pmstPropId,
    required this.pmstPropName,
    this.prodModelId,
  });
  ProductModel_stProperty copy({
    int? pmstPropId,
    String? pmstPropName,
    int? prodModelId,
  }) =>
      ProductModel_stProperty(
        pmstPropId: pmstPropId ?? this.pmstPropId,
        pmstPropName: pmstPropName ?? this.pmstPropName,
        prodModelId: prodModelId ?? this.prodModelId,
      );
  static ProductModel_stProperty fromJson(Map<String, Object?> json) =>
      ProductModel_stProperty(
        pmstPropId: json[ProductModel_stPropertyFields.pmstPropId] as int,
        pmstPropName:
            json[ProductModel_stPropertyFields.pmstPropName] as String,
        prodModelId: json[ProductModel_stPropertyFields.prodModelId] as int,
      );
  Map<String, Object?> toJson() => {
        ProductModel_stPropertyFields.prodModelId: pmstPropId,
        ProductModel_stPropertyFields.pmstPropName: pmstPropName,
        ProductModel_stPropertyFields.prodModelId: pmstPropId,
      };
}
