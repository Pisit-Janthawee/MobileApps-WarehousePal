// Others
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:provider/provider.dart';

import 'package:warehouse_mnmt/Page/Model/ProductCategory.dart';
import 'package:warehouse_mnmt/Page/Model/ProductLot.dart';
import 'package:warehouse_mnmt/Page/Model/ProductModel.dart';
import 'package:warehouse_mnmt/Page/Model/Purchasing_item.dart';
import 'package:warehouse_mnmt/Page/Provider/theme_provider.dart';
import 'package:warehouse_mnmt/Page/Shop/Buying/nav_showProduct.dart';

import '../../../db/database.dart';
import '../../Model/Product.dart';
import '../../Model/ProductModel_ndProperty.dart';
import '../../Model/ProductModel_stProperty.dart';
import '../../Model/Selling_item.dart';

class SellingNavShowProd extends StatefulWidget {
  final Product product;
  final ProductCategory? prodCategory;
  final int? productTotalAmount;
  final ValueChanged<SellingItemModel> update;

  SellingNavShowProd({
    Key? key,
    required this.update,
    required this.product,
    this.prodCategory,
    this.productTotalAmount,
  }) : super(key: key);

  @override
  State<SellingNavShowProd> createState() => _SellingNavShowProdState();
}

class _SellingNavShowProdState extends State<SellingNavShowProd> {
  List<ProductModel> productModels = [];
  List<ProductLot> productLots = [];
  List<ProductModel_stProperty> stPropertys = [];
  List<ProductModel_ndProperty> ndPropertys = [];

