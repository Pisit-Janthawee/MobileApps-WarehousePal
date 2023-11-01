const String tableCustomerAddress = 'customerAddress';

class CustomerAddressFields {
  static final List<String> values = [cAddreId, cAddress, cPhone, cusId];

  static final String cAddreId = '_addreId';
  static final String cAddress = 'cAddress';
  static final String cPhone = 'cPhone';
  static final String cusId = 'cusId';
}

class CustomerAddressModel {
  final int? cAddreId;
  final String cAddress;
  final String cPhone;
  final int? cusId;

  CustomerAddressModel({
    this.cAddreId,
    required this.cAddress,
    required this.cPhone,
    this.cusId,
  });
  CustomerAddressModel copy({
    int? addreId,
    String? cAddress,
    String? cPhone,
    int? cusId,
  }) =>
      CustomerAddressModel(
        cAddreId: addreId ?? this.cAddreId,
        cAddress: cAddress ?? this.cAddress,
        cPhone: cPhone ?? this.cPhone,
        cusId: cusId ?? this.cusId,
      );

  static CustomerAddressModel fromJson(Map<String, Object?> json) =>
      CustomerAddressModel(
        cAddreId: json[CustomerAddressFields.cAddreId] as int?,
        cAddress: json[CustomerAddressFields.cAddress] as String,
        cPhone: json[CustomerAddressFields.cPhone] as String,
        cusId: json[CustomerAddressFields.cusId] as int,
      );
  Map<String, Object?> toJson() => {
        CustomerAddressFields.cAddreId: cAddreId,
        CustomerAddressFields.cAddress: cAddress,
        CustomerAddressFields.cPhone: cPhone,
        CustomerAddressFields.cusId: cusId,
      };
}
