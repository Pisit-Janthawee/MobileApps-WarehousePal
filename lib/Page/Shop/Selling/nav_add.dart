import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:warehouse_mnmt/Page/Model/Customer.dart';
import 'package:warehouse_mnmt/Page/Model/CustomerAdress.dart';
import 'package:warehouse_mnmt/Page/Model/DeliveryCompany.dart';
import 'package:warehouse_mnmt/Page/Model/DeliveryRate.dart';
import 'package:warehouse_mnmt/Page/Model/Product.dart';
import 'package:warehouse_mnmt/Page/Model/ProductLot.dart';
import 'package:warehouse_mnmt/Page/Model/Selling.dart';
import 'package:warehouse_mnmt/Page/Model/Selling_item.dart';
import 'package:warehouse_mnmt/Page/Provider/theme_provider.dart';
import 'package:warehouse_mnmt/Page/Shop/Buying/nav_choose_shipping.dart';
import 'package:warehouse_mnmt/Page/Shop/Buying/nav_edit_deliveryCompany.dart';
import 'package:warehouse_mnmt/Page/Shop/Selling/selling_nav_chooseCustomer.dart';
import 'package:warehouse_mnmt/Page/Shop/Selling/nav_choose_product.dart';
import 'package:warehouse_mnmt/db/database.dart';

import '../../Component/DatePicker.dart';
import '../../Model/ProductModel.dart';
import '../../Model/Shop.dart';

class SellingNavAdd extends StatefulWidget {
  final Shop shop;
  const SellingNavAdd({required this.shop, Key? key}) : super(key: key);

  @override
  State<SellingNavAdd> createState() => _SellingNavAddState();
}

class _SellingNavAddState extends State<SellingNavAdd> {
  TextEditingController shipPricController = TextEditingController();
  TextEditingController specReqController = TextEditingController();
  TextEditingController discountPercentController = TextEditingController();
  CustomerModel _customer = CustomerModel(cName: 'ยังไม่ระบุลูกค้า');
  CustomerAddressModel _address = CustomerAddressModel(
    cAddress: 'ที่อยู่',
    cPhone: 'เบอร์โทร',
  );

  DateTime date = DateTime.now();
  final df = new DateFormat('dd-MM-yyyy hh:mm a');

  var shippingCost = 0;
  var showtotalPrice = 0;
  var totalPrice = 0;
  var noShippingPrice = 0;
  var amount = 0;
  var discountPercent = 0;
  var discountPercentPrice = 0;
  var profit = 0;
  var totalWeight = 0;
  double vat7percent = 0.0;
  double noVatPrice = 0.0;
  bool isDelivered = false;
  List<Product> products = [];
  List<ProductModel> models = [];
  List<ProductLot> lots = [];
  List<SellingItemModel> carts = [];
  List<ProductLot> productLots = [];
  DeliveryCompanyModel company =
      DeliveryCompanyModel(dcName: 'ระบุการจัดส่ง', dcisRange: false);
  _addSellingItem(SellingItemModel product) {
    carts.add(product);
  }

  @override
  void initState() {
    super.initState();
    refreshProducts();

    shipPricController.addListener(() => setState(() {}));
    shipPricController.addListener(() => setState(() {}));
    specReqController.addListener(() => setState(() {}));
  }

  Future refreshProducts() async {
    products =
        await DatabaseManager.instance.readAllProducts(widget.shop.shopid!);
    productLots = await DatabaseManager.instance.readAllProductLots();
    models = await DatabaseManager.instance.readAllProductModels();
    lots = await DatabaseManager.instance.readAllProductLots();

    setState(() {});
  }

  _updateCustomer(CustomerModel customer) {
    setState(() {
      _customer = customer;
    });
  }

  _updateCustomerAddress(CustomerAddressModel address) {
    setState(() {
      _address = address;
    });
  }

  _updateShipping(DeliveryCompanyModel shipping) async {
    setState(() {
      company = shipping;
    });
  }

