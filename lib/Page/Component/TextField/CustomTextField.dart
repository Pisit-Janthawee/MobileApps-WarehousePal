import 'package:flutter/foundation.dart';

import '../../Provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const primary_color = Color.fromRGBO(56, 48, 77, 1);

class CustomTextField {
  final _formKey = GlobalKey<FormState>();

  static Widget textField(BuildContext context, String title, bool? _validate,
      {length,
      bool isNumber = false,
      Color? bgColor,
      required textController}) {
    bool _validate = false;
    return Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: bgColor != null
                ? bgColor
                : Theme.of(context).colorScheme.background.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15)),
        height: 80,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: TextFormField(
              validator: (v) {
                if (v == '' || v == null) {
                  return 'โปรดระบุ';
                }
              },
              textAlign: TextAlign.start,
              keyboardType:
                  isNumber ? TextInputType.number : TextInputType.text,
              // maxLength: length,
              inputFormatters: <TextInputFormatter>[
                isNumber
                    ? FilteringTextInputFormatter.digitsOnly
                    : LengthLimitingTextInputFormatter(length),
                LengthLimitingTextInputFormatter(length)
              ],
              controller: textController,
              //-----------------------------------------------------

              style: const TextStyle(color: Colors.white, fontSize: 12),
              cursorColor: primary_color,
              decoration: InputDecoration(
                errorText: _validate ? 'โปรดระบุ' : null, //
                contentPadding:
                    EdgeInsets.only(top: 25, bottom: 10, left: 10, right: 10),
                // labelText: title,
                fillColor: Theme.of(context).colorScheme.background,

                hoverColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20)),
                    borderSide: BorderSide.none),
                hintText: title,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                // prefixIcon: const Icon(Icons.local_shipping, color: Colors.white),
                suffixIcon: textController.text.isEmpty
                    ? Container(
                        width: 0,
                      )
                    : IconButton(
                        onPressed: () => textController.clear(),
                        icon: const Icon(
                          Icons.close_sharp,
                          color: Colors.white,
                        ),
                      ),
              )),
        ));
  }
}
