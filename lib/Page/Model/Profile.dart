const String tableProfile = 'profile';

class ProfileFields {
  static final List<String> values = [
    id,
    name,
    phone,
    image,
    loginDateTime,
    isDisable,
    isDarkTheme,
    pin
  ];

  static final String id = '_id';
  static final String name = 'name';
  static final String phone = 'phone';
  static final String image = 'image';
  static final String loginDateTime = 'loginDateTime';
  static final String isDisable = 'isDisable';
  static final String isDarkTheme = 'isDarkTheme';
  static final String pin = 'pin';
}

class Profile {
  final int? id;
  final String name;
  late final String phone;
  final String image;
  final DateTime? loginDateTime;
  final bool isDisable;
  final bool isDarkTheme;
  final String pin;

  Profile({
    this.id,
    required this.name,
    required this.phone,
    required this.image,
    this.loginDateTime,
    required this.isDisable,
    required this.isDarkTheme,
    required this.pin,
  });
  Profile copy({
    int? id,
    String? name,
    String? phone,
    String? image,
    DateTime? loginDateTime,
    bool? isDisable,
    bool? isDarkTheme,
    String? pin,
  }) =>
      Profile(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        image: image ?? this.image,
        loginDateTime: loginDateTime ?? this.loginDateTime,
        isDisable: isDisable ?? this.isDisable,
        isDarkTheme: isDarkTheme ?? this.isDarkTheme,
        pin: pin ?? this.pin,
      );
  static Profile fromJson(Map<String, Object?> json) => Profile(
        id: json[ProfileFields.id] as int,
        name: json[ProfileFields.name] as String,
        phone: json[ProfileFields.phone] as String,
        image: json[ProfileFields.image] as String,
        loginDateTime: json[ProfileFields.loginDateTime] == null
            ? null
            : DateTime.parse(json[ProfileFields.loginDateTime] as String),
        isDisable: json[ProfileFields.isDisable] == 1,
        isDarkTheme: json[ProfileFields.isDarkTheme] == 1,
        pin: json[ProfileFields.pin] as String,
      );
  Map<String, Object?> toJson() => {
        ProfileFields.id: id,
        ProfileFields.name: name,
        ProfileFields.phone: phone,
        ProfileFields.image: image,
        ProfileFields.loginDateTime: loginDateTime?.toIso8601String(),
        ProfileFields.isDisable: isDisable ? 1 : 0,
        ProfileFields.isDarkTheme: isDarkTheme ? 1 : 0,
        ProfileFields.pin: pin,
      };
}
