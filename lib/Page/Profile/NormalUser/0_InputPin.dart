import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:warehouse_mnmt/Page/Model/Profile.dart';
import 'package:warehouse_mnmt/Page/Profile/AllShop.dart';
import 'package:warehouse_mnmt/Page/Profile/NormalUser/DisableWrongPin.dart';
import 'package:warehouse_mnmt/Page/Profile/NormalUser/ForgetPassword/1_PhoneVerify.dart';
import 'package:warehouse_mnmt/db/database.dart';

class InputPinPage extends StatefulWidget {
  Profile profile;

  InputPinPage({Key? key, required this.profile}) : super(key: key);

  @override
  State<InputPinPage> createState() => _InputPinPageState();
}

class _InputPinPageState extends State<InputPinPage> {
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // ignore: prefer_const_constructors
        decoration: BoxDecoration(
            // ignore: prefer_const_constructors
            gradient: LinearGradient(
          // ignore: prefer_const_literals_to_create_immutables
          colors: [
            Color.fromRGBO(29, 29, 65, 1.0),
            Color.fromRGBO(31, 31, 31, 1.0),
          ],
          begin: Alignment.topCenter,
        )),
        child: OtpScreen(profile: widget.profile),
      ),
    );
  }
}

class OtpScreen extends StatefulWidget {
  Profile profile;

  OtpScreen({
    Key? key,
    required this.profile,
  }) : super(key: key);

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  List<String> currentPin = ['', '', '', '', '', ''];
  TextEditingController pinOneController = TextEditingController();
  TextEditingController pinTwoController = TextEditingController();
  TextEditingController pinThreeController = TextEditingController();
  TextEditingController pinFourController = TextEditingController();
  TextEditingController pinFiveController = TextEditingController();
  TextEditingController pinSixController = TextEditingController();

