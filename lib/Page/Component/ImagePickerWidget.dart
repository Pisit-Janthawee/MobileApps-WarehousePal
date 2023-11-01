import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'ImagePickerController.dart';

class ImagePickerWidget extends StatefulWidget {
  final ImagePickerController controller;

  const ImagePickerWidget({required this.controller, Key? key})
      : super(key: key);

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _image;

  Future getImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      widget.controller.xfile = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 200,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          if (widget.controller.path != null)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  widget.controller.file!,
                  width: 180,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        getImage();
                      },
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image,
                              size: 100,
                              color: Color.fromRGBO(75, 75, 75, 1.0),
                              // Theme.of(context)
                              //     .colorScheme
                              //     .background
                              //     .withOpacity(0.9)
                            ),
                            Text(
                              "โปรดเลือกรูป",
                              style: TextStyle(
                                color: Color.fromRGBO(75, 75, 75, 1.0),
                              ),
                            )
                          ]),
                      style: ElevatedButton.styleFrom(
                          fixedSize: Size(180, 180),
                          primary: Color.fromRGBO(175, 175, 175, 1.0))),
                ],
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
                  icon: const Icon(Icons.add_photo_alternate_outlined,
                      size: 25, color: Color.fromARGB(255, 94, 94, 94)),
                  onPressed: () async {
                    await getImage();
                  },
                )),
          ),
        ],
      ),
    );
  }
}
