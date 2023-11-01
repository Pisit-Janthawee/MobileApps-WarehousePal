import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:warehouse_mnmt/Page/Component/Dialog/CustomDialog.dart';
import 'package:warehouse_mnmt/Page/Profile/AllShop.dart';

import '../../../main.dart';

import '../../Provider/theme_provider.dart';
import 'package:warehouse_mnmt/Page/Component/TextField/CustomTextField.dart';

import '5_addPin.dart';

class AddImagePage extends StatefulWidget {
  final String profileName;
  final String profilePhone;

  const AddImagePage({
    Key? key,
    required this.profileName,
    required this.profilePhone,
  }) : super(key: key);

  @override
  State<AddImagePage> createState() => _AddImagePageState();
}

class _AddImagePageState extends State<AddImagePage> {
  final profilePhoneController = TextEditingController();
  File? _image;

  void initState() {
    super.initState();
    profilePhoneController.addListener(() => setState(() {}));
  }

  Future getImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final imageTemporary = File(image.path);
    print(_image);
    print(_image.runtimeType);

    setState(() {
      _image = imageTemporary;
    });
    return imageTemporary;
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
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: const Text(
                  "รูปโปรไฟล์",
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
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
              const SizedBox(
                height: 10,
              ),
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
                          Text(
                              widget.profilePhone.replaceAllMapped(
                                  RegExp(r'(\d{3})(\d{3})(\d+)'),
                                  (Match m) => "${m[1]}-${m[2]}-${m[3]}"),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: Stack(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _image != null
                        ? Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(
                                _image!,
                                width: 180,
                                height: 180,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Center(
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Color.fromARGB(255, 202, 202, 202),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    fixedSize: const Size(180, 180)),
                                onPressed: () {
                                  getImage();
                                  setState(() {});
                                },
                                child: const Text(
                                  'เลือกรูป',
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Color.fromARGB(255, 94, 94, 94)),
                                )),
                          ),
                    Positioned(
                      top: 0.0,
                      right: 0.0,
                      child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.7),
                                  spreadRadius: 0,
                                  blurRadius: 5,
                                  offset: Offset(0, 4))
                            ],
                            color: Color.fromARGB(255, 255, 255, 255),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add_photo_alternate_outlined,
                                size: 25,
                                color: Color.fromARGB(255, 94, 94, 94)),
                            onPressed: () {
                              getImage();
                              setState(() {});
                            },
                          )),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(fixedSize: const Size(80, 40)),
                  onPressed: () {
                    if (_image != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddPinPage(
                                  profileName: widget.profileName,
                                  profilePhone: widget.profilePhone,
                                  profileImg: _image!.path,
                                )),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.redAccent,
                          content: Text("โปรดเลือกรูปภาพ"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Text('ยืนยัน'))
            ]),
          ),
        ),
      ),
    );
  }
}
