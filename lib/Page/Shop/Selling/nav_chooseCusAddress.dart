import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Components ?
import 'package:warehouse_mnmt/Page/Component/styleButton.dart';
import 'package:warehouse_mnmt/Page/Model/Customer.dart';
import 'package:warehouse_mnmt/Page/Model/CustomerAdress.dart';
import 'package:warehouse_mnmt/db/database.dart';

import '../../Component/TextField/CustomTextField.dart';
import '../../Model/Shop.dart';
import '../../Provider/theme_provider.dart';

class SellingNavCreateCustomerAddress extends StatefulWidget {
  final CustomerModel customer;
  final ValueChanged<CustomerAddressModel> update;
  const SellingNavCreateCustomerAddress(
      {required this.customer, required this.update, Key? key})
      : super(key: key);

  @override
  State<SellingNavCreateCustomerAddress> createState() =>
      _SellingNavCreateCustomerAddressState();
}

class _SellingNavCreateCustomerAddressState
    extends State<SellingNavCreateCustomerAddress> {
  // Text Field
  final cusPhoneController = TextEditingController();
  final cusAddressController = TextEditingController();
  List<CustomerAddressModel> cusAddresses = [];
  late CustomerModel customer = widget.customer;
  void initState() {
    super.initState();
    cusPhoneController.addListener(() => setState(() {}));
    cusAddressController.addListener(() => setState(() {}));
    refreshCustomerAddresses();
  }

  bool _validate = false;
  Future refreshCustomerAddresses() async {
    cusAddresses = await DatabaseManager.instance
        .readCustomerAllAddress(widget.customer.cusId!);
    setState(() {});
  }

  Future refreshCustomerInfo() async {
    customer =
        await DatabaseManager.instance.readCustomer(widget.customer.cusId!);
    setState(() {});
  }

  _alertNullDialog(title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        content: Text("โปรดระบุ ${title}"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> dialogCreateCusAddress(TextEditingController pController,
      TextEditingController addressController) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dContext, DialogSetState) {
          return AlertDialog(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            title: Container(
              width: 150,
              child: Row(
                children: [
                  const Text(
                    'เพิ่มที่อยู่',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  CustomTextField.textField(
                    dContext,
                    'ระบุเบอร์โทรศัพท์',
                    isNumber: true,
                    _validate,
                    length: 10,
                    textController: pController,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  CustomTextField.textField(
                    dContext,
                    'ระบุที่อยู่',
                    _validate,
                    length: 200,
                    textController: addressController,
                  )
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('เพิ่ม'),
                onPressed: () async {
                  if (pController.text.isEmpty ||
                      pController.text == null ||
                      pController.text == '') {
                    _alertNullDialog('เบอร์โทรศัพท์');
                  } else if (addressController.text.isEmpty ||
                      addressController.text == null ||
                      addressController.text == '') {
                    _alertNullDialog('ที่อยู่');
                  } else {
                    final address = CustomerAddressModel(
                        cAddress: addressController.text,
                        cPhone: pController.text,
                        cusId: widget.customer.cusId!);
                    await DatabaseManager.instance
                        .createCustomerAddress(address);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Theme.of(context).backgroundColor,
                        behavior: SnackBarBehavior.floating,
                        content: Text("เพิ่มที่อยู่"),
                        duration: Duration(seconds: 2),
                      ),
                    );

                    Navigator.of(dContext).pop();
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> dialogEditCusAddress(CustomerAddressModel address) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dContext, DialogSetState) {
          final eCusPhoneController =
              TextEditingController(text: address.cPhone);
          final eCusAddressController =
              TextEditingController(text: address.cAddress);
          return AlertDialog(
            backgroundColor: Theme.of(dContext).appBarTheme.backgroundColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            title: Container(
              width: 150,
              child: Row(
                children: [
                  const Text(
                    'แก้ไขที่อยู่',
                    style: TextStyle(color: Colors.white),
                  ),
                  Spacer(),
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey,
                      ))
                ],
              ),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  CustomTextField.textField(
                    dContext,
                    'โปรดระบุเบอร์โทรศัพท์',
                    isNumber: true,
                    _validate,
                    length: 10,
                    textController: eCusPhoneController,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  CustomTextField.textField(
                    dContext,
                    'โปรดระบุที่อยู่',
                    _validate,
                    length: 200,
                    textController: eCusAddressController,
                  )
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('บันทึก'),
                onPressed: () async {
                  if (eCusPhoneController.text.isEmpty ||
                      eCusPhoneController.text == null ||
                      eCusPhoneController.text == '') {
                    _alertNullDialog('เบอร์โทรศัพท์');
                  } else if (eCusAddressController.text.isEmpty ||
                      eCusAddressController.text == null ||
                      eCusAddressController.text == '') {
                    _alertNullDialog('ที่อยู่');
                  } else {
                    final newAddress = CustomerAddressModel(
                        cAddreId: address.cAddreId,
                        cAddress: eCusAddressController.text,
                        cPhone: eCusPhoneController.text,
                        cusId: widget.customer.cusId!);
                    await DatabaseManager.instance
                        .updateCustomerAddress(newAddress);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Theme.of(context).backgroundColor,
                        behavior: SnackBarBehavior.floating,
                        content: Text("อัพเดต"),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    Navigator.of(dContext).pop();
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> dialogEditCusName() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dContext, DialogSetState) {
          final CusNameController = TextEditingController(text: customer.cName);
          return AlertDialog(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            title: Container(
              width: 150,
              child: Row(
                children: [
                  const Text(
                    'แก้ไขชื่อ',
                    style: TextStyle(color: Colors.white),
                  ),
                  Spacer(),
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey,
                      ))
                ],
              ),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  CustomTextField.textField(
                    dContext,
                    '${customer.cName}',
                    isNumber: true,
                    _validate,
                    length: 30,
                    textController: CusNameController,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('บันทึก'),
                onPressed: () async {
                  await DatabaseManager.instance.updateCustomer(
                      customer.copy(dName: CusNameController.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).backgroundColor,
                      behavior: SnackBarBehavior.floating,
                      content: Text("อัพเดต"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  refreshCustomerInfo();
                  refreshCustomerAddresses();

                  Navigator.of(dContext).pop();
                },
              ),
            ],
          );
        });
      },
    );
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
                "ลูกค้า",
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
          child: Column(children: [
            SizedBox(height: 90),
            // Text & Container Text Field of ชื่อ - นามสกุล
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_pin_circle,
                  size: 25,
                ),
                Text(
                  'คุณ ${customer.cName}',
                  style: TextStyle(fontSize: 25),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0, primary: Colors.transparent),
                  onPressed: () {
                    dialogEditCusName();
                  },
                  child: Icon(Icons.edit,
                      color: themeProvider.isDark
                          ? Colors.white
                          : Color.fromRGBO(14, 14, 14, 1.0)),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 10,
                ),
                Text(
                  'รายการที่อยู่ (${cusAddresses.length})',
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.all(5),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(15)),
              width: 400,
              height: (MediaQuery.of(context).size.height),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'เลือกที่อยู่',
                          style: TextStyle(fontSize: 20),
                        ),
                        Spacer(),
                        ElevatedButton(
                          onPressed: () async {
                            await dialogCreateCusAddress(
                                cusPhoneController, cusAddressController);
                            refreshCustomerAddresses();
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 25,
                              ),
                              Text(
                                'เพิ่ม',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    cusAddresses.isEmpty
                        ? Container(
                            height: (MediaQuery.of(context).size.height * 0.5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15)),
                            child: Center(
                              child: Text(
                                'ไม่มีที่อยู่',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 25),
                              ),
                            ))
                        : Container(
                            decoration: BoxDecoration(
                                // color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(15)),
                            height: 400,
                            child: ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: cusAddresses.length,
                                itemBuilder: (context, index) {
                                  final addresss = cusAddresses[index];

                                  return Dismissible(
                                    key: UniqueKey(),
                                    onDismissed: (direction) async {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.redAccent,
                                        content: Container(
                                            child: Row(
                                          children: [
                                            Text(" ลบที่อยู่"),
                                            Text(
                                              ' ${addresss.cAddress}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        )),
                                        duration: Duration(seconds: 5),
                                      ));
                                      cusAddresses.remove(addresss);
                                      await DatabaseManager.instance
                                          .deleteCustomerAddress(
                                              addresss.cAddreId!);
                                      refreshCustomerAddresses();
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
                                    direction: DismissDirection.endToStart,
                                    resizeDuration: Duration(seconds: 1),
                                    child: TextButton(
                                      onPressed: () {
                                        widget.update(addresss);
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 0.0, horizontal: 0.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                            height: 80,
                                            color: themeProvider.isDark
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Color.fromRGBO(
                                                    10, 10, 10, 1.0),
                                            child: Row(
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Row(
                                                        children: [
                                                          Text(
                                                            customer.cName,
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            addresss.cPhone
                                                                .replaceAllMapped(
                                                                    RegExp(
                                                                        r'(\d{3})(\d{3})(\d+)'),
                                                                    (Match m) =>
                                                                        "${m[1]}-${m[2]}-${m[3]}"),
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ],
                                                      ),
                                                      Column(
                                                        children: [
                                                          Text(
                                                              addresss.cAddress,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize:
                                                                      12)),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Spacer(),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          elevation: 0,
                                                          primary: Colors
                                                              .transparent),
                                                  onPressed: () async {
                                                    await dialogEditCusAddress(
                                                      addresss,
                                                    );
                                                    refreshCustomerAddresses();
                                                  },
                                                  child: const Icon(Icons.edit,
                                                      color: Color.fromARGB(
                                                          255, 205, 205, 205)),
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
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
