import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:warehouse_mnmt/Page/Model/Customer.dart';
import 'package:warehouse_mnmt/Page/Model/CustomerAdress.dart';
import 'package:warehouse_mnmt/Page/Model/DeliveryCompany.dart';
import 'package:warehouse_mnmt/Page/Model/Product.dart';
import 'package:warehouse_mnmt/Page/Model/ProductLot.dart';
import 'package:warehouse_mnmt/Page/Model/Selling.dart';
import 'package:warehouse_mnmt/Page/Model/Selling_item.dart';
import 'package:warehouse_mnmt/Page/Provider/theme_provider.dart';
import 'package:warehouse_mnmt/Page/Shop/Buying/nav_choose_shipping.dart';
import 'package:warehouse_mnmt/Page/Shop/Selling/selling_nav_chooseCustomer.dart';
import 'package:warehouse_mnmt/Page/Shop/Selling/nav_choose_product.dart';
import 'package:warehouse_mnmt/db/database.dart';

import '../../Component/DatePicker.dart';
import '../../Model/ProductModel.dart';
import '../../Model/Shop.dart';

class SellingNavEdit extends StatefulWidget {
  final Shop shop;
  final CustomerModel customer;
  final CustomerAddressModel customerAddress;
  final SellingModel selling;
  const SellingNavEdit(
      {required this.customer,
      required this.customerAddress,
      required this.selling,
      required this.shop,
      Key? key})
      : super(key: key);

  @override
  State<SellingNavEdit> createState() => _SellingNavEditState();
}

class _SellingNavEditState extends State<SellingNavEdit> {
  final df = new DateFormat('dd-MM-yyyy hh:mm a');
  late DeliveryCompanyModel _shipping;
  late var shippingCost = widget.selling.shippingCost;
  late var discountPercent = widget.selling.discountPercent;
  var noShippingPrice = 0;
  late var showtotalPrice = widget.selling.total;
  late var amount = widget.selling.amount;
  late var vat7percent = noShippingPrice * 7 / 100;
  double noVatPrice = 0.0;
  var profit = 0;
  var totalWeight = 0;
  late bool isDelivered = widget.selling.isDelivered;
  List<Product> products = [];
  List<ProductModel> models = [];
  List<ProductLot> lots = [];
  List<CustomerModel> customers = [];
  List<CustomerAddressModel> addresses = [];
  List<SellingItemModel> sellingItems = [];
  List<ProductLot> productLots = [];
  DeliveryCompanyModel? company;

  _addProductInCart(SellingItemModel product) {
    sellingItems.add(product);
  }

  @override
  void initState() {
    super.initState();
    refreshPage();
  }

  Future refreshPage() async {
    products =
        await DatabaseManager.instance.readAllProducts(widget.shop.shopid!);
    models = await DatabaseManager.instance.readAllProductModels();
    lots = await DatabaseManager.instance.readAllProductLots();
    customers = await DatabaseManager.instance
        .readAllCustomerInShop(widget.shop.shopid!);
    addresses = await DatabaseManager.instance.readAllCustomerAddresses();
    sellingItems = await DatabaseManager.instance
        .readAllSellingItemsWhereSellID(widget.selling.selId!);
    productLots = await DatabaseManager.instance.readAllProductLots();
    // companys = await DatabaseManager.instance
    // .readDeliveryCompanys(widget.shop.shopid!);
    for (var item in sellingItems) {
      noShippingPrice += item.total;
      for (var model in models) {
        if (item.prodModelId == model.prodModelId) {
          profit = (item.amount * model.price) - (item.amount * model.cost);
          totalWeight += (model.weight * item.amount).toInt();
        }
      }
    }
    if (widget.selling.deliveryCompanyId != null) {
      company = await DatabaseManager.instance
          .readDeliveryCompanysOnlyOne(widget.selling.deliveryCompanyId!);
    } else {
      company = widget.selling.shippingCost == 0
          ? DeliveryCompanyModel(
              dcName: 'รับสินค้าเอง', dcisRange: false, fixedDeliveryCost: 0)
          : DeliveryCompanyModel(
              dcName: 'ระบุราคา', dcisRange: false, fixedDeliveryCost: 0);
    }

    setState(() {});
  }

  _calculate() {
    var oldTotalPrice = 0;
    for (var i in sellingItems) {
      oldTotalPrice += i.total;
      for (var model in models) {
        if (i.prodModelId == model.prodModelId) {
          profit = (i.amount * model.price) - (i.amount * model.cost);
        }
      }
    }
    setState(() {
      noShippingPrice = oldTotalPrice;
    });
  }

