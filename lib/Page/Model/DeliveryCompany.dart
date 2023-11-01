const String tableDeliveryCompany = 'deliveryCompany';

class DeliveryCompanyFields {
  static final List<String> values = [dcId, dcName,dcisRange,fixedDeliveryCost, shopId];

  static final String dcId = '_dcId';
  static final String dcName = 'dcName';
  static final String dcisRange = 'dcisRange';
  static final String fixedDeliveryCost = 'fixedDeliveryCost';
  static final String shopId = 'shopId';
}

class DeliveryCompanyModel {
  
  final int? dcId;
  final String dcName;
   final bool dcisRange;
   // TRUE / FALSE
   final int? fixedDeliveryCost;
  final int? shopId;

  DeliveryCompanyModel({
    this.dcId,
    required this.dcName,
    required this.dcisRange,
     this.fixedDeliveryCost,
    this.shopId,
  });
  DeliveryCompanyModel copy({
    int? dcId,
    String? dcName,
    bool? dcisRange,
    int? fixedDeliveryCost,
    int? shopId,
  }) =>
      DeliveryCompanyModel(
          dcId: dcId ?? this.dcId,
          dcName: dcName ?? this.dcName,
          dcisRange: dcisRange??this.dcisRange,
          fixedDeliveryCost: fixedDeliveryCost ?? this.fixedDeliveryCost,
          shopId: shopId ?? this.shopId);

  static DeliveryCompanyModel fromJson(Map<String, Object?> json) =>
      DeliveryCompanyModel(
        dcId: json[DeliveryCompanyFields.dcId] as int?,
        dcName: json[DeliveryCompanyFields.dcName] as String,
        dcisRange: json[DeliveryCompanyFields.dcisRange] == 1,
        fixedDeliveryCost: json[DeliveryCompanyFields.fixedDeliveryCost] as int?,
        shopId: json[DeliveryCompanyFields.shopId] as int?,
      );
  Map<String, Object?> toJson() => {
        DeliveryCompanyFields.dcId: dcId,
        DeliveryCompanyFields.dcName: dcName,
        DeliveryCompanyFields.dcisRange: dcisRange ? 1 : 0,
        DeliveryCompanyFields.fixedDeliveryCost:  fixedDeliveryCost,
        DeliveryCompanyFields.shopId: shopId,
      };
}
