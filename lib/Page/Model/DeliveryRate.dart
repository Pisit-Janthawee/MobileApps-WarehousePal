const String tableDeliveryRate = 'deliveryRate';

class DeliveryRateFields {
  static final List<String> values = [rId, weightRange, cost, dcId];

  static final String rId = '_rId';
  static final String weightRange = 'weightRange';
  static final String cost = 'cost';
  static final String dcId = 'dcId';
}

class DeliveryRateModel {
  final int? rId;
  final String weightRange;
  final int cost;
  final int? dcId;

  
  DeliveryRateModel({
    this.rId,
    required this.weightRange,
    required this.cost,
    this.dcId,
  });
  DeliveryRateModel copy({
    int? rId,
    String? weightRange,
    int? cost,
    int? dcId,
  }) =>
      DeliveryRateModel(
          rId: rId ?? this.rId,
          weightRange: weightRange ?? this.weightRange,
          cost: cost ?? this.cost,
          dcId: dcId ?? this.dcId);

  static DeliveryRateModel fromJson(Map<String, Object?> json) =>
      DeliveryRateModel(
        rId: json[DeliveryRateFields.rId] as int?,
        weightRange: json[DeliveryRateFields.weightRange] as String,
        cost: json[DeliveryRateFields.cost] as int,
        dcId: json[DeliveryRateFields.dcId] as int?,
      );
  Map<String, Object?> toJson() => {
        DeliveryRateFields.rId: rId,
        DeliveryRateFields.weightRange: weightRange,
        DeliveryRateFields.cost: cost,
        DeliveryRateFields.dcId: dcId,
      };
}
