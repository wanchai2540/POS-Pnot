import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos/data/api/api.dart';
import 'package:pos/presentation/scan_find_items/bloc/scan_find_items_page_bloc.dart';

class RepackPage extends StatefulWidget {
  const RepackPage({super.key});

  @override
  State<RepackPage> createState() => _RepackPageState();
}

class _RepackPageState extends State<RepackPage> {
  final _reportFormKey = GlobalKey<FormState>();
  String? reasonValue;
  Map<String, dynamic> result = {};
  List<DropdownMenuEntry<String>> reasonList = [];
  final ValueNotifier<File?> _imageRepack = ValueNotifier<File?>(null);
  String uuid = "";
  String datePicked = "";

  @override
  void initState() {
    super.initState();
    getListResaon();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getListResaon();

    final args = ModalRoute.of(context)?.settings.arguments as Map;
    uuid = args["uuid"];
    datePicked = args["datePicked"];
  }

  Future<void> getListResaon() async {
    Map<String, dynamic>? problemList = await DataService().getProblemList();
    List<DropdownMenuEntry<String>> dropReasonList = (problemList['data'] as List)
        .map((item) => DropdownMenuEntry<String>(label: item['text'], value: item['value']))
        .toList();
    setState(() {
      result = problemList;
      reasonList = dropReasonList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF5ECD5),
        title: Text("ยืนยันการ Repack"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'สาเหตุ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                    children: [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("ยินยันการ Repack"),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                ValueListenableBuilder<File?>(
                  valueListenable: _imageRepack,
                  builder: (context, capturedImage, child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        capturedImage == null
                            ? SizedBox()
                            : Center(
                                child: Image.file(
                                  capturedImage,
                                  height: 200,
                                  width: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ],
                    );
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: const Text('ถ่ายรูป', style: TextStyle(fontSize: 18)),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 1080,
                      maxHeight: 1080,
                      imageQuality: 100,
                    );
                    if (image != null) {
                      setState(() {
                        _imageRepack.value = File(image.path);
                      });
                    }
                  },
                ),
                Row(children: [
                  TextButton(
                    child: const Text('ยกเลิก', style: TextStyle(fontSize: 18)),
                    onPressed: () {
                      setState(() {
                        _imageRepack.value = null;
                      });
                      context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('ยืนยัน', style: TextStyle(fontSize: 18)),
                    onPressed: () async {
                      if (_imageRepack.value != null) {
                        await DataService().sendRepack(uuid, datePicked, _imageRepack.value!).then((res) {
                          if (res == "success") {
                            setState(() {
                              _imageRepack.value = null;
                            });
                            snackBarUtil('แจ้งการ Repack สำเร็จ');
                          } else {
                            snackBarUtil('แจ้งการ Repack ไม่สำเร็จ กรุณาลองใหม่อีกครั้ง');
                          }
                        });
                        context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));
                        Navigator.of(context).pop();
                      } else {
                        snackBarUtil('กรุณาถ่ายรูปเพื่อเปลี่ยนสถานะเป็น Repack');
                      }
                    },
                  ),
                ])
              ],
            )
          ],
        ),
      ),
    );
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackBarUtil(String title) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(title),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
