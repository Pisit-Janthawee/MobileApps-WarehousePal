import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:warehouse_mnmt/Page/Model/ProductLot.dart';
import 'package:warehouse_mnmt/Page/Model/ProductModel.dart';
import 'package:warehouse_mnmt/Page/Provider/theme_provider.dart';
import 'package:warehouse_mnmt/Page/Shop/Product/nav_add.dart';
import 'package:warehouse_mnmt/Page/Shop/Selling/nav_add.dart';
import 'package:warehouse_mnmt/db/database.dart';

import '../Component/TextField/CustomTextField.dart';
import '../Component/SearchBox.dart';
import '../Component/SearchBoxController.dart';
import '../Model/Product.dart';
import '../Model/ProductCategory.dart';
import '../Model/Shop.dart';
import 'Product/nav.edit.dart';

class ProductPage extends StatefulWidget {
  final Shop shop;
  const ProductPage({required this.shop, Key? key}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  TextEditingController searchProductController = TextEditingController();
  @override
  void initState() {
    super.initState();
    refreshPage();
    refreshProductCategorys();

    setState(() {});
    searchProductController.addListener(() => setState(() {}));
  }

  List<Product> products = [];
  List<ProductCategory> productCategorys = [];
  List<ProductModel> productModels = [];
  List<ProductLot> productLots = [];

  bool _validate = false;
  Future refreshPage() async {
    productModels = await DatabaseManager.instance.readAllProductModels();
    productCategorys = await DatabaseManager.instance
        .readAllProductCategorys(widget.shop.shopid!);
    products =
        await DatabaseManager.instance.readAllProducts(widget.shop.shopid!);
    productLots = await DatabaseManager.instance.readAllProductLots();
    setState(() {});
  }

  Future refreshProductCategorys() async {
    productCategorys = await DatabaseManager.instance
        .readAllProductCategorys(widget.shop.shopid!);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(190),
        child: AppBar(
          backgroundColor: themeProvider.isDark
              ? Colors.transparent
              : Theme.of(context).appBarTheme.backgroundColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Text(
                "สินค้า",
                textAlign: TextAlign.start,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: Text(
                      '${NumberFormat("#,###.##").format(products.length)}',
                      style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
          flexibleSpace: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Baseline(
                baseline: 110,
                baselineType: TextBaseline.alphabetic,
                child: Column(
                  children: [
                    TextFormField(
                        keyboardType: TextInputType.text,
                        onChanged: (text) async {
                          products = await DatabaseManager.instance
                              .readAllProductsByName(widget.shop.shopid!,
                                  searchProductController.text);
                          setState(() {});
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(100),
                        ],
                        controller: searchProductController,
                        style: TextStyle(
                            color: themeProvider.isDark
                                ? Colors.white
                                : Colors.black,
                            fontSize: 15),
                        cursorColor: primary_color,
                        decoration: InputDecoration(
                          // labelText: title,
                          filled: true,
                          fillColor: themeProvider.isDark
                              ? Theme.of(context).colorScheme.background
                              : Theme.of(context).colorScheme.onPrimary,
                          border: const OutlineInputBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20)),
                              borderSide: BorderSide.none),

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          ),
                          hintText: 'ชื่อสินค้า',
                          hintStyle:
                              const TextStyle(color: Colors.grey, fontSize: 14),
                          prefixIcon: Icon(Icons.search,
                              color: themeProvider.isDark
                                  ? Colors.white
                                  : Color.fromRGBO(14, 14, 14, 1.0)),
                          suffixIcon: searchProductController.text.isEmpty
                              ? Container(
                                  width: 0,
                                )
                              : IconButton(
                                  onPressed: () {
                                    searchProductController.clear();
                                    refreshPage();
                                  },
                                  icon: Icon(
                                    Icons.close_sharp,
                                    color: themeProvider.isDark
                                        ? Colors.white
                                        : Color.fromRGBO(14, 14, 14, 1.0),
                                  ),
                                ),
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    productCategorys.isEmpty
                        ? Container(
                            width: 0,
                          )
                        : Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .appBarTheme
                                          .backgroundColor,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10),
                                                child: Text(
                                                  'หมวดหมู่สินค้า',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                child: CircleAvatar(
                                                  radius: 10,
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                  child: Text(
                                                      '${NumberFormat("#,###.##").format(productCategorys.length)}',
                                                      style: const TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: (MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.5),
                                          color: themeProvider.isDark
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .background
                                              : Color.fromRGBO(10, 10, 10, 1.0),
                                          child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              padding: EdgeInsets.zero,
                                              itemCount:
                                                  productCategorys.length,
                                              itemBuilder: (context, index) {
                                                final prodCateg =
                                                    productCategorys[index];
                                                return TextButton(
                                                  onPressed: () async {
                                                    products = await DatabaseManager
                                                        .instance
                                                        .readAllProductsByCategory(
                                                            widget.shop.shopid!,
                                                            prodCateg
                                                                .prodCategId!);
                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5.0),
                                                      child: Center(
                                                        child: Text(
                                                          prodCateg
                                                              .prodCategName,
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                  ],
                )),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                await Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => ProductNavAdd(
                              shop: widget.shop,
                            )));
                refreshPage();
              },
              icon: const Icon(
                Icons.add,
                size: 30,
              ),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: (MediaQuery.of(context).size.height * 1.05),
          decoration: BoxDecoration(
              gradient: themeProvider.isDark == true
                  ? scafBG_dark_Color
                  : LinearGradient(
                      colors: [
                        Color.fromARGB(255, 219, 219, 219),
                        Color.fromARGB(255, 219, 219, 219),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )),
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 200,
                ),
                Container(
                  decoration: BoxDecoration(
                    // color: Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      products.isEmpty
                          ? GestureDetector(
                              onVerticalDragStart: (detail) {
                                refreshPage();
                              },
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.65,
                                child: Center(
                                    child: Text(
                                  "(ไม่มีสินค้า${searchProductController.text.isEmpty ? '' : ' ' + searchProductController.text})",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 25),
                                )),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.62,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: RefreshIndicator(
                                  onRefresh: refreshPage,
                                  child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount: products.length,
                                      itemBuilder: (context, index) {
                                        final product = products[index];
                                        var category;
                                        for (var prCategory
                                            in productCategorys) {
                                          if (product.prodCategId ==
                                              prCategory.prodCategId) {
                                            category = prCategory;
                                          }
                                        }

                                        var _amountOfProd = 0;

                                        var cost = [];
                                        var price = [];

                                        for (var prModel in productModels) {
                                          if (prModel.prodId ==
                                              product.prodId) {
                                            cost.add(prModel.cost);
                                            price.add(prModel.price);

                                            for (var lot in productLots) {
                                              if (prModel.prodModelId ==
                                                  lot.prodModelId) {
                                                _amountOfProd +=
                                                    lot.remainAmount!;
                                              }
                                            }
                                          }
                                        }
                                        var amountOfProd = _amountOfProd;

                                        var _minCost = 0;
                                        var _maxCost = 0;
                                        var _minPrice = 0;
                                        var _maxPrice = 0;

                                        if (cost.isNotEmpty &&
                                            price.isNotEmpty) {
                                          var minCost = cost.reduce(
                                              (curr, next) =>
                                                  curr < next ? curr : next);
                                          var maxCost = cost.reduce(
                                              (curr, next) =>
                                                  curr > next ? curr : next);
                                          var minprice = price.reduce(
                                              (curr, next) =>
                                                  curr < next ? curr : next);
                                          var maxprice = price.reduce(
                                              (curr, next) =>
                                                  curr > next ? curr : next);
                                          _minCost = minCost;
                                          _maxCost = maxCost;
                                          _minPrice = minprice;
                                          _maxPrice = maxprice;
                                        }

                                        return Dismissible(
                                          key: Key(products[index].prodName),
                                          onDismissed: (direction) async {
                                            await DatabaseManager.instance
                                                .deleteProduct(product.prodId!);
                                            refreshPage();
                                            setState(() {});
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              backgroundColor: Colors.redAccent,
                                              content: Text(
                                                  "ลบสินค้า ${product.prodName}"),
                                              duration: Duration(seconds: 2),
                                            ));
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
                                                    BorderRadius.circular(10)),
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
                                          resizeDuration: Duration(seconds: 1),
                                          child: TextButton(
                                            onPressed: () async {
                                              await Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProductNavEdit(
                                                            product: product,
                                                            prodCategory:
                                                                category,
                                                            shop: widget.shop,
                                                          )));
                                              refreshPage();
                                              setState(() {});
                                            },
                                            child: Container(
                                              // decoration: BoxDecoration(
                                              //   boxShadow: [
                                              //     BoxShadow(
                                              //         color: Colors.black,
                                              //         spreadRadius: 1,
                                              //         blurRadius: 5,
                                              //         offset: Offset(0, 4))
                                              //   ],
                                              // ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: themeProvider.isDark
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                        : Color.fromRGBO(
                                                            10, 10, 10, 1.0),
                                                  ),
                                                  height: 90,
                                                  width: 400,
                                                  child: Row(
                                                    children: <Widget>[
                                                      Container(
                                                        width: 90,
                                                        height: 90,
                                                        child: Image.file(
                                                          File(product
                                                              .prodImage!),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
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
                                                              product.prodName,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .secondary,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10)),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        2.0),
                                                                child: Text(
                                                                  category ==
                                                                          null
                                                                      ? "ไม่มีหมวดหมู่สินค้า"
                                                                      : category
                                                                          .prodCategName,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                                'ต้นทุน ฿${NumberFormat("#,###.##").format(_minCost)} - ฿${NumberFormat("#,###.##").format(_maxCost)}',
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        12)),
                                                            Text(
                                                                'ราคาขาย ฿${NumberFormat("#,###.##").format(_minPrice)} - ฿${NumberFormat("#,###.##").format(_maxPrice)}',
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12)),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .secondary,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5.0),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                  '${NumberFormat("#,###.##").format(amountOfProd)}',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
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
                            )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
