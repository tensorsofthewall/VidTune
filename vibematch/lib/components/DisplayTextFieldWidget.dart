import 'package:flutter/material.dart';

class DisplayTextFieldWidget extends StatefulWidget {
  final String initialText;
  final bool isReadOnly;
  final Function(String)? onEdit;
  const DisplayTextFieldWidget({super.key, required this.initialText, this.isReadOnly = true, this.onEdit});
  // void toggleEditable() {
  //   isEditable = !isEditable;
  // }
  
  @override
  State<DisplayTextFieldWidget> createState() => _DisplayTextFieldWidgetState();
}

class _DisplayTextFieldWidgetState extends State<DisplayTextFieldWidget> {
  late bool _isReadOnly;
  late TextEditingController _controller;
  // late Function(String?) _onEdit;

  @override
  void initState() {
    super.initState();
    _isReadOnly = widget.isReadOnly;
    _controller = TextEditingController(text: widget.initialText);
  }

  void toggleEditable() {
    setState(() {
      _isReadOnly = !_isReadOnly;
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
        readOnly: _isReadOnly,
        maxLines: null,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        onChanged: (value) {
          if (widget.onEdit != null) {
            widget.onEdit!(value);
          }
        },

      ),
    );
  }
}

