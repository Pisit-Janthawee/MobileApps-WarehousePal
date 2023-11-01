import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:warehouse_mnmt/Page/Model/Dealer.dart';
import 'package:warehouse_mnmt/Page/Model/DeliveryCompany.dart';
import 'package:warehouse_mnmt/Page/Model/DeliveryRate.dart';
import 'package:warehouse_mnmt/Page/Model/Product.dart';
import 'package:warehouse_mnmt/Page/Model/ProductLot.dart';
import 'package:warehouse_mnmt/Page/Model/ProductModel.dart';
import 'package:warehouse_mnmt/Page/Model/Purchasing.dart';
import 'package:warehouse_mnmt/Page/Model/Purchasing_item.dart';
import 'package:warehouse_mnmt/Page/Provider/theme_provider.dart';
import 'package:warehouse_mnmt/Page/Shop/Buying/nav_edit_deliveryCompany.dart';

import '../../../db/database.dart';
import '../../Model/Shop.dart';
import 'nav_choose_dealer.dart';
import 'nav_choose_product.dart';
import 'nav_choose_shipping.dart';

class BuyingNavAdd extends StatefulWidget {
  final Shop shop;
  const BuyingNavAdd({super.key, required this.shop});
  @override
  State<BuyingNavAdd> createState() => _BuyingNavAddState();
}

class _BuyingNavAddState extends State<BuyingNavAdd> {
  List<PurchasingItemsModel> carts = [];
  List<Product> products = [];
  List<ProductModel> models = [];

  DateTime date = DateTime.now();
  final df = new DateFormat('dd-MM-yyyy');
  DealerModel _dealer =
      DealerModel(dName: 'ยังไม่ระบุตัวแทนจำหน่าย', dAddress: '', dPhone: '');

  var totalWeight = 0;
  var shippingCost = 0;
  var totalPrice = 0;
  var noShippingPrice = 0;
  var amount = 0;
  bool isReceived = false;
  final shipPricController = TextEditingController();

  void initState() {
    super.initState();

    shipPricController.addListener(() => setState(() {}));
    refreshProducts();
  }

  Future refreshProducts() async {
    products =
        await DatabaseManager.instance.readAllProducts(widget.shop.shopid!);

    models = await DatabaseManager.instance.readAllProductModels();
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

  _updateDealer(DealerModel dealer) {
    setState(() {
      _dealer = dealer;
    });
  }

  _addProductInCart(PurchasingItemsModel product) {
    carts.add(product);
  }

  dialogAlertWeightNotInRange(DeliveryCompanyModel company) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dContext, DialogSetState) {
          return AlertDialog(
            backgroundColor: Theme.of(dContext).scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            title: Flexible(
              child: Container(
                width: 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ต้องเพิ่มช่วงน้ำของ ?',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      ' ${company.dcName} ?',
                      style: TextStyle(
                          overflow: TextOverflow.ellipsis, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            content: const Text(
              '"น้ำหนักรวม" ไม่อยู่ในช่วง',
              style: TextStyle(color: Colors.grey),
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.redAccent),
                child: const Text('ไม่'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                child: const Text('ใช่'),
                onPressed: () async {
                  await Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => EditShippingPage(
                                shop: widget.shop!,
                                company: company,
                              )));

                  setState(() {});

                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
      },
    );
  }

  _calculate(
    oldTotal,
    oldAmount,
    oldShippingPrice,
    oldNoShippingPrice,
    oldTotalWeight,
  ) async {
    oldTotal = 0;
    oldAmount = 0;
    oldNoShippingPrice = 0;
    oldTotalWeight = 0;

    for (var i in carts) {
      oldTotal += i.total;
      oldAmount += i.amount;
      for (var model in models) {
        if (model.prodModelId == i.prodModelId) {
          oldTotalWeight += (model.weight * i.amount).toInt();
        }
      }
    }

    totalPrice = oldTotal + oldShippingPrice;
    amount = oldAmount;
    totalWeight = oldTotalWeight;
    shippingCost = oldShippingPrice;
    noShippingPrice = oldTotal;

    setState(() {});
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
                "เพิ่มการสั่งซื้อ",
                style: TextStyle(fontSize: 25),
              )
            ],
          ),
          centerTitle: true,
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
              Container(
                width: 440,
                height: 80,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Color.fromRGBO(56, 48, 77, 1.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_month),
                        Spacer(),
                        Text(
                          '${date.day}/${date.month}/${date.year}',
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                  onPressed: () async {
                    DateTime? newDate = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                        builder: (context, child) => Theme(
                              data: ThemeData().copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: Colors.white,
                                  onPrimary: Theme.of(context).backgroundColor,
                                  surface: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  onSurface: Colors.white,
                                ),
                                dialogBackgroundColor:
                                    Theme.of(context).colorScheme.background,
                              ),
                              child: child!,
                            ));
                    // 'Cancel' => null
                    if (newDate == null) return;

