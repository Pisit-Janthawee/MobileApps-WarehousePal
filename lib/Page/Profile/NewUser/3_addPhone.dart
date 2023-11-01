import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:warehouse_mnmt/Page/Profile/NewUser/4_addProfileImg.dart';

import '../../../main.dart';
import '../../Provider/theme_provider.dart';
import 'package:warehouse_mnmt/Page/Component/TextField/CustomTextField.dart';

class AddPhonePage extends StatefulWidget {
  final String profileName;
  const AddPhonePage({Key? key, required this.profileName}) : super(key: key);

  @override
  State<AddPhonePage> createState() => _AddPhonePageState();
}

class _AddPhonePageState extends State<AddPhonePage> {
  final profilePhoneController = TextEditingController();

  void initState() {
    super.initState();
    profilePhoneController.addListener(() => setState(() {}));
  }

  Color txtFColor = Color.fromRGBO(56, 48, 77, 1.0);

  bool _validate = false;

  void _Validation(profileName) {
    setState(() {
      if (profilePhoneController.text.isEmpty ||
          profilePhoneController.text == null) {
        _validate = true;
      } else {
        _validate = false;
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     backgroundColor: Theme.of(context).backgroundColor,
        //     behavior: SnackBarBehavior.floating,
        //     content: Text("ถูกต้อง"),
        //     duration: Duration(seconds: 1),
        //   ),
        // );
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddImagePage(
                    profileName: profileName,
                    profilePhone: profilePhoneController.text,
                  )),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_pin,
                            color: Colors.white,
                          ),
                          Text(widget.profileName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: const Text(
                  "เบอร์โทรศัพท์ของคุณ",
                  style: TextStyle(color: Colors.white, fontSize: 22),
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
                    textAlign: TextAlign.start,
                    keyboardType: TextInputType.number,

                    // maxLength: length,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    controller: profilePhoneController,
                    //-----------------------------------------------------

                    style: const TextStyle(color: Colors.white),
                    cursorColor: primary_color,
                    decoration: InputDecoration(
                      errorText: _validate ? 'โปรดระบุ' : null, //here
                      errorStyle: TextStyle(fontSize: 12),
                      contentPadding: EdgeInsets.only(
                          top: 25, bottom: 10, left: 10, right: 10),
                      // labelText: title,
                      filled: true,
                      labelStyle: TextStyle(color: Colors.white),
                      counterStyle: TextStyle(color: Colors.white),
                      // fillColor: Theme.of(context).colorScheme.background,
                      focusColor: Color.fromARGB(255, 255, 0, 0),
                      hoverColor: Theme.of(context)
                          .colorScheme
                          .surface
                          .withOpacity(0.5),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.surface,
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
                      hintText: 'กรอกเบอร์โทรศัพท์ของคุณ',
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 14),
                      // prefixIcon: const Icon(Icons.local_shipping, color: Colors.white),
                      suffixIcon: profilePhoneController.text.isEmpty
                          ? Container(
                              width: 0,
                            )
                          : IconButton(
                              onPressed: () => profilePhoneController.clear(),
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
                    _Validation(widget.profileName);
                  },
                  child: Text('ยืนยัน'))
            ]),
          ),
        ),
      ),
    );
  }
}
