import 'package:flutter/material.dart';

class FloadtinWidget extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final Function() onResultScan;

  const FloadtinWidget({super.key, required this.formKey, required this.controller, required this.onResultScan});

  @override
  State<FloadtinWidget> createState() => _FloadtinWidgetState();
}

class _FloadtinWidgetState extends State<FloadtinWidget> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Color(0xFFF5ECD5),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Form(
              key: widget.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ระบุเลขบาร์โค้ด',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: widget.controller,
                    decoration: InputDecoration(
                      labelText: 'เลขบาร์โค้ด',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "กรุณาถ่ายระบุเลขบาร์โค้ด";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Color(0xFFF5ECD5),
                      ),
                    ),
                    onPressed: () {
                      if (widget.formKey.currentState!.validate()) {
                        widget.onResultScan();
                        Navigator.pop(context);
                      }
                      widget.controller.text = "";
                    },
                    child: Text('Submit', style: TextStyle(color: Colors.black)),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
      child: Icon(Icons.edit),
    );
  }
}
