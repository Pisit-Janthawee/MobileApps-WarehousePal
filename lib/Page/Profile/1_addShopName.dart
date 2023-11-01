import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:warehouse_mnmt/Page/Model/Profile.dart';
import 'package:warehouse_mnmt/db/database.dart';
import 'package:warehouse_mnmt/Page/Model/Shop.dart';
import 'package:warehouse_mnmt/Page/Profile/2._addShopPhone.dart';
import 'package:warehouse_mnmt/Page/Profile/AllShop.dart';
import 'package:warehouse_mnmt/main.dart';

class AddShopPage extends StatefulWidget {
  final Profile profile;
  const AddShopPage({
    required this.profile,
    Key? key,
  }) : super(key: key);

  @override
  State<AddShopPage> createState() => _AddShopPageState();
}

class _AddShopPageState extends State<AddShopPage> {
  List<Shop> shops = [];
  void initState() {
    super.initState();
    refreshAllShops();
  }

  Future refreshAllShops() async {
    shops = await DatabaseManager.instance.readAllShops();
    setState(() {});
  }

  Color primary_color = Color.fromRGBO(56, 48, 77, 1);
  Color txtFColor = Color.fromRGBO(56, 48, 77, 1.0);

  final profileNameController = TextEditingController();
  bool _validate = false;

  _Validation() {
    print('SHOP length : ${shops.length}');
    if (profileNameController.text.isEmpty ||
        profileNameController.text == null) {
      _validate = true;
    } else {
      _validate = false;
      if (shops.isNotEmpty) {
        var foundDupNameShop = shops.indexWhere(
          (shop) => shop.name == profileNameController.text.trim(),
        );
        if (foundDupNameShop == -1) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddShopPhonePage(
                    profile: widget.profile,
                    shopName: profileNameController.text.trim())

                // profileName: profileNameController.text,
                ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).backgroundColor,
              behavior: SnackBarBehavior.floating,
              content: Text(
                  "มีชื่อร้าน ${profileNameController.text.trim()} อยู่แล้ว"),
              duration: Duration(seconds: 1),
            ),
          );
        }

        // for (var shop in shops) {
        //   if (profileNameController.text.trim() == shop.name) {
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       SnackBar(
        //         backgroundColor: Theme.of(context).backgroundColor,
        //         behavior: SnackBarBehavior.floating,
        //         content: Text("มีชื่อร้าน ${shop.name} อยู่แล้ว"),
        //         duration: Duration(seconds: 1),
        //       ),
        //     );
        //   } else {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //           builder: (context) => AddShopPhonePage(
        //               profile: widget.profile,
        //               shopName: profileNameController.text.trim())

        //           // profileName: profileNameController.text,
        //           ),
        //     );
        //   }

        // }
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddShopPhonePage(
                  profile: widget.profile,
                  shopName: profileNameController.text.trim())

              // profileName: profileNameController.text,
              ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '1/4',
          style: TextStyle(fontSize: 15, color: Colors.grey),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          // ignore: prefer_const_literals_to_create_immutables
          colors: [
            Color.fromRGBO(29, 29, 65, 1.0),
            Color.fromRGBO(31, 31, 31, 1.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(
                height: 20,
              ),
              const Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  "เพิ่มร้านค้า",
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: txtFColor, borderRadius: BorderRadius.circular(15)),
                child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    textAlign: TextAlign.start,
                    keyboardType: TextInputType.text,

                    // maxLength: length,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(30),
                    ],
                    controller: profileNameController,
                    //-----------------------------------------------------

                    style: const TextStyle(color: Colors.white),
                    cursorColor: primary_color,
                    decoration: InputDecoration(
                      errorText: _validate
                          ? 'ชื่อร้านของคุณว่าง โปรดตั้งชื่อ'
                          : null, //here
                      errorStyle: TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 227, 67, 67)),
                      contentPadding: EdgeInsets.only(
                          top: 25, bottom: 10, left: 10, right: 10),
                      // labelText: title,
                      filled: true,
                      labelStyle: TextStyle(color: Colors.white),
                      counterStyle: TextStyle(color: Colors.white),
                      // fillColor: Theme.of(context).colorScheme.background,
                      focusColor: Color.fromARGB(255, 255, 0, 0),
                      hoverColor: Theme.of(context).colorScheme.surface,

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .surface
                              .withOpacity(0.9),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                      hintText: 'กำหนดชื่อร้านค้าของคุณ',
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 14),
                      // prefixIcon: const Icon(Icons.local_shipping, color: Colors.white),
                      suffixIcon: profileNameController.text.isEmpty
                          ? Container(
                              width: 0,
                            )
                          : IconButton(
                              onPressed: () => profileNameController.clear(),
                              icon: const Icon(
                                Icons.close_sharp,
                                color: Colors.white,
                              ),
                            ),
                    )),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(fixedSize: const Size(80, 40)),
                  onPressed: () {
                    _Validation();
                  },
                  child: Text('ถัดไป'))
            ]),
          ),
        ),
      ),
    );
  }
}
