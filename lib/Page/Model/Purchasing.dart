const String tablePurchasing = 'purchasing';

class PurchasingFields {
  static final List<String> values = [
    purId,
    orderedDate,
    dealerId,

    shippingCost,
    amount,
    total,
    isReceive,
    shopId
  ];

  static final String purId = '_purId';
  static final String orderedDate = 'orderedDate';
  static final String dealerId = 'dealerId';
 
  static final String shippingCost = 'shippingCost';
  static final String amount = 'amount';
  static final String total = 'total';
  static final String isReceive = 'isReceive';
  static final String shopId = 'shopId';
}

class PurchasingModel {
  final int? purId;
  final DateTime orderedDate;
  final int dealerId;

  final int shippingCost;
  final int amount;
  final int total;
  final bool isReceive;
  final int? shopId;

  PurchasingModel(
      {this.purId,
      required this.orderedDate,
      required this.dealerId,
   
      required this.shippingCost,
      required this.amount,
      required this.total,
      required this.isReceive,
      required this.shopId});
  PurchasingModel copy({
    int? purId,
    DateTime? orderedDate,
    int? dealerId,
    String? shippingMedthod,
    int? shippingCost,
    int? amount,
    int? total,
    bool? isReceive,
    int? shopId,
  }) =>
      PurchasingModel(
          purId: purId ?? this.purId,
          orderedDate: orderedDate ?? this.orderedDate,
          dealerId: dealerId ?? this.dealerId,
      
          shippingCost: shippingCost ?? this.shippingCost,
          amount: amount ?? this.amount,
          total: total ?? this.total,
          isReceive: isReceive ?? this.isReceive,
          shopId: shopId ?? this.shopId);
  static PurchasingModel fromJson(Map<String, Object?> json) => PurchasingModel(
        purId: json[PurchasingFields.purId] as int?,
        orderedDate:
            DateTime.parse(json[PurchasingFields.orderedDate] as String),
        dealerId: json[PurchasingFields.dealerId] as int,
     
        shippingCost: json[PurchasingFields.shippingCost] as int,
        amount: json[PurchasingFields.amount] as int,
        total: json[PurchasingFields.total] as int,
        isReceive: json[PurchasingFields.isReceive] == 1,
        shopId: json[PurchasingFields.shopId] as int,
      );
  Map<String, Object?> toJson() => {
        PurchasingFields.purId: purId,
        PurchasingFields.orderedDate: orderedDate.toIso8601String(),
        PurchasingFields.dealerId: dealerId,
       
        PurchasingFields.shippingCost: shippingCost,
        PurchasingFields.amount: amount,
        PurchasingFields.total: total,
        PurchasingFields.isReceive: isReceive ? 1 : 0,
        PurchasingFields.shopId: shopId,
      };
}
