// Main.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// Theme

import 'package:warehouse_mnmt/Page/Model/Shop.dart';
import 'package:warehouse_mnmt/Page/Profile/NewUser/1_welcomePage.dart';
import 'package:warehouse_mnmt/Page/Profile/NewUser/2_addName.dart';
import 'package:warehouse_mnmt/Page/Profile/NormalUser/0_InputPin.dart';
import 'package:warehouse_mnmt/Page/Profile/NormalUser/DisableWrongPin.dart';
import 'package:warehouse_mnmt/Page/Shop/main_selling.dart';
import 'package:warehouse_mnmt/Page/Shop/main_shop.dart';
import 'package:warehouse_mnmt/Page/Provider/theme_provider.dart';
import 'package:warehouse_mnmt/db/database.dart';

// Import Page
import 'Page/Model/Profile.dart';
import 'Page/Profile/AllShop.dart';
import 'Page/Shop/main_buying.dart';
import 'Page/Shop/main_dashboard.dart';
import 'Page/Shop/main_product.dart';

void main() {
  var app = const MyApp();
  runApp(app);
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Profile? profile;

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  Future getProfile() async {
    profile = await DatabaseManager.instance.readProfile(1);
    setState(() {});
    print('Welcome Found Profile !${profile?.name}');
  }

  _decideMainPage(Profile? profile) {
    if (profile != null) {
      DateTime? loginTime = profile.loginDateTime == null
          ? null
          : DateTime.parse(
              DateFormat("yyyy-MM-dd hh:mm:ss").format(profile.loginDateTime!));
      DateTime now = DateTime.now();

      if (profile.isDisable == false) {
        return InputPinPage(profile: profile);
      } else {
        return DisableWrongPinPage(
          profile: profile,
        );
      }
    } else {
      return const BuildingScreen();
    }
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      builder: (context, _) {
        final themeProvider = Provider.of<ThemeProvider>(context);

        return MaterialApp(
          theme: MyThemes.lightTheme,
          darkTheme: MyThemes.darkTheme,
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
          home: _decideMainPage(profile),
        );
      });
}

class MyHomePage extends StatefulWidget {
  final Shop shop;
  final Profile profile;

  const MyHomePage({required this.shop, Key? key, required this.profile})
      : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentIndex = 0;
  late Shop shop = widget.shop;
  Future refreshShop() async {
    shop = await DatabaseManager.instance.readShop(widget.shop.shopid!);
    setState(() {});
  }

  Widget build(BuildContext context) {
    final screens = [
      DashboardPage(shop: shop),
      SellingPage(shop: shop),
      BuyingPage(shop: shop),
      ProductPage(shop: shop),
      ShopPage(Profile: widget.profile, shop: shop),
    ];

    return Scaffold(
      extendBody: true,
      body: screens[currentIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => setState(() {
            currentIndex = index;
            refreshShop();
          }),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.add_chart_rounded),
              label: "ภาพรวม",
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("assets/Icons/WhiteSellingIcon.png"),
              ),
              label: "ขายสินค้า",
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("assets/Icons/WhiteBuyingIcon.png"),
              ),
              label: "สั่งซื้อสินค้า",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.warehouse),
              label: "สินค้า",
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.store_mall_directory_rounded),
                label: "ร้านของฉัน"),
          ],
        ),
      ),
    );
  }
}
