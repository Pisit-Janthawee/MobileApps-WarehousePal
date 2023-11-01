import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:warehouse_mnmt/Page/Model/Profile.dart';
import 'package:warehouse_mnmt/Page/Profile/ChangePin/2_ChangeNewPin.dart';
import 'package:warehouse_mnmt/Page/Profile/EditProfile.dart';
import 'package:warehouse_mnmt/Page/Profile/NewUser/4_addProfileImg.dart';
import 'package:warehouse_mnmt/db/database.dart';

import '../../../main.dart';
import '../../Provider/theme_provider.dart';
import 'package:warehouse_mnmt/Page/Component/TextField/CustomTextField.dart';

class VerifyPhonePage extends StatefulWidget {
  final Profile profile;
  const VerifyPhonePage({Key? key, required this.profile}) : super(key: key);

  @override
  State<VerifyPhonePage> createState() => _VerifyPhonePageState();
}

class _VerifyPhonePageState extends State<VerifyPhonePage> {
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
  bool isWrong = false;
  Future getProfile() async {
    this.profile =
        await DatabaseManager.instance.readProfile(widget.profile.id!);
  }

  void _Validation() {
    setState(() {
      if (profilePhoneController.text == widget.profile.phone) {
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => ChangeNewPinPage(
                      profile: widget.profile,
                    )));
      } else {
        if (profilePhoneController.text.isEmpty ||
            profilePhoneController.text == null) {
          isWrong = false;
          _validate = true;
        } else {
          _validate = false;
          isWrong = true;
          setState(() {});
        }
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
                  "ยืนยันตัวตน",
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
              isWrong
                  ? Text("เบอร์โทรศัพท์ไม่ถูกต้อง",
                      // ignore: prefer_const_constructors
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ))
                  : Container(),
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
                  },
                  child: Text('ยืนยัน'))
            ]),
          ),
        ),
      ),
    );
  }
}
