import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:warehouse_mnmt/Page/Model/Product.dart';
import 'package:warehouse_mnmt/Page/Model/ProductCategory.dart';
import 'package:warehouse_mnmt/Page/Model/ProductLot.dart';
import 'package:warehouse_mnmt/Page/Model/ProductModel.dart';
import 'package:warehouse_mnmt/Page/Model/ProductModel_stProperty.dart';
import 'package:warehouse_mnmt/Page/Model/ProductModel_ndProperty.dart';
import 'package:warehouse_mnmt/Page/Model/Shop.dart';
import 'package:warehouse_mnmt/Page/Shop/Buying/nav_showProduct.dart';

import '../../../db/database.dart';
import '../../Component/ImagePickerController.dart';
import '../../Component/ImagePickerWidget.dart';
import '../../Component/TextField/CustomTextField.dart';
import '../../Model/ProductModel_ndProperty.dart';
import '../../Provider/theme_provider.dart';

class ProductNavAdd extends StatefulWidget {
  final Shop shop;
  const ProductNavAdd({required this.shop, Key? key}) : super(key: key);

  @override
  State<ProductNavAdd> createState() => _ProductNavAddState();
}

class _ProductNavAddState extends State<ProductNavAdd> {
  ImagePickerController productImgController = ImagePickerController();
  TextEditingController productNameController = TextEditingController();
  TextEditingController productDescriptionController = TextEditingController();
  TextEditingController productCategoryNameController = TextEditingController();
  TextEditingController productModel_stPropNameController =
      TextEditingController();
  TextEditingController productModel_ndPropNameController =
      TextEditingController();
  TextEditingController productModel_stPropListNameController =
      TextEditingController();
  TextEditingController productModel_ndPropListNameController =
      TextEditingController();
  List<TextEditingController> editCostControllers = [];
  List<TextEditingController> editPriceControllers = [];
  List<TextEditingController> weightControllers = [];

  TextEditingController editAllCostController = TextEditingController();
  TextEditingController editAllPriceController = TextEditingController();
  TextEditingController pController = TextEditingController();
  TextEditingController cController = TextEditingController();
  TextEditingController wController = TextEditingController();

  @override
  void initState() {
    super.initState();
    refreshProductCategorys();
    setState(() {});
    productNameController.addListener(() => setState(() {}));
    productCategoryNameController.addListener(() => setState(() {}));
    productDescriptionController.addListener(() => setState(() {}));
    productModel_stPropNameController.addListener(() => setState(() {}));
    productModel_ndPropNameController.addListener(() => setState(() {}));
    productModel_stPropListNameController.addListener(() => setState(() {}));
    productModel_ndPropListNameController.addListener(() => setState(() {}));
    editAllCostController.addListener(() => setState(() {}));
    editAllPriceController.addListener(() => setState(() {}));
    pController.addListener(() => setState(() {}));
    cController.addListener(() => setState(() {}));
    wController.addListener(() => setState(() {}));
  }

  var productCategory = ProductCategory(prodCategName: 'เลือกหมวดหมู่สินค้า');
  bool _validate = false;
  bool isDialogChooseFst = false;
  bool isDelete_ndProp = false;
  bool isFoundNullCost = false;
  bool isFoundNullPrice = false;
  String stPropName = 'สี';
  String ndPropName = 'ขนาด';
  List<ProductCategory> productCategorys = [];
  List<ProductModel> productModels = [];
  List<ProductModel_stProperty> stPropsList = [];
  List<ProductModel_ndProperty> ndPropsList = [];
  List<ProductLot> productLots = [];
  List stPropertySelecteds = [];
  List ndPropertySelecteds = [];

