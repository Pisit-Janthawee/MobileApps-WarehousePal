// Others
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:provider/provider.dart';

import 'package:warehouse_mnmt/Page/Component/SearchBox.dart';
import 'package:warehouse_mnmt/Page/Component/TextField/CustomTextField.dart';
import 'package:warehouse_mnmt/Page/Model/ProductCategory.dart';
import 'package:warehouse_mnmt/Page/Model/ProductLot.dart';
import 'package:warehouse_mnmt/Page/Model/ProductModel.dart';
import 'package:warehouse_mnmt/Page/Model/Purchasing_item.dart';
import 'package:warehouse_mnmt/Page/Provider/theme_provider.dart';

import '../../../db/database.dart';
import '../../Model/Product.dart';
import '../../Model/ProductModel_ndProperty.dart';
import '../../Model/ProductModel_stProperty.dart';

class BuyingNavShowProd extends StatefulWidget {
  final Product product;
  final ProductCategory? prodCategory;
  final int? productTotalAmount;
  final ValueChanged<PurchasingItemsModel> update;
  BuyingNavShowProd({
    Key? key,
    this.prodCategory,
    this.productTotalAmount,
    required this.update,
    required this.product,
  }) : super(key: key);
  @override
  State<BuyingNavShowProd> createState() => _BuyingNavShowProdState();
}

// New

List<ProductModel> selectedItems = [];
List<TextEditingController> amountControllers = [];

final List<String> items = [
  'Item1',
  'Item2',
  'Item3',
  'Item4',
  'Item5',
  'Item6',
  'Item7',
  'Item8',
  'Item9',
  'Item10',
  'Item11',
  'Item12',
];

// New

class _BuyingNavShowProdState extends State<BuyingNavShowProd> {
  List<ProductModel> productModels = [];
  List<ProductLot> productLots = [];
  List<ProductModel_stProperty> stPropertys = [];
  List<ProductModel_ndProperty> ndPropertys = [];
  ProductModel? selectedValue;
  var allTotal = 0;
  var allTotalAmount = 0;
  String? value;
  bool isReceived = false;
  final prodAmountController = TextEditingController();
  bool _validate = false;

  void initState() {
    super.initState();
    refreshProducts();
    setState(() {});
  }

  final _formKey = GlobalKey<FormState>();
  final _formAmountKey = GlobalKey<FormState>();

  Future refreshProducts() async {
    productModels = await DatabaseManager.instance
        .readAllProductModelsInProduct(widget.product.prodId!);
    productLots = await DatabaseManager.instance.readAllProductLots();

    setState(() {});
  }

  _calculateTotal(int oldAllTotal) {
    var oldAllTotal = 0;

    for (var controller in amountControllers) {
      for (var item in selectedItems) {
        if (controller.text != null && controller.text != '') {
          oldAllTotal += item.cost * double.parse(controller.text).toInt();
        }
        break;
      }
    }

    allTotal = oldAllTotal;
    setState(() {});
    return allTotal;
  }

  _calculateTotalAmount(int allTotalAmount) {
    var oldAllTotalAmount = 0;
    for (var controller in amountControllers) {
      if (controller.text != null && controller.text != '') {
        oldAllTotalAmount += double.parse(controller.text).toInt();
      }
    }
    allTotalAmount = oldAllTotalAmount;
    setState(() {});
    return allTotalAmount;
  }

