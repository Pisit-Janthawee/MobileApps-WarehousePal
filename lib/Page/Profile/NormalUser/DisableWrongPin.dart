import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:warehouse_mnmt/Page/Model/Profile.dart';

// Components

// Models
import 'package:warehouse_mnmt/Page/Model/Shop.dart';
import 'package:warehouse_mnmt/Page/Profile/1_addShopName.dart';
import 'package:warehouse_mnmt/Page/Profile/NormalUser/0_InputPin.dart';
import 'package:warehouse_mnmt/Page/Provider/theme_provider.dart';
import 'package:warehouse_mnmt/db/database.dart';
import 'package:warehouse_mnmt/main.dart';

class DisableWrongPinPage extends StatefulWidget {
  final Profile profile;
  const DisableWrongPinPage({
    required this.profile,
    Key? key,
  }) : super(key: key);

  @override
  State<DisableWrongPinPage> createState() => _DisableWrongPinPageState();
}

class _DisableWrongPinPageState extends State<DisableWrongPinPage> {
  bool isLoading = false;
  List<Shop> shops = [];
  Profile? profile;

  @override
  void initState() {
    profile = widget.profile;
    print(
        'Received Profile isDisable ${profile!.isDisable} loginDateTime ${profile!.loginDateTime}');
    DateTime loginTime = DateTime.parse(
        DateFormat("yyyy-MM-dd hh:mm:ss").format(profile!.loginDateTime!));

    super.initState();
    startTimer();

    updatedProfile();
    setState(() {});
  }

  DateTime date = DateTime.now();

  Timer? countdownTimer;

  // IF Fail
  late Duration addDuration = profile!.loginDateTime!.difference(date);
  void startTimer() async {
    countdownTimer =
        Timer.periodic(Duration(seconds: 1), (_) => setCountDown());

    ;
  }

  // ELSE Out of Apps
  // late Duration waitingDuration = profile!.loginDateTime.difference(date);
  Future updatedProfile() async {
    print('Add Duration !! ${date.add(addDuration)}');

    final addedDuration =
        profile!.copy(isDisable: true, loginDateTime: date.add(addDuration));
    await DatabaseManager.instance.updateProfile(addedDuration);
    profile = await DatabaseManager.instance.readProfile(widget.profile.id!);
    setState(() {});
  }

  void setCountDown() {
    final reduceSecondsBy = 1;
    setState(() {
      final seconds = addDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        countdownTimer!.cancel();
        isLoading = true;
      } else {
        addDuration = Duration(seconds: seconds);
      }
    });
  }

  // Step 4
  void stopTimer() {
    setState(() => countdownTimer!.cancel());
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');

    final hours = strDigits(addDuration.inHours.remainder(24));
    final minutes = strDigits(addDuration.inMinutes.remainder(60));
    final seconds = strDigits(addDuration.inSeconds.remainder(60));

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            height: (MediaQuery.of(context).size.height),
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
                padding: const EdgeInsets.all(10.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                          width: 150,
                          height: 150,
                          child: Image.asset('assets/Icons/Warehouse.png')),
                      isLoading
                          ? Text(
                              'สิ้นสุดการรอ!',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 50),
                            )
                          : isLoading
                              ? Text(
                                  'ยินดีต้อนรับ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 40),
                                )
                              : Text(
                                  '$hours:$minutes:$seconds',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 50),
                                ),
                      isLoading
                          ? Container()
                          : Text(
                              'ถึง ${DateFormat.Hms().format(profile!.loginDateTime!)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 20),
                            ),
                      isLoading
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(80, 40)),
                              onPressed: () async {
                                await DatabaseManager.instance.updateProfile(
                                    profile!.copy(
                                        isDisable: false, loginDateTime: null));

                                profile = await DatabaseManager.instance
                                    .readProfile(widget.profile.id!);
                                setState(() {});

                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) => InputPinPage(
                                              profile: profile!,
                                            )));
                              },
                              child: Text('ถัดไป'))
                          : SizedBox(height: 20),
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
