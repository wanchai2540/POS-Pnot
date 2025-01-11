import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos/common.dart';
import 'package:pos/data/api/api.dart';
import 'package:pos/presentation/scan_find_items/bloc/scan_find_items_page_bloc.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  TextEditingController _controllerRemark = TextEditingController();
  final _reportFormKey = GlobalKey<FormState>();
  String? reasonValue;
  Map<String, dynamic> result = {};
  List<DropdownMenuEntry<String>> reasonList = [];
  final ValueNotifier<File?> _imageReport = ValueNotifier<File?>(null);
  String uuid = "";
  String datePicked = "";
  bool _isProcessing = false;
  String _problemCode = "08";
  @override
  void initState() {
    super.initState();
    getListResaon();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments as Map;
    uuid = args["uuid"];
    datePicked = args["datePicked"];
    if (args["problemCode"] != null) {
      setState(() {
        _problemCode = args["problemCode"];
        getListResaon();
      });
    }
  }

  Future<void> getListResaon() async {
    List<DropdownMenuEntry<String>>? dropReasonList;
    Map<String, dynamic>? problemList = await DataService().getProblemList(_problemCode);
    if (problemList.isNotEmpty) {
      dropReasonList = (problemList['data'] as List)
          .map((item) => DropdownMenuEntry<String>(label: item['text'], value: item['value']))
          .toList();
    }
    setState(() {
      result = problemList;
      reasonList = dropReasonList ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF5ECD5),
        title: Text("แจ้งปัญหา"),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
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
                        Form(
                          key: _reportFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              DropdownButtonFormField<String>(
                                value: reasonValue,
                                decoration: InputDecoration(
                                  labelText: 'เลือกสาเหตุ',
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  for (var dropValue in reasonList)
                                    DropdownMenuItem(value: '${dropValue.value}', child: Text('${dropValue.label}')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    reasonValue = value!;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'กรุณาเลือกสาเหตุในการแจ้งปัญหา';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),
                              Text("หมายเหตุ", style: TextStyle(fontSize: 20)),
                              TextFormField(
                                controller: _controllerRemark,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'ระบุหมายเหตุ...',
                                ),
                              ),
                              SizedBox(height: 30),
                              ValueListenableBuilder<File?>(
                                valueListenable: _imageReport,
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
                                _imageReport.value = File(image.path);
                              });
                            }
                          },
                        ),
                        Row(children: [
                          TextButton(
                            child: const Text('ยกเลิก', style: TextStyle(fontSize: 18)),
                            onPressed: () {
                              setState(() {
                                _imageReport.value = null;
                              });
                              context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));
                              Navigator.of(context).pop();
                            },
                          ),
                          SizedBox(width: 10),
                          TextButton(
                            child: const Text('ยืนยัน', style: TextStyle(fontSize: 18)),
                            onPressed: () async {
                              if (_reportFormKey.currentState!.validate()) {
                                setState(() {
                                  _isProcessing = true;
                                });
                                var res;

                                try {
                                  if (reasonValue == "03") {
                                    if (_imageReport.value != null) {
                                      res = await DataService().sendReport(
                                        uuid,
                                        datePicked,
                                        reasonValue!,
                                        "2",
                                        image: _imageReport.value!,
                                        remark: _controllerRemark.text,
                                      );

                                      if (res == "success") {
                                        DialogScan().snackBarUtil(context, 'แจ้งปัญหาสำเร็จ');
                                      } else {
                                        DialogScan().snackBarUtil(context, 'แจ้งปัญหาไม่สำเร็จ กรุณาลองใหม่อีกครั้ง');
                                      }
                                    } else {
                                      DialogScan().snackBarUtil(context, 'กรุณาถ่ายรูปสินค้าหรือพัสดุเพื่อแจ้งปัญหา');
                                    }
                                    _imageReport.value = null;
                                    context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));
                                    Navigator.of(context).pop();
                                  } else {
                                    if (_imageReport.value != null) {
                                      res = await DataService().sendReport(
                                        uuid,
                                        datePicked,
                                        reasonValue!,
                                        "2",
                                        image: _imageReport.value!,
                                        remark: _controllerRemark.text,
                                      );
                                    } else {
                                      res = await DataService().sendReport(
                                        uuid,
                                        datePicked,
                                        reasonValue!,
                                        "2",
                                        remark: _controllerRemark.text,
                                      );
                                    }
                                    if (res == "success") {
                                      DialogScan().snackBarUtil(context, 'แจ้งปัญหาสำเร็จ');
                                    } else {
                                      DialogScan().snackBarUtil(context, 'แจ้งปัญหาไม่สำเร็จ กรุณาลองใหม่อีกครั้ง');
                                    }

                                    _imageReport.value = null;
                                    context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));
                                    Navigator.of(context).pop();
                                  }
                                } catch (e) {
                                  DialogScan().snackBarUtil(context, 'เกิดข้อผิดพลาด: ${e.toString()}');
                                } finally {
                                  setState(() {
                                    _isProcessing = false;
                                  });
                                }
                              }
                            },
                          ),
                        ])
                      ],
                    )
                  ],
                )),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5), // Dimmed background
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
      
        ],
      ),
    );
  }
}