  List<TextEditingController> amountControllers = [];
  List<ProductModel> ddModelSelectedItems = [];
  List<ProductLot> ddLotSelectedItems = [];
  ProductModel? modelSelectedValue;
  ProductLot? lotSelectedValue;
  var totalAmount = 0;
  List<DropdownMenuItem<ProductLot>> _dropDownProductLotItems(model) {
    List<ProductLot> lotModelItems = [];
    for (var lot in productLots) {
      if (lot.prodModelId == model.prodModelId) {
        lotModelItems.add(lot);
      }
    }

    return lotModelItems
        .map((item) => DropdownMenuItem<ProductLot>(
              value: item,
              child: StatefulBuilder(builder: (context, menuSetState) {
                final isSelectedLot = ddLotSelectedItems.contains(item);
                return InkWell(
                  onTap: () {
                    if (isSelectedLot == false) {
                      ddLotSelectedItems.add(item);
                    } else {
                      ddLotSelectedItems.remove(item);
                    }

                    setState(() {});

                    menuSetState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                          height: 100,
                          color: Color.fromRGBO(66, 64, 87, 1.0),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  isSelectedLot
                                      ? Icon(
                                          Icons.check_box_rounded,
                                          color:
                                              Theme.of(context).backgroundColor,
                                        )
                                      : Icon(
                                          Icons.check_box_outline_blank,
                                          color:
                                              Theme.of(context).backgroundColor,
                                        ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'ล็อตที่ ${NumberFormat("#,###.##").format(item.prodLotId)}',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12)),
                                      Text(
                                          '(วันที่ ${df.format(item.orderedTime!)})',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .backgroundColor,
                                              fontSize: 12)),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                      'คงเหลือ ${NumberFormat("#,###.##").format(item.remainAmount)}',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12)),
                                ]),
                          )),
                    ),
                  ),
                );
              }),
            ))
        .toList();
  }

  final df = new DateFormat('dd-MM-yyyy');
  final prodRequestController = TextEditingController();
  // Text Field

  void initState() {
    super.initState();
    refreshProducts();
    for (var controller in amountControllers) {
      controller.addListener(() => setState(() {}));
    }
    _pageController = PageController(viewportFraction: 0.8);

    setState(
      () {},
    );
  }

  final _formKeyProdModel = GlobalKey<FormState>();
  final _formKeyAmount = GlobalKey<FormState>();

  Future refreshProducts() async {
    productModels = await DatabaseManager.instance
        .readAllProductModelsInProduct(widget.product.prodId!);
    productLots = await DatabaseManager.instance.readAllProductLots();
    setState(() {});
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

  //sellling Page
  int activePage = 1;
  late PageController _pageController;

  List<Widget> sellingIndicators(sellingItemsLength, currentIndex) {
    return List<Widget>.generate(sellingItemsLength, (index) {
      return Container(
        margin: EdgeInsets.all(3),
        width: 10,
        height: 10,
        decoration: BoxDecoration(
            color: currentIndex == index
                ? Theme.of(context).backgroundColor
                : Colors.black26,
            shape: BoxShape.circle),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
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
            height: ddModelSelectedItems.isNotEmpty
                ? null
                : (MediaQuery.of(context).size.height),
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
                const SizedBox(
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
                SizedBox(
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
                          widget.prodCategory?.prodCategName == null
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
                // Drop Down แบบสินค้า
                Container(
                  width: 370,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Text(
                            "ขั้นตอนที่ 1 : ",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "เลือกรูปแบบสินค้า",
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      Form(
                        key: _formKeyProdModel,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DropdownButtonHideUnderline(
                              child: DropdownButtonFormField2(
                                validator: (value) {
                                  if (value == null) {
                                    return 'โปรดเลือกรูปแบบสินค้า';
                                  }
                                },
                                onChanged: (value) {
                                  modelSelectedValue = value as ProductModel;

                                  setState(() {});
                                },
                                onSaved: (value) {
                                  modelSelectedValue = value as ProductModel;

                                  setState(() {});
                                },
                                dropdownMaxHeight: 360,
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
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
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
                                    .map((item) =>
                                        DropdownMenuItem<ProductModel>(
                                          value: item,
                                          child: StatefulBuilder(
                                              builder: (context, menuSetState) {
                                            final _isSelected =
                                                ddModelSelectedItems
                                                    .contains(item);
                                            final found = ddModelSelectedItems
                                                .indexWhere((e) => e == item);
                                            var remainAmt = _getLotRemainAmount(
                                                item.prodModelId);
                                            var getLastestLot;

                                            for (var lot in productLots) {
                                              if (lot.prodModelId ==
                                                  item.prodModelId) {
                                                if (lot.remainAmount != 0) {
                                                  getLastestLot = lot;
                                                  break;
                                                }
                                              }
                                            }

                                            return InkWell(
                                              onTap: () {
                                                if (_isSelected == false &&
                                                    remainAmt != 0) {
                                                  ddModelSelectedItems
                                                      .add(item);
                                                  amountControllers.add(
                                                      TextEditingController());
                                                  ddLotSelectedItems
                                                      .add(getLastestLot);
                                                } else if (remainAmt == 0) {
                                                  //Alert 0 Stock
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .backgroundColor,
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      content: Text(
                                                          "สินค้า ${item.stProperty} ${item.ndProperty} สินค้าหมด!"),
                                                      duration:
                                                          Duration(seconds: 2),
                                                    ),
                                                  );
                                                } else {
                                                  ddModelSelectedItems
                                                      .remove(item);
                                                  ddLotSelectedItems
                                                      .remove(getLastestLot);
                                                  amountControllers
                                                      .remove(found);
                                                }
                                                setState(() {});
                                                menuSetState(() {});
                                              },
                                              child: Padding(
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
                                                                .start,
                                                        children: [
                                                          remainAmt == 0
                                                              ? Icon(
                                                                  Icons
                                                                      .close_sharp,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .backgroundColor,
                                                                )
                                                              : _isSelected
                                                                  ? Icon(
                                                                      Icons
                                                                          .check_box_rounded,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .bottomNavigationBarTheme
                                                                          .selectedItemColor)
                                                                  : Icon(
                                                                      Icons
                                                                          .check_box_outline_blank,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .bottomNavigationBarTheme
                                                                          .selectedItemColor),
                                                          const SizedBox(
                                                              width: 16),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                '${item.stProperty} ${(item.ndProperty)}',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        11,
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
                                                                  ' ราคาขาย ฿${NumberFormat("#,###.##").format(item.price)}',
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          12)),
                                                            ],
                                                          ),
                                                          const Spacer(),
                                                          Text(
                                                              remainAmt == 0
                                                                  ? 'สินค้าหมด '
                                                                  : 'คงเหลือ ',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .white,
                                                              )),
                                                          remainAmt == 0
                                                              ? Container()
                                                              : Container(
                                                                  decoration: BoxDecoration(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .bottomNavigationBarTheme
                                                                          .selectedItemColor,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              15)),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            5.0),
                                                                    child: Text(
                                                                        '${NumberFormat("#,###.##").format(remainAmt)}',
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold)),
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
                                value: ddModelSelectedItems.isEmpty
                                    ? null
                                    : ddModelSelectedItems.last,
                                buttonWidth: 200,
                                itemPadding: EdgeInsets.zero,
                                selectedItemBuilder: (context) {
                                  return items.map(
                                    (item) {
                                      return Row(
                                        children: [
                                          Container(
                                            height: 90,
                                            width: 250,
                                            child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                padding:
                                                    const EdgeInsets.all(8),
                                                itemCount: selectedItems.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  final indItem =
                                                      ddModelSelectedItems[
                                                          index];
                                                  // ??????asdsd
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(3),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: Container(
                                                        height: 100,
                                                        color: Color.fromRGBO(
                                                            66, 64, 87, 1.0),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10.0),
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
                                                                    .backgroundColor,
                                                              ),
                                                              const SizedBox(
                                                                  width: 10),
                                                              Text(
                                                                '${indItem.stProperty} ${(indItem.ndProperty)}',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        11,
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Container of ListView ProuductLots
                Container(
                  height: 90,
                  width: 370,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(8),
                      itemCount: ddModelSelectedItems.length,
                      itemBuilder: (BuildContext context, int index) {
                        final indItem = ddModelSelectedItems[index];
                        final found = ddModelSelectedItems
                            .indexWhere((e) => e == indItem);
                        var getLastestLot;
                        var _isSelected =
                            ddModelSelectedItems.contains(indItem);
                        for (var lot in productLots) {
                          if (lot.prodModelId == indItem.prodModelId) {
                            if (lot.remainAmount != 0) {
                              getLastestLot = lot;
                              break;
                            }
                          }
                        }

                        return InkWell(
                          onTap: () {
                            if (_isSelected == false) {
                              ddModelSelectedItems.add(indItem);
                              ddLotSelectedItems.add(getLastestLot);
                              amountControllers.add(TextEditingController());
                            } else {
                              ddModelSelectedItems.remove(indItem);
                              ddLotSelectedItems.remove(getLastestLot);
                              amountControllers.remove(found);
                            }
                            setState(() {});
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .bottomNavigationBarTheme
                                        .selectedItemColor),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_outlined,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        '${indItem.stProperty} ${(indItem.ndProperty)}',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
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
                ),

                // Container of จำนวนสินค้า
                if (ddModelSelectedItems.isNotEmpty)
                  Container(
                    width: 370,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "ขั้นตอนที่ 2 : ",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "กำหนดจำนวนสินค้า",
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),

                        // Container of ListView LotSelectedItems
                        Form(
                          key: _formKeyAmount,
                          child: Container(
                            height: 300,
                            width: 450,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: PageView.builder(
                                scrollDirection: Axis.horizontal,
                                // padding: EdgeInsets.zero,
                                pageSnapping: true,
                                controller: _pageController,
                                onPageChanged: (page) {
                                  setState(() {
                                    activePage = page;
                                  });
                                },
                                itemCount: ddModelSelectedItems.length,
                                itemBuilder: (context, index) {
                                  final selectedModel =
                                      ddModelSelectedItems[index];
                                  final _isSelected = ddModelSelectedItems
                                      .contains(selectedModel);

                                  final found = selectedItems
                                      .indexWhere((e) => e == selectedModel);
                                  var getLastestLot;

                                  for (var lot in productLots) {
                                    if (lot.prodModelId ==
                                        selectedModel.prodModelId) {
                                      if (lot.remainAmount != 0) {
                                        getLastestLot = lot;
                                        break;
                                      }
                                    }
                                  }
                                  var amount = 0;
                                  if (amountControllers[index].text != '-' &&
                                      amountControllers[index]
                                          .text
                                          .isNotEmpty) {
                                    amount = int.parse(
                                        amountControllers[index].text.isEmpty
                                            ? '0'
                                            : amountControllers[index].text);
                                  }

                                  var subTotal = selectedModel.price * amount;

                                  return TextButton(
                                    onPressed: () {},
                                    child: Container(
                                      width: 250,
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
                                              Theme.of(context).backgroundColor,
                                              Theme.of(context)
                                                  .colorScheme
                                                  .onSecondary,
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          )),
                                      child: Column(
                                          // mainAxisAlignment:
                                          //     MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                    onPressed: () {
                                                      if (_isSelected ==
                                                          false) {
                                                        ddModelSelectedItems
                                                            .add(selectedModel);
                                                        amountControllers.add(
                                                            TextEditingController());
                                                        ddLotSelectedItems
                                                            .add(getLastestLot);
                                                      } else {
                                                        ddModelSelectedItems
                                                            .remove(
                                                                selectedModel);
                                                        ddLotSelectedItems
                                                            .remove(
                                                                getLastestLot);
                                                        amountControllers
                                                            .remove(found);
                                                      }
                                                      setState(() {});
                                                    },
                                                    icon: Icon(
                                                      Icons.close_rounded,
                                                      color: Colors.grey,
                                                    )),
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Row(
                                                children: [
                                                  Center(
                                                    child: Stack(
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(22),
                                                          child: Image.file(
                                                            File(widget.product
                                                                .prodImage!),
                                                            width: 80,
                                                            height: 80,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                        Positioned(
                                                          bottom: 0.0,
                                                          right: 0.0,
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              boxShadow: [
                                                                BoxShadow(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.7),
                                                                    spreadRadius:
                                                                        0,
                                                                    blurRadius:
                                                                        5,
                                                                    offset:
                                                                        Offset(
                                                                            0,
                                                                            4))
                                                              ],
                                                              color: Colors
                                                                  .redAccent,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30),
                                                            ),
                                                            child: Text(
                                                              '${NumberFormat("#,###.##").format(amount)} ชิ้น',
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          top: 0.0,
                                                          right: 0.0,
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              boxShadow: [
                                                                BoxShadow(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.7),
                                                                    spreadRadius:
                                                                        0,
                                                                    blurRadius:
                                                                        5,
                                                                    offset:
                                                                        Offset(
                                                                            0,
                                                                            4))
                                                              ],
                                                              color: Theme.of(
                                                                      context)
                                                                  .backgroundColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30),
                                                            ),
                                                            child: Text(
                                                              '฿${NumberFormat("#,###.##").format(subTotal)}',
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: 150,
                                                            child: Text(
                                                              '${selectedModel.stProperty} ${selectedModel.ndProperty} ',
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Text(
                                                        'ราคาขาย ฿${NumberFormat("#,###.##").format(selectedModel.price)}',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(3.0),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          getLastestLot == null
                                                              ? Container()
                                                              : Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                        'ล็อตที่ (วันที่ ${df.format(getLastestLot.orderedTime!)})',
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 12)),
                                                                    Text(
                                                                        '(คงเหลือ ${NumberFormat("#,###.##").format(getLastestLot.remainAmount)})',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 12)),
                                                                  ],
                                                                ),
                                                        ],
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        height: 90,
                                                        child: TextFormField(
                                                            inputFormatters: [
                                                              FilteringTextInputFormatter
                                                                  .digitsOnly
                                                            ],
                                                            validator: (value) {
                                                              if (value ==
                                                                      null ||
                                                                  value
                                                                      .isEmpty) {
                                                                return 'โปรดระบุจำนวน';
                                                              }
                                                              return null;
                                                            },
                                                            onChanged:
                                                                ((value) {
                                                              if (amountControllers[
                                                                          index]
                                                                      .text
                                                                      .isNotEmpty &&
                                                                  amountControllers[
                                                                              index]
                                                                          .text !=
                                                                      null &&
                                                                  amountControllers[
                                                                              index]
                                                                          .text !=
                                                                      '' &&
                                                                  amountControllers[
                                                                              index]
                                                                          .text !=
                                                                      '-') {
                                                                if (double.parse(amountControllers[index].text.replaceAll(
                                                                            RegExp(
                                                                                '[^0-9]'),
                                                                            ''))
                                                                        .toInt() >
                                                                    getLastestLot
                                                                        .remainAmount) {
                                                                  amountControllers[
                                                                          index]
                                                                      .clear();
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                      backgroundColor:
                                                                          Theme.of(context)
                                                                              .backgroundColor,
                                                                      behavior:
                                                                          SnackBarBehavior
                                                                              .floating,
                                                                      content: Text(
                                                                          "สินค้าคเหลือไม่เพียพอ"),
                                                                      duration: Duration(
                                                                          seconds:
                                                                              2),
                                                                    ),
                                                                  );
                                                                }
                                                              } else {
                                                                subTotal =
                                                                    selectedModel
                                                                            .cost *
                                                                        amount;
                                                              }

                                                              setState(() {});
                                                            }),
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            controller:
                                                                amountControllers[
                                                                    index],
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                            decoration:
                                                                InputDecoration(
                                                              filled: true,
                                                              fillColor: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      32,
                                                                      31,
                                                                      45),
                                                              border: const OutlineInputBorder(
                                                                  borderRadius: BorderRadius.only(
                                                                      topLeft:
                                                                          Radius.circular(
                                                                              15),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              15),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              15),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              15)),
                                                                  borderSide:
                                                                      BorderSide
                                                                          .none),
                                                              hintText: 'จำนวน',
                                                              hintStyle:
                                                                  const TextStyle(
                                                                      color:
                                                                          Colors
                                                                              .grey,
                                                                      fontSize:
                                                                          14),
                                                              suffixIcon: amountControllers[
                                                                          index]
                                                                      .text
                                                                      .isEmpty
                                                                  ? Container(
                                                                      width: 0,
                                                                    )
                                                                  : IconButton(
                                                                      onPressed:
                                                                          () {
                                                                        amountControllers[index]
                                                                            .clear();
                                                                        setState(
                                                                            () {});
                                                                      },
                                                                      icon:
                                                                          const Icon(
                                                                        Icons
                                                                            .close_sharp,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                            )),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          ]),
                                    ),
                                  );
                                }),
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: sellingIndicators(
                        ddModelSelectedItems.length, activePage)),
                ddModelSelectedItems.isEmpty
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.all(15.0),
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
                                  onPressed: () async {
                                    if (_formKeyAmount.currentState!
                                        .validate()) {
                                      print('All Amount Controller is filled');
                                      // ผลรวม จำนวน[สินค้า]ทั้งหมด
                                      var oldTotalAmount = 0;

                                      for (var i = 0;
                                          i < ddModelSelectedItems.length;
                                          i++) {
                                        oldTotalAmount += double.parse(
                                                amountControllers[i].text)
                                            .toInt();
                                        final createdSellingItem = SellingItemModel(
                                            prodId: widget.product.prodId,
                                            prodModelId: ddModelSelectedItems[i]
                                                .prodModelId,
                                            prodLotId: ddLotSelectedItems[i]
                                                .prodLotId!,
                                            amount: double.parse(
                                                    amountControllers[i]
                                                        .text
                                                        .replaceAll(
                                                            RegExp('[^0-9]'),
                                                            ''))
                                                .toInt(),
                                            total: double.parse(
                                                        amountControllers[i]
                                                            .text
                                                            .replaceAll(
                                                                RegExp('[^0-9]'),
                                                                ''))
                                                    .toInt() *
                                                ddModelSelectedItems[i].price);
                                        widget.update(createdSellingItem);
                                        final updateAmountSelectedProductLot =
                                            ddLotSelectedItems[i].copy(
                                                remainAmount: ddLotSelectedItems[
                                                            i]
                                                        .remainAmount -
                                                    double.parse(
                                                            amountControllers[i]
                                                                .text)
                                                        .toInt());
                                        await DatabaseManager.instance
                                            .updateProductLot(
                                                updateAmountSelectedProductLot);
                                      }
                                      totalAmount = oldTotalAmount;
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
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              child: Container(
                                                width: 20,
                                                height: 20,
                                                child: Image.file(
                                                  File(widget
                                                      .product.prodImage!),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .backgroundColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(3.0),
                                                child: Text(
                                                  "+${totalAmount}",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                            Text(
                                                " ${widget.product.prodName} "),
                                          ],
                                        ),
                                        duration: Duration(seconds: 5),
                                      ));
                                      Navigator.pop(context);
                                    } else {
                                      print('Some Amount Controller is null');
                                    }
                                  },
                                  child: Text(
                                    "ยืนยัน",
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
