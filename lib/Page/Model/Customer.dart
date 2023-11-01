const String tableCustomer = 'customer';

class CustomerFields {
  static final List<String> values = [cusId, cName,shopId];

  static final String cusId = '_cusId';
  static final String cName = 'cName';
  static final String shopId = 'shopId';
}

class CustomerModel {
  final int? cusId;
  final String cName;
  final int? shopId;
  CustomerModel({
    this.cusId,
    required this.cName,
     this.shopId,
  });
  CustomerModel copy({
    int? dealerId,
    String? dName,
    int? shopId,

  }) =>
      CustomerModel(
        cusId: dealerId ?? this.cusId,
        cName: dName ?? this.cName,
        shopId: shopId?? this.shopId
      );

  static CustomerModel fromJson(Map<String, Object?> json) => CustomerModel(
        cusId: json[CustomerFields.cusId] as int?,
        cName: json[CustomerFields.cName] as String,
        shopId: json[CustomerFields.shopId] as int?,
      );
  Map<String, Object?> toJson() => {
        CustomerFields.cusId: cusId,
        CustomerFields.cName: cName,
        CustomerFields.shopId: shopId,
      };
}
