import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:warehouse_mnmt/Page/Model/Dealer.dart';
import 'package:warehouse_mnmt/Page/Model/DeliveryCompany.dart';
import 'package:warehouse_mnmt/Page/Model/Product.dart';
import 'package:warehouse_mnmt/Page/Model/ProductLot.dart';
import 'package:warehouse_mnmt/Page/Model/ProductModel.dart';
import 'package:warehouse_mnmt/Page/Model/Purchasing.dart';
import 'package:warehouse_mnmt/Page/Model/Purchasing_item.dart';
import 'package:warehouse_mnmt/Page/Provider/theme_provider.dart';
import 'package:warehouse_mnmt/Page/Shop/Buying/nav_showProduct.dart';

import '../../../db/database.dart';
import '../../Model/Shop.dart';
import 'nav_choose_dealer.dart';
import 'nav_choose_product.dart';
import 'nav_choose_shipping.dart';

class BuyingNavEdit extends StatefulWidget {
  final Shop shop;
  final DealerModel dealer;
  final PurchasingModel purchasing;
  const BuyingNavEdit(
      {super.key,
      required this.dealer,
      required this.purchasing,
      required this.shop});
  @override
  State<BuyingNavEdit> createState() => _BuyingNavEditState();
}

class _BuyingNavEditState extends State<BuyingNavEdit> {
  List<PurchasingItemsModel> purchasingItems = [];
  List<Product> products = [];
  List<ProductLot> productLots = [];
  List<ProductModel> models = [];
  List<DealerModel> dealers = [];
  List<DeliveryCompanyModel> companys = [];

  DateTime date = DateTime.now();
  final df = new DateFormat('dd-MM-yyyy hh:mm a');
  var totalWeight = 0;
  late var shippingCost = widget.purchasing.shippingCost;
  late var totalPrice = widget.purchasing.total;
  late var noShippingPrice = widget.purchasing.total - shippingCost;
  late var amount = widget.purchasing.amount;
  late bool isReceived = widget.purchasing.isReceive;

  void initState() {
    super.initState();

    refreshPage();
  }

  Future refreshPage() async {
    purchasingItems = await DatabaseManager.instance
        .readAllPurchasingItemsWherePurID(widget.purchasing.purId!);
    products =
        await DatabaseManager.instance.readAllProducts(widget.shop.shopid!);
    productLots = await DatabaseManager.instance.readAllProductLots();
    models = await DatabaseManager.instance.readAllProductModels();
    dealers =
        await DatabaseManager.instance.readAllDealers(widget.shop.shopid!);
    for (var item in purchasingItems) {
      noShippingPrice += item.total;
      for (var model in models) {
        if (item.prodModelId == model.prodModelId) {
          totalWeight += (model.weight * item.amount).toInt();
        }
      }
    }
    setState(() {});
  }

