import 'package:flutter/material.dart';

class DisplayTextFieldWidget extends StatefulWidget {
  final String initialText;
  final bool isEditable;
  const DisplayTextFieldWidget({super.key, required this.initialText, this.isEditable = false});
  

  // void toggleEditable() {
  //   isEditable = !isEditable;
  // }
  
  @override
  State<DisplayTextFieldWidget> createState() => _DisplayTextFieldWidgetState();
}

class _DisplayTextFieldWidgetState extends State<DisplayTextFieldWidget> {
  late bool _isEditable;

  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _isEditable = widget.isEditable;
    _controller = TextEditingController(text: widget.initialText);
  }

  void toggleEditable() {
    setState(() {
      _isEditable = !_isEditable;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
        controller: _controller,
        enabled: _isEditable,
        maxLines: null,
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
    );
  }
}

