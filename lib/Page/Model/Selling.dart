const String tableSelling = 'selling';

class SellingFields {
  static final List<String> values = [
    selId,
    orderedDate,
    customerId,
    cAddreId,
    deliveryCompanyId,
    shippingCost,
    amount,
    discountPercent,
    total,
    profit,
    speacialReq,
    isDelivered,
    shopId
  ];

  static final String selId = 'selId';
  static final String orderedDate = 'orderedDate';
  static final String customerId = 'customerId';
  static final String cAddreId = 'cAddreId';
  static final String deliveryCompanyId = 'deliveryCompanyId';
  static final String shippingCost = 'shippingCost';
  static final String amount = 'amount';
  static final String discountPercent = 'discountPercent';
  static final String total = 'total';
  static final String profit = 'profit';

  static final String speacialReq = 'speacialReq';
  static final String isDelivered = 'isDelivered';
  static final String shopId = 'shopId';
}

class SellingModel {
  final int? selId;
  final DateTime orderedDate;
  final int customerId;
  final int cAddreId;
  final int? deliveryCompanyId;
  final int shippingCost;
  final int amount;
  final int discountPercent;
  final int total;
  final int profit;
  final String? speacialReq;
  final bool isDelivered;
  final int? shopId;

  SellingModel(
      {this.selId,
      required this.orderedDate,
      required this.customerId,
      required this.cAddreId,
      required this.deliveryCompanyId,
      required this.shippingCost,
      required this.amount,
      required this.discountPercent,
      required this.total,
      required this.profit,
      required this.speacialReq,
      required this.isDelivered,
      required this.shopId});
  SellingModel copy({
    int? selId,
    DateTime? orderedDate,
    int? customerId,
    int? cAddreId,
    int? shippingCost,
    String? shipping,
    int? amount,
    int? discountPercent,
    int? total,
    int? profit,
    String? speacialReq,
    bool? isDelivered,
    int? shopId,
  }) =>
      SellingModel(
          selId: selId ?? this.selId,
          orderedDate: orderedDate ?? this.orderedDate,
          customerId: customerId ?? this.customerId,
          cAddreId: cAddreId ?? this.cAddreId,
          deliveryCompanyId: deliveryCompanyId ?? this.deliveryCompanyId,
          shippingCost: shippingCost ?? this.shippingCost,
          amount: amount ?? this.amount,
          discountPercent: discountPercent ?? this.discountPercent,
          total: total ?? this.total,
          profit: profit ?? this.profit,
          speacialReq: speacialReq ?? this.speacialReq,
          isDelivered: isDelivered ?? this.isDelivered,
          shopId: shopId ?? this.shopId);
  static SellingModel fromJson(Map<String, Object?> json) => SellingModel(
        selId: json[SellingFields.selId] as int?,
        orderedDate: DateTime.parse(json[SellingFields.orderedDate] as String),
        customerId: json[SellingFields.customerId] as int,
        cAddreId: json[SellingFields.cAddreId] as int,
        deliveryCompanyId: json[SellingFields.deliveryCompanyId] as int?,
        shippingCost: json[SellingFields.shippingCost] as int,
        amount: json[SellingFields.amount] as int,
        discountPercent: json[SellingFields.discountPercent] as int,
        total: json[SellingFields.total] as int,
        profit: json[SellingFields.profit] as int,
        speacialReq: json[SellingFields.speacialReq] as String,
        isDelivered: json[SellingFields.isDelivered] == 1,
        shopId: json[SellingFields.shopId] as int,
      );
  Map<String, Object?> toJson() => {
        SellingFields.selId: selId,
        SellingFields.orderedDate: orderedDate.toIso8601String(),
        SellingFields.customerId: customerId,
        SellingFields.cAddreId: cAddreId,
        SellingFields.deliveryCompanyId: deliveryCompanyId,
        SellingFields.shippingCost: shippingCost,
        SellingFields.amount: amount,
        SellingFields.speacialReq: speacialReq,
        SellingFields.discountPercent: discountPercent,
        SellingFields.total: total,
        SellingFields.profit: profit,
        SellingFields.isDelivered: isDelivered ? 1 : 0,
        SellingFields.shopId: shopId,
      };
}
