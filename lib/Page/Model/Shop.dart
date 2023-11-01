const String tableShop = 'shop';

class ShopFields {
  static final List<String> values = [
    shopid,
    name,
    phone,
    image,
    dcId,
    profileId
  ];

  static final String shopid = '_shopid';
  static final String name = 'name';
  static final String phone = 'phone';
  static final String image = 'image';
  static final String dcId = 'dcId';
  static final String profileId = 'profileId';
}

class Shop {
  final int? shopid;
  final String name;
  final String phone;
  final String image;
  final int? dcId;
  final int profileId;

  Shop({
    this.shopid,
    required this.name,
    required this.phone,
    required this.image,
    this.dcId,
    required this.profileId,
  });
  Shop copy({
    int? shopid,
    String? name,
    String? phone,
    String? image,
    int? dcId,
    int? profileId,
  }) =>
      Shop(
        shopid: shopid ?? this.shopid,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        image: image ?? this.image,
        dcId: dcId ?? this.dcId,
        profileId: profileId ?? this.profileId,
      );
  static Shop fromJson(Map<String, Object?> json) => Shop(
        shopid: json[ShopFields.shopid] as int,
        name: json[ShopFields.name] as String,
        phone: json[ShopFields.phone] as String,
        image: json[ShopFields.image] as String,
        dcId: json[ShopFields.dcId] as int?,
        profileId: json[ShopFields.profileId] as int,
      );
  Map<String, Object?> toJson() => {
        ShopFields.shopid: shopid,
        ShopFields.name: name,
        ShopFields.phone: phone,
        ShopFields.image: image,
        ShopFields.dcId: dcId,
        ShopFields.profileId: profileId,
      };
}
