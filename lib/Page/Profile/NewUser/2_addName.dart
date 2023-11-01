import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../../../main.dart';
import '../../Provider/theme_provider.dart';
import 'package:warehouse_mnmt/Page/Component/TextField/CustomTextField.dart';

import '3_addPhone.dart';

class AddNamePage extends StatefulWidget {
  const AddNamePage({Key? key}) : super(key: key);

  @override
  State<AddNamePage> createState() => _AddNamePageState();
}

class _AddNamePageState extends State<AddNamePage> {
  final profileNameController = TextEditingController();

  void initState() {
    super.initState();
    profileNameController.addListener(() => setState(() {}));
  }

  Color txtFColor = Color.fromRGBO(56, 48, 77, 1.0);

  bool _validate = false;
  void _Validation() {
    setState(() {
      if (profileNameController.text.isEmpty ||
          profileNameController.text == null) {
        _validate = true;
      } else {
        _validate = false;

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddPhonePage(
                    profileName: profileNameController.text,
                  )),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: const Text(
                  "สร้างโปรไฟล์ของคุณ",
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              // CustomTextField.textField(
              //     bgColor: const Color.fromRGBO(56, 48, 77, 1.0),
              //     context,
              //     length: 30,
              //     textController: profileNameController,
              //     'กำหนดชื่อโปรไฟล์ของคุณ'),
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
                          ? 'ชื่อของคุณว่าง โปรดตั้งชื่อ'
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
                      hintText: 'กำหนดชื่อโปรไฟล์ของคุณ',
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
                  child: Text('ยืนยัน'))
            ]),
          ),
        ),
      ),
    );
  }
}
