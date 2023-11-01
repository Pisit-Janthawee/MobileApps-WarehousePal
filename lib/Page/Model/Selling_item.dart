const String tableSellingItem = 'sellingItem';

class SellingItemFields {
  static final List<String> values = [
    selItemId,
    prodId,
    prodModelId,
    prodLotId,
    amount,
    total,
    selId
  ];

  static final String selItemId = '_selItemId';
  static final String prodId = 'prodId';
  static final String prodModelId = 'prodModelId';
  static final String prodLotId = 'prodLotId';
  static final String amount = 'amount';
  static final String total = 'total';
  static final String selId = 'selId';
}

class SellingItemModel {
  final int? selItemId;
  final int? prodId;
  final int? prodModelId;
  final int? prodLotId;
  final int amount;
  final int total;
  final int? selId;

  SellingItemModel({
    this.selItemId,
    this.prodId,
    required this.prodModelId,
     required this.prodLotId,
    required this.amount,
    required this.total,
    this.selId,
  });
  SellingItemModel copy({
    int? selItemId,
    int? prodId,
    int? prodModelId,
    int? amount,
    int? total,
    int? selId,
  }) =>
      SellingItemModel(
        selItemId: selItemId ?? this.selItemId,
        prodId: prodId ?? this.prodId,
        prodModelId: prodModelId ?? this.prodModelId,
        prodLotId: prodLotId ?? this.prodLotId,
        amount: amount ?? this.amount,
        total: total ?? this.total,
        selId: selId ?? this.selId,
      );

  static SellingItemModel fromJson(Map<String, Object?> json) =>
      SellingItemModel(
        selItemId: json[SellingItemFields.selItemId] as int?,
        prodId: json[SellingItemFields.prodId] as int,
        prodModelId: json[SellingItemFields.prodModelId] as int,
        prodLotId: json[SellingItemFields.prodLotId] as int,
        amount: json[SellingItemFields.amount] as int,
        total: json[SellingItemFields.total] as int,
        selId: json[SellingItemFields.selId] as int,
      );
  Map<String, Object?> toJson() => {
        SellingItemFields.selItemId: selItemId,
        SellingItemFields.prodId: prodId,
        SellingItemFields.prodModelId: prodModelId,
        SellingItemFields.prodLotId: prodLotId,
        SellingItemFields.amount: amount,
        SellingItemFields.total: total,
        SellingItemFields.selId: selId,
      };
}
