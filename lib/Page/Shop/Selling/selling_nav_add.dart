import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:warehouse_mnmt/Page/Model/Product.dart';

import '../../Component/datePicker.dart';

class SellingNavAdd extends StatefulWidget {
  const SellingNavAdd({Key? key}) : super(key: key);

  @override
  State<SellingNavAdd> createState() => _SellingNavAddState();
}

class _SellingNavAddState extends State<SellingNavAdd> {
  TextEditingController shipPricController = TextEditingController();
  TextEditingController specReqController = TextEditingController();
  double _onlyProd_price = 0;
  double _shipping_price = 0;
  double _total_price = 0;

  @override
  void initState() {
    super.initState();
  }

  List<Product> products = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
          title: Column(
            children: [
              Text(
                "เพิ่มรายการขาย",
                style: TextStyle(fontSize: 25),
              )
            ],
          ),
          centerTitle: true,
          backgroundColor: Color.fromRGBO(30, 30, 65, 1.0),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            colors: [
              Color.fromRGBO(29, 29, 65, 1.0),
              Color.fromRGBO(31, 31, 31, 1.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )),
          child:
              // Text(
              //   user.username,
              //   style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              // )
              Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(children: [
              const SizedBox(
                height: 90,
              ),
              // Date Picker
              datePicker(),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "รายการสินค้า",
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              // Container of รายการสินค้า
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Color.fromRGBO(56, 48, 77, 1.0),
                    borderRadius: BorderRadius.circular(15)),
                width: 440,
                height: 340,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: [
                    ElevatedButton(
                      // style: prodPickButtonStyle,
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add),
                          Text("เลือกสินค้า"),
                        ],
                      ),
                    ),
                    // ListView
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        height: 224.0,
                        width: 440.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Color.fromRGBO(37, 35, 53, 1.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            products.isEmpty
                                ? const Text(
                                    'ไม่มีสินค้า',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 25),
                                  )
                                : Container(
                                    height: 224.0,
                                    width: 440.0,
                                    child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        itemCount: products.length,
                                        itemBuilder: (context, index) {
                                          final product = products[index];
                                          return TextButton(
                                            onPressed: () {
                                              // Navigator.of(context).push(
                                              //     MaterialPageRoute(
                                              //         builder: (context) =>
                                              //             sellingNavShowProd(
                                              //                 product:
                                              //                     product)));
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 0.0,
                                                  horizontal: 0.0),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Container(
                                                  height: 80,
                                                  width: 400,
                                                  color: Color.fromRGBO(
                                                      56, 54, 76, 1.0),
                                                  child: Row(
                                                    children: <Widget>[
                                                      // Container(
                                                      //     width: 80,
                                                      //     height: 80,
                                                      //     decoration:
                                                      //         new BoxDecoration(
                                                      //             image:
                                                      //                 new DecorationImage(
                                                      //       image: new AssetImage(
                                                      //           product
                                                      //               .prodImage),
                                                      //       fit: BoxFit.fill,
                                                      //     ))),
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
                                                              product.prodName,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            Text(
                                                              '${product.prodCategId!}',
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            // Text(
                                                            //     'ราคา ${NumberFormat("#,###.##").format(product.prodPrice)} / หน่วย',
                                                            //     style: const TextStyle(
                                                            //         color: Colors
                                                            //             .grey,
                                                            //         fontSize:
                                                            //             12)),
                                                            // Text(
                                                            //     'ราคา ${NumberFormat("#,###.##").format(product.prodPrice * product.prodAmount)}',
                                                            //     style: const TextStyle(
                                                            //         color: Colors
                                                            //             .grey,
                                                            //         fontSize:
                                                            //             12)),
                                                          ],
                                                        ),
                                                      ),
                                                      // Padding(
                                                      //   padding:
                                                      //       const EdgeInsets
                                                      //           .all(5.0),
                                                      //   child: CircleAvatar(
                                                      //     radius: 15,
                                                      //     backgroundColor:
                                                      //         Color.fromRGBO(30,
                                                      //             30, 49, 1.0),
                                                      //     child:
                                                      //     Text(
                                                      //         '${NumberFormat("#,###.##").format(product.prodAmount)}',
                                                      //         style: const TextStyle(
                                                      //             fontSize: 15,
                                                      //             color: Colors
                                                      //                 .greenAccent,
                                                      //             fontWeight:
                                                      //                 FontWeight
                                                      //                     .bold)),
                                                      //   ),
                                                      // ),
                                                      IconButton(
                                                        iconSize: 20,
                                                        icon: Icon(Icons.delete,
                                                            color: Colors
                                                                .redAccent),
                                                        onPressed: () {
                                                          setState(() {});
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                  )
                          ],
                        ),
                      ),
                    ),
                    // ListView
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "จำนวนทั้งหมด",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.only(left: 5),
                        //   child: CircleAvatar(
                        //     radius: 12,
                        //     backgroundColor: Color.fromRGBO(30, 30, 49, 1.0),
                        //     child: Text(
                        //         '${NumberFormat("#,###").format(_allProd_amt)}',
                        //         style: const TextStyle(
                        //             fontSize: 12,
                        //             color: Colors.greenAccent,
                        //             fontWeight: FontWeight.bold)),
                        //   ),
                        // ),
                      ],
                    )
                  ]),
                ),
              ),
              // Container of รายการสินค้า
              const SizedBox(
                height: 10,
              ),
              // Container of การจัดส่ง
              Container(
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(56, 48, 77, 1.0),
                    borderRadius: BorderRadius.circular(15)),
                width: 400,
                height: 70,
                child: Row(children: [
                  const Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text("การจัดส่ง",
                        style: TextStyle(fontSize: 15, color: Colors.white)),
                  ),
                  const Spacer(),
                  // Text('$_shipping',
                  //     style: TextStyle(fontSize: 15, color: Colors.grey)),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios,
                        color: Colors.white),
                    onPressed: () {
                      // Navigator.push(
                      //     context,
                      //     new MaterialPageRoute(
                      //         builder: (context) => selling_nav_chooseShipping(
                      //               update: _updateShipping,
                      //             )));
                    },
                  ),
                ]),
              ),
              // Container of การจัดส่ง
              const SizedBox(
                height: 10,
              ),
              // Container of ค่าจัดส่ง
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(56, 48, 77, 1.0),
                    borderRadius: BorderRadius.circular(15)),
                width: 400,
                height: 70,
                child: TextField(
                    textAlign: TextAlign.end,
                    keyboardType: TextInputType.number,
                    onSubmitted: (context) {
                      // if (shipPricController.text.isEmpty == true) {
                      //   _calculateShip(0.0);
                      // } else {
                      //   _calculateShip(double.parse(shipPricController.text));
                      // }
                    },
                    //-----------------------------------------------------
                    style: const TextStyle(color: Colors.grey),
                    controller: shipPricController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.transparent,
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide.none),
                      hintText: "ใส่ค่าจัดส่ง",
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 14),
                      prefixIcon:
                          const Icon(Icons.local_shipping, color: Colors.white),
                      suffixIcon: !shipPricController.text.isEmpty
                          ? IconButton(
                              onPressed: () {
                                // shipPricController.clear();

                                // double totalProdPrice = 0;
                                // for (var i = 0; i < products.length; i++) {
                                //   final product = products[i];
                                //   totalProdPrice +=
                                //       product.prodPrice * product.prodAmount;
                                // }

                                // _total_price = totalProdPrice;
                                // _shipping_price = 0;
                              },
                              icon: const Icon(
                                Icons.close_sharp,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    )),
              ),
              // Container of ค่าจัดส่ง
              const SizedBox(
                height: 10,
              ),
              // Container of ภาษี 7 %
              Container(
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(56, 48, 77, 1.0),
                    borderRadius: BorderRadius.circular(15)),
                width: 400,
                height: 70,
                child: Row(children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: const Text("Vat (7%)",
                        style: TextStyle(fontSize: 15, color: Colors.white)),
                  ),
                  Spacer(),
                  // Padding(
                  //   padding: const EdgeInsets.all(20.0),
                  //   child: Text(
                  //       '${NumberFormat("#,###.##").format(_vat_price)}',
                  //       textAlign: TextAlign.left,
                  //       style:
                  //           const TextStyle(fontSize: 15, color: Colors.grey)),
                  // ),
                ]),
              ),
              // Container of ภาษี 7 %
              const SizedBox(
                height: 10,
              ),
              // Container of ราคาสุทธิ
              Container(
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(56, 48, 77, 1.0),
                    borderRadius: BorderRadius.circular(15)),
                width: 400,
                height: 70,
                child: Row(children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: const Text("ราคาสุทธิ",
                        style: TextStyle(fontSize: 15, color: Colors.white)),
                  ),
                  Spacer(),
                  // Padding(
                  //   padding: const EdgeInsets.all(20.0),
                  //   child:
                  //   // Text(
                  //   //     '${NumberFormat("#,###.##").format(_withoutVat_price)}',
                  //   //     textAlign: TextAlign.left,
                  //   //     style:
                  //   //         const TextStyle(fontSize: 15, color: Colors.grey)),
                  // ),
                ]),
              ),
              // Container of ราคาสุทธิ
              const SizedBox(
                height: 10,
              ),
              // Container of ราคาขายรวม
              Container(
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(56, 48, 77, 1.0),
                    borderRadius: BorderRadius.circular(15)),
                width: 400,
                height: 70,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: const Text("ราคาขายรวม",
                          style: TextStyle(fontSize: 15, color: Colors.white)),
                    ),
                    if (products.length != 0)
                      Row(
                        children: [
                          const Icon(Icons.shopping_cart_rounded,
                              color: Colors.white, size: 15),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                                'สินค้า (${NumberFormat("#,###,###,###.##").format(_onlyProd_price)})',
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ),
                          if (shipPricController.text.isNotEmpty)
                            Row(
                              children: [
                                const Icon(Icons.local_shipping,
                                    color: Colors.greenAccent, size: 15),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                      '+ (${NumberFormat("#,###,###,###.##").format(_shipping_price)})',
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.greenAccent)),
                                ),
                              ],
                            )
                        ],
                      ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                          '${NumberFormat("#,###,###,###.##").format(_total_price)}',
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              fontSize: 15, color: Colors.grey)),
                    ),
                  ]),
                ),
              ),
              // Container of ราคาขายรวม
              Row(
                children: [
                  Text(
                    "ลูกค้า",
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              // Container of เลือกลูกค้า
              Container(
                decoration: BoxDecoration(
                    color: Color.fromRGBO(56, 48, 77, 1.0),
                    borderRadius: BorderRadius.circular(15)),
                width: 400,
                height: 70,
                child: Row(children: [
                  // Padding(
                  //   padding: const EdgeInsets.all(20.0),
                  //   child: Text(
                  //     _customer,
                  //       style: TextStyle(fontSize: 15, color: Colors.grey)),
                  // ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
                    onPressed: () {
                      // Navigator.push(
                      //     context,
                      //     new MaterialPageRoute(
                      //         builder: (context) => selling_nav_chooseCustomer(
                      //               update: _updateCus,
                      //             )));
                    },
                  ),
                ]),
              ),
              // Container of เลือกลูกค้า
              Row(
                children: [
                  Text(
                    "คำร้องขอพิเศษ",
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ],
              ),
              // Container of คำร้องขอพิเศษ
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(56, 48, 77, 1.0),
                    borderRadius: BorderRadius.circular(15)),
                width: 400,
                height: 70,
                child: TextField(
                    style: const TextStyle(color: Colors.white),
                    controller: specReqController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromRGBO(56, 48, 77, 1.0),
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide.none),
                      hintText: "เช่น ฝากวางหน้าบ้าน ตรงโต๊ะไม้หินอ่อน",
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 14),
                      prefixIcon: const Icon(Icons.edit, color: Colors.white),
                      suffixIcon: specReqController.text.isEmpty
                          ? Container(
                              width: 0,
                            )
                          : IconButton(
                              onPressed: () => specReqController.clear(),
                              icon: const Icon(
                                Icons.close_sharp,
                                color: Colors.white,
                              ),
                            ),
                    )),
              ),
              // Container of คำร้องขอพิเศษ

              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(children: [
                      ElevatedButton(
                          onPressed: () {},
                          child: Text(
                            "ยกเลิก",
                            style: TextStyle(fontSize: 17),
                          ),
                          style: ElevatedButton.styleFrom(primary: Colors.red))
                    ]),
                    Column(children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: Text(
                          "บันทึก",
                          style: TextStyle(fontSize: 17),
                        ),
                      )
                    ]),
                  ],
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
