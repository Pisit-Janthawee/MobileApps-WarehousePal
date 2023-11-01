import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:warehouse_mnmt/Page/Model/Dealer.dart';
import 'package:warehouse_mnmt/Page/Provider/theme_provider.dart';

import '../../../db/database.dart';
import '../../Model/Shop.dart';
import 'nav_create_dealer.dart';

class BuyingNavChooseDealer extends StatefulWidget {
  final Shop shop;
  final ValueChanged<DealerModel> update;

  const BuyingNavChooseDealer(
      {required this.shop, required this.update, Key? key})
      : super(key: key);
  @override
  State<BuyingNavChooseDealer> createState() => _buying_nav_chooseDealerState();
}

class _buying_nav_chooseDealerState extends State<BuyingNavChooseDealer> {
  @override
  void initState() {
    super.initState();
    refreshDealer();
  }

  _alertNullTextController(title) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        content: Text("${title} ว่าง"),
        duration: Duration(seconds: 3)));
  }

  Future<void> dialogEditDealer(DealerModel dealer) async {
    final nameController = TextEditingController(text: dealer.dName);
    final addressController = TextEditingController(text: dealer.dAddress);
    final phoneController = TextEditingController(text: dealer.dPhone);

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, DialogSetState) {
        nameController.addListener(() => DialogSetState(() {}));
        addressController.addListener(() => DialogSetState(() {}));
        phoneController.addListener(() => DialogSetState(() {}));
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.background,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          title: Container(
            width: 150,
            child: Row(
              children: [
                const Text(
                  'แก้ไขตัวแทนจำหน่าย',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
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
          content: SingleChildScrollView(
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      "ชื่อ",
                      style: TextStyle(fontSize: 15, color: Colors.white),
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
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(56, 48, 77, 1.0),
                    borderRadius: BorderRadius.circular(15)),
                width: 370,
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
                        style: TextStyle(fontSize: 15, color: Colors.white),
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
                width: 370,
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
                        nameController.text.isNotEmpty &&
                                addressController.text.isNotEmpty &&
                                phoneController.text.isNotEmpty == true
                            ? ElevatedButton(
                                onPressed: () async {
                                  if (nameController.text.isNotEmpty &&
                                      addressController.text.isNotEmpty &&
                                      phoneController.text.isNotEmpty) {
                                    final updatedDealer = dealer.copy(
                                        dName: nameController.text,
                                        dAddress: addressController.text,
                                        dPhone: phoneController.text);

                                    await DatabaseManager.instance
                                        .updateDealer(updatedDealer);

                                    Navigator.pop(context);
                                  } else if (nameController.text.isEmpty ||
                                      nameController.text == null ||
                                      nameController.text == '') {
                                    _alertNullTextController('ชื่อ');
                                  } else if (addressController.text.isEmpty ||
                                      addressController.text == null ||
                                      addressController.text == '') {
                                    _alertNullTextController('ที่อยู่');
                                  } else if (phoneController.text.isEmpty ||
                                      phoneController.text == null ||
                                      phoneController.text == '') {
                                    _alertNullTextController('เบอร์โทรศัพท์');
                                  }
                                },
                                child: Text(
                                  "บันทึก",
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
              ),
            ]),
          ),
        );
      }),
    );
  }

  List<DealerModel> dealers = [];
  Future refreshDealer() async {
    dealers =
        await DatabaseManager.instance.readAllDealers(widget.shop.shopid!);
    setState(() {});
  }

  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
        title: Column(
          children: [
            Text(
              "เลือกตัวแทนจำหน่าย",
              style: TextStyle(fontSize: 25),
            )
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => BuyingNavCreateDealer(
                            shop: widget.shop,
                          )));
              refreshDealer();
            },
            icon: Icon(Icons.add),
          )
        ],
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
          child: Column(children: [
            const SizedBox(height: 90),
            dealers.isEmpty
                ? Container()
                : Row(
                    children: [
                      const Spacer(),
                      Text(
                        'ทั้งหมด (${NumberFormat("#,###.##").format(dealers.length)})',
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      )
                    ],
                  ),
            dealers.isEmpty
                ? Container(
                    width: (MediaQuery.of(context).size.width),
                    height: (MediaQuery.of(context).size.height),
                    child: Center(
                        child: Text(
                      'ไม่มีตัวแทนจำหน่าย',
                      style: TextStyle(color: Colors.grey, fontSize: 25),
                    )),
                  )
                : Container(
                    width: (MediaQuery.of(context).size.width),
                    height: (MediaQuery.of(context).size.height),
                    child: RefreshIndicator(
                      onRefresh: refreshDealer,
                      child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: dealers.length,
                          itemBuilder: (context, index) {
                            final dealer = dealers[index];
                            return Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Dismissible(
                                background: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
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
                                ),
                                direction: DismissDirection.endToStart,
                                resizeDuration: Duration(seconds: 1),
                                key: Key(dealers[index].dName),
                                onDismissed: (direction) async {
                                  await DatabaseManager.instance
                                      .deleteDealer(dealer.dealerId!);
                                  refreshDealer();
                                  setState(() {});
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.redAccent,
                                    content:
                                        Text("ลบตัวแทนจำหน่าย ${dealer.dName}"),
                                    duration: Duration(seconds: 2),
                                  ));
                                },
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary:
                                          const Color.fromRGBO(56, 54, 76, 1.0),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15))),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    widget.update(dealer);
                                  },
                                  child: Container(
                                    child: Row(children: [
                                      Icon(Icons.person_pin_circle),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 230,
                                              child: Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(dealer.dName,
                                                        style: TextStyle(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            fontSize: 17,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.white)),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                      dealer.dPhone.replaceAllMapped(
                                                          RegExp(
                                                              r'(\d{3})(\d{3})(\d+)'),
                                                          (Match m) =>
                                                              "${m[1]}-${m[2]}-${m[3]}"),
                                                      style: TextStyle(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white)),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: 230,
                                              child: Text(
                                                  'ที่อยู่ ${dealer.dAddress}',
                                                  style: TextStyle(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontSize: 15,
                                                      color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // const Spacer(),
                                      IconButton(
                                          onPressed: () async {
                                            await dialogEditDealer(dealer);
                                            refreshDealer();
                                            setState(() {});
                                          },
                                          icon: Icon(Icons.edit))
                                    ]),
                                  ),
                                ),
                              ),
                            );
                            // Choose Customer Button;
                          }),
                    ),
                  ),
          ]),
        ),
      ),
    );
  }
}
