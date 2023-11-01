const String tableProductLot = 'productLot';

class ProductLotFields {
  static final List<String> values = [
    prodLotId,
    orderedTime,
    amount,
    remainAmount,
    purId,
    isReceived,
    prodModelId
  ];
  static final String prodLotId = 'prodLotId';
  static final String orderedTime = 'orderedTime';
  static final String amount = 'amount';
  static final String remainAmount = 'remainAmount';
  static final String purId = 'purId';
  static final String isReceived = 'isReceived';
  static final String prodModelId = 'prodModelId';
}

class ProductLot {
  final int? prodLotId;
  final DateTime? orderedTime;
  final String? amount;
  final int remainAmount;
  final int? purId;
  final bool isReceived;
  final int? prodModelId;

  ProductLot({
    this.prodLotId,
    this.orderedTime,
    this.amount,
    required this.remainAmount,
    this.purId,
    required this.isReceived,
    this.prodModelId,
  });
  ProductLot copy({
    int? prodLotId,
    DateTime? orderedTime,
    String? amount,
    int? remainAmount,
    int? purId,
    bool? isReceived,
    int? prodModelId,
  }) =>
      ProductLot(
        prodLotId: prodLotId ?? this.prodLotId,
        orderedTime: orderedTime ?? this.orderedTime,
        amount: amount ?? this.amount,
        remainAmount: remainAmount ?? this.remainAmount,
        purId: purId ?? this.purId,
        isReceived: isReceived ?? this.isReceived,
        prodModelId: prodModelId ?? this.prodModelId,
      );
  static ProductLot fromJson(Map<String, Object?> json) => ProductLot(
        prodLotId: json[ProductLotFields.prodLotId] as int,
        orderedTime:
            DateTime.parse(json[ProductLotFields.orderedTime] as String),
        amount: json[ProductLotFields.amount] as String,
        remainAmount: json[ProductLotFields.remainAmount] as int,
        purId: json[ProductLotFields.purId] as int,
        isReceived: json[ProductLotFields.isReceived] == 1,
        prodModelId: json[ProductLotFields.prodModelId] as int,
      );
  Map<String, Object?> toJson() => {
        ProductLotFields.prodLotId: prodLotId,
        ProductLotFields.orderedTime: orderedTime?.toIso8601String(),
        ProductLotFields.amount: amount,
        ProductLotFields.remainAmount: remainAmount,
        ProductLotFields.purId: purId,
        ProductLotFields.isReceived: isReceived ? 1 : 0,
        ProductLotFields.prodModelId: prodModelId,
      };
}
