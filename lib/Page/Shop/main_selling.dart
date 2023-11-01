import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:warehouse_mnmt/Page/Component/SearchBox.dart';
// Component

import 'package:warehouse_mnmt/Page/Model/Customer.dart';
import 'package:warehouse_mnmt/Page/Model/CustomerAdress.dart';
import 'package:warehouse_mnmt/Page/Model/ProductLot.dart';
import 'package:warehouse_mnmt/Page/Model/Selling.dart';
import 'package:warehouse_mnmt/Page/Model/Selling_item.dart';
import 'package:warehouse_mnmt/Page/Provider/theme_provider.dart';
import 'package:warehouse_mnmt/Page/Shop/Selling/nav_edit.dart';

import '../../db/database.dart';
import '../Component/SearchBoxController.dart';
import '../Model/Shop.dart';
import 'Selling/nav_add.dart';

class SellingPage extends StatefulWidget {
  final Shop shop;
  const SellingPage({required this.shop, Key? key}) : super(key: key);

  @override
  State<SellingPage> createState() => _SellingPageState();
}

class _SellingPageState extends State<SellingPage> {
  bool isTapSelect = true;
  List<SellingModel> selllings = [];
  List<SellingItemModel> selllingItems = [];
  List<CustomerModel> customers = [];
  List<CustomerAddressModel> addresses = [];
  List<ProductLot> productLots = [];

  TextEditingController searchCustomerController = new TextEditingController();
  @override
  void initState() {
    super.initState();
    refreshSellings();
    searchCustomerController.addListener(() => setState(() {}));
  }

  Future refreshSellings() async {
    productLots = await DatabaseManager.instance.readAllProductLots();
    selllings = await DatabaseManager.instance
        .readAlSellingsORDERBYPresent(widget.shop.shopid!);

    customers = await DatabaseManager.instance
        .readAllCustomerInShop(widget.shop.shopid!);
    addresses = await DatabaseManager.instance.readAllCustomerAddresses();
    print('Customers -> [${customers.length}]');
    if (!mounted) return;
    setState(() {});
  }

  Future getAllSellingsWHEREisDelivered() async {
    selllings = await DatabaseManager.instance
        .readAllSellingsWHEREisDelivered(widget.shop.shopid!);
    if (!mounted) return;
    setState(() {});
  }

  Future getAllSellingsWHEREisNotDelivered() async {
    selllings = await DatabaseManager.instance
        .readAllSellingsWHEREisNotDelivered(widget.shop.shopid!);
    if (!mounted) return;
    setState(() {});
  }

  Future searchCustomerByName() async {
    selllings = await DatabaseManager.instance.readAllSellingByCusName(
        widget.shop.shopid!, searchCustomerController.text);
    selllings.toSet();
    if (!mounted) return;
    setState(() {});
  }

  bool isSelectedSelling = false;
  List<SellingModel> selectedSelling = [];

