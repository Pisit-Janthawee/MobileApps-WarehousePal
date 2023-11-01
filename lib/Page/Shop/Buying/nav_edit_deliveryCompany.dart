import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:warehouse_mnmt/Page/Component/change_theme_btn.dart';
import 'package:warehouse_mnmt/Page/Model/DeliveryCompany.dart';
import 'package:warehouse_mnmt/Page/Model/DeliveryRate.dart';
import 'package:warehouse_mnmt/Page/Model/Shop.dart';

import 'package:warehouse_mnmt/Page/Provider/theme_provider.dart';
import 'package:warehouse_mnmt/db/database.dart';
import 'package:warehouse_mnmt/main.dart';

class EditShippingPage extends StatefulWidget {
  final Shop shop;
  final DeliveryCompanyModel company;
  const EditShippingPage({required this.company, required this.shop, Key? key})
      : super(key: key);

  @override
  State<EditShippingPage> createState() => _EditShippingPageState();
}

class _EditShippingPageState extends State<EditShippingPage> {
  List<DeliveryRateModel> deliveryRates = [];
  List<TextEditingController> startControllers = [];
  List<TextEditingController> endControllers = [];
  List<TextEditingController> costControllers = [];

  @override
  void initState() {
    super.initState();
    refreshPage();
  }

  Future refreshPage() async {
    deliveryRates = await DatabaseManager.instance
        .readDeliveryRatesWHEREdcId(widget.company.dcId!);
    print('Delivery Rates (${deliveryRates.length})');
    for (var i = 0; i < deliveryRates.length; i++) {
      startControllers.add(TextEditingController(
          text: deliveryRates[i].weightRange.split('-')[0]));
      endControllers.add(TextEditingController(
          text: deliveryRates[i].weightRange.split('-')[1]));
      costControllers
          .add(TextEditingController(text: '${deliveryRates[i].cost}'));
      print(
          '---------------------------------------------------------------(${i})');
      print('Start Controller : (${startControllers[i].text})');
      print('End Controller : (${endControllers[i].text})');
      print('Cost Controller : (${costControllers[i].text})');
    }

    setState(() {});
  }

  Future refreshPageDeliveryRates() async {
    deliveryRates = await DatabaseManager.instance
        .readDeliveryRatesWHEREdcId(widget.company.dcId!);
  }

