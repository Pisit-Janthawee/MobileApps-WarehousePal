import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warehouse_mnmt/Page/Model/Dealer.dart';
import 'package:warehouse_mnmt/Page/Provider/theme_provider.dart';
import 'package:warehouse_mnmt/db/database.dart';

import '../../Model/Shop.dart';

class BuyingNavCreateDealer extends StatefulWidget {
  final Shop shop;
  const BuyingNavCreateDealer({required this.shop, Key? key}) : super(key: key);

  @override
  State<BuyingNavCreateDealer> createState() => _BuyingNavCreateDealerState();
}

class _BuyingNavCreateDealerState extends State<BuyingNavCreateDealer> {
  // Text Field
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  bool _validateController = false;
  void initState() {
    super.initState();
    nameController.addListener(() => setState(() {}));
    addressController.addListener(() => setState(() {}));
    phoneController.addListener(() => setState(() {}));
  }

  // Text Field
  _alertNullTextController(title) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        content: Text("${title} ว่าง"),
        duration: Duration(seconds: 3)));
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
          title: Column(
            children: [
              Text(
                "เพิ่มตัวแทนจำหน่าย",
                style: TextStyle(fontSize: 25),
              )
            ],
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: (MediaQuery.of(context).size.height),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(20),
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
          child: Column(children: [
            const SizedBox(height: 90),
            // Text & Container Text Field of ชื่อ - นามสกุล
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    "ชื่อ",
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: const Color.fromRGBO(56, 48, 77, 1.0),
                  borderRadius: BorderRadius.circular(15)),
              width: 400,
              height: 70,
              child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  style: const TextStyle(color: Colors.white),
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'ชื่อตัวแทนจำหน่าย',
                    filled: true,
                    fillColor: const Color.fromRGBO(56, 48, 77, 1.0),
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide.none),
                    hintStyle:
                        const TextStyle(color: Colors.grey, fontSize: 14),
                    suffixIcon: nameController.text.isEmpty
                        ? Container(
                            width: 0,
                          )
                        : IconButton(
                            onPressed: () => nameController.clear(),
                            icon: const Icon(
                              Icons.close_sharp,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                  )),
            ),
            // Text & Container Text Field of ชื่อ - นามสกุล

            // Text & Container Text Field of ที่อยู่
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    " ที่อยู่               ",
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: const Color.fromRGBO(56, 48, 77, 1.0),
                  borderRadius: BorderRadius.circular(15)),
              width: 400,
              height: 100,
              child: SizedBox(
                height: 120,
                width: 100.0,
                child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.multiline,
                    maxLines: 10,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    controller: addressController,
                    decoration: InputDecoration(
                      hintText: 'ที่อยู่ตัวแทนจำหน่าย',
                      isDense: true,
                      contentPadding: EdgeInsets.all(8),
                      filled: true,
                      fillColor: const Color.fromRGBO(56, 48, 77, 1.0),
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide.none),
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 14),
                      suffixIcon: addressController.text.isEmpty
                          ? Container(
                              width: 0,
                            )
                          : IconButton(
                              onPressed: () => addressController.clear(),
                              icon: const Icon(
                                Icons.close_sharp,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                    )),
              ),
            ),
            // Text & Container Text Field of ที่อยู่

            // Text & Container Text Field of หมายเลขโทรศัพท์
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "หมายเลขเบอร์โทรศัพท์",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: const Color.fromRGBO(56, 48, 77, 1.0),
                  borderRadius: BorderRadius.circular(15)),
              width: 400,
              height: 70,
              child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'โปรดระบุ';
                    }
                    return null;
                  },
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                  ],
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  controller: phoneController,
                  decoration: InputDecoration(
                    hintText: 'เบอร์โทรศัพท์ตัวแทนจำหน่าย',
                    filled: true,
                    fillColor: const Color.fromRGBO(56, 48, 77, 1.0),
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide.none),
                    hintStyle:
                        const TextStyle(color: Colors.grey, fontSize: 14),
                    suffixIcon: phoneController.text.isEmpty
                        ? Container(
                            width: 0,
                          )
                        : IconButton(
                            onPressed: () => phoneController.clear(),
                            icon: const Icon(
                              Icons.close_sharp,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                  )),
            ),
            // Text & Container Text Field of หมายเลขโทรศัพท์

            // ยกเลิก Button
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Wrap(
                    spacing: 20,
                    children: [
                      ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(primary: Colors.redAccent),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "ยกเลิก",
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                      nameController.text.isNotEmpty &&
                              addressController.text.isNotEmpty &&
                              phoneController.text.isNotEmpty == true
                          ? ElevatedButton(
                              onPressed: () async {
                                if (nameController.text.isNotEmpty &&
                                    addressController.text.isNotEmpty &&
                                    phoneController.text.isNotEmpty) {
                                  final dealer = DealerModel(
                                      dName: nameController.text,
                                      dAddress: addressController.text,
                                      dPhone: phoneController.text,
                                      shopId: widget.shop.shopid);
                                  await DatabaseManager.instance
                                      .createDealer(dealer);

                                  Navigator.pop(context);
                                } else if (nameController.text.isEmpty) {
                                  _alertNullTextController('ชื่อ');
                                } else if (addressController.text.isEmpty) {
                                  _alertNullTextController('ที่อยู่');
                                } else if (phoneController.text.isEmpty) {
                                  _alertNullTextController('เบอร์โทรศัพท์');
                                }
                              },
                              child: Text(
                                "สร้าง",
                                style: TextStyle(fontSize: 17),
                              ),
                            )
                          : Container(
                              width: 0,
                            ),
                    ],
                  )
                ],
              ),
            )
            // บันทึก Button
          ]),
        ),
      ),
    );
  }
}
