import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warehouse_mnmt/Page/Model/DeliveryCompany.dart';
import 'package:warehouse_mnmt/Page/Model/DeliveryRate.dart';
import 'package:warehouse_mnmt/Page/Model/Shop.dart';
import 'package:warehouse_mnmt/Page/Provider/theme_provider.dart';
import 'package:warehouse_mnmt/Page/Shop/Buying/nav_create_shipping.dart';
import 'package:warehouse_mnmt/Page/Shop/Buying/nav_edit_deliveryCompany.dart';
import 'package:warehouse_mnmt/db/database.dart';

import '../../Component/TextField/CustomTextField.dart';

class ChooseShippingNav extends StatefulWidget {
  final Shop shop;
  final ValueChanged<DeliveryCompanyModel> update;

  const ChooseShippingNav(
      {super.key, required this.shop, required this.update});
  @override
  State<ChooseShippingNav> createState() => _ChooseShippingNavState();
}

class _ChooseShippingNavState extends State<ChooseShippingNav> {
  List<DeliveryCompanyModel> companys = [];
  @override
  void initState() {
    super.initState();
    refreshPage();
  }

  Future refreshPage() async {
    companys = await DatabaseManager.instance
        .readDeliveryCompanys(widget.shop.shopid!);
    companys.add(DeliveryCompanyModel(
        dcName: 'รับสินค้าเอง', dcisRange: false, fixedDeliveryCost: 0));
    companys.add(DeliveryCompanyModel(
        dcName: 'ระบุราคา', dcisRange: false, fixedDeliveryCost: 0));

    setState(() {});
  }

  TextEditingController controller = TextEditingController();
  bool _validate = false;

  Future<void> dialog(
      TextEditingController controller, DeliveryCompanyModel company) async {
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
                    'ราคาการจัดส่ง',
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
                    'ราคา',
                    isNumber: true,
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
                  // widget.update(controller.text);
                  final updatedCompany = company.copy(
                      fixedDeliveryCost: double.parse(
                              controller.text.replaceAll(RegExp('[^0-9]'), ''))
                          .toInt());

                  widget.update(
                    updatedCompany,
                  );
                  Navigator.of(dContext).pop();
                  Navigator.of(context).pop();
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
    bool _validate = false;
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
        title: Column(
          children: [
            Text(
              "เลือกการจัดส่ง",
              style: TextStyle(fontSize: 25),
            )
          ],
        ),
        centerTitle: true,
        backgroundColor: themeProvider.isDark
            ? Theme.of(context).colorScheme.onSecondary
            : Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: (MediaQuery.of(context).size.height),
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
            const SizedBox(
              height: 90,
            ),
            companys.isEmpty
                ? Expanded(
                    child: Container(
                      child: Center(
                        child: Text(
                          'ไม่มีการจัดส่ง',
                          style: TextStyle(color: Colors.grey, fontSize: 25),
                        ),
                      ),
                    ),
                  )
                : Container(
                    width: 440,
                    height: 510,
                    child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: companys.length,
                        itemBuilder: (context, index) {
                          final company = companys[index];
                          List<DeliveryRateModel> rates = [];
                          return // Choose Customer Button
                              Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary:
                                      const Color.fromRGBO(56, 54, 76, 1.0),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15))),
                              onPressed: () {
                                if (company.dcName == 'ระบุราคา') {
                                  dialog(controller, company);
                                } else {
                                  Navigator.of(context).pop();
                                  widget.update(
                                    company,
                                  );
                                  refreshPage();
                                }
                              },
                              child: Row(children: [
                                Icon(company.dcName == 'รับสินค้าเอง'
                                    ? Icons.front_hand_rounded
                                    : company.dcName == 'ระบุราคา'
                                        ? Icons.edit
                                        : Icons.local_shipping_rounded),
                                Padding(
                                  padding: const EdgeInsets.all(25.0),
                                  child: Text(company.dcName,
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.white)),
                                ),
                                const Spacer(),
                              ]),
                            ),
                          );
                          // Choose Customer Button;
                        }),
                  ),
          ]),
        ),
      ),
    );
  }
}
