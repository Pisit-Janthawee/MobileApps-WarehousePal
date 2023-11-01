import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:warehouse_mnmt/Page/Model/Profile.dart';
import 'package:warehouse_mnmt/Page/Profile/EditProfile.dart';
import 'package:warehouse_mnmt/Page/Profile/NewUser/4_addProfileImg.dart';
import 'package:warehouse_mnmt/db/database.dart';

import '../../../main.dart';
import '../../Provider/theme_provider.dart';
import 'package:warehouse_mnmt/Page/Component/TextField/CustomTextField.dart';

class ChangeNewPhonePage extends StatefulWidget {
  final Profile profile;
  const ChangeNewPhonePage({Key? key, required this.profile}) : super(key: key);

  @override
  State<ChangeNewPhonePage> createState() => _ChangeNewPhonePageState();
}

class _ChangeNewPhonePageState extends State<ChangeNewPhonePage> {
  final profilePhoneController = TextEditingController();

  void initState() {
    super.initState();
    profilePhoneController.addListener(() => setState(() {}));
  }

  Color txtFColor = Color.fromRGBO(56, 48, 77, 1.0);

  bool _validate = false;
  Future updateProfile() async {
    final profile = widget.profile.copy(phone: profilePhoneController.text);
    await DatabaseManager.instance.updateProfile(profile);
  }

  Profile? profile;
  Future getProfile() async {
    this.profile =
        await DatabaseManager.instance.readProfile(widget.profile.id!);
  }

  void _Validation() {
    setState(() {
      if (profilePhoneController.text.isEmpty ||
          profilePhoneController.text == null) {
        _validate = true;
      } else {
        _validate = false;
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text("อัพเดทข้อมูล ${widget.profile.phone}"),
        //     duration: Duration(seconds: 2),
        //   ),
        // );
        int count = 0;
        Navigator.of(
          context,
        ).popUntil((_) => count++ >= 2);
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
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          File(widget.profile.image),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: const Text(
                  "เบอร์โทรศัพท์ใหม่ของคุณ",
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
                    _Validation();
                    updateProfile();
                  },
                  child: Text('ยืนยัน'))
            ]),
          ),
        ),
      ),
    );
  }
}