  _showAlertSnackBar(title) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Theme.of(context).backgroundColor,
      content: Text(title),
      duration: Duration(seconds: 2),
    ));
  }

  Future<void> dialogConfirmDelete() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dContext, DialogSetState) {
          return AlertDialog(
            backgroundColor: Theme.of(dContext).scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            title: Container(
              width: 150,
              child: Row(
                children: [
                  const Text(
                    'ต้องการลบ ?',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('ยืนยัน'),
                onPressed: () async {
                  if (isReceived == true) {
                    print(widget.purchasing.isReceive);
                    for (var item in purchasingItems) {
                      for (var lot in productLots) {
                        if (item.purId == lot.purId) {
                          final updatedLot = lot.copy(
                              remainAmount: lot.remainAmount - item.amount < 0
                                  ? 0
                                  : lot.remainAmount - item.amount);
                          await DatabaseManager.instance
                              .updateProductLot(updatedLot);
                        }
                      }
                      await DatabaseManager.instance
                          .deletePurchasingItem(item.purItemsId!);
                    }
                  } else {
                    print('else Purchjasing');
                    for (var item in purchasingItems) {
                      await DatabaseManager.instance
                          .deletePurchasingItem(item.purItemsId!);
                    }
                  }
                  await DatabaseManager.instance
                      .deletePurchasing(widget.purchasing.purId!);
                  Navigator.of(dContext).pop();
                  Navigator.of(context).pop();
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
          title: Column(
            children: const [
              Text(
                "รายงานการสั่งซื้อ",
                style: TextStyle(fontSize: 25),
              )
            ],
          ),
          centerTitle: true,
          actions: [
            PopupMenuButton<int>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
              ),
              itemBuilder: (context) => [
                // popupmenu item 2
                PopupMenuItem(
                  onTap: () {
                    Future.delayed(
                      const Duration(seconds: 0),
                      () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                          title: const Text(
                            'ต้องการลบ ?',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          actions: <Widget>[
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.redAccent),
                              child: const Text('ยกเลิก'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            ElevatedButton(
                              child: const Text('ยืนยัน'),
                              onPressed: () async {
                                if (isReceived == true) {
                                  print(widget.purchasing.isReceive);
                                  for (var item in purchasingItems) {
                                    for (var lot in productLots) {
                                      if (item.purId == lot.purId) {
                                        final updatedLot = lot.copy(
                                            remainAmount:
                                                lot.remainAmount - item.amount <
                                                        0
                                                    ? 0
                                                    : lot.remainAmount -
                                                        item.amount);
                                        await DatabaseManager.instance
                                            .updateProductLot(updatedLot);
                                      }
                                    }
                                    await DatabaseManager.instance
                                        .deletePurchasingItem(item.purItemsId!);
                                  }
                                } else {
                                  print('else Purchasing');
                                  for (var item in purchasingItems) {
                                    await DatabaseManager.instance
                                        .deletePurchasingItem(item.purItemsId!);
                                  }
                                }
                                await DatabaseManager.instance
                                    .deletePurchasing(widget.purchasing.purId!);
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  value: 2,
                  // row has two child icon and text
                  child: Row(
                    children: [
                      Icon(Icons.delete),
                      SizedBox(
                        // sized box with width 10
                        width: 10,
                      ),
                      Text(
                        "ลบรายการการสั่งซื้อ",
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
              ],
              offset: Offset(0, 80),
              color: Theme.of(context).colorScheme.onSecondary,
              elevation: 2,
            ),
          ],
          backgroundColor: themeProvider.isDark
              ? Theme.of(context).colorScheme.onSecondary
              : Theme.of(context).colorScheme.primary,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              gradient: themeProvider.isDark
                  ? scafBG_dark_Color
                  : LinearGradient(
                      colors: [
                        Color.fromARGB(255, 219, 219, 219),
                        Color.fromARGB(255, 219, 219, 219),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(children: [
              const SizedBox(
                height: 70,
              ),
              // Date Picker
              Container(
                width: 440,
                height: 80,
                child: Row(children: [
                  Icon(
                    Icons.calendar_month,
                  ),
                  Spacer(),
                  Text(
                    '${DateFormat('HH:mm:ss, y-MMM-d').format(widget.purchasing.orderedDate)}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ]),
              ),
              Row(
                children: [
                  Text(
                    "ตัวแทนจำหน่าย",
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),

              Row(children: [
                Expanded(
                  child: Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.dealer.dName}',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                        Text(
                          '${widget.dealer.dAddress}',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "รายการสั่งซื้อ",
                    style: TextStyle(fontSize: 25),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              purchasingItems.isEmpty
                  ? Text('ไม่มีสินค้า',
                      style: const TextStyle(color: Colors.grey, fontSize: 12))
                  :
                  // Container of รายการสินค้า
                  Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          // color: Color.fromRGBO(56, 48, 77, 1.0),
                          borderRadius: BorderRadius.circular(15)),
                      child: Column(children: [
                        // ListView

                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Container(
                            height: purchasingItems.length >= 2 ? 230 : 90,
                            width: 440.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              // color: Color.fromRGBO(37, 35, 53, 1.0),
                            ),
                            child: ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: purchasingItems.length,
                                itemBuilder: (context, index) {
                                  final purchasing = purchasingItems[index];
                                  var prodName;
                                  var prodImg;
                                  var prodModel;

                                  for (var prod in products) {
                                    if (prod.prodId == purchasing.prodId) {
                                      prodImg = prod.prodImage;
                                      prodName = prod.prodName;
                                    }
                                  }

                                  var stProperty;
                                  var ndProperty;

                                  for (var model in models) {
                                    if (model.prodModelId ==
                                        purchasing.prodModelId) {
                                      stProperty = model.stProperty;
                                      ndProperty = model.ndProperty;
                                    }
                                  }

                                  return Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        height: 80,
                                        width: 400,
                                        color: themeProvider.isDark
                                            ? Color.fromRGBO(56, 54, 76, 1.0)
                                                .withOpacity(0.4)
                                            : Theme.of(context)
                                                .colorScheme
                                                .primary,
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              width: 90,
                                              height: 90,
                                              child: prodImg == null
                                                  ? Icon(Icons
                                                      .image_not_supported_rounded)
                                                  : Image.file(
                                                      File(prodImg),
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    '${prodName == null ? '-' : prodName}',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                                // Theme.of(context)
                                                                //       .colorScheme
                                                                //       .background
                                                                color: Color
                                                                    .fromRGBO(
                                                                        36,
                                                                        33,
                                                                        50,
                                                                        1.0),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(3.0),
                                                          child: Text(
                                                            stProperty == null
                                                                ? '-'
                                                                : stProperty,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .white),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                            color:
                                                                Color.fromRGBO(
                                                                    36,
                                                                    33,
                                                                    50,
                                                                    1.0),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(3.0),
                                                          child: Text(
                                                            ndProperty == null
                                                                ? '-'
                                                                : ndProperty,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .white),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                      'รวม ฿${NumberFormat("#,###.##").format(purchasing.total)}',
                                                      style: const TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12)),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: Color.fromRGBO(
                                                      30, 30, 49, 1.0),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(3.0),
                                                child: Text(
                                                    '${NumberFormat("#,###.##").format(purchasing.amount)}',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Theme.of(context)
                                                            .backgroundColor,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 180,
                              child: Row(
                                children: [
                                  Text(
                                    'น้ำหนักรวม ',
                                  ),
                                  Flexible(
                                    child: Text(
                                        '${NumberFormat("#,###.##").format(totalWeight)}',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Theme.of(context)
                                                .bottomNavigationBarTheme
                                                .selectedItemColor,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Text(
                                    ' กรัม',
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'ทั้งหมด ',
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(30, 30, 49, 1.0),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Text(
                                    '${NumberFormat("#,###.##").format(purchasingItems.length)}',
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Theme.of(context)
                                            .bottomNavigationBarTheme
                                            .selectedItemColor,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            Text(
                              ' รายการ ',
                            ),
                          ],
                        ),
                      ]),
                    ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "ค่าจัดส่ง",
                    style: TextStyle(fontSize: 25),
                  ),
                ],
              ),
              // Container of รายการสินค้า

              Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(15)),
                width: 400,
                height: 30,
                child: Row(children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child:
                        const Text("ค่าจัดส่ง", style: TextStyle(fontSize: 15)),
                  ),
                  Spacer(),
                  Text(
                      '฿${NumberFormat("#,###.##").format(widget.purchasing.shippingCost)}',
                      style: TextStyle(fontSize: 15, color: Colors.grey)),
                ]),
              ),
              // Container of ค่าจัดส่ง

              const SizedBox(
                height: 10,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "สรุปรายการสั่งซื้อ",
                    style: TextStyle(fontSize: 25),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),

              // Container of จำนวน
              Container(
                decoration: BoxDecoration(
                    // color: const Color.fromRGBO(56, 48, 77, 1.0),
                    borderRadius: BorderRadius.circular(15)),
                width: 400,
                height: 30,
                child: Row(children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: const Text("จำนวน", style: TextStyle(fontSize: 15)),
                  ),
                  Spacer(),
                  Text('${NumberFormat("#,###,###,### ชิ้น").format(amount)}',
                      textAlign: TextAlign.left,
                      style: const TextStyle(fontSize: 15, color: Colors.grey)),
                ]),
              ),
              // Container of จำนวน

              // Container of รวม
              Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(15)),
                width: 400,
                height: 30,
                child: Wrap(
                  children: [
                    Row(children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child:
                            const Text("รวม", style: TextStyle(fontSize: 15)),
                      ),
                      Spacer(),
                      Column(
                        children: [
                          shippingCost == 0
                              ? Container(
                                  width: 0,
                                )
                              : Text(
                                  'สินค้า (฿${NumberFormat("#,###,###,###.##").format(totalPrice)})',
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.grey)),
                          shippingCost == 0
                              ? Container(
                                  width: 0,
                                )
                              : Text(
                                  '   + ค่าส่ง (฿${NumberFormat("#,###,###,###.##").format(shippingCost)})',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color:
                                          Theme.of(context).backgroundColor)),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                            '฿${NumberFormat("#,###,###,###.##").format(totalPrice + shippingCost)}',
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                                fontSize: 15, color: Colors.grey)),
                      ),
                    ]),
                  ],
                ),
              ),
              // Container of รวม
              const SizedBox(
                height: 50,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                      child: widget.purchasing.isReceive == true
                          ? Icon(
                              Icons.check_box,
                              size: 40.0,
                              color: Theme.of(context).backgroundColor,
                            )
                          : InkWell(
                              onTap: () {
                                setState(() {
                                  isReceived = !isReceived;
                                  if (isReceived == false) {
                                    print('ยังไม่ได้รับสินค้า (${isReceived})');
                                  } else {
                                    print('ได้รับสินค้าแล้ว ${isReceived})');
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.transparent),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: isReceived
                                      ? Icon(
                                          Icons.check_box,
                                          size: 40.0,
                                          color:
                                              Theme.of(context).backgroundColor,
                                        )
                                      : Icon(
                                          Icons.check_box_outline_blank,
                                          size: 40.0,
                                          color:
                                              Theme.of(context).backgroundColor,
                                        ),
                                ),
                              ),
                            )),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ได้รับสินค้าเรียบร้อยแล้ว",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isReceived == true
                              ? Colors.grey
                              : themeProvider.isDark
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                      Text(
                        "(สินค้าคงเหลือจะได้รับการปรับปรุง)",
                        style: TextStyle(
                          fontSize: 15,
                          color: isReceived == true
                              ? Colors.grey
                              : themeProvider.isDark
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              widget.purchasing.isReceive == true
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.redAccent),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "ยกเลิกรายการ",
                                style: TextStyle(fontSize: 17),
                              ),
                            )
                          ]),
                          Column(children: [
                            ElevatedButton(
                              onPressed: () async {
                                // Product Lot
                                if (isReceived) {
                                  for (var item in purchasingItems) {
                                    for (var lot in productLots) {
                                      if (item.purId == lot.purId) {
                                        final updatedLot = lot.copy(
                                            isReceived: isReceived,
                                            remainAmount:
                                                int.parse('${lot.amount}'));
                                        await DatabaseManager.instance
                                            .updateProductLot(updatedLot);
                                      }
                                    }
                                  }

                                  final updatedPurchasing = widget.purchasing!
                                      .copy(isReceive: isReceived);

                                  await DatabaseManager.instance
                                      .updatePurchasing(updatedPurchasing);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    backgroundColor:
                                        Theme.of(context).backgroundColor,
                                    behavior: SnackBarBehavior.floating,
                                    content: Row(
                                      children: [
                                        Text("ปรับปรุงสินค้าคงเหลือแล้ว"),
                                      ],
                                    ),
                                    duration: Duration(seconds: 5),
                                  ));
                                  Navigator.pop(context);
                                } else {
                                  // for (var item in purchasingItems) {
                                  //   final productLot = ProductLot(
                                  //       purId: item.purId,
                                  //       orderedTime: date,
                                  //       amount: '${item.amount}',
                                  //       remainAmount: int.parse('${item.amount}'),
                                  //       prodModelId: item.prodModelId);
                                  //   await DatabaseManager.instance
                                  //       .updateProductLot(productLot);
                                  // }
                                  final updatedPurchasing = widget.purchasing!
                                      .copy(isReceive: isReceived);

                                  await DatabaseManager.instance
                                      .updatePurchasing(updatedPurchasing);
                                }
                              },
                              child: Text(
                                "บันทึก",
                                style: TextStyle(fontSize: 17),
                              ),
                            )
                          ]),
                        ],
                      ),
                    )
            ]),
          ),
        ),
      ),
    );
  }
}
