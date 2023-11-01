import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:warehouse_mnmt/Page/Model/Product.dart';
import 'package:warehouse_mnmt/Page/Model/ProductCategory.dart';
import 'package:warehouse_mnmt/Page/Model/ProductLot.dart';
import 'package:warehouse_mnmt/Page/Model/ProductModel.dart';
import 'package:warehouse_mnmt/Page/Model/ProductModel_stProperty.dart';
import 'package:warehouse_mnmt/Page/Model/ProductModel_ndProperty.dart';
import 'package:warehouse_mnmt/Page/Model/Shop.dart';
import 'package:warehouse_mnmt/Page/Provider/theme_provider.dart';
import 'package:warehouse_mnmt/Page/Shop/Product/nav_editModel.dart';

import '../../../db/database.dart';
import '../../Component/ImagePickerController.dart';
import '../../Component/TextField/CustomTextField.dart';
import '../../Model/ProductModel_ndProperty.dart';

class ProductNavEdit extends StatefulWidget {
  final Shop shop;
  final Product product;
  final ProductCategory? prodCategory;

  const ProductNavEdit(
      {required this.product, this.prodCategory, required this.shop, Key? key})
      : super(key: key);

  @override
  State<ProductNavEdit> createState() => _ProductNavEditState();
}

class _ProductNavEditState extends State<ProductNavEdit> {
  ImagePickerController productImgController = ImagePickerController();
  late TextEditingController productNameController =
      TextEditingController(text: widget.product.prodName);
  late TextEditingController productDescriptionController =
      TextEditingController(text: widget.product.prodDescription);
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
  List<ProductModel> productModels = [];
  List<TextEditingController> amountControllers = [];
  List stPropertySelecteds = [];
  List ndPropertySelecteds = [];
  @override
  void initState() {
    super.initState();
    refreshProductCategorys();
    refreshPage();

    print(
        'Welcome to ${widget.shop.name} -> Product Categorys -> ${productCategorys.length}');
    productNameController.addListener(() => setState(() {}));
    productDescriptionController.addListener(() => setState(() {}));
    productCategoryNameController.addListener(() => setState(() {}));
    pController.addListener(() => setState(() {}));
    cController.addListener(() => setState(() {}));
  }

  bool _validate = false;
  bool isDialogChooseFst = false;
  bool isDelete_ndProp = false;
  File? _image;

  late String stPropName = productModels.isEmpty
      ? 'สี'
      : productModels[0].prodModelname.split(',')[0];
  late String ndPropName = productModels.isEmpty
      ? 'ขนาด'
      : productModels[0].prodModelname.split(',')[1];

  late var productCategory = widget.prodCategory;
  List<ProductCategory> productCategorys = [];
  List<ProductModel_stProperty> stPropsList = [];
  List<ProductModel_ndProperty> ndPropsList = [];
  List<ProductLot> productLots = [];

  Future refreshPage() async {
    productModels = await DatabaseManager.instance
        .readAllProductModelsInProduct(widget.product.prodId!);
    productLots = await DatabaseManager.instance.readAllProductLots();
// stPropsList = await DatabaseManager.instance.readAll1stProperty();
// ndPropsList = await DatabaseManager.instance.readAll2ndProperty();
    setState(() {});
  }

