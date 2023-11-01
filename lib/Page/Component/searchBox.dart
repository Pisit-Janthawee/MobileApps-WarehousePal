import 'package:flutter/material.dart';
import 'package:warehouse_mnmt/Page/Component/SearchBoxController.dart';

class SearchBox extends StatefulWidget {
  String title;
  SearchBox(this.title);
  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  final controller = TextEditingController();
  void initState() {
    super.initState();
    controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).colorScheme.background,
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20)),
              borderSide: BorderSide.none),
          hintText: widget.title,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          suffixIcon: !controller.text.isEmpty
              ? IconButton(
                  onPressed: () => controller.clear(),
                  icon: const Icon(
                    Icons.close_sharp,
                    color: Colors.white,
                  ),
                )
              : null,
        ));
  }
}
