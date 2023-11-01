import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:warehouse_mnmt/Page/Component/change_theme_btn.dart';
import 'package:warehouse_mnmt/Page/Model/DeliveryCompany.dart';

import 'package:warehouse_mnmt/Page/Provider/theme_provider.dart';
import 'package:warehouse_mnmt/Page/Shop/Buying/nav_edit_deliveryCompany.dart';

import 'package:warehouse_mnmt/main.dart';

import '../../db/database.dart';
import '../Component/Dialog/EditShopDialog.dart';
import '../Model/Shop.dart';

class ShopPage extends StatefulWidget {
  final Shop shop;
  final Profile;
  const ShopPage({required this.Profile, required this.shop, Key? key})
      : super(key: key);

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  late final shopNameController = TextEditingController(text: widget.shop.name);
  late final shopPhoneController =
      TextEditingController(text: widget.shop.phone);
  bool _validate = false;
  File? _image;
  bool isChange = false;
  Shop? shop;
  ThemeMode themeMode = ThemeMode.dark;
  DeliveryCompanyModel? company;

  @override
  void initState() {
    refreshShop();
    shop = widget.shop;

    super.initState();
    shopNameController.addListener(() => setState(() {}));
    shopPhoneController.addListener(() => setState(() {}));
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

  Future refreshShop() async {
    shop = await DatabaseManager.instance.readShop(widget.shop.shopid!);
    company = await DatabaseManager.instance
        .readDeliveryCompanysOnlyOne(widget.shop.dcId!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Future updateShop() async {
      final shop = widget.shop.copy(
          name: shopNameController.text.isEmpty
              ? widget.shop.name
              : shopNameController.text,
          phone: shopPhoneController.text.isEmpty
              ? widget.shop.phone
              : shopPhoneController.text,
          image: _image?.path == null ? widget.shop.image : _image!.path);
      await DatabaseManager.instance.updateShop(shop);
    }

    final themeProvider = Provider.of<ThemeProvider>(context);

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: AppBar(
            backgroundColor: themeProvider.isDark
                ? Theme.of(context).colorScheme.onSecondary
                : Theme.of(context).appBarTheme.backgroundColor,
            automaticallyImplyLeading: false,
            actions: [
              PopupMenuButton<int>(
                color: Theme.of(context).appBarTheme.backgroundColor,
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: () {
                      Future.delayed(
                        const Duration(seconds: 0),
                        () => showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                  builder: (context, DialogSetState) {
                                return Dialog(
                                  backgroundColor: Theme.of(context)
                                      .appBarTheme
                                      .backgroundColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          30.0)), //this right here
                                  child: SizedBox(
                                    height: 400,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  // color: Theme.of(context).colorScheme.background,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15)),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: const [
                                                  Icon(
                                                    Icons.edit,
                                                    color: Colors.white,
                                                    size: 30,
                                                  ),
                                                  Text(
                                                    'แก้ไขร้านค้า',
                                                    style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 255, 255, 255),
                                                      fontSize: 25,
                                                      // fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              height: 200,
                                              width: 200,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              child: Stack(
                                                children: [
                                                  if (_image != null)
                                                    Center(
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
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
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        child: Image.file(
                                                          File(widget
                                                              .shop.image),
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
                                                        decoration:
                                                            BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.7),
                                                                spreadRadius: 0,
                                                                blurRadius: 5,
                                                                offset: Offset(
                                                                    0, 4))
                                                          ],
                                                          color: Color.fromARGB(
                                                              255,
                                                              255,
                                                              255,
                                                              255),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                        ),
                                                        child: IconButton(
                                                          icon: const Icon(
                                                              Icons
                                                                  .add_photo_alternate_outlined,
                                                              size: 25,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      94,
                                                                      94,
                                                                      94)),
                                                          onPressed: () async {
                                                            await getImage(
                                                                isChange);
                                                            DialogSetState(() {
                                                              isChange =
                                                                  !isChange;
                                                            });
                                                          },
                                                        )),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .background
                                                        .withOpacity(0.9),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                width: 400,
                                                height: 80,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: TextFormField(
                                                      textAlign:
                                                          TextAlign.start,
                                                      keyboardType:
                                                          TextInputType.text,
                                                      // maxLength: length,
                                                      inputFormatters: [
                                                        LengthLimitingTextInputFormatter(
                                                            30),
                                                      ],
                                                      controller:
                                                          shopNameController,
                                                      //-----------------------------------------------------
                                                      onFieldSubmitted:
                                                          (context) {
                                                        DialogSetState(() {
                                                          isChange = true;
                                                          print(isChange);
                                                        });
                                                      },
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                      cursorColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .background,
                                                      decoration:
                                                          InputDecoration(
                                                        errorText: _validate
                                                            ? 'โปรดระบุ'
                                                            : null, //
                                                        contentPadding:
                                                            EdgeInsets.only(
                                                                top: 25,
                                                                bottom: 10,
                                                                left: 10,
                                                                right: 10),
                                                        // labelText: title,
                                                        filled: true,
                                                        labelStyle: TextStyle(
                                                            color:
                                                                Colors.white),
                                                        counterStyle: TextStyle(
                                                            color:
                                                                Colors.white),
                                                        // fillColor: Theme.of(context).colorScheme.background,
                                                        focusColor:
                                                            Color.fromARGB(
                                                                255, 255, 0, 0),
                                                        hoverColor:
                                                            Colors.white,

                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                            Radius.circular(
                                                                10.0),
                                                          ),
                                                          borderSide:
                                                              BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .surface,
                                                          ),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15.0),
                                                          borderSide:
                                                              const BorderSide(
                                                            color: Colors
                                                                .transparent,
                                                          ),
                                                        ),
                                                        disabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15.0),
                                                          borderSide:
                                                              BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .surface,
                                                          ),
                                                        ),
                                                        hintText:
                                                            widget.shop.name,
                                                        hintStyle:
                                                            const TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 14),
                                                        prefixIcon: const Icon(
                                                            Icons.person_pin,
                                                            color:
                                                                Colors.white),
                                                        suffixIcon:
                                                            shopNameController
                                                                    .text
                                                                    .isEmpty
                                                                ? Container(
                                                                    width: 0,
                                                                  )
                                                                : IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      shopNameController
                                                                          .clear();
                                                                      if (shopPhoneController
                                                                              .text
                                                                              .isNotEmpty ||
                                                                          _image !=
                                                                              null) {
                                                                        DialogSetState(
                                                                            () {
                                                                          isChange =
                                                                              true;
                                                                        });
                                                                      } else {
                                                                        DialogSetState(
                                                                            () {
                                                                          isChange =
                                                                              false;
                                                                        });
                                                                      }
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
                                                )),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .background
                                                        .withOpacity(0.9),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                width: 400,
                                                height: 80,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: TextFormField(
                                                      textAlign:
                                                          TextAlign.start,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      // maxLength: 10,
                                                      inputFormatters: [
                                                        LengthLimitingTextInputFormatter(
                                                            10),
                                                        FilteringTextInputFormatter
                                                            .digitsOnly
                                                      ],
                                                      controller:
                                                          shopPhoneController,
                                                      //-----------------------------------------------------
                                                      onFieldSubmitted:
                                                          (context) {
                                                        DialogSetState(() {
                                                          isChange = true;
                                                        });
                                                      },
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                      cursorColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .background,
                                                      decoration:
                                                          InputDecoration(
                                                        errorText: _validate
                                                            ? 'โปรดระบุ'
                                                            : null, //
                                                        contentPadding:
                                                            EdgeInsets.only(
                                                                top: 25,
                                                                bottom: 10,
                                                                left: 10,
                                                                right: 10),
                                                        // labelText: title,
                                                        filled: true,
                                                        labelStyle: TextStyle(
                                                            color:
                                                                Colors.white),
                                                        counterStyle: TextStyle(
                                                            color:
                                                                Colors.white),
                                                        // fillColor: Theme.of(context).colorScheme.background,
                                                        focusColor:
                                                            Color.fromARGB(
                                                                255, 255, 0, 0),
                                                        hoverColor:
                                                            Colors.white,

                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                            Radius.circular(
                                                                10.0),
                                                          ),
                                                          borderSide:
                                                              BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .surface,
                                                          ),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15.0),
                                                          borderSide:
                                                              const BorderSide(
                                                            color: Colors
                                                                .transparent,
                                                          ),
                                                        ),
                                                        disabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15.0),
                                                          borderSide:
                                                              BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .surface,
                                                          ),
                                                        ),
                                                        hintText:
                                                            widget.shop.phone,
                                                        hintStyle:
                                                            const TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 14),
                                                        prefixIcon: const Icon(
                                                            Icons.phone_in_talk,
                                                            color:
                                                                Colors.white),
                                                        suffixIcon:
                                                            shopPhoneController
                                                                    .text
                                                                    .isEmpty
                                                                ? Container(
                                                                    width: 0,
                                                                  )
                                                                : IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      shopPhoneController
                                                                          .clear();
                                                                      if (shopNameController
                                                                              .text
                                                                              .isNotEmpty ||
                                                                          _image !=
                                                                              null) {
                                                                        DialogSetState(
                                                                            () {
                                                                          isChange =
                                                                              true;
                                                                        });
                                                                      } else {
                                                                        DialogSetState(
                                                                            () {
                                                                          isChange =
                                                                              false;
                                                                        });
                                                                      }
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
                                                )),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                isChange == true
                                                    ? ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                fixedSize:
                                                                    const Size(
                                                                        80,
                                                                        40)),
                                                        onPressed: () {
                                                          updateShop();
                                                          shopNameController
                                                              .clear();
                                                          shopPhoneController
                                                              .clear();
                                                          Navigator.pop(
                                                              context);
                                                          DialogSetState(() {
                                                            refreshShop();
                                                            isChange = false;
                                                          });
                                                        },
                                                        child: Text('บันทึก'))
                                                    : Container(
                                                        width: 0,
                                                      ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            primary: Colors
                                                                .redAccent,
                                                            fixedSize:
                                                                const Size(
                                                                    80, 40)),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('ยกเลิก')),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              });
                            }),
                      );
                    },
                    value: 1,
                    // row has two child icon and text
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(
                          // sized box with width 10
                          width: 10,
                        ),
                        Text(
                          "แก้ไขร้าน",
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      Future.delayed(
                        const Duration(seconds: 0),
                        () => showDialog(
                          context: context,
                          builder: (context) => StatefulBuilder(
                              builder: (context, menuDialogSetState) {
                            return AlertDialog(
                              backgroundColor:
                                  Theme.of(context).appBarTheme.backgroundColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0)),
                              title: Container(
                                width: 150,
                                child: Row(
                                  children: [
                                    const Text(
                                      'ธีม',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                    ChangeThemeButtonWidget(
                                        profile: widget.Profile),
                                    Spacer(),
                                    IconButton(
                                        onPressed: (() {
                                          Navigator.pop(context);
                                        }),
                                        icon: Icon(
                                          Icons.close,
                                          color: Colors.grey,
                                        ))
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    },
                    value: 2,
                    // row has two child icon and text
                    child: Row(
                      children: [
                        Icon(Icons.color_lens),
                        SizedBox(
                          // sized box with width 10
                          width: 10,
                        ),
                        Text(
                          "ธีม",
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    value: 2,
                    // row has two child icon and text
                    child: Row(
                      children: [
                        Icon(Icons.exit_to_app),
                        SizedBox(
                          // sized box with width 10
                          width: 10,
                        ),
                        Text(
                          "ออกจากร้าน",
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
            title: Text(
              "ร้านของฉัน",
              textAlign: TextAlign.start,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            height: (MediaQuery.of(context).size.height),
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
              child: Column(
                children: [
                  const SizedBox(
                    height: 90,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 0, top: 10, right: 10, bottom: 0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            File(shop!.image),
                            width: (MediaQuery.of(context).size.width / 2),
                            height: (MediaQuery.of(context).size.width / 2),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                        color: themeProvider.isDark
                            ? Theme.of(context)
                                .colorScheme
                                .background
                                .withOpacity(1.0)
                            : Color.fromRGBO(10, 10, 10, 1.0),
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('ชื่อร้าน',
                              style: TextStyle(color: Colors.white)),
                          const SizedBox(
                            width: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(shop!.name,
                                        style: TextStyle(color: Colors.grey)),
                                  )
                                ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                        color: themeProvider.isDark
                            ? Theme.of(context)
                                .colorScheme
                                .background
                                .withOpacity(1.0)
                            : Color.fromRGBO(10, 10, 10, 1.0),
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('เบอร์โทรศัพท์',
                              style: TextStyle(color: Colors.white)),
                          const SizedBox(
                            width: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                        shop!.phone.replaceAllMapped(
                                            RegExp(r'(\d{3})(\d{3})(\d+)'),
                                            (Match m) =>
                                                "${m[1]}-${m[2]}-${m[3]}"),
                                        style: TextStyle(color: Colors.grey)),
                                  )
                                ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => EditShippingPage(
                                    shop: widget.shop!,
                                    company: company!,
                                  )));
                      refreshShop();
                    },
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                          color: themeProvider.isDark
                              ? Theme.of(context)
                                  .colorScheme
                                  .background
                                  .withOpacity(1.0)
                              : Color.fromRGBO(10, 10, 10, 1.0),
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(Icons.settings, color: Colors.white),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text('ตั้งค่าอัตราการขนส่ง',
                                        style: TextStyle(color: Colors.white)),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(' ${company?.dcName}',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: Colors.grey)),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                  ]),
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
        ),
      ),
    );
  }
}