  showSnackBarIfEmpty(titleHeader) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      content: Text("${titleHeader} ว่าง"),
      duration: Duration(seconds: 3),
    ));
  }

  _invalidationPriceController() {
    var found = 0;
    for (var i = 0; i < productModels.length; i++) {
      var c = editCostControllers[i];
      var p = editPriceControllers[i];
      if (c.text.isEmpty || p.text.isEmpty) {
        if (c.text.isEmpty) {
          print('[Cost] Found Null in (${found})');
          isFoundNullCost = true;
          return found;
        } else {
          print('[Price] Found Null in (${found})');
          isFoundNullPrice = true;
          return found;
        }
      } else if (int.parse(c.text.replaceAll(RegExp('[^0-9]'), '')) >
          int.parse(p.text.replaceAll(RegExp('[^0-9]'), ''))) {
        isFoundNullCost = true;
        isFoundNullPrice = true;
        setState(() {});
        var whereModel = productModels[i];
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          content: Text(
              "(${i}) ${whereModel.stProperty} ${whereModel.ndProperty} ราคาขายน้อยกว่าต้นทุน (${found})"),
          duration: Duration(seconds: 3),
        ));
      } else {
        found++;
        isFoundNullCost = false;
        isFoundNullPrice = false;
        setState(() {});
      }
    }
  }

  Future _insertProduct(shop) async {
    if (productImgController.path == null) {
      showSnackBarIfEmpty('รูปสินค้า');
    } else if (productNameController.text.isEmpty) {
      showSnackBarIfEmpty('ชื่อสินค้า');
    } else if (productCategory.prodCategName == 'เลือกหมวดหมู่สินค้า') {
      showSnackBarIfEmpty('หมวดหมู่สินค้า');
    } else if (productNameController.text.isNotEmpty) {
      // Insert Product -> Database
      final product = Product(
          prodName: productNameController.text.trim(),
          prodDescription: productDescriptionController.text.trim(),
          prodImage: productImgController.path,
          prodCategId: productCategory.prodCategId == null
              ? null
              : productCategory.prodCategId,
          shopId: widget.shop.shopid!);
      // Inserted Get Product ID
      final prodInserted =
          await DatabaseManager.instance.createProduct(product);
      productModels.clear();
      var i = 0;
      for (var st in stPropsList) {
        if (ndPropsList.isEmpty) {
          final model = ProductModel(
              prodModelname: '${stPropName},${ndPropName}',
              stProperty: '${st.pmstPropName}',
              ndProperty: '-',
              cost: int.parse(editCostControllers[i].text),
              price: int.parse(editPriceControllers[i].text),
              weight: double.parse(
                  weightControllers[i].text.replaceAll(RegExp('[^0-9]'), '')),
              prodId: prodInserted.prodId);
          productModels.add(model);
          editCostControllers.add(TextEditingController());
          editPriceControllers.add(TextEditingController());

          i++;
        } else {
          for (var nd in ndPropsList) {
            final model = ProductModel(
                prodModelname: '${stPropName},${ndPropName}',
                stProperty: '${st.pmstPropName}',
                ndProperty: '${nd.pmndPropName}',
                cost: int.parse(editCostControllers[i].text),
                price: int.parse(editPriceControllers[i].text),
                weight: double.parse(
                    weightControllers[i].text.replaceAll(RegExp('[^0-9]'), '')),
                prodId: prodInserted.prodId);
            productModels.add(model);
            editCostControllers.add(TextEditingController());
            editPriceControllers.add(TextEditingController());
            i++;
          }
        }
      }
      setState(
        () {},
      );
      if (productModels.isEmpty) {
      } else {
        for (var model in productModels) {
          final modelInserted =
              await DatabaseManager.instance.createProductModel(model);

          for (var st in stPropsList) {
            final new_st = ProductModel_stProperty(
                pmstPropName: st.pmstPropName,
                prodModelId: modelInserted.prodModelId);

            final get1stId =
                await DatabaseManager.instance.create1stProperty(new_st);
          }

          for (var nd in ndPropsList) {
            final new_nd = ProductModel_ndProperty(
                pmndPropName: nd.pmndPropName,
                prodModelId: modelInserted.prodModelId);
            final get2ndId =
                await DatabaseManager.instance.create2ndProperty(new_nd);
          }
        }
      }
      Navigator.pop(context);
    }
  }

  _addCostPriceInProdModel(stPropsList, ndPropsList) {
    setState(() {
      productModels.clear();
      if (ndPropsList.isNotEmpty) {
        var i = 0;
        for (var st in stPropsList) {
          for (var nd in ndPropsList) {
            final model = ProductModel(
              prodModelname: '${stPropName},${ndPropName}',
              stProperty: '${st.pmstPropName}',
              ndProperty: '${nd.pmndPropName}',
              cost: int.parse(
                  editCostControllers[i].text.replaceAll(RegExp('[^0-9]'), '')),
              price: int.parse(editPriceControllers[i]
                  .text
                  .replaceAll(RegExp('[^0-9]'), '')),
              weight: double.parse(
                  weightControllers[i].text.replaceAll(RegExp('[^0-9]'), '')),
            );
            productModels.add(model);
            editCostControllers.add(TextEditingController());
            editPriceControllers.add(TextEditingController());
            weightControllers.add(TextEditingController());
            i++;
          }
        }
      } else {
        var i = 0;
        for (var st in stPropsList) {
          final model = ProductModel(
            prodModelname: '${stPropName},${ndPropName}',
            stProperty: '${st.pmstPropName}',
            ndProperty: '-',
            cost: int.parse(
                editCostControllers[i].text.replaceAll(RegExp('[^0-9]'), '')),
            price: int.parse(
                editPriceControllers[i].text.replaceAll(RegExp('[^0-9]'), '')),
            weight: double.parse(
                weightControllers[i].text.replaceAll(RegExp('[^0-9]'), '')),
          );
          productModels.add(model);
          editCostControllers.add(TextEditingController());
          editPriceControllers.add(TextEditingController());
          weightControllers.add(TextEditingController());
          i++;
        }
      }
    });
  }

  // Product Model
  Future refreshProductCategorys() async {
    productCategorys = await DatabaseManager.instance
        .readAllProductCategorys(widget.shop.shopid!);
    productLots = await DatabaseManager.instance.readAllProductLots();
    setState(() {});
  }

  // Product
  _updateChooseProductCateg(ProductCategory _productCategory) {
    print(productCategory.prodCategName);

    setState(() {
      productCategory = _productCategory;
    });
  }

  _createProductModeltoSetPrice(stPropsList, ndPropsList) {
    for (var st in stPropsList) {
      if (ndPropsList.isNotEmpty) {
        for (var nd in ndPropsList) {
          final model = ProductModel(
              prodModelname: '${stPropName},${ndPropName}',
              stProperty: '${st.pmstPropName}',
              ndProperty: '${nd.pmndPropName}',
              cost: 0,
              price: 0,
              weight: 0);
          productModels.add(model);
          editCostControllers.add(TextEditingController());
          editPriceControllers.add(TextEditingController());
          weightControllers.add(TextEditingController());
        }
      } else {
        final model = ProductModel(
            prodModelname: '${stPropName}',
            stProperty: '${st.pmstPropName}',
            ndProperty: '',
            cost: 0,
            price: 0,
            weight: 0);
        productModels.add(model);
        editCostControllers.add(TextEditingController());
        editPriceControllers.add(TextEditingController());
        weightControllers.add(TextEditingController());
      }
    }

    setState(() {});
  }

  Future<void> dialogEdit_AllWeight() async {
    final _costformKey = GlobalKey<FormState>();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, EditPropCostPriceDialogSetState) {
          return AlertDialog(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            title: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'กำหนดน้ำหนักทั้งหมด',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      '(ไม่ต้องเลือกหากตั้งการกำหนดทั้งหมด)',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                Spacer(),
                IconButton(
                    onPressed: () {
                      stPropertySelecteds.clear();
                      ndPropertySelecteds.clear();
                      wController.clear();

                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey,
                    ))
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${stPropName}',
                          style: TextStyle(color: Colors.white),
                        ),
                        MultiSelectContainer(
                            textStyles: const MultiSelectTextStyles(
                                textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 255, 255, 255))),
                            prefix: MultiSelectPrefix(
                              selectedPrefix: const Padding(
                                padding: EdgeInsets.only(right: 5),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                            itemsDecoration: MultiSelectDecorations(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    const Color.fromRGBO(56, 54, 76, 1.0),
                                    const Color.fromRGBO(56, 54, 76, 1.0),
                                  ]),
                                  borderRadius: BorderRadius.circular(20)),
                              selectedDecoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    Theme.of(context).backgroundColor,
                                    Theme.of(context).backgroundColor,
                                  ]),
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            items: stPropsList
                                .map((item) => MultiSelectCard(
                                    value: '${item.pmstPropName}',
                                    label: '${item.pmstPropName}'))
                                .toList(),
                            onChange: (allSelectedItems, selectedItem) {
                              // for (var item in allSelectedItems) {
                              //   stPropertySelecteds.add(item);
                              //   print('${item}');
                              // }
                              EditPropCostPriceDialogSetState(() {
                                stPropertySelecteds = allSelectedItems;
                                print(
                                    'stPropertySelecteds -> ${stPropertySelecteds.length}');
                              });
                            }),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ndPropsList.isEmpty
                            ? Container()
                            : Text(
                                '${ndPropName}',
                                style: TextStyle(color: Colors.white),
                              ),
                        ndPropsList.isEmpty
                            ? Container()
                            : MultiSelectContainer(
                                textStyles: const MultiSelectTextStyles(
                                    textStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(
                                            255, 255, 255, 255))),
                                prefix: MultiSelectPrefix(
                                  selectedPrefix: const Padding(
                                    padding: EdgeInsets.only(right: 5),
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                                itemsDecoration: MultiSelectDecorations(
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [
                                        const Color.fromRGBO(56, 54, 76, 1.0),
                                        const Color.fromRGBO(56, 54, 76, 1.0),
                                      ]),
                                      borderRadius: BorderRadius.circular(20)),
                                  selectedDecoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [
                                        Theme.of(context).backgroundColor,
                                        Theme.of(context).backgroundColor,
                                      ]),
                                      borderRadius: BorderRadius.circular(20)),
                                ),
                                items: ndPropsList
                                    .map((item) => MultiSelectCard(
                                        value: '${item.pmndPropName}',
                                        label: '${item.pmndPropName}'))
                                    .toList(),
                                onChange: (allSelectedItems, selectedItem) {
                                  EditPropCostPriceDialogSetState(() {
                                    ndPropertySelecteds = allSelectedItems;
                                    print(
                                        'ndPropertySelecteds -> ${ndPropertySelecteds.length}');
                                  });
                                }),
                      ],
                    ),
                  ),
                  ListBody(
                    children: <Widget>[
                      Form(
                        key: _costformKey,
                        child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .background
                                    .withOpacity(0.9),
                                borderRadius: BorderRadius.circular(15)),
                            width: 400,
                            height: 80,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'โปรดระบุน้ำหนัก';
                                    }
                                    return null;
                                  },
                                  textAlign: TextAlign.start,
                                  keyboardType: TextInputType.number,
                                  // maxLength: length,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(20),
                                  ],
                                  controller: wController,
                                  //-----------------------------------------------------

                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                  cursorColor: primary_color,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(
                                        top: 25,
                                        bottom: 10,
                                        left: 10,
                                        right: 10),
                                    // labelText: title,
                                    fillColor: Theme.of(context)
                                        .colorScheme
                                        .background,

                                    hoverColor: Colors.white,
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                      ),
                                    ),
                                    border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20)),
                                        borderSide: BorderSide.none),
                                    hintText: 'กรัม',
                                    hintStyle: const TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                    // prefixIcon: const Icon(Icons.local_shipping, color: Colors.white),
                                    suffixIcon: wController.text.isEmpty
                                        ? Container(
                                            width: 0,
                                          )
                                        : IconButton(
                                            onPressed: () =>
                                                wController.clear(),
                                            icon: const Icon(
                                              Icons.close_sharp,
                                              color: Colors.white,
                                            ),
                                          ),
                                  )),
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('ยืนยัน'),
                onPressed: () {
                  if (_costformKey.currentState!.validate()) {
                    if (ndPropsList.isNotEmpty) {
                      print('1st + 2nd Propertys');
                      if (stPropertySelecteds.isNotEmpty &&
                          ndPropertySelecteds.isNotEmpty) {
                        print('Both Selected');
                        for (var i = 0; i < ndPropertySelecteds.length; i++) {
                          for (var st in stPropertySelecteds) {
                            for (var nd in ndPropertySelecteds) {
                              for (var model in productModels) {
                                if (model.stProperty == st &&
                                    model.ndProperty == nd) {
                                  var findIndex = productModels
                                      .indexWhere((e) => e == model);

                                  weightControllers[findIndex].text =
                                      wController.text
                                          .replaceAll(RegExp('[^0-9]'), '');
                                  ;
                                }
                              }
                            }
                          }
                        }
                        Navigator.of(context).pop();
                      } else if (stPropertySelecteds.isNotEmpty &&
                          ndPropertySelecteds.isEmpty) {
                        print('Only 1st Selected');
                        for (var i = 0; i < stPropertySelecteds.length; i++) {
                          var stSelectedInd = stPropertySelecteds[i];

                          print(stSelectedInd);
                          for (var model in productModels) {
                            if (model.stProperty == stSelectedInd) {
                              var findIndex =
                                  productModels.indexWhere((e) => e == model);

                              weightControllers[findIndex].text = wController
                                  .text
                                  .replaceAll(RegExp('[^0-9]'), '');
                              ;
                            } else {}
                          }
                        }
                        Navigator.of(context).pop();
                      } else if (stPropertySelecteds.isEmpty &&
                          ndPropertySelecteds.isNotEmpty) {
                        print('Only 2nd Selected');
                        for (var i = 0; i < ndPropertySelecteds.length; i++) {
                          var ndSelectedInd = ndPropertySelecteds[i];

                          for (var model in productModels) {
                            if (model.ndProperty == ndSelectedInd) {
                              var findIndex =
                                  productModels.indexWhere((e) => e == model);

                              weightControllers[findIndex].text =
                                  wController.text;
                            }
                          }
                        }
                        Navigator.of(context).pop();
                      } else {
                        print('No Selected');
                        var cnt = 0;
                        for (var w in weightControllers) {
                          w.text =
                              wController.text.replaceAll(RegExp('[^0-9]'), '');
                          ;
                          cnt++;
                        }

                        Navigator.of(context).pop();
                      }
                    } else {
                      print('Only 1st Property');
                      // Created Only 1st Propertys
                      if (stPropertySelecteds.isNotEmpty) {
                        print('Empty Selection 1st Property');
                        for (var st in stPropertySelecteds) {
                          for (var model in productModels) {
                            if (model.stProperty == st) {
                              var findIndex =
                                  productModels.indexWhere((e) => e == model);

                              weightControllers[findIndex].text =
                                  wController.text;
                            }
                          }
                        }

                        Navigator.of(context).pop();
                      } else {
                        for (var w in weightControllers) {
                          w.text = wController.text;
                        }

                        Navigator.of(context).pop();
                      }
                    }
                    stPropertySelecteds.clear();
                    ndPropertySelecteds.clear();
                  } else {
                    print('Else');
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  // Dialog Zone
  // ราคาทั้งหมด
  Future<void> dialogEdit_PropCostPrice() async {
    final _costformKey = GlobalKey<FormState>();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, EditPropCostPriceDialogSetState) {
          return AlertDialog(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            title: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'กำหนดราคาทั้งหมด',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      '(ไม่ต้องเลือกหากตั้งการกำหนดทั้งหมด)',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                Spacer(),
                IconButton(
                    onPressed: () {
                      stPropertySelecteds.clear();
                      ndPropertySelecteds.clear();
                      cController.clear();
                      pController.clear();
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey,
                    ))
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${stPropName}',
                          style: TextStyle(color: Colors.white),
                        ),
                        MultiSelectContainer(
                            textStyles: const MultiSelectTextStyles(
                                textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 255, 255, 255))),
                            prefix: MultiSelectPrefix(
                              selectedPrefix: const Padding(
                                padding: EdgeInsets.only(right: 5),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                            itemsDecoration: MultiSelectDecorations(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    const Color.fromRGBO(56, 54, 76, 1.0),
                                    const Color.fromRGBO(56, 54, 76, 1.0),
                                  ]),
                                  borderRadius: BorderRadius.circular(20)),
                              selectedDecoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    Theme.of(context).backgroundColor,
                                    Theme.of(context).backgroundColor,
                                  ]),
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            items: stPropsList
                                .map((item) => MultiSelectCard(
                                    value: '${item.pmstPropName}',
                                    label: '${item.pmstPropName}'))
                                .toList(),
                            onChange: (allSelectedItems, selectedItem) {
                              // for (var item in allSelectedItems) {
                              //   stPropertySelecteds.add(item);
                              //   print('${item}');
                              // }
                              EditPropCostPriceDialogSetState(() {
                                stPropertySelecteds = allSelectedItems;
                                print(
                                    'stPropertySelecteds -> ${stPropertySelecteds.length}');
                              });
                            }),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ndPropsList.isEmpty
                            ? Container()
                            : Text(
                                '${ndPropName}',
                                style: TextStyle(color: Colors.white),
                              ),
                        ndPropsList.isEmpty
                            ? Container()
                            : MultiSelectContainer(
                                textStyles: const MultiSelectTextStyles(
                                    textStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(
                                            255, 255, 255, 255))),
                                prefix: MultiSelectPrefix(
                                  selectedPrefix: const Padding(
                                    padding: EdgeInsets.only(right: 5),
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                                itemsDecoration: MultiSelectDecorations(
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [
                                        const Color.fromRGBO(56, 54, 76, 1.0),
                                        const Color.fromRGBO(56, 54, 76, 1.0),
                                      ]),
                                      borderRadius: BorderRadius.circular(20)),
                                  selectedDecoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [
                                        Theme.of(context).backgroundColor,
                                        Theme.of(context).backgroundColor,
                                      ]),
                                      borderRadius: BorderRadius.circular(20)),
                                ),
                                items: ndPropsList
                                    .map((item) => MultiSelectCard(
                                        value: '${item.pmndPropName}',
                                        label: '${item.pmndPropName}'))
                                    .toList(),
                                onChange: (allSelectedItems, selectedItem) {
                                  EditPropCostPriceDialogSetState(() {
                                    ndPropertySelecteds = allSelectedItems;
                                    print(
                                        'ndPropertySelecteds -> ${ndPropertySelecteds.length}');
                                  });
                                }),
                      ],
                    ),
                  ),
                  ListBody(
                    children: <Widget>[
                      Form(
                        key: _costformKey,
                        child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .background
                                    .withOpacity(0.9),
                                borderRadius: BorderRadius.circular(15)),
                            width: 400,
                            height: 80,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'โปรดระบุราคาต้นทุน';
                                    } else if (pController.text.isNotEmpty &&
                                        value.isNotEmpty &&
                                        value != null) {
                                      if (double.parse(pController.text)
                                              .toInt() <
                                          double.parse(cController.text)
                                              .toInt()) {
                                        return 'ราคาต้นทุน น้อยกว่า ราคาขาย';
                                      }
                                    }
                                    return null;
                                  },
                                  textAlign: TextAlign.start,
                                  keyboardType: TextInputType.number,
                                  // maxLength: length,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(20),
                                  ],
                                  controller: cController,
                                  //-----------------------------------------------------

                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                  cursorColor: primary_color,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(
                                        top: 25,
                                        bottom: 10,
                                        left: 10,
                                        right: 10),
                                    // labelText: title,
                                    fillColor: Theme.of(context)
                                        .colorScheme
                                        .background,

                                    hoverColor: Colors.white,
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                      ),
                                    ),
                                    border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20)),
                                        borderSide: BorderSide.none),
                                    hintText: 'ราคาต้นทุน',
                                    hintStyle: const TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                    // prefixIcon: const Icon(Icons.local_shipping, color: Colors.white),
                                    suffixIcon: cController.text.isEmpty
                                        ? Container(
                                            width: 0,
                                          )
                                        : IconButton(
                                            onPressed: () =>
                                                cController.clear(),
                                            icon: const Icon(
                                              Icons.close_sharp,
                                              color: Colors.white,
                                            ),
                                          ),
                                  )),
                            )),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .background
                                  .withOpacity(0.9),
                              borderRadius: BorderRadius.circular(15)),
                          width: 400,
                          height: 80,
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: TextFormField(
                                textAlign: TextAlign.start,
                                keyboardType: TextInputType.number,
                                // maxLength: length,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(20),
                                ],
                                controller: pController,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                                cursorColor: primary_color,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(
                                      top: 25, bottom: 10, left: 10, right: 10),
                                  // labelText: title,
                                  fillColor:
                                      Theme.of(context).colorScheme.background,

                                  hoverColor: Colors.white,
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                    borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                    ),
                                  ),
                                  border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20)),
                                      borderSide: BorderSide.none),
                                  hintText: 'ราคาขาย',
                                  hintStyle: const TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                  // prefixIcon: const Icon(Icons.local_shipping, color: Colors.white),
                                  suffixIcon: pController.text.isEmpty
                                      ? Container(
                                          width: 0,
                                        )
                                      : IconButton(
                                          onPressed: () => pController.clear(),
                                          icon: const Icon(
                                            Icons.close_sharp,
                                            color: Colors.white,
                                          ),
                                        ),
                                )),
                          )),
                    ],
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('ยืนยัน'),
                onPressed: () {
                  if (_costformKey.currentState!.validate()) {
                    if (ndPropsList.isNotEmpty) {
                      print('1st + 2nd Propertys');
                      if (stPropertySelecteds.isNotEmpty &&
                          ndPropertySelecteds.isNotEmpty) {
                        print('Both Selected');
                        for (var i = 0; i < ndPropertySelecteds.length; i++) {
                          for (var st in stPropertySelecteds) {
                            for (var nd in ndPropertySelecteds) {
                              for (var model in productModels) {
                                if (model.stProperty == st &&
                                    model.ndProperty == nd) {
                                  var findIndex = productModels
                                      .indexWhere((e) => e == model);

                                  editCostControllers[findIndex].text =
                                      cController.text
                                          .replaceAll(RegExp('[^0-9]'), '');
                                  ;
                                  editPriceControllers[findIndex].text =
                                      pController.text;
                                  print(cController.text);
                                  print(cController.runtimeType);
                                  print(pController.text);
                                  print(pController.runtimeType);
                                }
                              }
                            }
                          }
                        }
                        Navigator.of(context).pop();
                      } else if (stPropertySelecteds.isNotEmpty &&
                          ndPropertySelecteds.isEmpty) {
                        print('Only 1st Selected');
                        for (var i = 0; i < stPropertySelecteds.length; i++) {
                          var stSelectedInd = stPropertySelecteds[i];

                          print(stSelectedInd);
                          for (var model in productModels) {
                            if (model.stProperty == stSelectedInd) {
                              var findIndex =
                                  productModels.indexWhere((e) => e == model);

                              editCostControllers[findIndex].text = cController
                                  .text
                                  .replaceAll(RegExp('[^0-9]'), '');
                              ;
                              editPriceControllers[findIndex].text = pController
                                  .text
                                  .replaceAll(RegExp('[^0-9]'), '');
                              ;
                              print(cController.text);
                              print(cController.runtimeType);
                              print(pController.text);
                              print(pController.runtimeType);
                            } else {}
                          }
                        }
                        Navigator.of(context).pop();
                      } else if (stPropertySelecteds.isEmpty &&
                          ndPropertySelecteds.isNotEmpty) {
                        print('Only 2nd Selected');
                        for (var i = 0; i < ndPropertySelecteds.length; i++) {
                          var ndSelectedInd = ndPropertySelecteds[i];

                          for (var model in productModels) {
                            if (model.ndProperty == ndSelectedInd) {
                              var findIndex =
                                  productModels.indexWhere((e) => e == model);

                              editCostControllers[findIndex].text =
                                  cController.text;
                              editPriceControllers[findIndex].text =
                                  pController.text;
                            }
                          }
                        }
                        Navigator.of(context).pop();
                      } else {
                        print('No Selected');
                        var cnt = 0;
                        for (var c in editCostControllers) {
                          c.text =
                              cController.text.replaceAll(RegExp('[^0-9]'), '');
                          ;
                          cnt++;
                        }
                        print(cnt);
                        for (var p in editPriceControllers) {
                          p.text =
                              pController.text.replaceAll(RegExp('[^0-9]'), '');
                          ;
                        }
                        Navigator.of(context).pop();
                        print(cController.text);
                        print(cController.text.runtimeType);
                        print(pController.text);
                        print(pController.text.runtimeType);
                      }
                    } else {
                      print('Only 1st Property');
                      // Created Only 1st Propertys
                      if (stPropertySelecteds.isNotEmpty) {
                        print('Empty Selection 1st Property');
                        for (var st in stPropertySelecteds) {
                          for (var model in productModels) {
                            if (model.stProperty == st) {
                              var findIndex =
                                  productModels.indexWhere((e) => e == model);

                              editCostControllers[findIndex].text =
                                  cController.text;
                              editPriceControllers[findIndex].text =
                                  pController.text;
                            }
                          }
                        }

                        Navigator.of(context).pop();
                      } else {
                        for (var c in editCostControllers) {
                          c.text = cController.text;
                        }
                        for (var p in editPriceControllers) {
                          p.text = pController.text;
                        }
                        Navigator.of(context).pop();
                      }
                    }
                    stPropertySelecteds.clear();
                    ndPropertySelecteds.clear();
                  } else {
                    print('Else');
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  // กำหนดราคา
  dialogProduct_CostPrice() async {
    await showDialog(
        context: context,
        builder: (BuildContext dContext2) {
          return StatefulBuilder(builder: (dContext2, DialogSetState) {
            return Dialog(
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)), //th
              child: SizedBox(
                height: 500,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(

                              // color: Theme.of(context).colorScheme.background,
                              borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                width:
                                    (MediaQuery.of(context).size.width) * 0.7,
                                child: Row(
                                  children: [
                                    Text(
                                      'กำหนดราคา ',
                                      style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        fontSize: 16,
                                        // fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      '(2/3)',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        // fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    ElevatedButton(
                                        onPressed: () {
                                          dialogEdit_PropCostPrice();
                                        },
                                        child: Row(
                                          children: [
                                            Icon(Icons.mode_edit_outline_sharp),
                                            Text('ทั้งหมด')
                                          ],
                                        )),
                                    Spacer(),
                                    IconButton(
                                        onPressed: () {
                                          amountControllers.clear();
                                          Navigator.pop(context);
                                        },
                                        icon: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        // สี

                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              productModels.isEmpty
                                  ? Container(
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .background
                                              .withOpacity(0.9),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      height: 160,
                                      child: Center(
                                          child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.note_alt_outlined,
                                            color: Colors.grey,
                                            size: 20,
                                          ),
                                          Text(
                                            'ไม่มีรูปแบบสินค้า',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13),
                                          ),
                                        ],
                                      )),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .background
                                              .withOpacity(0.9),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      height: 350,
                                      child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          itemCount: productModels.length,
                                          itemBuilder: (context, index) {
                                            final productModelInd =
                                                productModels[index];
                                            bool isEditCategory = false;

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Row(children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              '${index + 1} ',
                                                              style: TextStyle(
                                                                  fontSize: 15,
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
                                                                        3.0),
                                                                child: Text(
                                                                    '${productModelInd.stProperty}',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      color: Colors
                                                                          .white,
                                                                    )),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 10,
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
                                                                        3.0),
                                                                child: Text(
                                                                  '${productModelInd.ndProperty}',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Container(
                                                          width: (MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              1.6),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                        decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(
                                                                                10)),
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text('ต้นทุน ฿',
                                                                                style: TextStyle(
                                                                                  fontSize: 15,
                                                                                  color: Colors.white,
                                                                                )),
                                                                            CustomTextField.textField(
                                                                              context,
                                                                              'ราคาขาย ฿',
                                                                              _validate,
                                                                              length: 10,
                                                                              isNumber: true,
                                                                              textController: editCostControllers[index],
                                                                            ),
                                                                          ],
                                                                        )),
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                        decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(
                                                                                10)),
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text('ราคาขาย ฿',
                                                                                style: TextStyle(
                                                                                  fontSize: 15,
                                                                                  color: Colors.white,
                                                                                )),
                                                                            CustomTextField.textField(
                                                                              context,
                                                                              'ราคา',
                                                                              _validate,
                                                                              isNumber: true,
                                                                              length: 10,
                                                                              textController: editPriceControllers[index],
                                                                            ),
                                                                          ],
                                                                        )),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ]),
                                                ),
                                              ),
                                            );
                                          }),
                                    ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'รูปแบบสินค้าทั้งหมด',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color:
                                              Theme.of(context).backgroundColor,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                            '${NumberFormat("#,###").format(productModels.length)}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Row(
                          mainAxisAlignment: productModels.isEmpty
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.redAccent,
                                    fixedSize: const Size(80, 40)),
                                onPressed: () {
                                  amountControllers.clear();
                                  productModels.clear();
                                  editCostControllers.clear();
                                  editPriceControllers.clear();

                                  Navigator.pop(context);

                                  setState(() {});
                                },
                                child: Text('ยกเลิก')),
                            productModels.isEmpty
                                ? Container(
                                    width: 0,
                                  )
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        fixedSize: const Size(80, 40)),
                                    onPressed: () {
                                      var foundNullIndex =
                                          _invalidationPriceController();
                                      DialogSetState(
                                        () {},
                                      );

                                      if (isFoundNullCost || isFoundNullPrice) {
                                        ScaffoldMessenger.of(dContext2)
                                            .showSnackBar(SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: Colors.redAccent,
                                          content: Text(
                                              "ราคารูปแบบสินค้าที่(${foundNullIndex}) ว่าง"),
                                          duration: Duration(seconds: 3),
                                        ));
                                      } else {
                                        dialogProduct_weight();
                                      }
                                    },
                                    child: Text('ถัดไป')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  Future<void> dialogEdit_ProductCategory(ProductCategory prodCategory) async {
    TextEditingController controller =
        TextEditingController(text: prodCategory.prodCategName);
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, Edit_st_PropDialogSetState) {
          return AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            title: Row(
              children: [
                Text(
                  'แก้ไข',
                  style: TextStyle(color: Colors.white),
                ),
                Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.grey,
                    size: 25,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  CustomTextField.textField(
                    context,
                    prodCategory.prodCategName,
                    _validate,
                    length: 30,
                    textController: controller,
                  )
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.redAccent),
                child: Wrap(
                  children: [
                    Icon(Icons.delete_rounded),
                    const Text('ลบ'),
                  ],
                ),
                onPressed: () async {
                  await DatabaseManager.instance
                      .deleteProductCategory(prodCategory.prodCategId!);
                  Navigator.of(context).pop();
                  refreshProductCategorys();
                },
              ),
              Spacer(),
              ElevatedButton(
                child: const Text('ยืนยัน'),
                onPressed: () async {
                  if (controller.text.isEmpty ||
                      controller.text == '' ||
                      controller.text == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Theme.of(context).backgroundColor,
                        behavior: SnackBarBehavior.floating,
                        content: Text("โปรดระบุ"),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    final updatedprodCateg = prodCategory.copy(
                        prodCategName: controller.text.trim());
                    await DatabaseManager.instance
                        .updateProductCategory(updatedprodCateg);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> dialogEdit_PropName(TextEditingController controller) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, Edit_st_PropDialogSetState) {
          return AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            title: Row(
              children: [
                Text(
                  'แก้ไข',
                  style: TextStyle(color: Colors.white),
                ),
                Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.grey,
                    size: 25,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  CustomTextField.textField(
                    context,
                    isDialogChooseFst == true ? stPropName : ndPropName,
                    _validate,
                    length: 30,
                    textController: controller,
                  )
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('ยืนยัน'),
                onPressed: () {
                  Edit_st_PropDialogSetState(() {
                    if (controller.text.isEmpty) {
                    } else {
                      isDialogChooseFst == true
                          ? stPropName = controller.text
                          : ndPropName = controller.text;
                    }
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }

  dialogProductModel() async {
    final ScrollController _firstController = ScrollController();
    await showDialog(
        context: context,
        useRootNavigator: false,
        builder: (BuildContext dContext1) {
          return StatefulBuilder(builder: (dContext1, DialogSetState) {
            return Dialog(
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)), //th
              child: SizedBox(
                height: 500,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                              // color: Theme.of(context).colorScheme.background,
                              borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                  width:
                                      (MediaQuery.of(context).size.width) * 0.7,
                                  child: Row(
                                    children: [
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      const Text(
                                        'สร้างรูปแบบสินค้า ',
                                        style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 255, 255, 255),
                                          fontSize: 16,
                                          // fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const Text(
                                        '(1/3)',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                          // fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.grey,
                                          size: 25,
                                        ),
                                        onPressed: () {
                                          productModels.clear();
                                          Navigator.pop(context);
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        // สี

                        Container(
                          height: 300,
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      stPropName,
                                      style: const TextStyle(
                                          fontSize: 25, color: Colors.white),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    IconButton(
                                        onPressed: () async {
                                          DialogSetState(
                                            () {
                                              isDialogChooseFst = true;
                                            },
                                          );
                                          await dialogEdit_PropName(
                                              productModel_stPropNameController);
                                          DialogSetState(
                                            () {
                                              isDialogChooseFst = false;
                                            },
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                        )),
                                    stPropsList.isEmpty
                                        ? Container()
                                        : Container(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Text(
                                                '${NumberFormat("#,###.##").format(stPropsList.length)}',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        height: 60,
                                        child: CustomTextField.textField(
                                          context,
                                          'ระบุ${stPropName}',
                                          _validate,
                                          length: 30,
                                          textController:
                                              productModel_stPropListNameController,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (productModel_stPropListNameController
                                            .text.isEmpty) {
                                          ScaffoldMessenger.of(dContext1)
                                              .showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.redAccent,
                                              content: Text(
                                                  "โปรดระบุชื่อรูปแบบ ${stPropName} สินค้า"),
                                              duration: Duration(seconds: 3),
                                            ),
                                          );
                                        } else {
                                          final stProp =
                                              ProductModel_stProperty(
                                            pmstPropName:
                                                productModel_stPropListNameController
                                                    .text
                                                    .trim(),
                                          );

                                          DialogSetState(
                                            () {
                                              stPropsList.add(stProp);
                                            },
                                          );
                                          // print(
                                          //     'Add Prod Prod Model Property 1st : [${prodCategory.prodCategId}, ${prodCategory.prodCategName} ${prodCategory.shopId}] Data Type? -> ${prodCategory.shopId.runtimeType}');

                                          productModel_stPropListNameController
                                              .clear();

                                          DialogSetState(() {
                                            refreshProductCategorys();
                                          });
                                        }
                                      },
                                      child: Row(children: const [
                                        Icon(
                                          Icons.add_rounded,
                                          color: Colors.white,
                                        ),
                                        Text('เพิ่ม'),
                                      ]),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                stPropsList.isEmpty
                                    ? Container(
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .background
                                                .withOpacity(0.9),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        height: 160,
                                        child: Center(
                                            child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.note_alt_outlined,
                                              color: Colors.grey,
                                              size: 20,
                                            ),
                                            Text(
                                              'ไม่มี ${stPropName} สินค้า',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 13),
                                            ),
                                          ],
                                        )),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .background
                                                .withOpacity(0.9),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        height: 160,
                                        child: ListView.builder(
                                            // scrollDirection: Axis.horizontal,
                                            padding: EdgeInsets.zero,
                                            itemCount: stPropsList.length,
                                            itemBuilder: (context, index) {
                                              final stPropsListInd =
                                                  stPropsList[index];
                                              return GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: Container(
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: Row(children: [
                                                        Text(
                                                          stPropsListInd
                                                              .pmstPropName,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        const Spacer(),
                                                        IconButton(
                                                            onPressed: () {
                                                              stPropsList
                                                                  .removeAt(
                                                                      index);
                                                              DialogSetState(
                                                                  () {
                                                                stPropsList =
                                                                    stPropsList;
                                                              });
                                                            },
                                                            icon: const Icon(
                                                              Icons
                                                                  .close_rounded,
                                                              color:
                                                                  Colors.white,
                                                            ))
                                                      ]),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                      ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),

                        // ขนาด
                        isDelete_ndProp == true
                            ? ElevatedButton(
                                child: Row(
                                  children: const [
                                    Icon(Icons.add_rounded,
                                        size: 25,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255)),
                                    Text(
                                      'เพิ่มอีกรูปแบบ',
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                ),
                                onPressed: () {
                                  DialogSetState(
                                    () {
                                      isDelete_ndProp = false;
                                    },
                                  );
                                },
                              )
                            : Stack(children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  height: 300,
                                  decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              ndPropName,
                                              style: const TextStyle(
                                                  fontSize: 25,
                                                  color: Colors.white),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            IconButton(
                                                onPressed: () async {
                                                  DialogSetState(
                                                    () {
                                                      isDialogChooseFst ==
                                                          false;
                                                    },
                                                  );
                                                  await dialogEdit_PropName(
                                                      productModel_ndPropNameController);
                                                },
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.white,
                                                )),
                                            ndPropsList.isEmpty
                                                ? Container()
                                                : Container(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child: Text(
                                                        '${NumberFormat("#,###.##").format(ndPropsList.length)}',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                height: 60,
                                                child:
                                                    CustomTextField.textField(
                                                  context,
                                                  'ระบุ${ndPropName}',
                                                  _validate,
                                                  length: 30,
                                                  textController:
                                                      productModel_ndPropListNameController,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                if (productModel_ndPropListNameController
                                                    .text.isEmpty) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      backgroundColor:
                                                          Colors.redAccent,
                                                      content: Text(
                                                          "โปรดระบุชื่อรูปแบบ ${ndPropName} สินค้า"),
                                                      duration:
                                                          Duration(seconds: 3),
                                                    ),
                                                  );
                                                } else {
                                                  final ndProp =
                                                      ProductModel_ndProperty(
                                                    pmndPropName:
                                                        productModel_ndPropListNameController
                                                            .text
                                                            .trim(),
                                                  );

                                                  DialogSetState(
                                                    () {
                                                      ndPropsList.add(ndProp);
                                                    },
                                                  );
                                                  // print(
                                                  //     'Add Prod Prod Model Property 1st : [${prodCategory.prodCategId}, ${prodCategory.prodCategName} ${prodCategory.shopId}] Data Type? -> ${prodCategory.shopId.runtimeType}');

                                                  productModel_ndPropListNameController
                                                      .clear();

                                                  DialogSetState(() {});
                                                }
                                              },
                                              child: Row(children: const [
                                                Icon(
                                                  Icons.add_rounded,
                                                  color: Colors.white,
                                                ),
                                                Text('เพิ่ม'),
                                              ]),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        ndPropsList.isEmpty
                                            ? Container(
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .background
                                                        .withOpacity(0.9),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                height: 160,
                                                child: Center(
                                                    child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.note_alt_outlined,
                                                      color: Colors.grey,
                                                      size: 20,
                                                    ),
                                                    Text(
                                                      'ไม่มี ${ndPropName} สินค้า',
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 13),
                                                    ),
                                                  ],
                                                )),
                                              )
                                            : Container(
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .background
                                                        .withOpacity(0.9),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                height: 160,
                                                child: ListView.builder(
                                                    // scrollDirection: Axis.horizontal,
                                                    padding: EdgeInsets.zero,
                                                    itemCount:
                                                        ndPropsList.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      final ndPropsListInd =
                                                          ndPropsList[index];
                                                      return GestureDetector(
                                                        onTap: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5.0),
                                                          child: Container(
                                                            height: 50,
                                                            decoration: BoxDecoration(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .all(
                                                                      10.0),
                                                              child: Row(
                                                                  children: [
                                                                    Text(
                                                                      ndPropsListInd
                                                                          .pmndPropName,
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                    const Spacer(),
                                                                    IconButton(
                                                                        onPressed:
                                                                            () {
                                                                          ndPropsList
                                                                              .removeAt(index);
                                                                          DialogSetState(
                                                                              () {
                                                                            ndPropsList =
                                                                                ndPropsList;
                                                                          });
                                                                        },
                                                                        icon:
                                                                            const Icon(
                                                                          Icons
                                                                              .close_rounded,
                                                                          color:
                                                                              Colors.white,
                                                                        ))
                                                                  ]),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0.0,
                                  right: 0,
                                  child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.7),
                                              spreadRadius: 0,
                                              blurRadius: 5,
                                              offset: Offset(0, 4))
                                        ],
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.close,
                                            size: 25,
                                            color: Color.fromARGB(
                                                255, 255, 255, 255)),
                                        onPressed: () {
                                          DialogSetState(
                                            () {
                                              ndPropsList.clear();
                                              isDelete_ndProp = true;
                                            },
                                          );
                                        },
                                      )),
                                ),
                              ]),
                        SizedBox(
                          height: 20,
                        ),
                        Wrap(
                          spacing: 10,
                          children: [
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.redAccent,
                                    fixedSize: const Size(80, 40)),
                                onPressed: () {
                                  productModels.clear();
                                  Navigator.pop(context);
                                  setState(() {});
                                },
                                child: Text('ยกเลิก')),
                            stPropsList.isEmpty
                                ? Container(
                                    width: 0,
                                  )
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        fixedSize: const Size(80, 40)),
                                    onPressed: () async {
                                      productModels.clear();
                                      editCostControllers.clear();
                                      editPriceControllers.clear();
                                      DialogSetState(
                                        () {},
                                      );

                                      _createProductModeltoSetPrice(
                                          stPropsList, ndPropsList);

                                      DialogSetState(
                                        () {},
                                      );
                                      // Setprice
                                      await dialogProduct_CostPrice();
                                      if (stPropertySelecteds.isNotEmpty &&
                                          ndPropertySelecteds.isNotEmpty) {
                                        stPropertySelecteds.clear();
                                        ndPropertySelecteds.clear();
                                      }
                                    },
                                    child: const Text('สร้าง')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  dialogProductChooseCategory() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (prodCategContext, CategoryDialogSetState) {
            return Dialog(
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)), //th
              child: SizedBox(
                height: 350,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              // color: Theme.of(context).colorScheme.background,
                              borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'เลือกหมวดหมู่สินค้า',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 25,
                                  // fontWeight: FontWeight.bold),
                                ),
                              ),
                              Spacer(),
                              IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.grey,
                                  size: 25,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10)),
                                height: 70,
                                child: CustomTextField.textField(
                                  context,
                                  'เช่น เสื้อ กางเกง...',
                                  _validate,
                                  length: 20,
                                  textController: productCategoryNameController,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (productCategoryNameController
                                    .text.isEmpty) {
                                  ScaffoldMessenger.of(prodCategContext)
                                      .showSnackBar(
                                    const SnackBar(
                                      backgroundColor: Colors.redAccent,
                                      content:
                                          Text("โปรดตั้งชื่อหมวดหมู่สินค้า"),
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                } else if (productCategorys.contains(
                                    productCategoryNameController.text)) {
                                  ScaffoldMessenger.of(prodCategContext)
                                      .showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.redAccent,
                                      content: Text(
                                          "มีหมวดหมู่สินค้า ${productCategoryNameController.text} อยู่แล้ว"),
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                } else {
                                  final prodCategory = ProductCategory(
                                    prodCategName:
                                        productCategoryNameController.text,
                                    shopId: widget.shop.shopid!,
                                  );

                                  await DatabaseManager.instance
                                      .createProductCategory(prodCategory);
                                  productCategoryNameController.clear();

                                  CategoryDialogSetState(() {
                                    refreshProductCategorys();
                                  });
                                }
                              },
                              child: Row(children: const [
                                Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                ),
                                Text('เพิ่ม'),
                              ]),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        productCategorys.isEmpty
                            ? Container(
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background
                                        .withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(10)),
                                height: 200,
                                child: Center(
                                    child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.note_alt_outlined,
                                      color: Colors.grey,
                                      size: 35,
                                    ),
                                    Text(
                                      'ไม่มีหมวดหมู่สินค้า',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 30),
                                    ),
                                  ],
                                )),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background
                                        .withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(10)),
                                height: 200,
                                child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: productCategorys.length,
                                    itemBuilder: (context, index) {
                                      final productCategory =
                                          productCategorys[index];
                                      bool isEditCategory = false;
                                      TextEditingController controller =
                                          TextEditingController(
                                              text: productCategory
                                                  .prodCategName);
                                      return Dismissible(
                                        key: UniqueKey(),
                                        direction: DismissDirection.endToStart,
                                        resizeDuration: Duration(seconds: 1),
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
                                        onDismissed: (direction) async {
                                          await DatabaseManager.instance
                                              .deleteProductCategory(
                                                  productCategory.prodCategId!);
                                          CategoryDialogSetState(() {
                                            refreshProductCategorys();
                                          });
                                        },
                                        child: GestureDetector(
                                          onTap: () {
                                            _updateChooseProductCateg(
                                                productCategory);
                                            print(
                                                productCategory.prodCategName);
                                            Navigator.pop(context);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Container(
                                              height: 60,
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .backgroundColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Row(children: [
                                                  Text(
                                                    productCategory == null
                                                        ? 'เลือกหมวดหมู่สินค้า'
                                                        : productCategory
                                                            .prodCategName,
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  const Spacer(),
                                                  IconButton(
                                                      onPressed: () async {
                                                        await dialogEdit_ProductCategory(
                                                            productCategory);

                                                        setState(() {});
                                                        refreshProductCategorys();
                                                        CategoryDialogSetState(
                                                            () {});
                                                      },
                                                      icon: const Icon(
                                                        Icons.edit,
                                                        color: Colors.white,
                                                      ))
                                                ]),
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
                ),
              ),
            );
          });
        });
  }

  dialogProduct_weight() async {
    await showDialog(
        context: context,
        builder: (BuildContext dContext3) {
          return StatefulBuilder(builder: (dContext3, DialogSetState) {
            return Dialog(
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)), //th
              child: SizedBox(
                height: 500,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              // color: Theme.of(context).colorScheme.background,
                              borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                width: 280,
                                child: Row(
                                  children: [
                                    Text(
                                      'กำหนดน้ำหนัก ',
                                      style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        fontSize: 16,
                                        // fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      '(3/3)',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        // fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Spacer(),
                                    IconButton(
                                        onPressed: () {
                                          amountControllers.clear();
                                          Navigator.pop(context);
                                        },
                                        icon: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                            onPressed: () {
                              dialogEdit_AllWeight();
                            },
                            child: Row(
                              children: [
                                Icon(Icons.mode_edit_outline_sharp),
                                Text('ทั้งหมด')
                              ],
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        // สี

                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              productModels.isEmpty
                                  ? Container(
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .background
                                              .withOpacity(0.9),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      height: 320,
                                      child: Expanded(
                                        child: Center(
                                            child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.note_alt_outlined,
                                              color: Colors.grey,
                                              size: 20,
                                            ),
                                            Text(
                                              'ว่าง',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 13),
                                            ),
                                          ],
                                        )),
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .background
                                              .withOpacity(0.9),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      height: 350,
                                      child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          itemCount: productModels.length,
                                          itemBuilder: (context, index) {
                                            final productModelInd =
                                                productModels[index];
                                            bool isEditCategory = false;

                                            return Dismissible(
                                              key: UniqueKey(),
                                              direction:
                                                  DismissDirection.endToStart,
                                              resizeDuration:
                                                  Duration(seconds: 1),
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
                                              onDismissed: (direction) {},
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Row(children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                '${index + 1} ',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15,
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
                                                                        BorderRadius.circular(
                                                                            10)),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          3.0),
                                                                  child: Text(
                                                                      '${productModelInd.stProperty}',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        color: Colors
                                                                            .white,
                                                                      )),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .secondary,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10)),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          3.0),
                                                                  child: Text(
                                                                    '${productModelInd.ndProperty}',
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Container(
                                                            width: 240,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  'น้ำหนัก',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .grey),
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Container(
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10)),
                                                                  height: 60,
                                                                  width: 130,
                                                                  child: CustomTextField
                                                                      .textField(
                                                                    context,
                                                                    'ระบุ',
                                                                    _validate,
                                                                    length: 10,
                                                                    isNumber:
                                                                        true,
                                                                    textController:
                                                                        weightControllers[
                                                                            index],
                                                                  ),
                                                                ),
                                                                Text(
                                                                  'กรัม',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .grey),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ]),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                    ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'รูปแบบสินค้าทั้งหมด',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color:
                                              Theme.of(context).backgroundColor,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                            '${NumberFormat("#,###").format(productModels.length)}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Row(
                          mainAxisAlignment: productModels.isEmpty
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.redAccent,
                                    fixedSize: const Size(80, 40)),
                                onPressed: () {
                                  // amountControllers.clear();
                                  // productModels.clear();
                                  // weightControllers.clear();

                                  Navigator.pop(context);

                                  setState(() {});
                                },
                                child: Text('ยกเลิก')),
                            productModels.isEmpty
                                ? Container(
                                    width: 0,
                                  )
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        fixedSize: const Size(80, 40)),
                                    onPressed: () {
                                      var foundNullIndex =
                                          _invalidationPriceController();
                                      DialogSetState(
                                        () {},
                                      );

                                      if (isFoundNullCost || isFoundNullPrice) {
                                        ScaffoldMessenger.of(dContext3)
                                            .showSnackBar(SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: Colors.redAccent,
                                          content: Text(
                                              "ราคารูปแบบสินค้าที่(${foundNullIndex}) ว่าง"),
                                          duration: Duration(seconds: 3),
                                        ));
                                      } else {
                                        _addCostPriceInProdModel(
                                            stPropsList, ndPropsList);

                                        Navigator.pop(dContext3);
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: Text('ยืนยัน')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: AppBar(
            title: const Text(
              "เพิ่มสินค้า",
              textAlign: TextAlign.start,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            // height: (MediaQuery.of(context).size.height),
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
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Wrap(
                alignment: WrapAlignment.center,
                runSpacing: 10,
                children: [
                  Container(
                    height: 90,
                  ),
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: ImagePickerWidget(controller: productImgController),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Text(
                        'ชื่อสินค้า',
                      )
                    ],
                  ),
                  CustomTextField.textField(
                    context,
                    'ระบุชื่อสินค้า',
                    _validate,
                    length: 30,
                    textController: productNameController,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'หมวดหมู่สินค้า',
                      )
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      await dialogProductChooseCategory();
                      refreshProductCategorys();
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .background
                              .withOpacity(0.9),
                          borderRadius: BorderRadius.circular(15)),
                      child: Row(children: [
                        Text(
                          productCategory.prodCategName,
                          style: TextStyle(color: Colors.grey),
                        ),
                        Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                        )
                      ]),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'รายละเอียดสินค้า',
                      )
                    ],
                  ),
                  CustomTextField.textField(
                    context,
                    'ระบุรายละเอียดสินค้า',
                    _validate,
                    length: 100,
                    textController: productDescriptionController,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        'รูปแบบสินค้า',
                      ),
                      Spacer(),
                      productModels.isEmpty
                          ? Container()
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.redAccent,
                              ),
                              onPressed: () {
                                productModels.clear();
                                setState(() {});
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.delete_sweep_rounded),
                                  Text(
                                    'ลบทั้งหมด',
                                    style: TextStyle(fontSize: 12),
                                  )
                                ],
                              )),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            dialogProductModel();
                          },
                          child: Icon(Icons.add_rounded))
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .background
                            .withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15)),
                    width: (MediaQuery.of(context).size.width),
                    height: 240,
                    child: Column(
                      children: [
                        productModels.isEmpty
                            ? Expanded(
                                child: Center(
                                    child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.note_alt_outlined,
                                      color: Colors.grey,
                                      size: 35,
                                    ),
                                    Text(
                                      'ไม่มีรูปแบบสินค้า',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 30),
                                    ),
                                  ],
                                )),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background
                                        .withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(10)),
                                height: 200,
                                child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: productModels.length,
                                    itemBuilder: (context, index) {
                                      final productModel = productModels[index];
                                      var _amountOfProd = 0;
                                      for (var lot in productLots) {
                                        if (productModel.prodModelId ==
                                            lot.prodModelId) {
                                          _amountOfProd +=
                                              int.parse(lot.amount!);
                                        }
                                      }
                                      var amountOfProd = _amountOfProd;
                                      return GestureDetector(
                                        onTap: () {},
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Container(
                                            height: 120,
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
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
                                                            Text(
                                                              '${index + 1}',
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .backgroundColor),
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .background,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10)),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        3.0),
                                                                child: Text(
                                                                  '${productModel.stProperty}',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          15,
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
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .background,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10)),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        3.0),
                                                                child: Text(
                                                                  '${productModel.ndProperty}',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Text(
                                                          'ต้นทุน ฿${NumberFormat("#,###,###.##").format(productModel.cost)}',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 12),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          'ราคาขาย ฿${NumberFormat("#,###,###.##").format(productModel.price)}',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 12),
                                                        ),
                                                        Text(
                                                          'น้ำหนัก ${NumberFormat("#,###,###.##").format(productModel.weight)} กรัม',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 12),
                                                        ),
                                                      ],
                                                    ),
                                                    const Spacer(),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .background,
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
                                                            Text('คงเหลือ ',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .white,
                                                                )),
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
                                                  ]),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              'จำนวนสินค้าทั้งหมด',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background
                                        .withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Text(
                                    '${NumberFormat("#,###").format(productModels.length)}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 200,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Colors.redAccent,
                              fixedSize: const Size(80, 40)),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('ยกเลิก')),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              fixedSize: const Size(80, 40)),
                          onPressed: () async {
                            _insertProduct(widget.shop);
                          },
                          child: Text('ยืนยัน')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