  bool isFoundNullCost = false;
  bool isFoundNullPrice = false;
  showSnackBarIfEmpty(object) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.redAccent,
      content: Text("${object} ว่าง"),
      duration: Duration(seconds: 3),
    ));
  }

  Future getImage(isChange) async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image == null) return;
    final imageTemporary = File(image.path);
    print(_image);
    print(_image.runtimeType);
    isChange = true;
    setState(() {
      _image = imageTemporary;
    });
  }

  Future _updateProduct(shop) async {
    final updatedProduct = widget.product.copy(
        prodName: productNameController.text.isEmpty
            ? widget.product.prodName
            : productNameController.text,
        prodDescription: productDescriptionController.text.isEmpty
            ? widget.product.prodDescription
            : productDescriptionController.text,
        prodImage: productImgController.path,
        prodCategId: productCategory?.prodCategId == null
            ? null
            : productCategory!.prodCategId,
        shopId: widget.shop.shopid!);

    await DatabaseManager.instance.updateProduct(updatedProduct);

    Navigator.pop(context);
  }

  // Product
  _checkNullPriceController() {
    var cIndex = 1;
    var pIndex = 1;
    for (var i in editCostControllers) {
      if (i.text.isEmpty) {
        print('Found Null in Cost -> ${i} ');
        isFoundNullCost = true;
        return cIndex;

        break;
      } else {
        cIndex++;
        isFoundNullCost = false;
      }
    }
    for (var i in editPriceControllers) {
      if (i.text.isEmpty) {
        print('Found Null in Price ->  ${i}');
        isFoundNullPrice = true;
        return pIndex;
        break;
      } else {
        pIndex++;
        isFoundNullPrice = false;
      }
    }
  }

  _addCostPriceInProdModel(stPropsList, ndPropsList) async {
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
            weight: double.parse(weightControllers[i].text),
            prodId: widget.product.prodId!);
        await DatabaseManager.instance.createProductModel(model);

        editCostControllers.add(TextEditingController());
        editPriceControllers.add(TextEditingController());
        weightControllers.add(TextEditingController());

        i++;
      } else {
        for (var nd in ndPropsList) {
          print('st ->${st.pmstPropName} nd -> ${nd.pmndPropName}');
          final model = ProductModel(
              prodModelname: '${stPropName},${ndPropName}',
              stProperty: '${st.pmstPropName}',
              ndProperty: '${nd.pmndPropName}',
              cost: int.parse(editCostControllers[i].text),
              price: int.parse(editPriceControllers[i].text),
              weight: double.parse(weightControllers[i].text),
              prodId: widget.product.prodId!);
          await DatabaseManager.instance.createProductModel(model);

          editCostControllers.add(TextEditingController());
          editPriceControllers.add(TextEditingController());
          weightControllers.add(TextEditingController());

          i++;
        }
      }
    }
  }

  showAlertDeleteProductModel(ProductModel model) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)), //this right here
            child: SizedBox(
              width: 300,
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          // Theme.of(context).colorScheme.background
                          // color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(15)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_forever,
                            color: Colors.white,
                            size: 25,
                          ),
                          Text(
                            'ลบรูปแบบสินค้า ${model.stProperty} ${model.ndProperty} ?',
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 20,
                              // fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                fixedSize: const Size(80, 40)),
                            onPressed: () async {
                              if (model.prodModelId != null) {
                                await DatabaseManager.instance
                                    .deleteProductModel(model.prodModelId!);
                                Navigator.pop(context);
                                refreshPage();
                              } else {
                                productModels.remove(model);
                                Navigator.pop(context);
                              }
                            },
                            child: Text('ลบ')),
                        const SizedBox(
                          width: 20,
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.redAccent,
                                fixedSize: const Size(80, 40)),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('ยกเลิก')),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  _addTempProductModel(stPropsList, ndPropsList) {
    for (var st in stPropsList) {
      if (ndPropsList.isNotEmpty) {
        for (var nd in ndPropsList) {
          print('st ->${st.pmstPropName} nd -> ${nd.pmndPropName}');
          final model = ProductModel(
              prodModelname: '${stPropName},${ndPropName}',
              stProperty: '${st.pmstPropName}',
              ndProperty: '${nd.pmndPropName}',
              cost: 0,
              weight: 0,
              price: 0);
          productModels.add(model);
          editCostControllers.add(TextEditingController());
          editPriceControllers.add(TextEditingController());
          print(' Add [${model.prodModelname}]');
          print(' Add [${productModels}]');
        }
      } else {
        final model = ProductModel(
            prodModelname: '${st.pmstPropName}',
            stProperty: '${st.pmstPropName}',
            cost: 0,
            weight: 0,
            price: 0);
        productModels.add(model);
        editCostControllers.add(TextEditingController());
        editPriceControllers.add(TextEditingController());
      }
    }

    setState(() {});
  }

  // Product Model
  Future refreshProductCategorys() async {
    productCategorys = await DatabaseManager.instance
        .readAllProductCategorys(widget.shop.shopid!);
    setState(() {});
  }

  // Product
  _updateChooseProductCateg(ProductCategory _productCategory) {
    setState(() {
      productCategory = _productCategory;
    });
  }

  //_showSet_CostPrice_Product_Dialog
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

  _showSet_CostPrice_Product_Dialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext dContext2) {
          return StatefulBuilder(builder: (dContext2, DialogSetState) {
            return Dialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                                                                '${index + 1}',
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
                                                                        .primary,
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
                                                                        .primary,
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
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      Container(
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10)),
                                                                    child: CustomTextField
                                                                        .textField(
                                                                      context,
                                                                      'ต้นทุน',
                                                                      _validate,
                                                                      length:
                                                                          10,
                                                                      isNumber:
                                                                          true,
                                                                      textController:
                                                                          editCostControllers[
                                                                              index],
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      Container(
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10)),
                                                                    child: CustomTextField
                                                                        .textField(
                                                                      context,
                                                                      'ขาย',
                                                                      _validate,
                                                                      isNumber:
                                                                          true,
                                                                      length:
                                                                          10,
                                                                      textController:
                                                                          editPriceControllers[
                                                                              index],
                                                                    ),
                                                                  ),
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

  Future<void> _showEdit_PropName_Dialog(
      TextEditingController controller) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, Edit_st_PropDialogSetState) {
          return AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            title: const Text(
              'แก้ไข',
              style: TextStyle(color: Colors.white),
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

  createProductModeltoSetPrice(stPropsList, ndPropsList) {
    for (var st in stPropsList) {
      if (ndPropsList.isNotEmpty) {
        for (var nd in ndPropsList) {
          final model = ProductModel(
              prodModelname: '${stPropName},${ndPropName}',
              stProperty: '${st.pmstPropName}',
              ndProperty: '${nd.pmndPropName}',
              cost: 0,
              weight: 0,
              price: 0);
          productModels.add(model);
          editCostControllers.add(TextEditingController());
          editPriceControllers.add(TextEditingController());
        }
      } else {
        final model = ProductModel(
            prodModelname: '${stPropName}',
            stProperty: '${st.pmstPropName}',
            ndProperty: '',
            cost: 0,
            weight: 0,
            price: 0);
        productModels.add(model);
        editCostControllers.add(TextEditingController());
        editPriceControllers.add(TextEditingController());
      }
    }

    setState(() {});
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
                onPressed: () async {
                  if (controller.text.isEmpty || controller == null) {
                  } else {
                    isDialogChooseFst == true
                        ? stPropName = controller.text
                        : ndPropName = controller.text;
                    for (var model in productModels) {
                      var updatedProductModel = model.copy(
                          prodModelname: '${stPropName},${ndPropName}');
                      await DatabaseManager.instance
                          .updateProductModel(updatedProductModel);
                    }
                    Navigator.of(context).pop();
                  }
                  Edit_st_PropDialogSetState(() {});
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
                                                                              'ราคา',
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

  _createProductModeltoSetPrice(stPropsList, ndPropsList) {
    for (var st in stPropsList) {
      if (ndPropsList.isNotEmpty) {
        for (var nd in ndPropsList) {
          final model = ProductModel(
              prodModelname: '${stPropName},${ndPropName}',
              stProperty: '${st.pmstPropName}',
              ndProperty: '${nd.pmndPropName}',
              cost: 0,
              weight: 0,
              price: 0);
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
            weight: 0,
            price: 0);
        productModels.add(model);
        editCostControllers.add(TextEditingController());
        editPriceControllers.add(TextEditingController());
        weightControllers.add(TextEditingController());
      }
    }

    setState(() {});
  }

  showProductCategoryDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (prodCategContext, DialogSetState) {
            return Dialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                              // IconButton(
                              //   icon: const Icon(
                              //     Icons.add_rounded,
                              //     color: Colors.white,
                              //     size: 25,
                              //   ),
                              //   onPressed: () {},
                              // ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10)),
                              height: 60,
                              width: 200,
                              child: CustomTextField.textField(
                                context,
                                'เช่น เสื้อ กางเกง...',
                                _validate,
                                length: 20,
                                textController: productCategoryNameController,
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
                                      content: Text("โปรดตั้งชื่อประเภทสินค้า"),
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
                        productCategorys.isEmpty
                            ? Container(
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background
                                        .withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(10)),
                                height: 200,
                                child: Expanded(
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
                                ),
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
                                      return GestureDetector(
                                        onTap: () {
                                          _updateChooseProductCateg(
                                              productCategory);

                                          Navigator.pop(context);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .backgroundColor,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Row(children: [
                                                Text(
                                                  productCategory.prodCategName,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                const Spacer(),
                                                IconButton(
                                                    onPressed: () async {
                                                      await DatabaseManager
                                                          .instance
                                                          .deleteProductCategory(
                                                              productCategory
                                                                  .prodCategId!);
                                                      DialogSetState(() {
                                                        refreshProductCategorys();
                                                      });
                                                    },
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      color: Colors.white,
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
            actions: [
              PopupMenuButton<int>(
                color: Theme.of(context).appBarTheme.backgroundColor,
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
                              'ต้องการลบสินค้า ?',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
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
                                  await DatabaseManager.instance
                                      .deleteProduct(widget.product.prodId!);

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
                          "ลบสินค้า",
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ],
                offset: Offset(0, 80),
                elevation: 2,
              ),
            ],
            title: const Text(
              "แก้ไขสินค้า",
              textAlign: TextAlign.start,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
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
              padding: const EdgeInsets.only(
                  top: 110, left: 10.0, right: 10.0, bottom: 10.0),
              child: Wrap(
                alignment: WrapAlignment.center,
                runSpacing: 10,
                children: [
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
                      child: Stack(
                        children: [
                          if (_image != null)
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(
                                  _image!,
                                  width: 180,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          else
                            Center(
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
                          Positioned(
                            top: 0.0,
                            right: 0.0,
                            child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.7),
                                        spreadRadius: 0,
                                        blurRadius: 5,
                                        offset: Offset(0, 4))
                                  ],
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 25,
                                      color: Color.fromARGB(255, 94, 94, 94)),
                                  onPressed: () async {
                                    // await getImage(isChange);
                                    // DialogSetState(() {
                                    //   isChange = !isChange;
                                    // });
                                    // if (_image!.path != null) {}
                                  },
                                )),
                          ),
                        ],
                      ),
                    ),
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
                    widget.product.prodName,
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
                    onTap: () {
                      showProductCategoryDialog();
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
                          productCategory?.prodCategName == null
                              ? 'ไม่มีหมวดหมู่สินค้า'
                              : productCategory!.prodCategName,
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
                    widget.product.prodDescription == null ||
                            widget.product.prodDescription == ''
                        ? 'เพิ่มรายละเอียดสินค้า'
                        : widget.product.prodDescription!,
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
                              onPressed: () async {
                                for (var model in productModels) {
                                  await DatabaseManager.instance
                                      .deleteProductModel(model.prodModelId!);
                                }
                                refreshPage();
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
                          onPressed: () async {
                            await dialogProductModel();
                            refreshPage();
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
                    width: 400,
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
                                          _amountOfProd += lot.remainAmount!;
                                        }
                                      }
                                      var amountOfProd = _amountOfProd;
                                      return Dismissible(
                                        key: UniqueKey(),
                                        onDismissed: (direction) async {
                                          // await DatabaseManager.instance
                                          //     .deleteProduct(product.prodId!);
                                          showAlertDeleteProductModel(
                                              productModel);
                                          refreshPage();
                                          setState(() {});
                                        },
                                        direction: DismissDirection.endToStart,
                                        resizeDuration: Duration(seconds: 1),
                                        background: Container(
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
                                            margin: EdgeInsets.only(
                                                left: 0,
                                                top: 10,
                                                right: 10,
                                                bottom: 10),
                                            decoration: BoxDecoration(
                                                color: Colors.redAccent,
                                                borderRadius:
                                                    BorderRadius.circular(10))),
                                        child: GestureDetector(
                                          onTap: () async {
                                            await Navigator.push(
                                                context,
                                                new MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProductEditModel(
                                                          model: productModel,
                                                        )));
                                            refreshPage();

                                            setState(() {});
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  height: 120,
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
                                                                    fontSize:
                                                                        15,
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
                                                                        BorderRadius.circular(
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
                                                                        BorderRadius.circular(
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
                                                      Spacer(),
                                                      amountOfProd == 0
                                                          ? Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .numbers_outlined,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                Text(
                                                                    'สินค้าหมด ',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      color: Colors
                                                                          .white,
                                                                    )),
                                                              ],
                                                            )
                                                          : Container(
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
                                                                        5.0),
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                        'คงเหลือ ',
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          color:
                                                                              Colors.white,
                                                                        )),
                                                                    Text(
                                                                        '${NumberFormat("#,###.##").format(amountOfProd)}',
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                15,
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold)),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                    ]),
                                                  ),
                                                ),
                                                productModel.prodModelId == null
                                                    ? Positioned(
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
                                                                  blurRadius: 5,
                                                                  offset:
                                                                      Offset(
                                                                          0, 4))
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
                                                            'รูปแบบใหม่',
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      )
                                                    : Container()
                                              ],
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
                            _updateProduct(widget.shop);
                          },
                          child: Text('บันทึก')),
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