  _showAlertSnackBar(title) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Theme.of(context).backgroundColor,
      content: Text(title),
      duration: Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
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
                                if (isDelivered == true) {
                                  print(widget.selling.isDelivered);
                                  for (var item in sellingItems) {
                                    for (var lot in productLots) {
                                      if (item.prodLotId == lot.prodLotId) {
                                        final updatedLot = lot.copy(
                                            remainAmount:
                                                lot.remainAmount + item.amount);
                                        await DatabaseManager.instance
                                            .updateProductLot(updatedLot);
                                      }
                                    }
                                    await DatabaseManager.instance
                                        .deletePurchasingItem(item.selItemId!);
                                  }
                                } else {
                                  for (var item in sellingItems) {
                                    await DatabaseManager.instance
                                        .deleteSellingItem(item.selItemId!);
                                  }
                                }
                                await DatabaseManager.instance
                                    .deleteSelling(widget.selling.selId!);

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
                        "ลบรายการการขาย",
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
              ],
              offset: Offset(0, 80),
              color: themeProvider.isDark
                  ? Theme.of(context).colorScheme.onSecondary
                  : Theme.of(context).colorScheme.primary,
              elevation: 2,
            ),
          ],
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
          title: Column(
            children: [
              Text(
                "แก้ไขรายการขาย",
                style: TextStyle(fontSize: 25),
              )
            ],
          ),
          centerTitle: true,
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
                height: 90,
              ),
              // Date Picker
              // Date Picker
              Container(
                width: 440,
                height: 80,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                      ),
                      Spacer(),
                      Text(
                        '${DateFormat('HH:mm:ss, y-MMM-d').format(widget.selling.orderedDate)}',
                        style: TextStyle(color: Colors.grey),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              // Container of ราคาขายรวม
              Row(
                children: [
                  Text(
                    "ลูกค้า",
                    style: TextStyle(fontSize: 25),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              // Container of เลือกลูกค้า
              Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(15)),
                width: 400,
                height: 100,
                child: Row(children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(widget.customer.cName,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                )),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                                widget.customerAddress!.cPhone.replaceAllMapped(
                                    RegExp(r'(\d{3})(\d{3})(\d+)'),
                                    (Match m) => "${m[1]}-${m[2]}-${m[3]}"),
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.customerAddress!.cAddress,
                                style: TextStyle(
                                    fontSize: 15, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
              // Container of เลือกลูกค้า
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "รายการสินค้า",
                    style: TextStyle(fontSize: 25),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              // Container of รายการสินค้า
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        width: 440.0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            sellingItems.isEmpty
                                ? const Text(
                                    '(ไม่มีสินค้า)',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 25),
                                  )
                                : Container(
                                    height: sellingItems.length > 1 ? 220 : 90,
                                    width: 440.0,
                                    child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        itemCount: sellingItems.length,
                                        itemBuilder: (context, index) {
                                          final selling = sellingItems[index];
                                          var prodName;
                                          var prodImg;
                                          var prodModel;

                                          for (var prod in products) {
                                            if (prod.prodId == selling.prodId) {
                                              prodImg = prod.prodImage!;
                                              prodName = prod.prodName;
                                            }
                                          }

                                          var stProperty;
                                          var ndProperty;

                                          for (var model in models) {
                                            if (model.prodModelId ==
                                                selling.prodModelId) {
                                              stProperty = model.stProperty;
                                              ndProperty = model.ndProperty;
                                            }
                                          }

                                          return Padding(
                                            padding: EdgeInsets.all(5),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Container(
                                                height: 80,
                                                width: 400,
                                                color: themeProvider.isDark
                                                    ? Color.fromRGBO(
                                                            56, 54, 76, 1.0)
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
                                                          ? Icon(Icons.image)
                                                          : Image.file(
                                                              File(prodImg),
                                                              fit: BoxFit.cover,
                                                            ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Text(
                                                            '${prodName}',
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          Row(
                                                            children: [
                                                              Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                        // Theme.of(context)
                                                                        //       .colorScheme
                                                                        //       .background
                                                                        color: Color.fromRGBO(
                                                                            36,
                                                                            33,
                                                                            50,
                                                                            1.0),
                                                                        borderRadius:
                                                                            BorderRadius.circular(10)),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          3.0),
                                                                  child: Text(
                                                                    stProperty ==
                                                                            null
                                                                        ? '-'
                                                                        : stProperty,
                                                                    style: const TextStyle(
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
                                                                    color: Color
                                                                        .fromRGBO(
                                                                            36,
                                                                            33,
                                                                            50,
                                                                            1.0),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10)),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          3.0),
                                                                  child: Text(
                                                                    ndProperty ==
                                                                            null
                                                                        ? '-'
                                                                        : ndProperty,
                                                                    style: const TextStyle(
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
                                                              'รวม ฿${NumberFormat("#,###.##").format(selling.total)}',
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize:
                                                                      12)),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          color: Color.fromRGBO(
                                                              30, 30, 49, 1.0),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(3.0),
                                                        child: Text(
                                                            '${NumberFormat("#,###.##").format(selling.amount)}',
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                color: Theme.of(
                                                                        context)
                                                                    .backgroundColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                  )
                          ],
                        ),
                      ),
                    ),
                    // ListView
                    SizedBox(
                      height: 5,
                    ),

                    sellingItems.isEmpty
                        ? Container()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'น้ำหนักรวม ',
                              ),
                              Text(
                                  '${NumberFormat("#,###.##").format(totalWeight)}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Theme.of(context)
                                          .bottomNavigationBarTheme
                                          .selectedItemColor,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                ' กรัม',
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
                                      '${NumberFormat("#,###.##").format(sellingItems.length)}',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color:
                                              Theme.of(context).backgroundColor,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                              Text(
                                'รายการ ',
                              ),
                            ],
                          )
                  ]),
                ),
              ),
              // Container of รายการสินค้า
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text(
                    "สรุปรายการ",
                    style: TextStyle(fontSize: 25),
                  ),
                ],
              ),
              // Container of การจัดส่ง
              Container(
                padding: const EdgeInsets.all(5),
                width: 400,
                height: 30,
                child: Row(children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text("การจัดส่ง", style: TextStyle(fontSize: 15)),
                  ),
                  company?.dcisRange == false
                      ? Text(' (อัตราคงที่)', style: TextStyle(fontSize: 15))
                      : Container(),
                  const Spacer(),
                  Container(
                    alignment: Alignment.centerRight,
                    width: 150,
                    child: Text('${company?.dcName}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15, color: Colors.grey)),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ]),
              ),

              // Container of การจัดส่ง
              const SizedBox(
                height: 10,
              ),
              // Container of ค่าจัดส่ง
              Container(
                padding: const EdgeInsets.all(5),
                width: 400,
                height: 30,
                child: Row(children: [
                  const Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text("ค่าจัดส่ง", style: TextStyle(fontSize: 15)),
                  ),
                  const Spacer(),
                  Text('฿${NumberFormat("#,###.##").format(shippingCost)}',
                      style: TextStyle(fontSize: 15, color: Colors.grey)),
                ]),
              ),
              // Container of ค่าจัดส่ง

              // Container of ราคาสุทธิ
              const SizedBox(
                height: 10,
              ),

              // Container of ราคาสุทธิ
              Container(
                padding: const EdgeInsets.all(5),
                width: 400,
                height: 30,
                child: Row(children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: const Text("ราคาสินค้า",
                        style: TextStyle(fontSize: 15)),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                        '฿${NumberFormat("#,###.##").format(noShippingPrice - noShippingPrice * 7 / 100)}',
                        textAlign: TextAlign.left,
                        style:
                            const TextStyle(fontSize: 15, color: Colors.grey)),
                  ),
                ]),
              ),
              const SizedBox(
                height: 10,
              ),
              // Container of ภาษี 7 %
              Container(
                padding: const EdgeInsets.all(5),
                width: 400,
                height: 30,
                child: Row(children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child:
                        const Text("ภาษี (7%)", style: TextStyle(fontSize: 15)),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                        '฿${NumberFormat("#,###.##").format(noShippingPrice * 7 / 100)}',
                        textAlign: TextAlign.left,
                        style:
                            const TextStyle(fontSize: 15, color: Colors.grey)),
                  ),
                ]),
              ),
              // Container of ภาษี 7 %
              const SizedBox(
                height: 10,
              ),

              // Container of ราคาสุทธิ
              Container(
                padding: const EdgeInsets.all(5),
                width: 400,
                height: 30,
                child: Row(children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: const Text("ราคาสินค้า + ภาษี (7%)",
                        style: TextStyle(fontSize: 15)),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                        '฿${NumberFormat("#,###.##").format(noShippingPrice)}',
                        textAlign: TextAlign.left,
                        style:
                            const TextStyle(fontSize: 15, color: Colors.grey)),
                  ),
                ]),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                padding: const EdgeInsets.all(5),
                width: 400,
                height: 30,
                child: Row(children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text("ส่วนลด ", style: TextStyle(fontSize: 15)),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                        //หัก 7%(${NumberFormat("#,###.##").format(noVatPrice)})
                        '${NumberFormat("#,###.##").format(discountPercent)} %',
                        textAlign: TextAlign.left,
                        style:
                            const TextStyle(fontSize: 15, color: Colors.grey)),
                  ),
                ]),
              ),
              const SizedBox(
                height: 10,
              ),
              // Container of ราคาสุทธิ
              Container(
                width: 400,
                child: Row(children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: const Text("ราคารวมสุทธิ ",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                  if (products.length != 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.shopping_cart_rounded, size: 15),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                  'สินค้า (฿${NumberFormat("#,###,###,###.##").format(noShippingPrice)})',
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        if (shippingCost != 0)
                          Row(
                            children: [
                              const Icon(Icons.local_shipping,
                                  color: Colors.greenAccent, size: 15),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                    '+ (฿${NumberFormat("#,###,###,###.##").format(shippingCost)})',
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.greenAccent)),
                              ),
                            ],
                          ),
                        Row(
                          children: [
                            const Icon(Icons.discount_rounded,
                                color: Colors.redAccent, size: 15),
                            Text(
                                ' ${NumberFormat("#,###,###,###.##").format(discountPercent)} %',
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.redAccent)),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                  '-(฿${NumberFormat("#,###,###,###.##").format(noShippingPrice * discountPercent / 100)})',
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.redAccent)),
                            ),
                          ],
                        )
                      ],
                    ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                        '฿${NumberFormat("#,###,###,###.##").format(showtotalPrice + shippingCost)}',
                        textAlign: TextAlign.left,
                        style:
                            const TextStyle(fontSize: 15, color: Colors.grey)),
                  ),
                ]),
              ),

              Row(
                children: [
                  Text(
                    "คำร้องขอพิเศษ",
                    style: TextStyle(fontSize: 25),
                  ),
                ],
              ),
              // Container of คำร้องขอพิเศษ
              Container(
                padding: const EdgeInsets.all(5),
                width: 400,
                height: 70,
                child: Text(widget.selling.speacialReq!,
                    style: TextStyle(fontSize: 15)),
              ),
              // Container of คำร้องขอพิเศษ
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                      child: widget.selling.isDelivered == true
                          ? Icon(
                              Icons.check_box,
                              size: 40.0,
                              color: Theme.of(context).backgroundColor,
                            )
                          : InkWell(
                              onTap: () {
                                setState(() {
                                  isDelivered = !isDelivered;
                                  if (isDelivered == false) {
                                    print(
                                        'ยังไม่ได้รับสินค้า (${isDelivered})');
                                  } else {
                                    print('ได้รับสินค้าแล้ว (${isDelivered})');
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.transparent),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: isDelivered
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
                        "จัดส่งสินค้าเรียบร้อยแล้ว",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isDelivered == true
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
                          color: isDelivered == true
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

              widget.selling.isDelivered == true
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(children: [
                            ElevatedButton(
                                onPressed: () async {
                                  for (var selling in sellingItems) {
                                    for (var lot in lots) {
                                      if (lot.prodLotId == selling.prodLotId) {
                                        final updateAmountDeletedProductLot =
                                            lot.copy(
                                                remainAmount: selling!.amount +
                                                    lot.remainAmount);

                                        await DatabaseManager.instance
                                            .updateProductLot(
                                                updateAmountDeletedProductLot);
                                      }
                                    }
                                  }
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "ยกเลิกรายการ",
                                  style: TextStyle(fontSize: 17),
                                ),
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.red))
                          ]),
                          Column(children: [
                            ElevatedButton(
                              onPressed: () async {
                                if (isDelivered == true) {
                                  final updatedSelling = widget.selling
                                      .copy(isDelivered: isDelivered);

                                  await DatabaseManager.instance
                                      .updateSelling(updatedSelling);
                                  for (var i = 0;
                                      sellingItems.length > i;
                                      i++) {
                                    for (var lot in productLots) {
                                      if (sellingItems[i].prodLotId ==
                                          lot.prodLotId) {
                                        print(
                                            'Before Update ${lot.remainAmount}');
                                        final updateAmountSelectedProductLot =
                                            lot.copy(
                                                remainAmount: lot.remainAmount -
                                                    sellingItems[i].amount);
                                        await DatabaseManager.instance
                                            .updateProductLot(
                                                updateAmountSelectedProductLot);
                                      }
                                    }
                                  }

                                  Navigator.pop(context);
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
