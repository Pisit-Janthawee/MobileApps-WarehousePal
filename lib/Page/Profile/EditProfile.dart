import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:image_picker/image_picker.dart';

import 'package:warehouse_mnmt/Page/Component/TextField/CustomTextField.dart';
import 'package:warehouse_mnmt/Page/Profile/ChangePin/1_PhoneVerify.dart';

import '../../db/database.dart';
import '../Model/Profile.dart';
import 'ChangePhone/1_PinVerify.dart';

class EditProfilePage extends StatefulWidget {
  final Profile profile;

  EditProfilePage({Key? key, required this.profile}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

File? _image;

class _EditProfilePageState extends State<EditProfilePage> {
  Profile? profile;
  bool isNameChange = false;
  bool isHidePin = true;
  late final profileNameController =
      TextEditingController(text: widget.profile.name);

  @override
  void initState() {
    super.initState();
    profile = widget.profile;
    profileNameController.addListener(() => setState(() {}));
  }

  Future updateProfileImage() async {
    final profile = widget.profile.copy(
      image: _image == null ? widget.profile.image : _image?.path,
    );
    await DatabaseManager.instance.updateProfile(profile);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("เปลี่ยนรูปภาพ"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future updateProfileName() async {
    final profile = widget.profile.copy(
      image: _image == null ? widget.profile.image : _image?.path,
      name: profileNameController.text,
    );
    await DatabaseManager.instance.updateProfile(profile);
  }

  Future refreshProfile() async {
    profile = await DatabaseManager.instance.readProfile(widget.profile.id!);
  }

  Future getImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final imageTemporary = File(image.path);

    setState(() {
      _image = imageTemporary;
      updateProfileImage();
    });
    return imageTemporary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "ร้านของฉัน",
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        backgroundColor: Color.fromRGBO(30, 30, 65, 1.0),
      ),
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
                padding: const EdgeInsets.only(
                    top: 110, bottom: 10, left: 10, right: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: (MediaQuery.of(context).size.width / 2),
                      width: (MediaQuery.of(context).size.width / 2),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: Stack(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_image != null)
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(
                                  _image!,
                                  width:
                                      (MediaQuery.of(context).size.width / 2.1),
                                  height:
                                      (MediaQuery.of(context).size.width / 2.1),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          else
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(
                                  File(widget.profile.image),
                                  width:
                                      (MediaQuery.of(context).size.width / 2.1),
                                  height:
                                      (MediaQuery.of(context).size.width / 2.1),
                                  fit: BoxFit.cover,
                                ),
                              ),
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
                                  icon: const Icon(
                                      Icons.add_photo_alternate_outlined,
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
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: Column(children: [
                        Row(
                          children: [
                            const Text(
                              "ชื่อผู้ใช้",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(56, 48, 77, 1),
                                borderRadius: BorderRadius.circular(15)),
                            height: 80,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: TextFormField(
                                  textAlign: TextAlign.start,
                                  keyboardType: TextInputType.text,
                                  // maxLength: length,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(30),
                                  ],
                                  controller: profileNameController,
                                  //-----------------------------------------------------
                                  onFieldSubmitted: (context) {
                                    setState(() {
                                      updateProfileName();
                                      refreshProfile();
                                      isNameChange == !isNameChange;
                                      profileNameController.clear();
                                    });
                                    setState(() {});
                                  },
                                  style: const TextStyle(color: Colors.white),
                                  cursorColor: primary_color,
                                  decoration: InputDecoration(
                                    // errorText:
                                    //     _validate ? 'โปรดระบุ' : null, //
                                    contentPadding: EdgeInsets.only(
                                        top: 25,
                                        bottom: 10,
                                        left: 10,
                                        right: 10),
                                    // labelText: title,
                                    filled: true,
                                    labelStyle: TextStyle(color: Colors.white),
                                    counterStyle:
                                        TextStyle(color: Colors.white),
                                    fillColor: Color.fromRGBO(56, 48, 77, 1),
                                    focusColor: Color.fromARGB(255, 255, 0, 0),
                                    hoverColor: Colors.white,

                                    // border: const OutlineInputBorder(
                                    //   borderRadius: BorderRadius.all(
                                    //     Radius.circular(10.0),
                                    //   ),
                                    //   borderSide: BorderSide(
                                    //     color: Colors.green,
                                    //   ),
                                    // ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                      ),
                                    ),
                                    hintText: profile!.name,
                                    hintStyle: const TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                    prefixIcon: const Icon(Icons.person_pin,
                                        color: Colors.white),
                                    suffixIcon:
                                        profileNameController.text.isEmpty
                                            ? Container(
                                                width: 0,
                                              )
                                            : IconButton(
                                                onPressed: () {
                                                  profileNameController.clear();
                                                },
                                                icon: const Icon(
                                                  Icons.close_sharp,
                                                  color: Colors.white,
                                                ),
                                              ),
                                  )),
                            )),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const Text(
                              "เบอร์โทรศัพท์",
                              style: TextStyle(color: Colors.white),
                            ),
                            Spacer(),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(0),
                              elevation: 0,
                              primary: Colors.transparent),
                          onPressed: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PinVerifyPage(
                                          profile: widget.profile,
                                        )));
                            refreshProfile();
                            setState(() {});
                          },
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(56, 48, 77, 1),
                                borderRadius: BorderRadius.circular(15)),
                            child: Row(children: [
                              const Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: const Icon(
                                  Icons.phone_in_talk,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              Text(
                                profile!.phone.replaceAllMapped(
                                    RegExp(r'(\d{3})(\d{3})(\d+)'),
                                    (Match m) => "${m[1]}-${m[2]}-${'XXXX'}"),
                                style: TextStyle(
                                    color: Color.fromARGB(255, 136, 136, 136),
                                    fontSize: 14),
                              ),
                            ]),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const Text(
                              "PIN",
                              style: TextStyle(color: Colors.white),
                            ),
                            Spacer(),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(0),
                              elevation: 0,
                              primary: Colors.transparent),
                          onPressed: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => VerifyPhonePage(
                                          profile: profile!,
                                        )));
                            refreshProfile();
                            setState(() {});
                          },
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(56, 48, 77, 1),
                                borderRadius: BorderRadius.circular(15)),
                            child: Row(children: [
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Icon(
                                  Icons.lock_open,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 10),
                              Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Color.fromARGB(255, 136, 136, 136),
                                    size: 10,
                                  ),
                                  SizedBox(width: 3),
                                  Icon(
                                    Icons.circle,
                                    color: Color.fromARGB(255, 136, 136, 136),
                                    size: 10,
                                  ),
                                  SizedBox(width: 3),
                                  Icon(
                                    Icons.circle,
                                    color: Color.fromARGB(255, 136, 136, 136),
                                    size: 10,
                                  ),
                                  SizedBox(width: 3),
                                  Icon(
                                    Icons.circle,
                                    color: Color.fromARGB(255, 136, 136, 136),
                                    size: 10,
                                  ),
                                  SizedBox(width: 3),
                                  Icon(
                                    Icons.circle,
                                    color: Color.fromARGB(255, 136, 136, 136),
                                    size: 10,
                                  ),
                                  SizedBox(width: 3),
                                  Icon(
                                    Icons.circle,
                                    color: Color.fromARGB(255, 136, 136, 136),
                                    size: 10,
                                  ),
                                ],
                              )
                            ]),
                          ),
                        ),
                      ]),
                    )
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
