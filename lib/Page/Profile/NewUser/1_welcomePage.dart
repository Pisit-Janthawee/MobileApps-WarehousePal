// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:warehouse_mnmt/Page/Profile/NewUser/2_addName.dart';

class BuildingScreen extends StatefulWidget {
  const BuildingScreen({Key? key}) : super(key: key);

  @override
  State<BuildingScreen> createState() => _BuildingScreenState();
}

class _BuildingScreenState extends State<BuildingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ignore: prefer_const_literals_to_create_immutables
      // Blackgroud
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
        child: SafeArea(
          child: Center(
            // ignore: prefer_const_literals_to_create_immutables
            child: Column(mainAxisAlignment: MainAxisAlignment.center,
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  Container(
                      width: 150,
                      height: 150,
                      child: Image.asset('assets/Icons/Warehouse.png')),

                  // เริ่มสร้างร้านค้าของคุณ text
                  Text('เริ่มสร้างร้านค้าของคุณ',
                      style: TextStyle(
                          color: Colors.white,
                          // fontWeight: FontWeight.bold,
                          fontSize: 22)),

                  // สร้างเลย button
                  SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).backgroundColor,
                    ),
                    child: Text(
                      'สร้างเลย',
                      style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 20),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddNamePage()),
                      );
                    },
                  )
                ]),
          ),
        ),
      ),
    );
  }
}