                    // 'OK' => DateTime
                    setState(() => date = newDate);
                  },
                ),
              ),
              Row(
                children: [
                  Text(
                    "ตัวแทนจำหน่าย",
                    style: TextStyle(fontSize: 25),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => BuyingNavChooseDealer(
                                shop: widget.shop,
                                update: _updateDealer,
                              )));
                },
                child: Container(
                  height: _dealer.dName == 'ยังไม่ระบุตัวแทนจำหน่าย' ? 80 : 100,
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(56, 48, 77, 1.0),
                      borderRadius: BorderRadius.circular(15)),
                  child: Row(children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        width: 270,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(_dealer.dName,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                        overflow: TextOverflow.ellipsis,
                                      )),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                _dealer.dName == 'ยังไม่ระบุตัวแทนจำหน่าย'
                                    ? Container()
                                    : Flexible(
                                        child: Text(
                                            '(${_dealer.dPhone.replaceAllMapped(RegExp(r'(\d{3})(\d{3})(\d+)'), (Match m) => "${m[1]}-${m[2]}-${m[3]}")})',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey,
                                              overflow: TextOverflow.ellipsis,
                                            )),
                                      ),
                              ],
                            ),
                            Flexible(
                              child: Text(_dealer.dAddress,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios, color: Colors.white),
                    const SizedBox(
                      width: 10,
                    )
                  ]),
                ),
              ),

              // Container of เลือกลูกค้า
              const SizedBox(
                height: 10,
              ),
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
              // Container of รายการสินค้า
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Color.fromRGBO(56, 48, 77, 1.0),
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).backgroundColor),
                      onPressed: () async {
                        totalPrice = 0;
                        amount = 0;
                        setState(() {});
                        await Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => BuyiingNavChooseProduct(
                                      shop: widget.shop,
                                      update: _addProductInCart,
                                    )));
                        _calculate(totalPrice, amount, shippingCost,
                            noShippingPrice, totalWeight);
                        setState(() {});
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.add), Text("เลือกสินค้า")],
                      ),
                    ),
                    // ListView
                    carts.isEmpty
                        ? Container(
                            width: 0,
                          )
                        : Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: carts.isEmpty
                                ? Container(
                                    width: 400,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: Color.fromRGBO(37, 35, 53, 1.0),
                                    ),
                                    child: Center(
                                        child: Text(
                                      'ไม่มีสินค้า',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 25),
                                    )),
                                  )
                                : Container(
                                    height: carts.length > 1 ? 200 : 100,
                                    width: 440.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: Color.fromRGBO(37, 35, 53, 1.0),
                                    ),
                                    child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        itemCount: carts.length,
                                        itemBuilder: (context, index) {
                                          final purchasing = carts[index];
                                          var prodName;
                                          var prodImg;
                                          var prodModel;

                                          for (var prod in products) {
                                            if (prod.prodId ==
                                                purchasing.prodId) {
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

                                          return Dismissible(
                                            key: UniqueKey(),
                                            onDismissed: (direction) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                backgroundColor:
                                                    Colors.redAccent,
                                                content: Container(
                                                    child: Row(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                      child: Container(
                                                        width: 20,
                                                        height: 20,
                                                        child: Image.file(
                                                          File(prodImg),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(" ลบสินค้า"),
                                                    Text(
                                                      ' ${prodName}',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                    ),
                                                    Text(
                                                        ' x ${NumberFormat("#,###.##").format(purchasing.amount)}',
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12)),
                                                    Text(
                                                        '(${NumberFormat("#,###.##").format(purchasing.total)})',
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12)),
                                                  ],
                                                )),
                                                duration: Duration(seconds: 3),
                                              ));
                                              carts.remove(purchasing);
                                              setState(() {});
                                              _calculate(
                                                totalPrice,
                                                amount,
                                                shippingCost,
                                                noShippingPrice,
                                                totalWeight,
                                              );
                                            },
                                            background: Container(
                                              margin: EdgeInsets.only(
                                                  left: 0,
                                                  top: 10,
                                                  right: 10,
                                                  bottom: 10),
                                              decoration: BoxDecoration(
                                                  color: Colors.redAccent,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.delete_forever,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(
                                                    width: 20,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            direction:
                                                DismissDirection.endToStart,
                                            resizeDuration:
                                                Duration(seconds: 1),
                                            child: TextButton(
                                              onPressed: () {
                                                // Navigator.of(context).push(MaterialPageRoute(
                                                //     builder: (context) => sellingNavShowProd(
                                                //         product: product)));
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 0.0,
                                                    horizontal: 0.0),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Container(
                                                    height: 80,
                                                    width: 400,
                                                    color: Color.fromRGBO(
                                                        56, 54, 76, 1.0),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Container(
                                                          width: 90,
                                                          height: 90,
                                                          child: Image.file(
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
                                                                    decoration: BoxDecoration(
                                                                        // Theme.of(context)
                                                                        //       .colorScheme
                                                                        //       .background
                                                                        color: Color.fromRGBO(36, 33, 50, 1.0),
                                                                        borderRadius: BorderRadius.circular(10)),
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              3.0),
                                                                      child:
                                                                          Text(
                                                                        stProperty,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.white),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                        color: Color.fromRGBO(
                                                                            36,
                                                                            33,
                                                                            50,
                                                                            1.0),
                                                                        borderRadius:
                                                                            BorderRadius.circular(10)),
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              3.0),
                                                                      child:
                                                                          Text(
                                                                        ndProperty,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.white),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Text(
                                                                  'รวม ฿${NumberFormat("#,###.##").format(purchasing.total)}',
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
                                                              color: Color
                                                                  .fromRGBO(
                                                                      30,
                                                                      30,
                                                                      49,
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
                                                                '${NumberFormat("#,###.##").format(purchasing.amount)}',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .bottomNavigationBarTheme
                                                                        .selectedItemColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                          ),
                    // ListView
                    carts.isEmpty
                        ? Container(
                            width: 10,
                          )
                        : Row(
                            children: [
                              Container(
                                width: 180,
                                child: Row(
                                  children: [
                                    Text(
                                      'น้ำหนักรวม ',
                                      style:
                                          const TextStyle(color: Colors.white),
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
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'ทั้งหมด ',
                                style: const TextStyle(color: Colors.white),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(30, 30, 49, 1.0),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Text(
                                      '${NumberFormat("#,###.##").format(carts.length)}',
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
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                  ]),
                ),
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

              // Container of การจัดส่ง
              const SizedBox(
                height: 10,
              ),
              // Container of ค่าจัดส่ง
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(56, 48, 77, 1.0),
                    borderRadius: BorderRadius.circular(15)),
                width: 400,
                height: 70,
                child: TextField(
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(7),
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    onChanged: (text) {
                      if (shipPricController.text != null &&
                          shipPricController.text != '') {
                        _calculate(
                            totalPrice,
                            amount,
                            double.parse(
                              shipPricController.text == null &&
                                      shipPricController.text == ''
                                  ? '0'
                                  : shipPricController.text
                                      .replaceAll(RegExp('[^0-9]'), ''),
                            ).toInt(),
                            noShippingPrice,
                            totalWeight);
                      }
                    },
                    textAlign: TextAlign.end,
                    // inputFormatters: [DecimalFormatter()],
                    keyboardType: TextInputType.number,
                    //-----------------------------------------------------
                    style: const TextStyle(color: Colors.grey),
                    controller: shipPricController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.transparent,
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide.none),
                      hintText: "ใส่ค่าจัดส่ง",
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 14),
                      prefixIcon:
                          const Icon(Icons.local_shipping, color: Colors.white),
                      suffixIcon: !shipPricController.text.isEmpty
                          ? IconButton(
                              onPressed: () {
                                shipPricController.clear();
                                shippingCost = 0;
                                _calculate(
                                  totalPrice,
                                  amount,
                                  shippingCost,
                                  noShippingPrice,
                                  totalWeight,
                                );
                                setState(() {});
                              },
                              icon: const Icon(
                                Icons.close_sharp,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    )),
              ),

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
                    color: const Color.fromRGBO(56, 48, 77, 1.0),
                    borderRadius: BorderRadius.circular(15)),
                width: 400,
                height: 70,
                child: Row(children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: const Text("จำนวน",
                        style: TextStyle(fontSize: 15, color: Colors.white)),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                        '${NumberFormat("#,###,###,### ชิ้น").format(amount)}',
                        textAlign: TextAlign.left,
                        style:
                            const TextStyle(fontSize: 15, color: Colors.grey)),
                  ),
                ]),
              ),
              // Container of จำนวน
              const SizedBox(
                height: 10,
              ),
              // Container of รวม
              Container(
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(56, 48, 77, 1.0),
                    borderRadius: BorderRadius.circular(15)),
                width: 400,
                height: 70,
                child: Wrap(
                  children: [
                    Row(children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: const Text("รวม",
                            style:
                                TextStyle(fontSize: 15, color: Colors.white)),
                      ),
                      Spacer(),
                      Column(
                        children: [
                          shippingCost == 0
                              ? Container(
                                  width: 0,
                                )
                              : Text(
                                  'สินค้า (฿${NumberFormat("#,###,###,###.##").format(noShippingPrice)})',
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
                            '฿${NumberFormat("#,###,###,###.##").format(totalPrice)}',
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
                height: 10,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                      child: InkWell(
                    onTap: () {
                      setState(() {
                        isReceived = !isReceived;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.transparent),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: isReceived
                            ? Icon(
                                Icons.check_box,
                                size: 40.0,
                                color: Theme.of(context)
                                    .bottomNavigationBarTheme
                                    .selectedItemColor,
                              )
                            : Icon(
                                Icons.check_box_outline_blank,
                                size: 40.0,
                                color: Theme.of(context)
                                    .bottomNavigationBarTheme
                                    .selectedItemColor,
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
                        ),
                      ),
                      Text(
                        "(สินค้าคงเหลือจะได้รับการปรับปรุง)",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(children: [
                      ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(primary: Colors.redAccent),
                        onPressed: () {},
                        child: Text(
                          "ยกเลิก",
                          style: TextStyle(fontSize: 17),
                        ),
                      )
                    ]),
                    Column(children: [
                      ElevatedButton(
                        onPressed: () async {
                          if (_dealer.dName == 'ยังไม่ระบุตัวแทนจำหน่าย') {
                            _showAlertSnackBar('โปรดระบุตัวแทนจำหน่าย');
                          } else if (carts.isEmpty || carts.length == 0) {
                            _showAlertSnackBar('รายการสั่งซื้อว่าง');
                          } else {
                            // Purchasing
                            final purchased = PurchasingModel(
                                orderedDate: date,
                                dealerId: _dealer.dealerId!,
                                shippingCost: shippingCost,
                                amount: amount,
                                total: totalPrice - shippingCost,
                                isReceive: isReceived,
                                shopId: widget.shop.shopid!);
                            final createdPur = await DatabaseManager.instance
                                .createPurchasing(purchased);
                            print(
                                'Created Purchasing WHERE ${createdPur.purId}');
                            // items

                            for (var cart in carts) {
                              final item = PurchasingItemsModel(
                                  prodId: cart.prodId,
                                  prodModelId: cart.prodModelId,
                                  amount: cart.amount,
                                  total: cart.total,
                                  purId: createdPur.purId!);
                              await DatabaseManager.instance
                                  .createPurchasingItem(item);
                              final productLot = ProductLot(
                                  orderedTime: date,
                                  amount: '${cart.amount}',
                                  remainAmount:
                                      isReceived == true ? cart.amount : 0,
                                  purId: createdPur.purId,
                                  isReceived: isReceived,
                                  prodModelId: cart.prodModelId);

                              await DatabaseManager.instance
                                  .createProductLot(productLot);
                            }
                            // Product Lot
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor:
                                  Theme.of(context).backgroundColor,
                              behavior: SnackBarBehavior.floating,
                              content: Row(
                                children: [
                                  Text(
                                      "ทำรายการเสร็จสิ้น ยอด ${NumberFormat("#,###,###.##").format(purchased.total)}"),
                                  Text(
                                    " ${df.format(date)}",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              duration: Duration(seconds: 5),
                            ));
                            Navigator.pop(context);
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