  Future<void> dialogConfirmDelete() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, dialogSetState) {
          return AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            title: Row(
              children: [
                const Text(
                  'ต้องการลบ ?',
                  style: TextStyle(color: Colors.white),
                ),
                const Spacer(),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.grey,
                    ))
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.redAccent),
                child: const Text('ลบ'),
                onPressed: () async {
                  List<SellingItemModel> sellingItems = [];
                  for (var selling in selectedSelling) {
                    sellingItems = await DatabaseManager.instance
                        .readAllSellingItemsWhereSellID(selling.selId!);
                    if (selling.isDelivered == true) {
                      print(selling.isDelivered);
                      for (var item in sellingItems) {
                        for (var lot in productLots) {
                          if (item.prodLotId == lot.prodLotId) {
                            final updatedLot = lot.copy(
                                remainAmount: lot.remainAmount + item.amount);
                            await DatabaseManager.instance
                                .updateProductLot(updatedLot);
                          }
                        }
                        await DatabaseManager.instance
                            .deleteSellingItem(item.selItemId!);
                      }
                    } else {
                      for (var item in sellingItems) {
                        await DatabaseManager.instance
                            .deletePurchasingItem(item.selItemId!);
                      }
                    }
                    await DatabaseManager.instance
                        .deleteSelling(selling.selId!);
                  }
                  if (!mounted) return;

                  dialogSetState(() {});
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }

  List<Widget> buyingIndicators(sellingsLength) {
    return List<Widget>.generate(sellingsLength, (index) {
      return Container(
        margin: EdgeInsets.all(3),
        width: 10,
        height: 10,
        decoration: BoxDecoration(
            color:
                // currentIndex == index
                //     ? Theme.of(context).backgroundColor
                //     :
                Colors.black26,
            shape: BoxShape.circle),
      );
    });
  }

  final df = new DateFormat('dd-MM-yyyy hh:mm a');
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(180),
          child: AppBar(
            backgroundColor: themeProvider.isDark
                ? Colors.transparent
                : Theme.of(context).appBarTheme.backgroundColor,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: const Text(
              "ขายสินค้า",
              textAlign: TextAlign.start,
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  await Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => SellingNavAdd(
                                shop: widget.shop,
                              )));
                  // if (!mounted) return;
                  refreshSellings();
                },
                icon: const Icon(
                  Icons.add,
                  size: 30,
                ),
              )
            ],
            flexibleSpace: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Baseline(
                baseline: 110,
                baselineType: TextBaseline.alphabetic,
                child:
                    // SearchBox("ชื่อลูกค้า หรือ เบอร์โทรศัพท์")
                    Column(
                  children: [
                    TextFormField(
                        keyboardType: TextInputType.text,
                        onChanged: (text) {
                          searchCustomerByName();
                          print(selllings.length);
                          if (!mounted) return;
                          setState(() {});
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(100),
                        ],
                        controller: searchCustomerController,
                        style: TextStyle(
                            color: themeProvider.isDark
                                ? Colors.white
                                : Colors.black,
                            fontSize: 15),
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
                          hintText: 'ชื่อตัวแทนจำหน่าย หรือ เบอร์โทรศัพท์',
                          hintStyle:
                              const TextStyle(color: Colors.grey, fontSize: 14),
                          prefixIcon: Icon(Icons.search,
                              color: themeProvider.isDark
                                  ? Colors.white
                                  : Color.fromRGBO(14, 14, 14, 1.0)),
                          suffixIcon: searchCustomerController.text.isEmpty
                              ? Container(
                                  width: 0,
                                )
                              : IconButton(
                                  onPressed: () {
                                    searchCustomerController.clear();
                                    refreshSellings();
                                  },
                                  icon: Icon(
                                    Icons.close_sharp,
                                    color: themeProvider.isDark
                                        ? Colors.white
                                        : Color.fromRGBO(14, 14, 14, 1.0),
                                  ),
                                ),
                        )),
                  ],
                ),
              ),
            ),
            bottom: TabBar(
                onTap: (value) {
                  setState(() {
                    if (value == 0) {
                      refreshSellings();
                    } else if (value == 1) {
                      getAllSellingsWHEREisDelivered();
                    } else {
                      getAllSellingsWHEREisNotDelivered();
                    }
                  });
                },
                tabs: [
                  Tab(
                    child: Container(
                      decoration: BoxDecoration(
                        // color: Color.fromRGBO(56, 54, 76, 1.0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(" ทั้งหมด "),
                      ),
                    ),
                  ),
                  Tab(
                    child: Container(
                      decoration: BoxDecoration(
                        // color: Color.fromRGBO(56, 54, 76, 1.0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.check_circle,
                              color: Colors.greenAccent,
                            ),
                            // Text("จัดส่งสินค้าแล้ว"),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: Container(
                      decoration: BoxDecoration(
                        // color: Color.fromRGBO(56, 54, 76, 1.0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.circle_outlined,
                              color: Colors.greenAccent,
                            ),
                            // Text("ไม่ได้จัดส่งสินค้า"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]),
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
                          Color.fromARGB(255, 255, 255, 255),
                          Color.fromARGB(255, 255, 255, 255),
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
                  selllings.isEmpty
                      ? Container()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            isSelectedSelling
                                ? ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: isSelectedSelling
                                            ? Colors.redAccent
                                            : Theme.of(context)
                                                .backgroundColor),
                                    onPressed: () {
                                      setState(() {
                                        isSelectedSelling = !isSelectedSelling;
                                        selectedSelling.clear();
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.select_all_rounded),
                                        Text('ยกเลิก')
                                      ],
                                    ))
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: isSelectedSelling
                                            ? Colors.redAccent
                                            : Theme.of(context)
                                                .backgroundColor),
                                    onPressed: () {
                                      setState(() {
                                        isSelectedSelling = !isSelectedSelling;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.select_all_rounded),
                                        Text('เลือก')
                                      ],
                                    ))
                          ],
                        ),
                  Container(
                    decoration: BoxDecoration(
                      // color: Theme.of(context).colorScheme.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        selllings.isEmpty
                            ? Container(
                                decoration: BoxDecoration(
                                  // color:
                                  //     Theme.of(context).colorScheme.background,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                height:
                                    MediaQuery.of(context).size.height * 0.65,
                                child: Center(
                                    child: Text(
                                  '(ไม่มีการขายสินค้า)',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 25),
                                )),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.55,
                                  width: 440.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    // color: Color.fromRGBO(37, 35, 53, 1.0),
                                  ),
                                  child: RefreshIndicator(
                                    onRefresh: refreshSellings,
                                    child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        itemCount: selllings.length,
                                        itemBuilder: (context, index) {
                                          final selling = selllings[index];
                                          var _customer;
                                          var _address;

                                          for (var customer in customers) {
                                            if (customer.cusId ==
                                                selling.customerId) {
                                              _customer = customer;
                                              for (var address in addresses) {
                                                if (address.cAddreId ==
                                                    selling.cAddreId) {
                                                  _address = address;
                                                }
                                              }
                                            }
                                          }
                                          final isSelectedItem =
                                              selectedSelling.contains(selling);

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
                                            onDismissed: (direction) async {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                backgroundColor:
                                                    Colors.redAccent,
                                                content: Container(
                                                    child: Row(
                                                  children: [
                                                    Text(_customer == null
                                                        ? 'ลบรากายขาย ลูกค้า - '
                                                        : "ลบรายการขาย ${_customer.cName}"),
                                                    Text(
                                                        ' ยอด ฿${NumberFormat("#,###.##").format(selling.total)}',
                                                        style: const TextStyle(
                                                            color: Colors.grey,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12)),
                                                  ],
                                                )),
                                                duration: Duration(seconds: 5),
                                              ));
                                              List<SellingItemModel>
                                                  sellingItemsList = [];
                                              if (selling.isDelivered == true) {
                                                sellingItemsList =
                                                    await DatabaseManager
                                                        .instance
                                                        .readAllSellingItemsWhereSellID(
                                                            selling.selId!);
                                                for (var item
                                                    in sellingItemsList) {
                                                  for (var lot in productLots) {
                                                    if (item.prodLotId ==
                                                        lot.prodLotId) {
                                                      final updatedLot = lot.copy(
                                                          remainAmount:
                                                              lot.remainAmount +
                                                                  item.amount);
                                                      await DatabaseManager
                                                          .instance
                                                          .updateProductLot(
                                                              updatedLot);
                                                    }
                                                  }
                                                  await DatabaseManager.instance
                                                      .deleteSellingItem(
                                                          item.selItemId!);
                                                }
                                              } else {
                                                for (var item
                                                    in sellingItemsList) {
                                                  await DatabaseManager.instance
                                                      .deleteSellingItem(
                                                          item.selItemId!);
                                                }
                                              }
                                              await DatabaseManager.instance
                                                  .deleteSelling(
                                                      selling.selId!);
                                              if (!mounted) return;
                                              refreshSellings();
                                              setState(() {});
                                            },
                                            child: TextButton(
                                              onPressed: () async {
                                                await Navigator.of(context)
                                                    .push(MaterialPageRoute(
                                                        builder: (context) => SellingNavEdit(
                                                            customer: _customer ==
                                                                    null
                                                                ? CustomerModel(
                                                                    cName:
                                                                        'ลูกค้าถูกลบ')
                                                                : _customer,
                                                            customerAddress:
                                                                _address == null
                                                                    ? CustomerAddressModel(
                                                                        cPhone:
                                                                            '-',
                                                                        cAddress:
                                                                            '-')
                                                                    : _address,
                                                            shop: widget.shop,
                                                            selling: selling)));
                                                refreshSellings();
                                                if (!mounted) return;
                                                setState(() {});
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 0.0,
                                                    horizontal: 0.0),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  child: Container(
                                                    height:
                                                        (MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            4),
                                                    width: 400,
                                                    color: themeProvider.isDark
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                        : Color.fromRGBO(
                                                            10, 10, 10, 1.0),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Container(
                                                          width: 80,
                                                          height: 80,
                                                          child: isSelectedSelling
                                                              ? IconButton(
                                                                  onPressed: () {
                                                                    if (isSelectedItem ==
                                                                        false) {
                                                                      selectedSelling
                                                                          .add(
                                                                              selling);
                                                                      showModalBottomSheet(
                                                                          elevation:
                                                                              0,
                                                                          backgroundColor: Colors
                                                                              .transparent,
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (context) {
                                                                            return Container(
                                                                              width: 370,
                                                                              height: 250,
                                                                              decoration: BoxDecoration(gradient: scafBG_dark_Color, borderRadius: new BorderRadius.only(topLeft: const Radius.circular(30.0), topRight: const Radius.circular(30.0))),
                                                                              child: Wrap(
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(left: 20, right: 20),
                                                                                    child: Container(
                                                                                      width: 390,
                                                                                      height: 90,
                                                                                      child: Row(
                                                                                        children: [
                                                                                          Text(
                                                                                            'รายการขายสินค้า \n(${selectedSelling.length})',
                                                                                            style: TextStyle(fontSize: 20),
                                                                                          ),
                                                                                          const Spacer(),
                                                                                          ElevatedButton(
                                                                                              style: ElevatedButton.styleFrom(primary: Colors.redAccent),
                                                                                              onPressed: () async {
                                                                                                await dialogConfirmDelete();
                                                                                                selectedSelling.clear();
                                                                                                isSelectedSelling = false;
                                                                                                refreshSellings();
                                                                                                Navigator.pop(context);
                                                                                              },
                                                                                              child: Icon(
                                                                                                Icons.delete_rounded,
                                                                                              )),
                                                                                          SizedBox(
                                                                                            width: 10,
                                                                                          ),
                                                                                          ElevatedButton(
                                                                                              onPressed: () async {
                                                                                                List<SellingItemModel> sellingItems = [];
                                                                                                for (var selling in selectedSelling) {
                                                                                                  if (selling.isDelivered != true) {
                                                                                                    sellingItems = await DatabaseManager.instance.readAllSellingItemsWhereSellID(selling.selId!);
                                                                                                    for (var item in sellingItems) {
                                                                                                      for (var lot in productLots) {
                                                                                                        if (item.prodLotId == lot.prodLotId) {
                                                                                                          final updatedLot = lot.copy(remainAmount: lot.remainAmount - item.amount);
                                                                                                          await DatabaseManager.instance.updateProductLot(updatedLot);
                                                                                                        }
                                                                                                      }
                                                                                                    }
                                                                                                    final updatedSelling = selling.copy(isDelivered: true);
                                                                                                    await DatabaseManager.instance.updateSelling(updatedSelling);
                                                                                                  }
                                                                                                }
                                                                                                isSelectedSelling = false;
                                                                                                if (!mounted) return;

                                                                                                refreshSellings();

                                                                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                                                  backgroundColor: Theme.of(context).backgroundColor,
                                                                                                  behavior: SnackBarBehavior.floating,
                                                                                                  content: Row(
                                                                                                    children: [
                                                                                                      Text("ปรับปรุงสินค้าคงเหลือแล้ว"),
                                                                                                    ],
                                                                                                  ),
                                                                                                  duration: Duration(seconds: 5),
                                                                                                ));
                                                                                                Navigator.pop(context);
                                                                                              },
                                                                                              child: Row(
                                                                                                children: [
                                                                                                  Text('จัดส่งแล้ว'),
                                                                                                  Icon(
                                                                                                    Icons.check_circle,
                                                                                                    color: Colors.greenAccent,
                                                                                                    size: 15,
                                                                                                  )
                                                                                                ],
                                                                                              ))
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Column(
                                                                                    children: [
                                                                                      Container(
                                                                                        width: 390,
                                                                                        height: 90,
                                                                                        child: ListView.builder(
                                                                                            scrollDirection: Axis.horizontal,
                                                                                            // padding: const EdgeInsets.all(8),

                                                                                            itemCount: selectedSelling.length,
                                                                                            itemBuilder: (BuildContext context, int index) {
                                                                                              final indItem = selectedSelling[index];

                                                                                              // ??????asdsd
                                                                                              return Padding(
                                                                                                padding: const EdgeInsets.all(3),
                                                                                                child: ClipRRect(
                                                                                                  borderRadius: BorderRadius.circular(10),
                                                                                                  child: Container(
                                                                                                    height: 30,
                                                                                                    color: Theme.of(context).colorScheme.primary,
                                                                                                    child: Padding(
                                                                                                      padding: const EdgeInsets.all(10.0),
                                                                                                      child: Row(
                                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                                        children: [
                                                                                                          IconButton(
                                                                                                              onPressed: () {
                                                                                                                selectedSelling.remove(indItem);
                                                                                                                Navigator.pop(context);
                                                                                                                setState(() {});
                                                                                                              },
                                                                                                              icon: Icon(
                                                                                                                Icons.check_box_rounded,
                                                                                                                color: Theme.of(context).backgroundColor,
                                                                                                              )),
                                                                                                          Text(
                                                                                                            _customer == null ? 'ลูกค้าถูกลบ' : _customer.cName,
                                                                                                            style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                                                                                          ),
                                                                                                          Row(
                                                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                                                            children: [
                                                                                                              indItem.isDelivered == true
                                                                                                                  ? Icon(
                                                                                                                      Icons.check_circle,
                                                                                                                      color: Colors.greenAccent,
                                                                                                                      size: 15,
                                                                                                                    )
                                                                                                                  : Icon(
                                                                                                                      Icons.circle_outlined,
                                                                                                                      color: Colors.greenAccent,
                                                                                                                      size: 15,
                                                                                                                    ),
                                                                                                              Text(
                                                                                                                '฿${NumberFormat("#,###.##").format(indItem.total)}',
                                                                                                                style: TextStyle(fontSize: 11, color: Colors.greenAccent, fontWeight: FontWeight.bold),
                                                                                                              ),
                                                                                                            ],
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              );
                                                                                            }),
                                                                                      ),
                                                                                      Row(mainAxisAlignment: MainAxisAlignment.center, children: buyingIndicators(selectedSelling.length)),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            );
                                                                          });
                                                                    } else {
                                                                      selectedSelling
                                                                          .remove(
                                                                              selling);
                                                                    }
                                                                    setState(
                                                                        () {});
                                                                  },
                                                                  icon: isSelectedItem
                                                                      ? Icon(
                                                                          Icons
                                                                              .check_box_rounded,
                                                                          color:
                                                                              Theme.of(context).backgroundColor,
                                                                          size:
                                                                              25,
                                                                        )
                                                                      : Icon(
                                                                          Icons
                                                                              .check_box_outline_blank_rounded,
                                                                          color:
                                                                              Theme.of(context).backgroundColor,
                                                                          size:
                                                                              25,
                                                                        ))
                                                              : Icon(
                                                                  Icons.person,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 25,
                                                                ),
                                                        ),
                                                        SizedBox(width: 10),
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
                                                                _customer ==
                                                                        null
                                                                    ? 'ลูกค้าถูกลบ'
                                                                    : _customer
                                                                        .cName,
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .phone_in_talk,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 14,
                                                                  ),
                                                                  Text(
                                                                    _address ==
                                                                            null
                                                                        ? '-'
                                                                        : _address.cPhone.replaceAllMapped(
                                                                            RegExp(
                                                                                r'(\d{3})(\d{3})(\d+)'),
                                                                            (Match m) =>
                                                                                "${m[1]}-${m[2]}-${m[3]}"),
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .grey),
                                                                  ),
                                                                ],
                                                              ),
                                                              Text(
                                                                _address == null
                                                                    ? '-'
                                                                    : _address
                                                                        .cAddress,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                              Center(
                                                                child: Text(
                                                                    '${DateFormat.yMMMd().format(selling.orderedDate)}',
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .grey,
                                                                        fontSize:
                                                                            11)),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(15.0),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              selling.isDelivered ==
                                                                      true
                                                                  ? Icon(
                                                                      Icons
                                                                          .check_circle,
                                                                      color: Colors
                                                                          .greenAccent,
                                                                    )
                                                                  : Icon(
                                                                      Icons
                                                                          .circle_outlined,
                                                                      color: Colors
                                                                          .greenAccent,
                                                                    ),
                                                              Text(
                                                                '฿${NumberFormat("#,###.##").format(selling.total + selling.shippingCost)}',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .greenAccent,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
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
                              ),
                      ],
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
