import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos/constant.dart';
import 'package:pos/data/api/api.dart';
import 'package:pos/data/models/scanAndRelease_model.dart';
import 'package:pos/data/models/scan_listener_model.dart';
import 'package:pos/presentation/scan_find_items/bloc/scan_find_items_page_bloc.dart';
import 'package:pos/presentation/scan_find_items/scanFindItems.dart';

class DialogScan {
  Future<void> showScanNoHawbDialog(
      {required bool isShowDialog, required BuildContext context, required String datePicked}) {
    if (isShowDialog) {
      Navigator.of(context).pop();
      isShowDialog = false;
    }
    isShowDialog = true;
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: MediaQuery.of(context).size.height * 0.20,
            alignment: Alignment.center,
            child: Text(
              'ไม่พบ HAWB ในระบบ',
              style: TextStyle(
                color: Colors.red[200],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('สแกนต่อ'),
              onPressed: () {
                context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));
                isShowDialog = false;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showScanDialog(
      {required bool isShowDialog,
      required BuildContext parentContext,
      required ScanListenerModel model,
      required String datePicked,
      int? statusCode,
      TypeDialogScanItems? typeDialogScan,
      String? nameReportBtn,
      String? remarkSuccess,
      String? remarkFailed}) {
    if (isShowDialog) {
      Navigator.of(parentContext).pop();
      isShowDialog = false;
    }
    isShowDialog = true;
    return showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              child: nameReportBtn != null
                  ? ElevatedButton(
                      onPressed: () async {
                        if (typeDialogScan == TypeDialogScanItems.dialog5 ||
                            typeDialogScan == TypeDialogScanItems.dialog4) {
                          isShowDialog = false;
                          Navigator.of(context).pop();
                          Navigator.of(parentContext)
                              .pushNamed("/report", arguments: {"uuid": model.uuid, "datePicked": datePicked});
                        } else if (statusCode == 400 && typeDialogScan == TypeDialogScanItems.dialog3) {
                          isShowDialog = false;
                          Navigator.of(context).pop();
                          Navigator.of(parentContext)
                              .pushNamed("/repack", arguments: {"uuid": model.uuid, "datePicked": datePicked});
                        }
                      },
                      child: Text("$nameReportBtn"),
                    )
                  : SizedBox(),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text("HAWB: ${model.hawb}"),
                if (model.productType == "G" || model.productType == "R")
                  customBadgeSpecial(model.productType)
                else
                  customTypeBadge(model.productType),
                Text("Pick Up: ${model.pickupBy}"),
                Text("สถานะล่าสุด: ${model.lastStatus}"),
                Text("Item No: xxx"),
                Text("Consignee: xxx"),
                Text("CTNS: xxx"),
                SizedBox(height: 30),
                remarkFailed != null
                    ? Container(
                        child: Text(
                          "$remarkFailed",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red[200],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : SizedBox(),
                SizedBox(height: 10),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('สแกนต่อ'),
              onPressed: () {
                // onPressed.call();
                context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));
                isShowDialog = false;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showScanAndReleaseDialog(
      {required bool isShowDialog,
      required ScanAndReleaseModel model,
      required BuildContext parentContext,
      required String datePicked,
      TypeDialogScanItems? typeDialogScan,
      int? statusCode,
      bool isDialog3 = false,
      String? nameReportBtn,
      String? remarkSuccess,
      String? remarkFailed,
      bool isGreen = false}) {
    if (isShowDialog) {
      Navigator.of(parentContext).pop();
      isShowDialog = false;
    }
    isShowDialog = true;
    return showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              child: nameReportBtn != null
                  ? ElevatedButton(
                      onPressed: () async {
                        isShowDialog = false;
                        Navigator.of(context).pop();
                        Navigator.of(parentContext)
                            .pushNamed("/report", arguments: {"uuid": model.uuid, "datePicked": datePicked});
                      },
                      child: Text("$nameReportBtn"),
                    )
                  : SizedBox(),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text("HAWB: ${model.hawb}"),
                if (model.productType == "G" || model.productType == "R")
                  customBadgeSpecial(model.productType)
                else
                  customTypeBadge(model.productType),
                Text("Pick Up: ${model.pickupBy}"),
                Text("สถานะล่าสุด: ${model.lastStatus}"),
                Text("Item No: xxx"),
                Text("Consignee: xxx"),
                Text("CTNS: xxx"),
                SizedBox(height: 30),
                remarkFailed != null
                    ? Container(
                        child: Text(
                          "$remarkFailed",
                          style: TextStyle(
                            color: isGreen ? Colors.green[200] : Colors.red[200],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : SizedBox(),
                SizedBox(height: 10),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('สแกนต่อ'),
              onPressed: () {
                context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));
                isShowDialog = false;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showConfirmRepackDialog({
    required bool isShowDialog,
    required BuildContext parentContext,
    required String uuid,
    required GlobalKey<FormState> repackFormKey,
    required ValueNotifier<File?> imageRepack,
    required String datePicked,
    required Widget snackBarUtil,
  }) async {
    imageRepack.value = null;

    if (isShowDialog) {
      Navigator.of(parentContext).pop();
      isShowDialog = false;
    }
    isShowDialog = true;
    return showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: RichText(
            text: TextSpan(
              text: 'สาเหตุ',
              style: TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                )
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text("ยินยันการ Repack"),
                SizedBox(
                  height: 30,
                ),
                ValueListenableBuilder<File?>(
                  valueListenable: imageRepack,
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
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: const Text('ถ่ายรูป'),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 1080,
                      maxHeight: 1080,
                      imageQuality: 100,
                    );
                    if (image != null) {
                      // setState(() {
                      //   imageRepack.value = File(image.path);
                      // });
                      imageRepack.value = File(image.path);
                    }
                  },
                ),
                Row(children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('ยกเลิก'),
                    onPressed: () {
                      isShowDialog = false;
                      imageRepack.value = null;
                      context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('ยืนยัน'),
                    onPressed: () async {
                      if (imageRepack.value != null) {
                        await DataService().sendRepack(uuid, datePicked, imageRepack.value!).then((res) {
                          if (res == "success") {
                            imageRepack.value = null;
                            // snackBarUtil('แจ้งการ Repack สำเร็จ');
                          } else {
                            // snackBarUtil('แจ้งการ Repack ไม่สำเร็จ กรุณาลองใหม่อีกครั้ง');
                          }
                        });
                        isShowDialog = false;
                        context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));
                        Navigator.of(context).pop();
                      } else {
                        // snackBarUtil('กรุณาถ่ายรูปเพื่อเปลี่ยนสถานะเป็น Repack');
                      }
                    },
                  ),
                ])
              ],
            )
          ],
        );
      },
    );
  }

  Future<void> showConfirmFindItemDialog({
    required bool isShowDialog,
    required BuildContext parentContext,
    required String uuid,
    required GlobalKey<FormState> reportFormKey,
    required ValueNotifier<File?> imageReport,
    required String datePicked,
    required Widget snackBarUtil,
  }) async {
    TextEditingController _controllerRemark = TextEditingController();
    String? reasonValue;

    Map<String, dynamic> result = await DataService().getProblemList();
    List<DropdownMenuEntry<String>> reasonList = (result['data'] as List)
        .map((item) => DropdownMenuEntry<String>(label: item['text'], value: item['value']))
        .toList();

    if (isShowDialog) {
      Navigator.of(parentContext).pop();
      isShowDialog = false;
    }
    isShowDialog = true;
    return await showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: RichText(
            text: TextSpan(
              text: 'สาเหตุ',
              style: TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                )
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: reportFormKey,
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
                      // setState(() {
                      //   reasonValue = value!;
                      // });
                      reasonValue = value!;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณาเลือกสาเหตุในการแจ้งปัญหา';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  Text("หมายเหตุ"),
                  TextFormField(
                    controller: _controllerRemark,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'ระบุหมายเหตุ...',
                    ),
                  ),
                  SizedBox(height: 30),
                  ValueListenableBuilder<File?>(
                    valueListenable: imageReport,
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
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: const Text('ถ่ายรูป'),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 1080,
                      maxHeight: 1080,
                      imageQuality: 100,
                    );
                    if (image != null) {
                      // setState(() {
                      //   imageReport.value = File(image.path);
                      // });
                      imageReport.value = File(image.path);
                    }
                  },
                ),
                Row(children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('ยกเลิก'),
                    onPressed: () {
                      isShowDialog = false;
                      imageReport.value = null;
                      context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('ยืนยัน'),
                    onPressed: () async {
                      var res;
                      if (reportFormKey.currentState!.validate()) {
                        if (reasonValue == "03") {
                          if (imageReport.value != null) {
                            res = await DataService().sendReport(uuid, datePicked, reasonValue!,
                                image: imageReport.value!, remark: _controllerRemark.text);

                            if (res == "success") {
                              // snackBarUtil('แจ้งปัญหาสำเร็จ');
                            } else {
                              // snackBarUtil('แจ้งปัญหาไม่สำเร็จ กรุณาลองใหม่อีกครั้ง');
                            }
                            isShowDialog = false;
                            imageReport.value = null;
                            context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));
                            Navigator.of(context).pop();
                          } else {
                            // snackBarUtil('กรุณาถ่ายรูปสินค้าหรือพัสดุเพื่อแจ้งปัญหา');
                          }
                        } else {
                          if (imageReport.value != null) {
                            res = await DataService().sendReport(uuid, datePicked, reasonValue!,
                                image: imageReport.value!, remark: _controllerRemark.text);
                          } else {
                            res = await DataService()
                                .sendReport(uuid, datePicked, reasonValue!, remark: _controllerRemark.text);
                          }
                          if (res == "success") {
                            // snackBarUtil('แจ้งปัญหาสำเร็จ');
                          } else {
                            // snackBarUtil('แจ้งปัญหาไม่สำเร็จ กรุณาลองใหม่อีกครั้ง');
                          }
                          isShowDialog = false;
                          imageReport.value = null;
                          context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));
                          Navigator.of(context).pop();
                        }
                      }
                    },
                  ),
                ])
              ],
            )
          ],
        );
      },
    );
  }

  Widget customBadgeSpecial(String productType) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Type:  "),
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            color: productType == "G" ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              productType,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget customTypeBadge(String productType) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Type:  "),
        Container(
          width: 30,
          height: 25,
          decoration: BoxDecoration(color: Colors.yellow),
          child: Center(
            child: Text(
              productType,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )
      ],
    );
  }
}