  dialogAlertWeightNotInRange(DeliveryCompanyModel company) async {
    List<DeliveryRateModel> deliveryRates = [];
    deliveryRates = await DatabaseManager.instance
        .readDeliveryRatesWHEREdcId(widget.shop.dcId!);
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
                      'ต้องเพิ่มช่วงน้ำหนักของ ',
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
            content: Text(
              '"น้ำหนักรวม" = ${totalWeight} กรัม ไม่อยู่ในช่วง \n ช่วงสูงสุดคือ ${deliveryRates.last.weightRange}',
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
                  _calculate(
                      totalPrice,
                      amount,
                      shippingCost,
                      noShippingPrice,
                      vat7percent,
                      noVatPrice,
                      discountPercent,
                      discountPercentPrice,
                      profit,
                      totalWeight,
                      company!);
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
      oldvat7percent,
      oldNoVatPrice,
      oldDiscountPercent,
      oldDiscountPercentPrice,
      oldProfit,
      oldTotalWeight,
      DeliveryCompanyModel _newShipping) async {
    oldTotal = 0;
    oldAmount = 0;
    oldNoShippingPrice = 0;
    oldvat7percent = 0;
    oldNoVatPrice = 0;
    oldProfit = 0;
    oldTotalWeight = 0;

    oldDiscountPercentPrice = 0;
    for (var i in carts) {
      oldTotal += i.total;
      oldAmount += i.amount;
      for (var model in models) {
        if (i.prodModelId == model.prodModelId) {
          oldProfit += (i.amount * model.price) - (i.amount * model.cost);
          oldTotalWeight += (model.weight * i.amount).toInt();
        }
      }
    }
    List<DeliveryRateModel> deliveryRates = [];

    if (carts.isNotEmpty) {
      if (_newShipping.dcId != null) {
        if (_newShipping.dcisRange == true) {
          deliveryRates = await DatabaseManager.instance
              .readDeliveryRatesWHEREdcId(widget.shop.dcId!);

          if (deliveryRates.isNotEmpty) {
            for (var rate in deliveryRates) {
              if (double.parse(rate.weightRange.split('-')[0]).toInt() <=
                      totalWeight.toInt() &&
                  oldTotalWeight.toInt() <=
                      double.parse(rate.weightRange.split('-')[1]).toInt()) {
                shippingCost = rate.cost;
                print('${rate}');
              }
            }

            if (shippingCost == 0) {
              shippingCost = 0;

              dialogAlertWeightNotInRange(company!);
            }
          }
        } else {
          shippingCost = _newShipping.fixedDeliveryCost!;
        }
      } else {
        if (_newShipping.dcName == 'รับสินค้าเอง') {
          shippingCost = 0;
        } else if (_newShipping.dcName == 'ระบุราคา') {
          shippingCost = _newShipping.fixedDeliveryCost!;
        } else {}
      }
    } else {
      shippingCost = 0;
    }
    discountPercent = oldDiscountPercent;
    discountPercentPrice = (oldTotal * oldDiscountPercent / 100).toInt();
    noShippingPrice = oldTotal;
    vat7percent = oldTotal * 7 / 100;
    noVatPrice = oldTotal - vat7percent;
    profit = oldProfit - (oldProfit * discountPercent / 100).toInt();
    totalWeight = oldTotalWeight;
    amount = oldAmount;
    totalPrice = oldTotal - discountPercentPrice;
    showtotalPrice = oldTotal + oldShippingPrice - discountPercentPrice;

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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),

            // Return Back Selling Items Remaining Amount
            onPressed: () async {
              if (carts.isNotEmpty) {
                for (var i = 0; carts.length > i; i++) {
                  for (var lot in productLots) {
                    if (carts[i].prodLotId == lot.prodLotId) {
                      final updateAmountSelectedProductLot = lot.copy(
                          remainAmount: lot.remainAmount + carts[i].amount);
                      await DatabaseManager.instance
                          .updateProductLot(updateAmountSelectedProductLot);
                    }
                  }
                }
                ;
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
              }
            },
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
          title: Column(
            children: [
              Text(
                "เพิ่มรายการขาย",
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
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => SellingNavChooseCustomer(
                                shop: widget.shop,
                                updateCustomer: _updateCustomer,
                                updateCustomerAddress: _updateCustomerAddress,
                              )));
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(56, 48, 77, 1.0),
                      borderRadius: BorderRadius.circular(15)),
                  height: _customer.cName == 'ยังไม่ระบุลูกค้า' ? 80 : 100,
                  child: Row(children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(_customer.cName,
                                  style: TextStyle(
                                      fontSize: 17,
                                      // fontWeight: FontWeight.bold,
                                      color:
                                          _customer.cName == 'ยังไม่ระบุลูกค้า'
                                              ? Colors.grey
                                              : Colors.white)),
                              _customer.cName == 'ยังไม่ระบุลูกค้า'
                                  ? Container(
                                      width: 0,
                                    )
                                  : Text(
                                      ' (${_address.cPhone.replaceAllMapped(RegExp(r'(\d{3})(\d{3})(\d+)'), (Match m) => "${m[1]}-${m[2]}-${m[3]}")})',
                                      style: TextStyle(
                                          fontSize: 17,
                                          // fontWeight: FontWeight.bold,
                                          color: _customer.cName ==
                                                  'ยังไม่ระบุลูกค้า'
                                              ? Colors.grey
                                              : Colors.white)),
                            ],
                          ),
                          _customer.cName == 'ยังไม่ระบุลูกค้า'
                              ? Container(
                                  width: 0,
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_address.cAddress,
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.grey)),
                                  ],
                                ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white),
                    const SizedBox(
                      width: 10,
                    )
                  ]),
                ),
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
                decoration: BoxDecoration(
                    color: Color.fromRGBO(56, 48, 77, 1.0),
                    borderRadius: BorderRadius.circular(15)),
                width: 440,
                height: carts.isEmpty ? 70 : 340,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: [
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => SellingNavChooseProduct(
                                      shop: widget.shop,
                                      update: _addSellingItem,
                                    )));
                        refreshProducts();

                        _calculate(
                            totalPrice,
                            amount,
                            shippingCost,
                            noShippingPrice,
                            vat7percent,
                            noVatPrice,
                            discountPercent,
                            discountPercentPrice,
                            profit,
                            totalWeight,
                            company!);

                        setState(() {});
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add),
                          Text("เลือกสินค้า"),
                        ],
                      ),
                    ),
                    // ListView
                    carts.isEmpty
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Container(
                              height: 224.0,
                              width: 440.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: Color.fromRGBO(37, 35, 53, 1.0),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  carts.isEmpty
                                      ? const Text(
                                          '(ไม่มีสินค้า)',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 25),
                                        )
                                      : Container(
                                          height: 224.0,
                                          width: 440.0,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            color:
                                                Color.fromRGBO(37, 35, 53, 1.0),
                                          ),
                                          child: ListView.builder(
                                              padding: EdgeInsets.zero,
                                              itemCount: carts.length,
                                              itemBuilder: (context, index) {
                                                final selling = carts[index];
                                                var prodName;
                                                var prodImg;
                                                var prodModel;
                                                for (var prod in products) {
                                                  if (prod.prodId ==
                                                      selling.prodId) {
                                                    prodImg = prod.prodImage!;
                                                    prodName = prod.prodName;
                                                  }
                                                }

                                                var stProperty;
                                                var ndProperty;

                                                for (var model in models) {
                                                  if (model.prodModelId ==
                                                      selling.prodModelId) {
                                                    stProperty =
                                                        model.stProperty;
                                                    ndProperty =
                                                        model.ndProperty;
                                                  }
                                                }

                                                return Dismissible(
                                                  key: UniqueKey(),
                                                  onDismissed:
                                                      (direction) async {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      backgroundColor:
                                                          Colors.redAccent,
                                                      content: Container(
                                                          child: Row(
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30),
                                                            child: Container(
                                                              width: 20,
                                                              height: 20,
                                                              child: Image.file(
                                                                File(prodImg),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(" ลบสินค้า"),
                                                          Text(
                                                            ' ${prodName}',
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ],
                                                      )),
                                                      duration:
                                                          Duration(seconds: 1),
                                                    ));
                                                    carts.remove(selling);
                                                    for (var lot in lots) {
                                                      if (lot.prodLotId ==
                                                          selling.prodLotId) {
                                                        final updateAmountDeletedProductLot =
                                                            lot.copy(
                                                                remainAmount: selling!
                                                                        .amount +
                                                                    lot.remainAmount);

                                                        await DatabaseManager
                                                            .instance
                                                            .updateProductLot(
                                                                updateAmountDeletedProductLot);
                                                      }
                                                    }
                                                    _calculate(
                                                        totalPrice,
                                                        amount,
                                                        shipPricController.text
                                                                    .isEmpty ||
                                                                shipPricController
                                                                        .text ==
                                                                    null
                                                            ? 0
                                                            : double.parse(
                                                                shipPricController
                                                                    .text,
                                                              ).toInt(),
                                                        noShippingPrice,
                                                        vat7percent,
                                                        noVatPrice,
                                                        discountPercentController
                                                                    .text
                                                                    .isEmpty ||
                                                                discountPercentController
                                                                        .text ==
                                                                    null
                                                            ? 0
                                                            : double.parse(
                                                                discountPercentController
                                                                    .text,
                                                              ).toInt(),
                                                        discountPercentPrice,
                                                        profit,
                                                        totalWeight,
                                                        company!);

                                                    setState(() {});
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
                                                            BorderRadius
                                                                .circular(10)),
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
                                                  direction: DismissDirection
                                                      .endToStart,
                                                  resizeDuration:
                                                      Duration(seconds: 1),
                                                  child: TextButton(
                                                    onPressed: () {
                                                      // Navigator.of(context).push(MaterialPageRoute(
                                                      //     builder: (context) => sellingNavShowProd(
                                                      //         product: product)));
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 0.0,
                                                              horizontal: 0.0),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
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
                                                                child:
                                                                    Image.file(
                                                                  File(
                                                                      prodImg!),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 10),
                                                              Expanded(
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: <
                                                                      Widget>[
                                                                    Text(
                                                                      '${prodName}',
                                                                      style: const TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.white),
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
                                                                                const EdgeInsets.all(3.0),
                                                                            child:
                                                                                Text(
                                                                              stProperty,
                                                                              style: const TextStyle(fontSize: 12, color: Colors.white),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        Container(
                                                                          decoration: BoxDecoration(
                                                                              color: Color.fromRGBO(36, 33, 50, 1.0),
                                                                              borderRadius: BorderRadius.circular(10)),
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(3.0),
                                                                            child:
                                                                                Text(
                                                                              ndProperty,
                                                                              style: const TextStyle(fontSize: 12, color: Colors.white),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Text(
                                                                        'รวม ฿${NumberFormat("#,###.##").format(selling.total)}',
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.grey,
                                                                            fontSize: 12)),
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
                                                                        BorderRadius.circular(
                                                                            10)),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          3.0),
                                                                  child: Text(
                                                                      '${NumberFormat("#,###.##").format(selling.amount)}',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          color: Theme.of(context)
                                                                              .bottomNavigationBarTheme
                                                                              .selectedItemColor,
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
                    carts.isEmpty
                        ? Container()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'น้ำหนักรวม ',
                                style: const TextStyle(color: Colors.white),
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
                                style: const TextStyle(color: Colors.white),
                              ),
                              const Spacer(),
                              Text(
                                "จำนวนทั้งหมด",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor:
                                      Color.fromRGBO(30, 30, 49, 1.0),
                                  child: Text(
                                      '${NumberFormat("#,###").format(carts.length)}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .bottomNavigationBarTheme
                                              .selectedItemColor,
                                          fontWeight: FontWeight.bold)),
                                ),
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
              // Container of การจัดส่ง
              GestureDetector(
                onTap: (() async {
                  await Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => ChooseShippingNav(
                                shop: widget.shop,
                                update: _updateShipping,
                              )));
                  setState(() {});
                  _calculate(
                      totalPrice,
                      amount,
                      shippingCost,
                      noShippingPrice,
                      vat7percent,
                      noVatPrice,
                      discountPercent,
                      discountPercentPrice,
                      profit,
                      totalWeight,
                      company!);
                  setState(() {});
                }),
                child: Container(
                  decoration: BoxDecoration(
                      color: const Color.fromRGBO(56, 48, 77, 1.0),
                      borderRadius: BorderRadius.circular(15)),
                  width: 400,
                  height: 70,
                  child: Row(children: [
                    const Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text("การจัดส่ง",
                          style: TextStyle(fontSize: 15, color: Colors.white)),
                    ),
                    const Spacer(),
                    Container(
                      width: 200,
                      alignment: Alignment.centerRight,
                      child: Text(
                          '${company == null ? 'ระบุการจัดส่ง' : company!.dcName}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 15, color: Colors.grey)),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white),
                    const SizedBox(
                      width: 10,
                    ),
                  ]),
                ),
              ),

              // Container of การจัดส่ง
              const SizedBox(
                height: 10,
              ),
              // Container of ค่าจัดส่ง self-gen
              Container(
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(56, 48, 77, 1.0),
                    borderRadius: BorderRadius.circular(15)),
                width: 400,
                height: 70,
                child: Row(children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: const Text("ค่าจัดส่ง",
                        style: TextStyle(fontSize: 15, color: Colors.white)),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                        company?.dcName == 'รับสินค้าเอง'
                            ? 'ไม่คิดค่าจัดส่ง'
                            : '฿${NumberFormat("#,###,###,###").format(shippingCost)}',
                        textAlign: TextAlign.left,
                        style:
                            const TextStyle(fontSize: 15, color: Colors.grey)),
                  ),
                ]),
              ),
              // Container of ค่าจัดส่ง self-gen
              const SizedBox(
                height: 10,
              ),

              Container(
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(56, 48, 77, 1.0),
                    borderRadius: BorderRadius.circular(15)),
                width: 400,
                height: 70,
                child: Row(children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: const Text("ราคาสินค้า",
                        style: TextStyle(fontSize: 15, color: Colors.white)),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                        //หัก 7%(${NumberFormat("#,###.##").format(noVatPrice)})
                        '฿${NumberFormat("#,###.##").format(noShippingPrice - vat7percent)}',
                        textAlign: TextAlign.left,
                        style:
                            const TextStyle(fontSize: 15, color: Colors.grey)),
                  ),
                ]),
              ),
              // Container of ราคาสุทธิ
              const SizedBox(
                height: 10,
              ),
              // Container of ภาษี 7 %
              Container(
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(56, 48, 77, 1.0),
                    borderRadius: BorderRadius.circular(15)),
                width: 400,
                height: 70,
                child: Row(children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: const Text("ภาษี (7%)",
                        style: TextStyle(fontSize: 15, color: Colors.white)),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                        '฿${NumberFormat("#,###.##").format(vat7percent)}',
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
              // Container of ภาษี 7 %
              Container(
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(56, 48, 77, 1.0),
                    borderRadius: BorderRadius.circular(15)),
                width: 400,
                height: 70,
                child: Row(children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: const Text("ราคาสินค้า + ภาษี (7%)",
                        style: TextStyle(fontSize: 15, color: Colors.white)),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                        '฿${NumberFormat("#,###.##").format(noShippingPrice)}',
                        textAlign: TextAlign.left,
                        style:
                            const TextStyle(fontSize: 15, color: Colors.grey)),
                  ),
                ]),
              ),
              // Container of ส่วนลด
              const SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(56, 48, 77, 1.0),
                    borderRadius: BorderRadius.circular(15)),
                width: 400,
                height: 70,
                child: Row(children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: const Text("กำไร",
                        style: TextStyle(fontSize: 15, color: Colors.white)),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text('฿${NumberFormat("#,###.##").format(profit)}',
                        textAlign: TextAlign.left,
                        style:
                            const TextStyle(fontSize: 15, color: Colors.grey)),
                  ),
                ]),
              ),
              // Container of ส่วนลด
              const SizedBox(
                height: 10,
              ),

              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(56, 48, 77, 1.0),
                    borderRadius: BorderRadius.circular(15)),
                width: 400,
                height: 70,
                child: Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    const Icon(Icons.discount_rounded, color: Colors.white),
                    Text(" % ส่วนลด ",
                        style: TextStyle(fontSize: 15, color: Colors.white)),
                    const Spacer(),
                    Container(
                      width: 150,
                      height: 70,
                      child: TextField(
                          onChanged: ((value) {
                            if (discountPercentController.text.isNotEmpty &&
                                discountPercentController.text != null &&
                                discountPercentController.text != '') {
                              if (double.parse(discountPercentController.text)
                                      .toInt() >
                                  100) {
                                discountPercentController.clear();
                                setState(() {});
                              } else {
                                _calculate(
                                    totalPrice,
                                    amount,
                                    shipPricController.text.isEmpty
                                        ? 0
                                        : double.parse(shipPricController.text
                                                .replaceAll(
                                                    RegExp('[^0-9]'), ''))
                                            .toInt(),
                                    noShippingPrice,
                                    vat7percent,
                                    noVatPrice,
                                    double.parse(discountPercentController.text
                                            .replaceAll(RegExp('[^0-9]'), ''))
                                        .toInt(),
                                    discountPercentPrice,
                                    profit,
                                    totalWeight,
                                    company!);
                              }
                            }
                          }),
                          textAlign: TextAlign.end,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(3),
                          ],
                          onSubmitted: (context) {
                            // if (shipPricController.text.isEmpty == true) {
                            //   _calculateShip(0.0);
                            // } else {
                            //   _calculateShip(double.parse(shipPricController.text));
                            // }
                          },
                          //-----------------------------------------------------
                          style: const TextStyle(color: Colors.grey),
                          controller: discountPercentController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.transparent,
                            border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide.none),
                            hintText: "%",
                            hintStyle: const TextStyle(
                                color: Colors.grey, fontSize: 14),
                            suffixIcon: !discountPercentController.text.isEmpty
                                ? IconButton(
                                    onPressed: () {
                                      discountPercentController.clear();
                                      discountPercent = 0;
                                      _calculate(
                                          totalPrice,
                                          amount,
                                          shipPricController.text.isEmpty
                                              ? 0
                                              : double.parse(shipPricController
                                                      .text
                                                      .replaceAll(
                                                          RegExp('[^0-9]'), ''))
                                                  .toInt(),
                                          noShippingPrice,
                                          vat7percent,
                                          noVatPrice,
                                          discountPercent,
                                          discountPercentPrice,
                                          profit,
                                          totalWeight,
                                          company!);
                                    },
                                    icon: const Icon(
                                      Icons.close_sharp,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          )),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              // Container of ราคาขายรวม
              Container(
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(56, 48, 77, 1.0),
                    borderRadius: BorderRadius.circular(15)),
                width: 400,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: const Text("ราคารวมสุทธิ",
                          style: TextStyle(fontSize: 15, color: Colors.white)),
                    ),
                    if (products.length != 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text('สินค้า ',
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                              ),
                              const Icon(Icons.shopping_cart_rounded,
                                  color: Colors.white, size: 15),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                    '(฿${NumberFormat("#,###,###,###.##").format(noShippingPrice)})',
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                              ),
                            ],
                          ),
                          if (shippingCost != 0)
                            Row(
                              children: [
                                Text(' ค่าจัดส่ง ',
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.greenAccent)),
                                const Icon(Icons.local_shipping,
                                    color: Colors.greenAccent, size: 15),
                                Text(
                                    ' + (฿  ${NumberFormat("#,###,###,###.##").format(shippingCost)})',
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.greenAccent)),
                              ],
                            ),
                          if (discountPercentController.text.isNotEmpty)
                            Row(
                              children: [
                                Text(
                                    ' ส่วนลด ${NumberFormat("#,###,###,###.##").format(discountPercent)} %',
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.redAccent)),
                                const Icon(Icons.discount_rounded,
                                    color: Colors.redAccent, size: 15),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                      '(-฿${NumberFormat("#,###,###,###.##").format(discountPercentPrice)})',
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.redAccent)),
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
                          style: const TextStyle(
                              fontSize: 15, color: Colors.grey)),
                    ),
                  ]),
                ),
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
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(56, 48, 77, 1.0),
                    borderRadius: BorderRadius.circular(15)),
                width: 400,
                height: 70,
                child: TextField(
                    style: const TextStyle(color: Colors.white),
                    controller: specReqController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromRGBO(56, 48, 77, 1.0),
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide.none),
                      hintText: "เช่น ฝากวางหน้าบ้าน ตรงโต๊ะไม้หินอ่อน",
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 14),
                      prefixIcon: const Icon(Icons.edit, color: Colors.white),
                      suffixIcon: specReqController.text.isEmpty
                          ? Container(
                              width: 0,
                            )
                          : IconButton(
                              onPressed: () => specReqController.clear(),
                              icon: const Icon(
                                Icons.close_sharp,
                                color: Colors.white,
                              ),
                            ),
                    )),
              ),
              // Container of คำร้องขอพิเศษ
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                      child: InkWell(
                    onTap: () {
                      setState(() {
                        isDelivered = !isDelivered;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.transparent),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: isDelivered
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
                        "จัดส่งสินค้าเรียบร้อยแล้ว",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        "(สินค้าคงเหลือจะได้รับการปรับปรุง)",
                        style: TextStyle(fontSize: 15),
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
                          onPressed: () async {
                            for (var selling in carts) {
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
                            "ยกเลิก",
                            style: TextStyle(fontSize: 17),
                          ),
                          style: ElevatedButton.styleFrom(primary: Colors.red))
                    ]),
                    Column(children: [
                      ElevatedButton(
                        onPressed: () async {
                          if (_customer.cName == 'ยังไม่ระบุลูกค้า') {
                            _showAlertSnackBar('โปรดระบุลูกค้า');
                          } else if (carts.isEmpty) {
                            _showAlertSnackBar(
                                'โปรดเลือกสินค้าอย่างน้อย 1 รายการ');
                          } else if (_address.cAddress == 'ที่อยู่') {
                            _showAlertSnackBar('โปรดเลือกที่อยู่ลูกค้า');
                          } else if (company!.dcName == 'ระบุการจัดส่ง') {
                            _showAlertSnackBar('โปรดเลือกการจัดส่ง');
                          } else {
                            _calculate(
                                totalPrice,
                                amount,
                                shipPricController.text.isEmpty ||
                                        shipPricController.text == null ||
                                        shipPricController.text == ''
                                    ? 0
                                    : double.parse(shipPricController.text
                                            .replaceAll(RegExp('[^0-9]'), ''))
                                        .toInt(),
                                noShippingPrice,
                                vat7percent,
                                noVatPrice,
                                discountPercentController.text.isEmpty ||
                                        discountPercentController.text ==
                                            null ||
                                        discountPercentController.text == ''
                                    ? 0
                                    : double.parse(discountPercentController
                                            .text
                                            .replaceAll(RegExp('[^0-9]'), ''))
                                        .toInt(),
                                discountPercentPrice,
                                profit,
                                totalWeight,
                                company!);
                            setState(() {});

                            final createSelling = SellingModel(
                                orderedDate: date,
                                customerId: _customer.cusId!,
                                cAddreId: _address.cAddreId!,
                                deliveryCompanyId:
                                    company.dcId == null ? null : company.dcId!,
                                shippingCost: shippingCost,
                                amount: amount,
                                discountPercent: discountPercent,
                                total: totalPrice,
                                profit: profit,
                                speacialReq: specReqController.text.isEmpty ||
                                        specReqController.text == null
                                    ? '-'
                                    : specReqController.text,
                                isDelivered: isDelivered,
                                shopId: widget.shop.shopid!);

                            final createdSelling = await DatabaseManager
                                .instance
                                .createSelling(createSelling);

                            for (var cart in carts) {
                              final item = SellingItemModel(
                                  prodId: cart.prodId,
                                  prodModelId: cart.prodModelId,
                                  prodLotId: cart.prodLotId,
                                  amount: cart.amount,
                                  total: cart.total,
                                  selId: createdSelling.selId);

                              await DatabaseManager.instance
                                  .createSellingItem(item);
                              if (carts.isNotEmpty) {
                                if (isDelivered == true) {
                                } else {
                                  for (var i = 0; carts.length > i; i++) {
                                    for (var lot in productLots) {
                                      if (carts[i].prodLotId == lot.prodLotId) {
                                        final updateAmountSelectedProductLot =
                                            lot.copy(
                                                remainAmount: lot.remainAmount +
                                                    carts[i].amount);
                                        await DatabaseManager.instance
                                            .updateProductLot(
                                                updateAmountSelectedProductLot);
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor:
                                  Theme.of(context).backgroundColor,
                              behavior: SnackBarBehavior.floating,
                              content: Row(
                                children: [
                                  Text(
                                      "ทำรายการเสร็จสิ้น ยอด ${NumberFormat("#,###,###.##").format(createSelling.total)}"),
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