  _getLotRemainAmount(prodModelId) {
    var remainAmount = 0;
    for (var lot in productLots) {
      if (lot.prodModelId == prodModelId) {
        remainAmount += lot.remainAmount;
      }
    }
    return remainAmount;
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
            onPressed: () {
              selectedItems.clear();
              amountControllers.clear();
              Navigator.of(context).pop();
            },
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
          title: Column(
            children: [
              Text(
                widget.product.prodName,
                style: TextStyle(fontSize: 25),
              )
            ],
          ),
          centerTitle: true,
          actions: [
            // ?
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
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 100,
                ),
                Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          File(widget.product.prodImage!),
                          width: 180,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Column(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      color: Theme.of(context).colorScheme.secondary,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          widget.prodCategory == null
                              ? 'ไม่มีหมวดหมู่สินค้า'
                              : widget.prodCategory!.prodCategName,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    widget.product.prodDescription!,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    "คงเหลือสินค้าทั้งหมด ${NumberFormat("#,###").format(widget.productTotalAmount)} ชิ้น",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ]),

                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField2(
                            validator: (value) {
                              if (value == null) {
                                return 'โปรดเลือกรูปแบบสินค้า';
                              }
                            },
                            onChanged: (value) {
                              selectedValue = value as ProductModel;
                              // if (prodAmountController.text.isNotEmpty) {
                              //   int amount =
                              //       int.parse(prodAmountController.text);
                              //   _calculateTotal(selectedValue, amount);
                              // }

                              setState(() {});
                            },
                            onSaved: (value) {
                              selectedValue = value as ProductModel;

                              setState(() {});
                            },
                            dropdownMaxHeight: 200,
                            itemHeight: 80,
                            buttonDecoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.transparent,
                              ),
                              color: Color.fromRGBO(66, 64, 87, 1.0),
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            isExpanded: true,
                            hint: Text(
                              productModels.isEmpty
                                  ? 'ไม่มีรูปแบบสินค้า'
                                  : 'โปรดเลือกรูปแบบสินค้า',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                            ),
                            iconSize: 30,
                            buttonHeight: 80,
                            buttonPadding:
                                const EdgeInsets.only(left: 20, right: 10),
                            dropdownDecoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.transparent,
                              ),
                              color: const Color.fromRGBO(56, 54, 76, 1.0),
                            ),
                            items: productModels
                                .map((item) => DropdownMenuItem<ProductModel>(
                                      value: item,
                                      child: StatefulBuilder(
                                          builder: (context, menuSetState) {
                                        final _isSelected =
                                            selectedItems.contains(item);
                                        final found = selectedItems
                                            .indexWhere((e) => e == item);

                                        return InkWell(
                                          onTap: () {
                                            if (_isSelected == false) {
                                              selectedItems.add(item);
                                              amountControllers
                                                  .add(TextEditingController());
                                            } else {
                                              selectedItems.remove(item);
                                              amountControllers.removeAt(found);
                                            }

                                            print(
                                                'Controller Length : ${amountControllers.length}');

                                            setState(() {});

                                            menuSetState(() {});
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(3),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Container(
                                                height: 100,
                                                color: Color.fromRGBO(
                                                    66, 64, 87, 1.0),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      _isSelected
                                                          ? Icon(
                                                              Icons
                                                                  .check_box_rounded,
                                                              color: Theme.of(
                                                                      context)
                                                                  .bottomNavigationBarTheme
                                                                  .selectedItemColor,
                                                            )
                                                          : Icon(
                                                              Icons
                                                                  .check_box_outline_blank,
                                                              color: Theme.of(
                                                                      context)
                                                                  .bottomNavigationBarTheme
                                                                  .selectedItemColor,
                                                            ),
                                                      const SizedBox(width: 16),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            '${item.stProperty} ${(item.ndProperty)}',
                                                            style: TextStyle(
                                                                fontSize: 11,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                              'ต้นทุน ฿${NumberFormat("#,###.##").format(item.cost)}',
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize:
                                                                      12)),
                                                          Text(
                                                              'ราคาขาย ฿${NumberFormat("#,###.##").format(item.price)}',
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      12)),
                                                        ],
                                                      ),
                                                      const Spacer(),
                                                      Text('คงเหลือ ',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.white,
                                                          )),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                            color: Theme.of(
                                                                    context)
                                                                .bottomNavigationBarTheme
                                                                .selectedItemColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15)),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5.0),
                                                          child: Text(
                                                              '${NumberFormat("#,###.##").format(_getLotRemainAmount(item.prodModelId))}',
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ))
                                .toList(),
                            value: selectedItems.isEmpty
                                ? null
                                : selectedItems.last,
                            buttonWidth: 200,
                            itemPadding: EdgeInsets.zero,
                            selectedItemBuilder: (context) {
                              return items.map(
                                (item) {
                                  return Row(
                                    children: [
                                      Container(
                                        width: 250,
                                        child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            padding: const EdgeInsets.all(8),
                                            itemCount: selectedItems.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              final indItem =
                                                  selectedItems[index];
                                              // ??????asdsd
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(3),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Container(
                                                    height: 100,
                                                    color: Color.fromRGBO(
                                                        66, 64, 87, 1.0),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .check_box_rounded,
                                                            color: Theme.of(
                                                                    context)
                                                                .bottomNavigationBarTheme
                                                                .selectedItemColor,
                                                          ),
                                                          const SizedBox(
                                                              width: 10),
                                                          Text(
                                                            '${indItem.stProperty} ${(indItem.ndProperty)}',
                                                            style: TextStyle(
                                                                fontSize: 11,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                      ),
                                    ],
                                  );
                                },
                              ).toList();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                // List View กำหนดจำนวน
                selectedItems.isEmpty
                    ? Container()
                    : Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            // color: const Color.fromRGBO(56, 48, 77, 1.0),
                            borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "กำหนดจำนวน",
                              style: TextStyle(fontSize: 20),
                            ),
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  // color: const Color.fromRGBO(56, 48, 77, 1.0),
                                  borderRadius: BorderRadius.circular(15)),
                              height: selectedItems.length > 1
                                  ? selectedItems.length * 90
                                  : 200,
                              child: Form(
                                key: _formAmountKey,
                                child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    padding: const EdgeInsets.all(8),
                                    itemCount: selectedItems.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final indItem = selectedItems[index];
                                      final _isSelected =
                                          selectedItems.contains(indItem);
                                      final found = selectedItems
                                          .indexWhere((e) => e == indItem);

                                      var amount = 0;
                                      amount = double.parse(
                                              amountControllers[index]
                                                      .text
                                                      .isEmpty
                                                  ? '0'
                                                  : amountControllers[index]
                                                      .text)
                                          .toInt();

                                      var subTotal = indItem.cost * amount;

                                      return InkWell(
                                        onTap: () {
                                          if (_isSelected == false) {
                                            selectedItems.add(indItem);
                                            amountControllers
                                                .add(TextEditingController());
                                          } else {
                                            selectedItems.remove(indItem);
                                            amountControllers.removeAt(found);
                                          }

                                          setState(() {});
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(3),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Container(
                                              height: 120,
                                              color: Color.fromRGBO(
                                                  66, 64, 87, 1.0),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(width: 10),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            _isSelected
                                                                ? Icon(
                                                                    Icons
                                                                        .check_box_rounded,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .bottomNavigationBarTheme
                                                                        .selectedItemColor,
                                                                  )
                                                                : Icon(
                                                                    Icons
                                                                        .check_box_outline_blank,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .bottomNavigationBarTheme
                                                                        .selectedItemColor,
                                                                  ),
                                                            Text(
                                                              '${indItem.stProperty} ${(indItem.ndProperty)}',
                                                              style: TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                            'ต้นทุน ฿${NumberFormat("#,###.##").format(indItem.cost)}',
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        12)),
                                                        Text(
                                                            ' ราคาขาย ฿${NumberFormat("#,###.##").format(indItem.price)}',
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12)),
                                                      ],
                                                    ),
                                                    const Spacer(),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                            '(฿${NumberFormat("#,###.##").format(subTotal)})',
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        12)),
                                                        Container(
                                                          child: SizedBox(
                                                            width: 150,
                                                            height: 80,
                                                            child:
                                                                TextFormField(
                                                                    validator:
                                                                        (value) {
                                                                      if (value ==
                                                                              null ||
                                                                          value
                                                                              .isEmpty) {
                                                                        return 'โปรดระบุ';
                                                                      }
                                                                      return null;
                                                                    },
                                                                    keyboardType:
                                                                        TextInputType.numberWithOptions(
                                                                            decimal:
                                                                                true),
                                                                    inputFormatters: <
                                                                        TextInputFormatter>[
                                                                      FilteringTextInputFormatter
                                                                          .digitsOnly,
                                                                      FilteringTextInputFormatter
                                                                          .allow(
                                                                              RegExp(r'^\d+\.?\d*')),
                                                                      LengthLimitingTextInputFormatter(
                                                                          6),
                                                                    ], // Only numbers can be entered
                                                                    onChanged:
                                                                        ((value) {
                                                                      subTotal =
                                                                          indItem.cost *
                                                                              amount;

                                                                      setState(
                                                                          () {});
                                                                    }),
                                                                    controller:
                                                                        amountControllers[
                                                                            index],
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .white),
                                                                    decoration:
                                                                        InputDecoration(
                                                                      filled:
                                                                          true,
                                                                      fillColor:
                                                                          Color.fromARGB(
                                                                              255,
                                                                              46,
                                                                              44,
                                                                              62),
                                                                      border: OutlineInputBorder(
                                                                          borderRadius: BorderRadius.only(
                                                                              topLeft: Radius.circular(20),
                                                                              topRight: Radius.circular(20),
                                                                              bottomLeft: Radius.circular(20),
                                                                              bottomRight: Radius.circular(20)),
                                                                          borderSide: BorderSide.none),
                                                                      hintText:
                                                                          'จำนวน',
                                                                      hintStyle: const TextStyle(
                                                                          color: Colors
                                                                              .grey,
                                                                          fontSize:
                                                                              12),
                                                                    )),
                                                          ),
                                                        ),
                                                      ],
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
                          ],
                        ),
                      ),

                const SizedBox(
                  height: 10,
                ),

                // Container of จำนวนสินค้า
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      // color: const Color.fromRGBO(56, 48, 77, 1.0),
                      borderRadius: BorderRadius.circular(15)),
                  height: 350,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "สรุปรายการ",
                        style: TextStyle(fontSize: 20),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            // color: Color.fromARGB(255, 45, 37, 63),
                            borderRadius: BorderRadius.circular(15)),
                        height: 150,
                        child: selectedItems.isEmpty
                            ? Container(
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background
                                        .withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                    child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.note_alt_outlined,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    Text(
                                      'โปรดเลือกแบบสินค้า',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 13),
                                    ),
                                  ],
                                )),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.vertical,
                                padding: const EdgeInsets.all(8),
                                itemCount: selectedItems.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final indItem = selectedItems[index];
                                  final _isSelected =
                                      selectedItems.contains(indItem);
                                  var amount = 0;
                                  amount = double.parse(
                                          amountControllers[index].text.isEmpty
                                              ? '0'
                                              : amountControllers[index].text)
                                      .toInt();

                                  var totalPrice = indItem.cost * amount;

                                  return Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Container(
                                      height: 60,
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .background
                                              .withOpacity(0.9),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Row(children: [
                                          Text(
                                            '${NumberFormat("#,###.##").format(index + 1)}. ${indItem.stProperty} ${(indItem.ndProperty)}',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                              ' ต้นทุน (฿${NumberFormat("#,###.##").format(indItem.cost)}) x ${NumberFormat("#,###.##").format(amount)}',
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12)),
                                          Spacer(),
                                          Text(
                                              '฿${NumberFormat("#,###.##").format(indItem.cost * amount)}',
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12)),
                                        ]),
                                      ),
                                    ),
                                  );
                                }),
                      ),
                      Container(
                        height: 150,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Text(
                                "รวมทั้งหมด",
                                style: TextStyle(fontSize: 15),
                              ),
                              Text(
                                " (จำนวน ${NumberFormat("#,###,###.##").format(_calculateTotalAmount(allTotalAmount))} ชิ้น)",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 15),
                              ),
                              Spacer(),
                              Text(
                                "฿${NumberFormat("#,###,###.##").format(_calculateTotal(allTotal))}",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Wrap(
                        spacing: 20,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.redAccent),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "ยกเลิก",
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_formAmountKey.currentState!.validate()) {
                                _formAmountKey.currentState!.save();

                                for (var i = 0; i < selectedItems.length; i++) {
                                  final puritem = PurchasingItemsModel(
                                    amount: double.parse(amountControllers[i]
                                            .text
                                            .replaceAll(RegExp('[^0-9-]'), ''))
                                        .toInt(),
                                    prodId: widget.product.prodId!,
                                    prodModelId: selectedItems[i].prodModelId!,
                                    total:
                                        int.parse(amountControllers[i].text) *
                                            selectedItems[i].cost,
                                  );
                                  widget.update(puritem);
                                }
                                // Display Summary Total Amount
                                var oldTotalAmount = 0;
                                for (var controller in amountControllers) {
                                  oldTotalAmount += int.parse(controller.text);
                                }

                                allTotalAmount = oldTotalAmount;

                                // Success
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  backgroundColor:
                                      Theme.of(context).backgroundColor,
                                  behavior: SnackBarBehavior.floating,
                                  content: Row(
                                    children: [
                                      Icon(
                                        Icons.shopping_cart_outlined,
                                        color: Colors.white,
                                      ),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(30),
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          child: Image.file(
                                            File(widget.product.prodImage!),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .backgroundColor,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Text(
                                            "+${allTotalAmount}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      Text(" ${widget.product.prodName} "),
                                    ],
                                  ),
                                  duration: Duration(seconds: 5),
                                ));

                                selectedItems.clear();
                                amountControllers.clear();
                                Navigator.pop(context);
                              } else {}
                            },
                            child: Text(
                              "บันทึก",
                              style: TextStyle(fontSize: 17),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            )),
      ),
    );
  }
}
