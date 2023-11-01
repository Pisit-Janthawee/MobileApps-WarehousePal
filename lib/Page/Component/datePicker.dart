import 'package:flutter/material.dart';

class datePicker extends StatefulWidget {
  const datePicker({Key? key}) : super(key: key);

  @override
  State<datePicker> createState() => _datePickerState();
}

class _datePickerState extends State<datePicker> {
  DateTime date = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: Color.fromRGBO(56, 48, 77, 1.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Row(
          children: [
            Icon(Icons.calendar_month),
            Spacer(),
            Text('${date.day}/${date.month}/${date.year}')
          ],
        ),
      ),
      onPressed: () async {
        DateTime? newDate = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
            builder: (context, child) => Theme(
                  data: ThemeData().copyWith(
                    colorScheme: ColorScheme.dark(
                      primary: Colors.white,
                      onPrimary: Theme.of(context).backgroundColor,
                      surface: Theme.of(context).colorScheme.onBackground,
                      onSurface: Colors.white,
                    ),
                    dialogBackgroundColor:
                        Theme.of(context).colorScheme.background,
                  ),
                  child: child!,
                ));
        // 'Cancel' => null
        if (newDate == null) return;

        // 'OK' => DateTime
        setState(() => date = newDate);
      },
    );
  }
}