  var outlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
    // ignore: prefer_const_constructors
    borderSide: BorderSide(color: Colors.transparent),
  );
  Profile? profile;
  void initState() {
    super.initState();
    refreshProfile();
  }

  int pinIndex = 0;
  bool isWrong = false;
  Future refreshProfile() async {
    profile = await DatabaseManager.instance.readProfile(widget.profile.id!);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          // buildExitButton(),
          Expanded(
            child: Container(
              alignment: Alignment(0, 0.5),
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  buildSecurityText(),
                  SizedBox(height: 40.0),
                  buildPinRow(),
                ],
              ),
            ),
          ),
          buildNumberPad(),
        ],
      ),
    );
  }

  buildNumberPad() {
    return Expanded(
      child: Container(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  KeyboardNumber(
                    n: 1,
                    onPressed: () {
                      pinIndexSetup("1");
                    },
                  ),
                  KeyboardNumber(
                    n: 2,
                    onPressed: () {
                      pinIndexSetup("2");
                    },
                  ),
                  KeyboardNumber(
                    n: 3,
                    onPressed: () {
                      pinIndexSetup("3");
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  KeyboardNumber(
                    n: 4,
                    onPressed: () {
                      pinIndexSetup("4");
                    },
                  ),
                  KeyboardNumber(
                    n: 5,
                    onPressed: () {
                      pinIndexSetup("5");
                    },
                  ),
                  KeyboardNumber(
                    n: 6,
                    onPressed: () {
                      pinIndexSetup("6");
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  KeyboardNumber(
                    n: 7,
                    onPressed: () {
                      pinIndexSetup("7");
                    },
                  ),
                  KeyboardNumber(
                    n: 8,
                    onPressed: () {
                      pinIndexSetup("8");
                    },
                  ),
                  KeyboardNumber(
                    n: 9,
                    onPressed: () {
                      pinIndexSetup("9");
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    width: 60.0,
                    // ignore: prefer_const_constructors
                    child: MaterialButton(
                      onPressed: null,
                      child: SizedBox(),
                    ),
                  ),
                  KeyboardNumber(
                    n: 0,
                    onPressed: () {
                      pinIndexSetup("0");
                    },
                  ),
                  Container(
                    width: 60.0,
                    child: MaterialButton(
                      height: 60.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(60.0),
                      ),
                      onPressed: () {
                        clearPin();
                      },
                      child: Icon(
                        Icons.backspace,
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => ForgetPin_VerifyPhonePage(
                                      profile: widget.profile,
                                    )));
                      },
                      child: Text(
                        'ลืมรหัส ?',
                        style: TextStyle(color: Colors.redAccent),
                      )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  clearPin() {
    if (pinIndex == 0)
      pinIndex = 0;
    else if (pinIndex == 6) {
      setPin(pinIndex, '');
      currentPin[pinIndex - 1] == '';
      pinIndex--;
    } else {
      setPin(pinIndex, '');
      currentPin[pinIndex - 1] = '';
      pinIndex--;
    }
  }

  var invalidCount = 0;
  Future _forgotPinWarningDialog() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            title: new Text('คุณลืมรหัส ?'),
            content: new Text('หากผิดเกิน 5 ครั้งระบบจะระงับการใช้งาน 5 นาที'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context), //<-- SEE HERE
                child: Text(
                  'ไม่',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => ForgetPin_VerifyPhonePage(
                                profile: widget.profile,
                              )));
                }, // <-- SEE HERE
                child: Text('ลืมรหัส', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        )) ??
        false;
  }

  validationProfilePin(pin) async {
    if (invalidCount != 5) {
      if (pin == widget.profile.pin) {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AllShopPage(
                      profile: widget.profile,
                    )));
        Navigator.of(context).pop(true);
      } else if (invalidCount == 3) {
        _forgotPinWarningDialog();
        for (var i = 0; i < 6; i++) {
          clearPin();
        }
        setState(() {
          isWrong = true;
          invalidCount++;
        });
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   behavior: SnackBarBehavior.floating,
        //   backgroundColor: Theme.of(context).backgroundColor,
        //   content: Text("รหัสไม่ถูกต้อง"),
        //   duration: Duration(seconds: 2),
        // ));
        for (var i = 0; i < 6; i++) {
          clearPin();
        }

        setState(() {
          isWrong = true;
          invalidCount++;
        });
        print('Wrong : ${invalidCount}');
      }
    } else {
      DateTime date = DateTime.now();

      Duration addDuration = Duration(minutes: 5);

      final addedDuration = widget.profile!
          .copy(isDisable: true, loginDateTime: date.add(addDuration));

      await DatabaseManager.instance.updateProfile(addedDuration);

      await refreshProfile();

      print(
          'Start isDisable ${profile!.isDisable} Widget loginDateTime ${widget.profile!.loginDateTime} loginDateTime ${profile!.loginDateTime}');

      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DisableWrongPinPage(
                    profile: profile!,
                  )));
    }
  }

  pinIndexSetup(String text) {
    if (pinIndex == 0)
      pinIndex = 1;
    else if (pinIndex < 6) pinIndex++;
    setPin(pinIndex, text);
    currentPin[pinIndex - 1] = text;
    String strPin = '';
    currentPin.forEach((e) {
      strPin += e;
    });
    if (pinIndex == 6) {
      print(["Login Pin", strPin]);
      print(strPin);
      validationProfilePin(strPin);
    }
  }

  setPin(int n, String text) {
    switch (n) {
      case 1:
        pinOneController.text = text;
        break;
      case 2:
        pinTwoController.text = text;
        break;
      case 3:
        pinThreeController.text = text;
        break;
      case 4:
        pinFourController.text = text;
        break;
      case 5:
        pinFiveController.text = text;
        break;
      case 6:
        pinSixController.text = text;
        break;
    }
  }

  buildPinRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        PINNumber(
          outlineInputBorder: outlineInputBorder,
          textEditingController: pinOneController,
        ),
        PINNumber(
          outlineInputBorder: outlineInputBorder,
          textEditingController: pinTwoController,
        ),
        PINNumber(
          outlineInputBorder: outlineInputBorder,
          textEditingController: pinThreeController,
        ),
        PINNumber(
          outlineInputBorder: outlineInputBorder,
          textEditingController: pinFourController,
        ),
        PINNumber(
          outlineInputBorder: outlineInputBorder,
          textEditingController: pinFiveController,
        ),
        PINNumber(
          outlineInputBorder: outlineInputBorder,
          textEditingController: pinSixController,
        ),
      ],
    );
  }

  buildSecurityText() {
    // ignore: prefer_const_constructors
    return Container(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Container(
                color: Theme.of(context).colorScheme.background,
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: widget.profile?.image == null
                        ? Icon(
                            Icons.image,
                            color: Colors.white,
                          )
                        : Image.file(
                            File(widget.profile!.image),
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                  ),
                )),
          ),
          const Text(
            "ยืนยันตัวตน",
            // ignore: prefer_const_constructors
            style: TextStyle(
              color: Colors.white,
              fontSize: 21.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Text(
          //   "${widget.profile.loginDateTime}",
          //   // ignore: prefer_const_constructors
          //   style: TextStyle(
          //     color: Colors.white,
          //     fontSize: 21.0,
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
          isWrong
              ? invalidCount == 5
                  ? Text(
                      "ครั้งสุดท้าย",
                      style: TextStyle(color: Colors.redAccent, fontSize: 15),
                    )
                  : Text(
                      "รหัสไม่ถูกต้อง ${invalidCount}",
                      style: TextStyle(color: Colors.redAccent, fontSize: 15),
                    )
              : Container(),
        ],
      ),
    );
  }
}

class PINNumber extends StatelessWidget {
  final TextEditingController textEditingController;
  final OutlineInputBorder outlineInputBorder;
  PINNumber(
      {required this.textEditingController, required this.outlineInputBorder});
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 50.0,
        child: TextField(
          controller: textEditingController,
          enabled: false,
          obscureText: true,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              filled: true,
              fillColor: const Color.fromRGBO(50, 224, 119, 1.0)),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15.0,
            color: Colors.white,
          ),
        ));
  }
}

class KeyboardNumber extends StatelessWidget {
  final int n;
  final Function() onPressed;
  KeyboardNumber({required this.n, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60.0,
      height: 60.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.deepPurpleAccent.withOpacity(0.1),
      ),
      alignment: Alignment.center,
      child: MaterialButton(
        padding: EdgeInsets.all(8.0),
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(60.0),
        ),
        height: 90.0,
        child: Text(
          "$n",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26 * MediaQuery.of(context).textScaleFactor,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