  final _formOnlyOneKey = GlobalKey<FormState>();
  final _formDcNameKey = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();
  late final nameController =
      TextEditingController(text: widget.company.dcName);
  late final onlyOneController =
      TextEditingController(text: '${widget.company.fixedDeliveryCost}');
  late bool _isSelectedRange = widget.company.dcisRange;
  late String? deliveryOptions = _isSelectedRange ? 'range' : 'onlyOne';

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
            backgroundColor: themeProvider.isDark
                ? Theme.of(context).colorScheme.onSecondary
                : Color.fromRGBO(10, 10, 10, 1.0),
            automaticallyImplyLeading: true,
            actions: [],
            title: Text(
              "${widget.company.dcName}",
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
                    height: 100,
                  ),
                  Form(
                    key: _formDcNameKey,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: themeProvider.isDark
                              ? Theme.of(context).colorScheme.onSecondary
                              : Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(15)),
                      width: 400,
                      height: 70,
                      child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'โปรดระบุชื่อ';
                            }
                            return null;
                          },
                          style: const TextStyle(color: Colors.white),
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText:
                                'ชื่อบริษัทขนส่ง เช่น Kerry Express, Flash...',
                            filled: true,
                            fillColor: Colors.transparent,
                            border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide.none),
                            hintStyle: const TextStyle(
                                color: Colors.grey, fontSize: 14),
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
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(15)),
                    height: 70,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 180,
                          child: RadioListTile(
                            title: Text(
                              "อัตราค่าบริการคงที่",
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            value: "onlyOne",
                            groupValue: deliveryOptions,
                            onChanged: (value) {
                              setState(() {
                                deliveryOptions = value.toString();
                                _isSelectedRange = false;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            child: RadioListTile(
                              title: Text("คำนวณตามน้ำหนัก",
                                  style: TextStyle(
                                    fontSize: 14,
                                  )),
                              value: "range",
                              groupValue: deliveryOptions,
                              onChanged: (value) {
                                setState(() {
                                  deliveryOptions = value.toString();
                                  _isSelectedRange = true;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  deliveryOptions == 'range'
                      ? Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(15)),
                          height: (MediaQuery.of(context).size.height) / 2,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'ช่วงน้ำหนัก (${deliveryRates.length})',
                                  ),
                                  Text(
                                    ' หน่วยเป็นกรัม',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(
                                    width: 400 / 9,
                                  ),
                                  Text(
                                    'ค่าจัดส่ง',
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    var cost = 32;
                                    final rate = DeliveryRateModel(
                                        weightRange: deliveryRates.isEmpty
                                            ? '0.0-50.0'
                                            : '${double.parse(endControllers.last.text)}-${double.parse(endControllers.last.text) * 2}',
                                        cost: costControllers.isEmpty
                                            ? cost
                                            : int.parse(
                                                    costControllers.last.text) +
                                                (int.parse(costControllers
                                                            .last.text) /
                                                        5)
                                                    .toInt());
                                    TextEditingController startController =
                                        TextEditingController(
                                            text: (double.parse(rate.weightRange
                                                            .split('-')[0])
                                                        .toInt() +
                                                    (deliveryRates.isEmpty ==
                                                            true
                                                        ? 0
                                                        : 1))
                                                .toString());
                                    TextEditingController endController =
                                        TextEditingController(
                                            text: double.parse(rate.weightRange
                                                    .split('-')[1])
                                                .toInt()
                                                .toString());
                                    TextEditingController costController =
                                        TextEditingController(
                                            text: '${rate.cost}');
                                    // Add DeliveryRates, StartController, EndController, CostController
                                    deliveryRates.add(rate);
                                    startControllers.add(startController);
                                    endControllers.add(endController);
                                    costControllers.add(costController);
                                    ++cost;
                                    print(
                                        'Delivery Rate (${deliveryRates.length}) - ${deliveryRates}');

                                    setState(() {});
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.add),
                                      Text('เพิ่มช่วง'),
                                    ],
                                  )),
                              Form(
                                key: _formKey,
                                child: Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    padding: EdgeInsets.all(2),
                                    child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        itemCount: deliveryRates.length,
                                        itemBuilder: (context, index) {
                                          final dr = deliveryRates[index];
                                          print('${dr.weightRange}');

                                          return Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Container(
                                              height: 70,
                                              decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Row(children: [
                                                  Text('${index + 1} ',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                      )),
                                                  Expanded(
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5),
                                                      decoration: BoxDecoration(
                                                          color: themeProvider
                                                                  .isDark
                                                              ? Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onSecondary
                                                              : Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15)),
                                                      child: TextFormField(
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value.isEmpty) {
                                                              return 'โปรดระบุช่วง';
                                                            } else if (startControllers[
                                                                        index]
                                                                    .text
                                                                    .isNotEmpty &&
                                                                value
                                                                    .isNotEmpty &&
                                                                value != null) {
                                                              if (double.parse(startControllers[
                                                                              index]
                                                                          .text
                                                                          .replaceAll(
                                                                              RegExp(
                                                                                  '[^0-9]'),
                                                                              ''))
                                                                      .toInt() >
                                                                  double.parse(endControllers[
                                                                              index]
                                                                          .text
                                                                          .replaceAll(
                                                                              RegExp('[^0-9]'),
                                                                              ''))
                                                                      .toInt()) {
                                                                return 'ช่วงมากกว่า';
                                                              } else if ((startControllers
                                                                              .firstWhere(
                                                                            (element) =>
                                                                                element.text ==
                                                                                startControllers[index].text,
                                                                          ) ==
                                                                          startControllers[
                                                                              index] &&
                                                                      endControllers
                                                                              .firstWhere(
                                                                            (element) =>
                                                                                element.text ==
                                                                                endControllers[index].text,
                                                                          ) ==
                                                                          endControllers[
                                                                              index]) ==
                                                                  false) {
                                                                return 'ช่วง ${startControllers[index].text} มีอยู่แล้ว';
                                                              }
                                                            }
                                                            return null;
                                                          },
                                                          textAlign:
                                                              TextAlign.start,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          // maxLength: length,
                                                          inputFormatters: [
                                                            LengthLimitingTextInputFormatter(
                                                                10),
                                                            FilteringTextInputFormatter
                                                                .digitsOnly
                                                          ],
                                                          controller:
                                                              startControllers[
                                                                  index],
                                                          //-----------------------------------------------------

                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 12),
                                                          cursorColor: Theme.of(
                                                                  context)
                                                              .backgroundColor,
                                                          decoration:
                                                              InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.all(
                                                                    10),
                                                            // labelText: title,

                                                            hoverColor: Theme
                                                                    .of(context)
                                                                .backgroundColor,
                                                            border: const OutlineInputBorder(
                                                                borderRadius: BorderRadius.only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            20),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            20),
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            20),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            20)),
                                                                borderSide:
                                                                    BorderSide
                                                                        .none),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .all(
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

                                                            hintText: 'กรัม',
                                                            hintStyle:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        14),
                                                            // prefixIcon: const Icon(Icons.local_shipping, color: Colors.white),
                                                          )),
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 5, right: 5),
                                                    child: Text('-'),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5),
                                                      decoration: BoxDecoration(
                                                          color: themeProvider
                                                                  .isDark
                                                              ? Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onSecondary
                                                              : Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15)),
                                                      child: TextFormField(
                                                          textAlign:
                                                              TextAlign.start,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          // maxLength: length,
                                                          inputFormatters: [
                                                            LengthLimitingTextInputFormatter(
                                                                10),
                                                            FilteringTextInputFormatter
                                                                .digitsOnly
                                                          ],
                                                          controller:
                                                              endControllers[
                                                                  index],
                                                          //-----------------------------------------------------

                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 12),
                                                          cursorColor: Theme.of(
                                                                  context)
                                                              .backgroundColor,
                                                          decoration:
                                                              InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.all(
                                                                    10),
                                                            // labelText: title,

                                                            hoverColor: Theme
                                                                    .of(context)
                                                                .backgroundColor,
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .all(
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
                                                            border: const OutlineInputBorder(
                                                                borderRadius: BorderRadius.only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            20),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            20),
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            20),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            20)),
                                                                borderSide:
                                                                    BorderSide
                                                                        .none),

                                                            hintText: 'กรัม',
                                                            hintStyle:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        14),
                                                            // prefixIcon: const Icon(Icons.local_shipping, color: Colors.white),
                                                          )),
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 5, right: 5),
                                                    child: Text('='),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5),
                                                      decoration: BoxDecoration(
                                                          color: themeProvider
                                                                  .isDark
                                                              ? Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onSecondary
                                                              : Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15)),
                                                      child: TextFormField(
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value.isEmpty) {
                                                              return 'โปรดระบุค่าจัดส่ง';
                                                            }
                                                            return null;
                                                          },
                                                          textAlign:
                                                              TextAlign.start,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          // maxLength: length,
                                                          inputFormatters: [
                                                            LengthLimitingTextInputFormatter(
                                                                10),
                                                            FilteringTextInputFormatter
                                                                .digitsOnly
                                                          ],
                                                          controller:
                                                              costControllers[
                                                                  index],
                                                          //-----------------------------------------------------

                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 12),
                                                          cursorColor: Theme.of(
                                                                  context)
                                                              .backgroundColor,
                                                          decoration:
                                                              InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.all(
                                                                    10),
                                                            // labelText: title,

                                                            hoverColor: Theme
                                                                    .of(context)
                                                                .backgroundColor,
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .all(
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

                                                            border: const OutlineInputBorder(
                                                                borderRadius: BorderRadius.only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            20),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            20),
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            20),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            20)),
                                                                borderSide:
                                                                    BorderSide
                                                                        .none),

                                                            hintText: 'ราคา',
                                                            hintStyle:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        14),
                                                            // prefixIcon: const Icon(Icons.local_shipping, color: Colors.white),
                                                            suffixIcon:
                                                                costControllers[
                                                                            index]
                                                                        .text
                                                                        .isEmpty
                                                                    ? Container(
                                                                        width:
                                                                            0,
                                                                      )
                                                                    : IconButton(
                                                                        onPressed:
                                                                            () =>
                                                                                costControllers[index].clear(),
                                                                        icon:
                                                                            const Icon(
                                                                          Icons
                                                                              .close_sharp,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                          )),
                                                    ),
                                                  ),
                                                ]),
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Center(
                          child: Form(
                            key: _formOnlyOneKey,
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "ค่าบริการจัดส่งสินค้า",
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    width: 150,
                                    height: 70,
                                    child: TextFormField(
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'โปรดระบุราคา';
                                          }
                                          return null;
                                        },
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(6),
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        style: const TextStyle(
                                            color: Colors.white),
                                        controller: onlyOneController,
                                        decoration: InputDecoration(
                                          hintText: 'ราคา',
                                          filled: true,
                                          fillColor: themeProvider.isDark
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onSecondary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                          border: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                              borderSide: BorderSide.none),
                                          hintStyle: const TextStyle(
                                              color: Colors.grey, fontSize: 14),
                                          suffixIcon: onlyOneController
                                                  .text.isEmpty
                                              ? Container(
                                                  width: 0,
                                                )
                                              : IconButton(
                                                  onPressed: () {
                                                    onlyOneController.clear();
                                                    setState(() {});
                                                  },
                                                  icon: const Icon(
                                                    Icons.close_sharp,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                  deliveryRates.isEmpty ||
                          _isSelectedRange == false ||
                          nameController.text.isEmpty
                      ? Container()
                      : ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate() &&
                                _formDcNameKey.currentState!.validate()) {
                              final updatedCompany = widget.company.copy(
                                  dcName: nameController.text,
                                  dcisRange: _isSelectedRange,
                                  fixedDeliveryCost: onlyOneController
                                          .text.isEmpty
                                      ? widget.company.fixedDeliveryCost
                                      : double.parse(onlyOneController.text
                                              .replaceAll(RegExp('[^0-9]'), ''))
                                          .toInt());
                              await DatabaseManager.instance
                                  .updateDeliveryCompany(updatedCompany);
                              print(
                                  'Updated Compamy : [ID ${updatedCompany.dcId}, NAME ${updatedCompany.dcName} ,isRange? ${updatedCompany.dcisRange}, Fixed ${updatedCompany.fixedDeliveryCost}, SHOP ID ${updatedCompany.shopId}]');

                              var cnt = 0;
                              for (var i = 0; i < deliveryRates.length; i++) {
                                final createdRate = deliveryRates[i].copy(
                                    weightRange:
                                        '${double.parse(startControllers[i].text)}-${double.parse(endControllers[i].text)}',
                                    cost: double.parse(costControllers[i]
                                            .text
                                            .replaceAll(RegExp('[^0-9]'), ''))
                                        .toInt(),
                                    dcId: widget.company.dcId!);
                                if (createdRate.rId == null) {
                                  await DatabaseManager.instance
                                      .createDeliveryRate(createdRate);
                                } else {
                                  await DatabaseManager.instance
                                      .updateDeliveryRate(createdRate);
                                }

                                cnt++;
                              }
                              int count = 0;
                              Navigator.pop(context);
                            }
                          },
                          child: Text('บันทึก')),
                  _isSelectedRange == true
                      ? Container()
                      : ElevatedButton(
                          onPressed: () async {
                            // if (_formOnlyOneKey.currentState!.validate() &&
                            //     _formDcNameKey.currentState!.validate()) {
                            //   final updatedCompany = widget.company.copy(
                            //       fixedDeliveryCost: onlyOneController
                            //               .text.isEmpty
                            //           ? widget.company.fixedDeliveryCost
                            //           : double.parse(onlyOneController.text
                            //                   .replaceAll(RegExp('[^0-9]'), ''))
                            //               .toInt());
                            //   await DatabaseManager.instance
                            //       .updateDeliveryCompany(updatedCompany);

                            //   print(
                            //       'Updated Compamy : [ID ${updatedCompany.dcId}, NAME ${updatedCompany.dcName} ,isRange? ${updatedCompany.dcisRange}, Fixed ${updatedCompany.fixedDeliveryCost}, SHOP ID ${updatedCompany.shopId}]');

                            //   int count = 0;
                            //   Navigator.of(
                            //     context,
                            //   ).popUntil((_) => count++ >= 4);
                            // } else {}
                            final updatedCompany = widget.company.copy(
                                dcName: nameController.text,
                                dcisRange: _isSelectedRange,
                                fixedDeliveryCost: onlyOneController
                                        .text.isEmpty
                                    ? widget.company.fixedDeliveryCost
                                    : double.parse(onlyOneController.text
                                            .replaceAll(RegExp('[^0-9]'), ''))
                                        .toInt());
                            await DatabaseManager.instance
                                .updateDeliveryCompany(updatedCompany);

                            print(
                                'Updated Compamy : [ID ${updatedCompany.dcId}, NAME ${updatedCompany.dcName} ,isRange? ${updatedCompany.dcisRange}, Fixed ${updatedCompany.fixedDeliveryCost}, SHOP ID ${updatedCompany.shopId}]');

                            Navigator.pop(context);
                          },
                          child: Text('บันทึก')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
