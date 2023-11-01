import 'dart:io';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'package:warehouse_mnmt/Page/Model/Customer.dart';
import 'package:warehouse_mnmt/Page/Model/CustomerAdress.dart';
import 'package:warehouse_mnmt/Page/Model/Product.dart';
import 'package:warehouse_mnmt/Page/Model/ProductLot.dart';
// Component

import 'package:warehouse_mnmt/Page/Model/Selling.dart';
import 'package:warehouse_mnmt/Page/Model/Selling_item.dart';
import 'package:warehouse_mnmt/Page/Model/Shop.dart';
import 'package:warehouse_mnmt/Page/Provider/theme_provider.dart';
import 'package:warehouse_mnmt/Page/Shop/Selling/nav_edit.dart';
import 'package:warehouse_mnmt/Page/Shop/main_shop.dart';

import '../../db/database.dart';
import '../Component/MoneyBox.dart';
import 'package:warehouse_mnmt/Page/Component/TextField/CustomTextField.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../Model/Purchasing.dart';

class DashboardPage extends StatefulWidget {
  final Shop shop;
  DashboardPage({required this.shop, Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DateTime date = DateTime.now();
  String rangeDate = '-';
  final DateRangePickerController _controller = DateRangePickerController();

  ThemeMode themeMode = ThemeMode.light;
  bool get isDark => themeMode == ThemeMode.dark;
  List<Color> gradientColors = [
    Color.fromARGB(255, 160, 119, 255),
    Color.fromRGBO(29, 29, 65, 1.0),
  ];

  List<Color> purchasingGradientColors = [
    Color.fromARGB(255, 141, 106, 225),
    Color.fromRGBO(29, 29, 65, 1.0)
  ];
  List<Color> sellingGradientColors = [
    Color.fromARGB(255, 255, 40, 40),
    Color.fromARGB(255, 135, 97, 0)
  ];
  List<Color> profitGradientColors = [
    Color.fromARGB(255, 40, 255, 126),
    Color.fromARGB(255, 0, 116, 60)
  ];
  bool isShowPurchasing = true;
  bool isShowSelling = true;
  bool isShowProfit = true;

  List<PurchasingModel> purchasings = [];
  List<SellingModel> sellings = [];
  List<CustomerModel> customers = [];
  List<Product> products = [];
  var tabbarSelectedIndex = 0;
  var sale = 0;
  var cost = 0;
  var profit = 0;
  bool isToday = true;
  late PageController _pageController;
  int activePage = 1;
  late Shop shop = widget.shop;
  @override
  void initState() {
    initializeDateFormatting();

    super.initState();
    refreshPage();
    _pageController = PageController(viewportFraction: 0.8);
    setState(() {});
  }

  Future refreshShop() async {
    shop = await DatabaseManager.instance.readShop(widget.shop.shopid!);
    setState(() {});
  }

  tabbarChanging() async {
    if (tabbarSelectedIndex == 0) {
      // Today
      var start = DateTime(date.year, date.month, date.day - 1, 0);
      var end = DateTime(date.year, date.month, date.day + 1, 0);

      purchasings = await DatabaseManager.instance
          .readPurchasingsWHEREisReceivedANDRangeDate(
              'Today',
              start.toIso8601String(),
              end.toIso8601String(),
              widget.shop.shopid!);
      sellings = await DatabaseManager.instance
          .readSellingsWHEREisReceivedANDRangeDate(
              'Today',
              start.toIso8601String(),
              end.toIso8601String(),
              widget.shop.shopid!);

      _calculateDashboard(sale, cost, profit);
      setState(() {});
    } else if (tabbarSelectedIndex == 1) {
      // Week
      var start = DateTime(date.year, date.month, 1);
      var end = DateTime(date.year, date.month, date.day + 1);

      purchasings = await DatabaseManager.instance
          .readPurchasingsWHEREisReceivedANDRangeDate(
              'Week',
              start.toIso8601String(),
              end.toIso8601String(),
              widget.shop.shopid!);
      sellings = await DatabaseManager.instance
          .readSellingsWHEREisReceivedANDRangeDate(
              'Week',
              start.toIso8601String(),
              end.toIso8601String(),
              widget.shop.shopid!);

      _calculateDashboard(sale, cost, profit);
      setState(() {});
      print('purchasings (${purchasings.length})');
    } else if (tabbarSelectedIndex == 2) {
      // Month
      var start = DateTime(date.year - 1, date.month, date.day);
      var end = DateTime(date.year, date.month, date.day + 1, 0);
      purchasings = await DatabaseManager.instance
          .readPurchasingsWHEREisReceivedANDRangeDate(
              'Month',
              start.toIso8601String(),
              end.toIso8601String(),
              widget.shop.shopid!);
      sellings = await DatabaseManager.instance
          .readSellingsWHEREisReceivedANDRangeDate(
              'Month',
              start.toIso8601String(),
              end.toIso8601String(),
              widget.shop.shopid!);

      _calculateDashboard(sale, cost, profit);
      setState(() {});
    } else if (tabbarSelectedIndex == 3) {
// Year
      var start = DateTime(date.year - 10, date.month, date.day);
      var end = DateTime(date.year, date.month, date.day + 1);
      purchasings = await DatabaseManager.instance
          .readPurchasingsWHEREisReceivedANDRangeDate(
              'Year',
              start.toIso8601String(),
              end.toIso8601String(),
              widget.shop.shopid!);
      sellings = await DatabaseManager.instance
          .readSellingsWHEREisReceivedANDRangeDate(
              'Year',
              start.toIso8601String(),
              end.toIso8601String(),
              widget.shop.shopid!);

      _calculateDashboard(sale, cost, profit);
      setState(() {});
    } else if (tabbarSelectedIndex == 4) {
      // ระบุวัน
      var start = DateTime(date.year - 1, date.month, date.day);
      var end = DateTime(date.year, date.month, date.day);
      purchasings = await DatabaseManager.instance
          .readPurchasingsWHEREisReceivedANDRangeDate(
              'Year',
              start.toIso8601String(),
              end.toIso8601String(),
              widget.shop.shopid!);
      sellings = await DatabaseManager.instance
          .readSellingsWHEREisReceivedANDRangeDate(
              'Month',
              start.toIso8601String(),
              end.toIso8601String(),
              widget.shop.shopid!);

      _calculateDashboard(sale, cost, profit);
      setState(() {});
    }
  }

  _returnMaxAxis(tabbarSelectedIndex) {
    if (tabbarSelectedIndex == 0) {
      // Today
      return 24.0;
    } else if (tabbarSelectedIndex == 1) {
      // Week
      return date.day.toDouble();
    } else if (tabbarSelectedIndex == 2) {
      // Month
      return 12.0;
    } else {
      // Year
      return 10.0;
    }
  }

  _returnMaxYAxis() {
    if (purchasings.isNotEmpty && sellings.isNotEmpty) {
      var maxPurchasing = purchasings
          .reduce((curr, next) => curr.total > next.total ? curr : next);

      var maxSelling = sellings
          .reduce((curr, next) => curr.total > next.total ? curr : next);

      return maxPurchasing.total > maxSelling.total
          ? maxPurchasing.total.toDouble()
          : maxSelling.total.toDouble();
    } else if (sellings.isEmpty && purchasings.isNotEmpty) {
      var maxPurchasing = purchasings
          .reduce((curr, next) => curr.total > next.total ? curr : next);
      return maxPurchasing.total.toDouble();
    } else {
      var maxSelling = sellings
          .reduce((curr, next) => curr.total > next.total ? curr : next);
      return maxSelling.total.toDouble();
    }
  }

  List<Widget> sellingIndicators(sellingLength) {
    return List<Widget>.generate(sellingLength, (index) {
      return Container(
        margin: EdgeInsets.all(3),
        width: 10,
        height: 10,
        decoration:
            BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
      );
    });
  }

  List<Widget> productIndicators(imagesLength, currentIndex) {
    return List<Widget>.generate(imagesLength, (index) {
      return Container(
        margin: EdgeInsets.all(3),
        width: 10,
        height: 10,
        decoration: BoxDecoration(
            color: currentIndex == index ? Colors.black : Colors.black26,
            shape: BoxShape.circle),
      );
    });
  }

  List<CustomerAddressModel> addresses = [];

  Future refreshPage() async {
    products =
        await DatabaseManager.instance.readAllProducts(widget.shop.shopid!);
    purchasings = await DatabaseManager.instance
        .readPurchasingsWHEREisReceivedANDToday(widget.shop.shopid!);
    addresses = await DatabaseManager.instance
        .readCustomerAllAddress(widget.shop.shopid!);
    sellings = await DatabaseManager.instance
        .readAllSellingsORDERBYPresentForGraph(widget.shop.shopid!);
    customers = await DatabaseManager.instance
        .readAllCustomerInShop(widget.shop.shopid!);

    _calculateDashboard(sale, cost, profit);
    setState(() {});
  }

  _calculateDashboard(_sale, _cost, _profit) {
    _cost = 0;
    _sale = 0;
    _profit = 0;
    for (var purchasing in purchasings) {
      _cost += purchasing.total;
    }
    for (var selling in sellings) {
      _sale += selling.total;
      _profit += selling.profit;
    }
    cost = _cost;
    sale = _sale;
    profit = _profit;
  }

  List<FlSpot> gatherPurData() {
    List<FlSpot> spotPurchasingList = [];
    // List<FlSpot> removedSpotWeightList = [];
    for (var pur in purchasings) {
      spotPurchasingList
          .add(FlSpot(pur.amount.toDouble(), pur.total.toDouble()));
    }
    return spotPurchasingList;
  }

  dialogPickDateTimeRange(themeProvider) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dContext, DialogSetState) {
          return AlertDialog(
            backgroundColor: themeProvider.isDark
                ? Theme.of(context).colorScheme.onSecondary
                : Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            title: Container(
              height: 80,
              width: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.date_range_rounded,
                    color: Colors.white,
                  ),
                  Text(
                    'ระบุช่วง',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            content: Container(
              width: 200,
              height: 200,
              child: SfDateRangePicker(
                controller: _controller,
                view: DateRangePickerView.month,
                selectionMode: DateRangePickerSelectionMode.range,

                // Style
                selectionTextStyle: const TextStyle(color: Colors.white),
                selectionColor: Colors.blue,
                startRangeSelectionColor:
                    Theme.of(dContext).colorScheme.primary,
                endRangeSelectionColor: Theme.of(dContext).colorScheme.primary,
                rangeSelectionColor: Theme.of(context).backgroundColor,
                rangeTextStyle:
                    const TextStyle(color: Colors.white, fontSize: 18),
                selectionRadius: 10,
                selectionShape: DateRangePickerSelectionShape.circle,
                todayHighlightColor: Theme.of(context).backgroundColor,

                // Style
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.redAccent),
                child: const Text('ยกเลิก'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                child: const Text('เลือกวัน'),
                onPressed: () async {
                  if (_controller.selectedRange != null) {
                    var start = _controller.selectedRange!.startDate;
                    var end = _controller.selectedRange!.endDate;
                    purchasings = await DatabaseManager.instance
                        .readPurchasingsWHEREisReceivedANDRangeDate(
                            'Year',
                            start!.toIso8601String(),
                            end!.toIso8601String(),
                            widget.shop.shopid!);
                    rangeDate =
                        '${DateFormat('yyyy-MM-dd').format(start)} ถึง ${DateFormat('yyyy-MM-dd').format(end)}';
                    _calculateDashboard(sale, cost, profit);

                    setState(() {});
                  }

                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat;
    dateFormat = new DateFormat.yMMMMd('th');
    final themeProvider = Provider.of<ThemeProvider>(context);
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(130),
          child: AppBar(
            // backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: const Text(
              "ภาพรวม ",
              textAlign: TextAlign.start,
            ),
            flexibleSpace: Center(
                child: Baseline(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(shop.name, style: Theme.of(context).textTheme.headline2),
                  const SizedBox(
                    width: 10,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                        color: Theme.of(context).colorScheme.background,
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: shop.image == null
                                ? Icon(
                                    Icons.image,
                                    color: Colors.white,
                                  )
                                : Image.file(
                                    File(shop.image),
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        )),
                  ),
                  const SizedBox(
                    width: 10,
                  )
                ],
              ),
              baselineType: TextBaseline.alphabetic,
              baseline: 25,
            )),
            bottom: TabBar(
                onTap: (value) async {
                  tabbarSelectedIndex = value;
                  setState(() {});
                  if (value == 4) {
                    dialogPickDateTimeRange(themeProvider);
                  }
                  tabbarChanging();
                },
                tabs: [
                  Tab(
                    child: Text("วันนี้"),
                  ),
                  Tab(
                    child: Text("สัปดาห ์"),
                  ),
                  Tab(
                    child: Text("เดือน"),
                  ),
                  Tab(
                    child: Text("ปี"),
                  ),
                  Tab(
                    child: Text("ระบุวันที่"),
                  )
                ]),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
                gradient: themeProvider.isDark
                    ? scafBG_dark_Color
                    : LinearGradient(
                        colors: [
                          Color.fromARGB(255, 255, 255, 255),
                          Color.fromARGB(255, 255, 255, 255),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )),
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(
                  bottom: 50.0, left: 10, right: 10, top: 10),
              child: Column(
                children: [
                  const SizedBox(
                    height: 160,
                  ),

                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        themeProvider.isDark
                            ? BoxShadow(
                                color: Theme.of(context).colorScheme.primary,
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 4))
                            : BoxShadow(
                                color: Colors.transparent,
                              )
                      ],
                      gradient: themeProvider.isDark
                          ? LinearGradient(
                              colors: [
                                Color.fromRGBO(29, 29, 65, 1.0),
                                Theme.of(context).backgroundColor,
                              ],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                              stops: [0.1, 0.8],
                              tileMode: TileMode.clamp,
                            )
                          : LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.primary,
                              ],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                              stops: [0.1, 0.8],
                              tileMode: TileMode.clamp,
                            ),
                    ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (tabbarSelectedIndex == 0)
                            Row(
                              children: [
                                Text(
                                  'วันนี้',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  ' ${DateFormat.yMMMd().format(date)}',

                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                  // color: Theme.of(context).bottomNavigationBarTheme.selectedItemColor),
                                ),
                              ],
                            ),
                          if (tabbarSelectedIndex == 1)
                            Row(
                              children: [
                                Text(
                                  'สัปดาห์',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  ' ${DateFormat.yMMMd().format(DateTime(date.year, date.month, 1))}',

                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                  // color: Theme.of(context).bottomNavigationBarTheme.selectedItemColor),
                                ),
                                Text(
                                  ' - ${DateFormat.yMMMd().format(date)}',

                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                  // color: Theme.of(context).bottomNavigationBarTheme.selectedItemColor),
                                ),
                              ],
                            ),
                          if (tabbarSelectedIndex == 2)
                            Row(
                              children: [
                                Text(
                                  'เดือน',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  ' Jan - Dec ${DateFormat.y().format(DateTime(date.year, date.month, date.day))}',

                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                  // color: Theme.of(context).bottomNavigationBarTheme.selectedItemColor),
                                ),
                              ],
                            ),
                          if (tabbarSelectedIndex == 3)
                            Row(
                              children: [
                                Text(
                                  'ปี',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  ' ${DateFormat.yMMMd().format(DateTime(date.year - 10, date.month, date.day))}',

                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                  // color: Theme.of(context).bottomNavigationBarTheme.selectedItemColor),
                                ),
                                Text(
                                  ' - ${DateFormat.yMMMd().format(date)}',

                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                  // color: Theme.of(context).bottomNavigationBarTheme.selectedItemColor),
                                ),
                              ],
                            ),
                          if (tabbarSelectedIndex == 4)
                            Row(
                              children: [
                                Text(
                                  'ช่วง',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  ' ${rangeDate}',

                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                  // color: Theme.of(context).bottomNavigationBarTheme.selectedItemColor),
                                ),
                              ],
                            ),
                        ]),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MoneyBox(
                          Icon(
                            Icons.sell,
                            color: Colors.white,
                          ),
                          Icon(
                            Icons.arrow_upward,
                            color: Colors.white,
                          ),
                          'ยอดขาย',
                          sale,
                          Color.fromRGBO(29, 29, 65, 1.0),
                          themeProvider.isDark == true
                              ? dark_secondary_accent_color
                              : Theme.of(context).backgroundColor,
                          90,
                          Colors.white),
                      MoneyBox(
                          Icon(Icons.price_change, color: Colors.white),
                          Icon(Icons.price_change, color: Colors.white),
                          'ยอดต้นทุน',
                          cost,
                          Color.fromRGBO(29, 29, 65, 1.0),
                          themeProvider.isDark == true
                              ? dark_secondary_accent_color
                              : Theme.of(context).backgroundColor,
                          90,
                          Colors.white),
                      MoneyBox(
                          Icon(Icons.attach_money_rounded, color: Colors.white),
                          Icon(Icons.price_change, color: Colors.white),
                          'กำไร',
                          profit < 0 ? 0 : profit,
                          Color.fromRGBO(29, 29, 65, 1.0),
                          themeProvider.isDark == true
                              ? dark_secondary_accent_color
                              : Theme.of(context).backgroundColor,
                          90,
                          Colors.white),
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                  // Graph Container
                  sellings.isEmpty && purchasings.isEmpty
                      ? tabbarSelectedIndex == 0
                          ? Container(
                              width: (MediaQuery.of(context).size.width),
                              height: (MediaQuery.of(context).size.width),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 4))
                                ],
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.primary,
                                  ],
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                  stops: [0.0, 0.8],
                                  tileMode: TileMode.clamp,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_chart_rounded,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                  Text('แสดงผลรูปแบบกราฟ'),
                                  Text('(วันนี้ไม่มีการขาย หรือ สั่งซื้อ)',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                          : Container(
                              width: (MediaQuery.of(context).size.width),
                              height: (MediaQuery.of(context).size.width),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 4))
                                ],
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.primary,
                                  ],
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                  stops: [0.0, 0.8],
                                  tileMode: TileMode.clamp,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_chart_rounded,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                  Text('แสดงผลรูปแบบกราฟ'),
                                  Text('(ไม่มีการขาย หรือ สั่งซื้อ)',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                      : Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Theme.of(context).colorScheme.primary,
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 4))
                            ],
                            gradient: themeProvider.isDark
                                ? LinearGradient(
                                    colors: [
                                      Color.fromRGBO(29, 29, 65, 1.0),
                                      Theme.of(context).colorScheme.primary,
                                    ],
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.topRight,
                                    stops: [0.0, 0.8],
                                    tileMode: TileMode.clamp,
                                  )
                                : LinearGradient(
                                    colors: [
                                      Theme.of(context).colorScheme.primary,
                                      Theme.of(context).colorScheme.primary,
                                    ],
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.topRight,
                                    stops: [0.0, 0.8],
                                    tileMode: TileMode.clamp,
                                  ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    if (tabbarSelectedIndex == 0)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'วันนี้',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            '${DateFormat.yMMMd().format(date)}',

                                            style: TextStyle(
                                                fontSize: 25,
                                                color: Colors.white),
                                            // color: Theme.of(context).bottomNavigationBarTheme.selectedItemColor),
                                          ),
                                        ],
                                      ),
                                    if (tabbarSelectedIndex == 1)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'สัปดาห์ ',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            '${DateFormat.yMMMd().format(DateTime(date.year, date.month, 1))} - ${DateFormat.yMMMd().format(date)}',

                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white),
                                            // color: Theme.of(context).bottomNavigationBarTheme.selectedItemColor),
                                          ),
                                        ],
                                      ),
                                    if (tabbarSelectedIndex == 2)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'เดือน Jan - Dec ${DateFormat.y().format(DateTime(date.year, date.month, date.day))}',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                                fontWeight: FontWeight.bold),
                                          ),
                                          // Text(
                                          //   '${DateFormat.yMMMd().format(DateTime(date.year, date.month - 1, date.day))} - ${DateFormat.yMMMd().format(date)}',

                                          //   style: TextStyle(
                                          //       fontSize: 12,
                                          //       color: Colors.white),
                                          //   // color: Theme.of(context).bottomNavigationBarTheme.selectedItemColor),
                                          // ),
                                        ],
                                      ),
                                    if (tabbarSelectedIndex == 3)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ปี ${DateFormat.y().format(DateTime(date.year - 10))} -  ${DateFormat.y().format(DateTime(date.year))}',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            '${DateFormat.yMMMd().format(DateTime(date.year - 10, date.month, date.day))} - ${DateFormat.yMMMd().format(date)}',

                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white),
                                            // color: Theme.of(context).bottomNavigationBarTheme.selectedItemColor),
                                          ),
                                        ],
                                      ),
                                    if (tabbarSelectedIndex == 4)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ช่วง',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            '${rangeDate}',

                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white),
                                            // color: Theme.of(context).bottomNavigationBarTheme.selectedItemColor),
                                          ),
                                        ],
                                      ),
                                    const Spacer(),
                                    Container(
                                      color: Colors.transparent,
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                isShowSelling = !isShowSelling;
                                                setState(() {});
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        isShowSelling
                                                            ? Icons
                                                                .remove_red_eye_rounded
                                                            : Icons
                                                                .remove_red_eye_outlined,
                                                        color: Color.fromARGB(
                                                            255, 255, 40, 40),
                                                        size: 20,
                                                      ),
                                                      Text(
                                                        ' ยอดขาย',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    255),
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        ' ฿${NumberFormat("#,###,###.##").format(sale)}',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    255)),
                                                        // color: Theme.of(context).bottomNavigationBarTheme.selectedItemColor),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                isShowPurchasing =
                                                    !isShowPurchasing;
                                                setState(() {});
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        isShowPurchasing
                                                            ? Icons
                                                                .remove_red_eye_rounded
                                                            : Icons
                                                                .remove_red_eye_outlined,
                                                        color: Color.fromARGB(
                                                            255, 119, 40, 255),
                                                        size: 20,
                                                      ),
                                                      Text(
                                                        ' ต้นทุน',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    255),
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        ' ฿${NumberFormat("#,###,###.##").format(cost)}',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    255)),
                                                        // color: Theme.of(context).bottomNavigationBarTheme.selectedItemColor),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                isShowProfit = !isShowProfit;
                                                setState(() {});
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        isShowProfit
                                                            ? Icons
                                                                .remove_red_eye_rounded
                                                            : Icons
                                                                .remove_red_eye_outlined,
                                                        color: Color.fromARGB(
                                                            255, 40, 255, 180),
                                                        size: 20,
                                                      ),
                                                      Text(
                                                        ' กำไร',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    255),
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        ' ฿${NumberFormat("#,###,###.##").format(profit)}',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    255)),
                                                        // color: Theme.of(context).bottomNavigationBarTheme.selectedItemColor),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 12, right: 38),
                                child: Center(
                                  child: SizedBox(
                                    width: (MediaQuery.of(context).size.width),
                                    height: (MediaQuery.of(context).size.width /
                                        1.2),
                                    child: LineChart(LineChartData(
                                        borderData: FlBorderData(
                                            show: true,
                                            border: Border.all(
                                                color: Colors.transparent,
                                                width: 2)),
                                        gridData: FlGridData(
                                          show: true,
                                          getDrawingHorizontalLine: (value) {
                                            return FlLine(
                                                // เส้น Horizon
                                                color: Color.fromARGB(
                                                    255, 93, 93, 93),
                                                strokeWidth: 1);
                                          },
                                          drawVerticalLine: false,
                                          getDrawingVerticalLine: (value) {
                                            return FlLine(
                                                color: Colors.white,
                                                strokeWidth: 1);
                                          },
                                        ),
                                        titlesData: FlTitlesData(
                                          show: true,
                                          bottomTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 35,
                                              getTextStyles: (context, value) {
                                                return const TextStyle(
                                                    color: Color(0xff68737d),
                                                    fontSize: 8,
                                                    fontWeight:
                                                        FontWeight.bold);
                                              },
                                              getTitles: (value) {
                                                // Today
                                                if (tabbarSelectedIndex == 0) {
                                                  for (value;
                                                      value <= 24;
                                                      value++) {
                                                    return '${value.toInt()}:00';
                                                  }
                                                } else if (tabbarSelectedIndex ==
                                                    1) {
                                                  // Week
                                                  for (value;
                                                      value <= date.day;
                                                      value++) {
                                                    return '${DateFormat.MMM().format(DateTime(date.year, value == 0 ? date.month - 1 : date.month, date.day))} ${DateFormat.d().format(DateTime(date.year, date.month, 0 + value.toInt()))}';
                                                  }
                                                } else if (tabbarSelectedIndex ==
                                                    2) {
                                                  // Monthly\

                                                  switch (value.toInt()) {
                                                    case 0:
                                                      return 'Jan';
                                                    case 1:
                                                      return 'Jan';
                                                    case 2:
                                                      return 'Feb';
                                                    case 3:
                                                      return 'Mar';
                                                    case 4:
                                                      return 'April';
                                                    case 5:
                                                      return 'May';
                                                    case 6:
                                                      return 'June';
                                                    case 7:
                                                      return 'July';
                                                    case 8:
                                                      return 'Aug';
                                                    case 9:
                                                      return 'Sep';
                                                    case 10:
                                                      return 'Oct';
                                                    case 11:
                                                      return 'Nov';
                                                    case 12:
                                                      return 'Dec';
                                                  }
                                                } else if (tabbarSelectedIndex ==
                                                    3) {
                                                  // Year
                                                  switch (value.toInt()) {
                                                    case 0:
                                                      return '${DateFormat('yyyy').format(DateTime(date.year - 10, date.month, date.day))}';
                                                    case 1:
                                                      return '${DateFormat('yyyy').format(DateTime(date.year - 9, date.month, date.day))}';
                                                    case 2:
                                                      return '${DateFormat('yyyy').format(DateTime(date.year - 8, date.month, date.day))}';
                                                    case 3:
                                                      return '${DateFormat('yyyy').format(DateTime(date.year - 7, date.month, date.day))}';
                                                    case 4:
                                                      return '${DateFormat('yyyy').format(DateTime(date.year - 6, date.month, date.day))}';
                                                    case 5:
                                                      return '${DateFormat('yyyy').format(DateTime(date.year - 5, date.month, date.day))}';
                                                    case 6:
                                                      return '${DateFormat('yyyy').format(DateTime(date.year - 4, date.month, date.day))}';
                                                    case 7:
                                                      return '${DateFormat('yyyy').format(DateTime(date.year - 3, date.month, date.day))}';
                                                    case 8:
                                                      return '${DateFormat('yyyy').format(DateTime(date.year - 2, date.month, date.day))}';
                                                    case 9:
                                                      return '${DateFormat('yyyy').format(DateTime(date.year - 1, date.month, date.day))}';
                                                    case 10:
                                                      return '${DateFormat('yyyy').format(DateTime(date.year, date.month, date.day))}';
                                                  }
                                                } else if (tabbarSelectedIndex ==
                                                    4) {
                                                  // Year
                                                  switch (value.toInt()) {
                                                    case 0:
                                                      return '${DateFormat('yyyy').format(DateTime(date.year - 10, date.month, date.day))}';
                                                    case 1:
                                                      return '${DateFormat('yyyy').format(DateTime(date.year - 9, date.month, date.day))}';
                                                    case 2:
                                                      return '${DateFormat('yyyy').format(DateTime(date.year - 8, date.month, date.day))}';
                                                    case 3:
                                                      return '${DateFormat('yyyy').format(DateTime(date.year - 7, date.month, date.day))}';
                                                    case 4:
                                                      return '${DateFormat('yyyy').format(DateTime(date.year - 6, date.month, date.day))}';
                                                    case 5:
                                                      return '${DateFormat('yyyy').format(DateTime(date.year - 5, date.month, date.day))}';
                                                    case 6:
                                                      return '${DateFormat('yyyy').format(DateTime(date.year - 4, date.month, date.day))}';
                                                    case 7:
                                                      return '${DateFormat('yyyy').format(DateTime(date.year - 3, date.month, date.day))}';
                                                    case 8:
                                                      return '${DateFormat('yyyy').format(DateTime(date.year - 2, date.month, date.day))}';
                                                    case 9:
                                                      return '${DateFormat('yyyy').format(DateTime(date.year - 1, date.month, date.day))}';
                                                    case 10:
                                                      return '${DateFormat('yyyy').format(DateTime(date.year, date.month, date.day))}';
                                                  }
                                                }

                                                return '';
                                              },
                                              margin: 8),
                                          rightTitles: SideTitles(),
                                          topTitles: SideTitles(),
                                          leftTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 35,
                                            getTextStyles: (context, value) {
                                              return const TextStyle(
                                                  color: Color(0xff68737d),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold);
                                            },
                                            getTitles: (value) {
                                              for (value;
                                                  value < _returnMaxYAxis();
                                                  value++) {
                                                return '${value.round()}';
                                              }
                                              return '';
                                            },
                                            margin: 12,
                                          ),
                                        ),
                                        maxX:
                                            _returnMaxAxis(tabbarSelectedIndex),
                                        maxY: _returnMaxYAxis(),
                                        minY: 0,
                                        minX: 0,
                                        lineBarsData: [
                                          if (sellings.isNotEmpty)
                                            LineChartBarData(
                                              spots: isShowPurchasing
                                                  ? sellings
                                                      .map((point) => FlSpot(
                                                          tabbarSelectedIndex ==
                                                                  0
                                                              ?
                                                              // Today
                                                              point.orderedDate
                                                                  .hour
                                                                  .toDouble()
                                                              :
                                                              // Year
                                                              tabbarSelectedIndex ==
                                                                          3 ||
                                                                      tabbarSelectedIndex ==
                                                                          4
                                                                  ? point.orderedDate
                                                                          .year
                                                                          .toDouble() /
                                                                      (date.year /
                                                                          10)
                                                                  :
                                                                  // Week
                                                                  tabbarSelectedIndex ==
                                                                          1
                                                                      ? point
                                                                          .orderedDate
                                                                          .day
                                                                          .toDouble()
                                                                      : point
                                                                          .orderedDate
                                                                          .month
                                                                          .toDouble()

                                                          // Month

                                                          ,
                                                          point.total
                                                              .toDouble()))
                                                      .toList()
                                                  : null,
                                              isCurved: false,
                                              colors: [
                                                Color.fromARGB(
                                                    255, 255, 40, 40),
                                              ],
                                              barWidth: 2,
                                            ),
                                          if (sellings.isNotEmpty)
                                            LineChartBarData(
                                              spots: isShowPurchasing
                                                  ? sellings
                                                      .map((point) => FlSpot(
                                                          tabbarSelectedIndex ==
                                                                  0
                                                              ?
                                                              // Today
                                                              point.orderedDate
                                                                  .hour
                                                                  .toDouble()
                                                              :
                                                              // Year
                                                              tabbarSelectedIndex ==
                                                                          3 ||
                                                                      tabbarSelectedIndex ==
                                                                          4
                                                                  ? point.orderedDate
                                                                          .year
                                                                          .toDouble() /
                                                                      (date.year /
                                                                          10)
                                                                  :
                                                                  // Week
                                                                  tabbarSelectedIndex ==
                                                                          1
                                                                      ? point
                                                                          .orderedDate
                                                                          .day
                                                                          .toDouble()
                                                                      : point
                                                                          .orderedDate
                                                                          .month
                                                                          .toDouble()

                                                          // Month

                                                          ,
                                                          point.profit
                                                              .toDouble()))
                                                      .toList()
                                                  : null,
                                              isCurved: false,
                                              colors: [
                                                Color.fromARGB(
                                                    255, 40, 255, 180)
                                              ],
                                              barWidth: 2,
                                            ),
                                          if (purchasings.isNotEmpty)
                                            LineChartBarData(
                                                spots: isShowPurchasing
                                                    ? purchasings
                                                        .map((point) => FlSpot(
                                                            tabbarSelectedIndex ==
                                                                    0
                                                                ?
                                                                // Today
                                                                point
                                                                    .orderedDate
                                                                    .hour
                                                                    .toDouble()
                                                                :
                                                                // Year
                                                                tabbarSelectedIndex ==
                                                                            3 ||
                                                                        tabbarSelectedIndex ==
                                                                            4
                                                                    ? point.orderedDate
                                                                            .year
                                                                            .toDouble() /
                                                                        (date.year /
                                                                            10)
                                                                    :
                                                                    // Week
                                                                    tabbarSelectedIndex ==
                                                                            1
                                                                        ? point
                                                                            .orderedDate
                                                                            .day
                                                                            .toDouble()
                                                                        : point
                                                                            .orderedDate
                                                                            .month
                                                                            .toDouble()

                                                            // Month

                                                            ,
                                                            point.total
                                                                .toDouble()))
                                                        .toList()
                                                    : null,
                                                isCurved: false,
                                                colors: [
                                                  dark_secondary_accent_color,
                                                ],
                                                barWidth: 2,
                                                belowBarData: BarAreaData(
                                                    gradientFrom: Offset(0, 1),
                                                    show: true,
                                                    colors: gradientColors
                                                        .map((e) =>
                                                            e.withOpacity(0.5))
                                                        .toList())),
                                        ])),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  // Doing

                  const SizedBox(
                    height: 10,
                  ),
                  tabbarSelectedIndex == 0
                      ? sellings.isNotEmpty
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    "ขายวันนี้",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: themeProvider.isDark
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                ),
                              ],
                            )
                          : Container()
                      : Container(),
                  tabbarSelectedIndex != 0
                      ? Container()
                      : Container(
                          height: 140,
                          width: 450,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.zero,
                              itemCount: sellings.length,
                              itemBuilder: (context, index) {
                                final selling = sellings[index];
                                CustomerModel _customerText =
                                    CustomerModel(cName: '');
                                CustomerAddressModel _custoemrAddress =
                                    CustomerAddressModel(
                                        cAddress: '', cPhone: '');

                                for (var customer in customers) {
                                  if (customer.cusId == selling.customerId) {
                                    _customerText = customer;
                                  }
                                }

                                for (var address in addresses) {
                                  if (address.cAddreId == selling.cAddreId) {
                                    _custoemrAddress = address;
                                  }
                                }
                                return TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SellingNavEdit(
                                                  customerAddress:
                                                      _custoemrAddress,
                                                  customer: _customerText,
                                                  shop: widget.shop,
                                                  selling: selling,
                                                )));
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                  spreadRadius: 0,
                                                  blurRadius: 5,
                                                  offset: Offset(0, 3))
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(22),
                                            gradient: LinearGradient(
                                              colors: [
                                                Color.fromRGBO(29, 29, 65, 1.0),
                                                Theme.of(context)
                                                    .backgroundColor,
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            )),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.person,
                                                size: 50,
                                                color: Colors.white,
                                              ),
                                              Text(
                                                _customerText.cName,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                '฿${NumberFormat("#,###.##").format(selling.total)}',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                ),
                                              )
                                            ]),
                                      ),
                                      Positioned(
                                        top: 0.0,
                                        right: 0.0,
                                        child: Container(
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.7),
                                                    spreadRadius: 0,
                                                    blurRadius: 5,
                                                    offset: Offset(0, 4))
                                              ],
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .background,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: Row(
                                              children: [
                                                selling.isDelivered == true
                                                    ? Row(
                                                        children: [
                                                          Icon(
                                                            Icons.check_circle,
                                                            color: Colors
                                                                .greenAccent,
                                                            size: 22,
                                                          ),
                                                          Text(
                                                            'จัดส่งแล้ว',
                                                            style: TextStyle(
                                                              fontSize: 9,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                    : Icon(
                                                        Icons.circle_outlined,
                                                        color:
                                                            Colors.greenAccent,
                                                        size: 25,
                                                      ),
                                              ],
                                            )),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        ),
                  tabbarSelectedIndex == 0
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: sellingIndicators(sellings.length))
                      : Container(),

                  const SizedBox(
                    height: 10,
                  ),
                  // Container(
                  //   height: 140,
                  //   width: 450,
                  //   child: PieChartSample2(),
                  // ),

                  // SizedBox(
                  //   height: 50,
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
