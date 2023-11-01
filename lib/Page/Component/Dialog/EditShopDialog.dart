import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../Model/Shop.dart';

class ShowEditShopDialog extends StatefulWidget {
  final Shop shop;
  const ShowEditShopDialog({required this.shop, Key? key}) : super(key: key);

  @override
  State<ShowEditShopDialog> createState() => _ShowEditShopDialogState();
}

class _ShowEditShopDialogState extends State<ShowEditShopDialog> {
  final shopNameController = TextEditingController();
  bool _validate = false;
  final shopPhoneController = TextEditingController();
  File? _image;
  Future getImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final imageTemporary = File(image.path);
    print(_image);
    print(_image.runtimeType);

    setState(() {
      _image = imageTemporary;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0)), //this right here
      child: SizedBox(
        height: 400,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                      // color: Theme.of(context).colorScheme.background,
                      borderRadius: BorderRadius.circular(15)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 30,
                      ),
                      Text(
                        'แก้ไขร้านค้า',
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 25,
                          // fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
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
                      if (_image != null)
                        Center(
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
                      else
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              File(widget.shop.image),
                              width: 180,
                              height: 180,
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
                const SizedBox(
                  height: 10,
                ),
                Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .background
                            .withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15)),
                    width: 400,
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
                          controller: shopNameController,
                          //-----------------------------------------------------

                          style: const TextStyle(color: Colors.white),
                          cursorColor: Theme.of(context).colorScheme.background,
                          decoration: InputDecoration(
                            errorText: _validate ? 'โปรดระบุ' : null, //
                            contentPadding: EdgeInsets.only(
                                top: 25, bottom: 10, left: 10, right: 10),
                            // labelText: title,
                            filled: true,
                            labelStyle: TextStyle(color: Colors.white),
                            counterStyle: TextStyle(color: Colors.white),
                            // fillColor: Theme.of(context).colorScheme.background,
                            focusColor: Color.fromARGB(255, 255, 0, 0),
                            hoverColor: Colors.white,

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
                            hintText: widget.shop.name,
                            hintStyle: const TextStyle(
                                color: Colors.grey, fontSize: 14),
                            prefixIcon: const Icon(Icons.person_pin,
                                color: Colors.white),
                            suffixIcon: shopNameController.text.isEmpty
                                ? Container(
                                    width: 0,
                                  )
                                : IconButton(
                                    onPressed: () => shopNameController.clear(),
                                    icon: const Icon(
                                      Icons.close_sharp,
                                      color: Colors.white,
                                    ),
                                  ),
                          )),
                    )),
                const SizedBox(
                  height: 10,
                ),
                Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .background
                            .withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15)),
                    width: 400,
                    height: 80,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: TextFormField(
                          textAlign: TextAlign.start,
                          keyboardType: TextInputType.number,
                          // maxLength: length,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                          ],
                          controller: shopPhoneController,
                          //-----------------------------------------------------

                          style: const TextStyle(color: Colors.white),
                          cursorColor: Theme.of(context).colorScheme.background,
                          decoration: InputDecoration(
                            errorText: _validate ? 'โปรดระบุ' : null, //
                            contentPadding: EdgeInsets.only(
                                top: 25, bottom: 10, left: 10, right: 10),
                            // labelText: title,
                            filled: true,
                            labelStyle: TextStyle(color: Colors.white),
                            counterStyle: TextStyle(color: Colors.white),
                            // fillColor: Theme.of(context).colorScheme.background,
                            focusColor: Color.fromARGB(255, 255, 0, 0),
                            hoverColor: Colors.white,

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
                            hintText: widget.shop.phone,
                            hintStyle: const TextStyle(
                                color: Colors.grey, fontSize: 14),
                            prefixIcon: const Icon(Icons.phone_in_talk,
                                color: Colors.white),
                            suffixIcon: shopPhoneController.text.isEmpty
                                ? Container(
                                    width: 0,
                                  )
                                : IconButton(
                                    onPressed: () =>
                                        shopPhoneController.clear(),
                                    icon: const Icon(
                                      Icons.close_sharp,
                                      color: Colors.white,
                                    ),
                                  ),
                          )),
                    )),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            fixedSize: const Size(80, 40)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('ยืนยัน')),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.redAccent,
                            fixedSize: const Size(80, 40)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('ยกเลิก')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
