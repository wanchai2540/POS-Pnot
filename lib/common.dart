import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos/constant.dart';
import 'package:pos/data/api/api.dart';
import 'package:pos/data/models/scanAndRelease_model.dart';
import 'package:pos/data/models/scan_listener_model.dart';
import 'package:pos/data/models/scan_result_model.dart';
import 'package:pos/presentation/scan_find_items/bloc/scan_find_items_page_bloc.dart';

class DialogScan {
  Future<void> showScanNoHawbDialog({
    required bool isShowDialog,
    required BuildContext context,
    required String datePicked,
  }) {
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
      required GlobalKey<FormState> formKeyDialogConfirm,
      required ValueNotifier<File?> imageDialogConfirm,
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
                            typeDialogScan == TypeDialogScanItems.dialog6) {
                          isShowDialog = false;
                          Navigator.of(context).pop();
                          // Navigator.of(parentContext).pushNamed("/report", arguments: {
                          //   "uuid": model.uuid,
                          //   "datePicked": datePicked,
                          //   "problemCode": "08",
                          // });
                          await showConfirmFindItemDialog(
                            isShowDialog: isShowDialog,
                            parentContext: parentContext,
                            uuid: model.uuid,
                            reportFormKey: formKeyDialogConfirm,
                            imageReport: imageDialogConfirm,
                            datePicked: datePicked,
                            module: "1",
                          );
                        } else if (statusCode == 400 && typeDialogScan == TypeDialogScanItems.dialog4) {
                          isShowDialog = false;
                          Navigator.of(context).pop();
                          // Navigator.of(parentContext).pushNamed("/repack", arguments: {
                          //   "uuid": model.uuid,
                          //   "datePicked": datePicked,
                          // });
                          await showConfirmRepackDialog(
                            isShowDialog: isShowDialog,
                            parentContext: parentContext,
                            uuid: model.uuid,
                            repackFormKey: formKeyDialogConfirm,
                            imageRepack: imageDialogConfirm,
                            datePicked: datePicked,
                          );
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
                Text("Item No: ${model.itemNo}"),
                Text("Consignee: ${model.consigneeName}"),
                Text("CTNS: ${model.ctns}"),
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

  Future<void> showNoDMCDialog({
    required bool isShowDialog,
    required BuildContext parentContext,
    required ScanResultModel model,
    required String datePicked,
    required ValueNotifier<File?> imageNoDMC,
    required String module,
    String? remarkFailed,
  }) {
    bool _isProgressing = false;

    if (isShowDialog) {
      Navigator.of(parentContext).pop();
      isShowDialog = false;
    }
    isShowDialog = true;
    return showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Stack(
            children: [
              AlertDialog(
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
                      Text("Item No: ${model.itemNo}"),
                      Text("Consignee: ${model.consigneeName}"),
                      Text("CTNS: ${model.ctns}"),
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
                      SizedBox(height: 30),
                      ValueListenableBuilder<File?>(
                        valueListenable: imageNoDMC,
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
                            imageNoDMC.value = File(image.path);
                          }
                        },
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          textStyle: Theme.of(context).textTheme.labelLarge,
                        ),
                        child: const Text('ยืนยัน'),
                        onPressed: () async {
                          var res;
                          setState(() {
                            _isProgressing = true;
                          });
                          if (imageNoDMC.value != null) {
                            res = await DataService().sendApproveProblem(
                              model.uuid,
                              datePicked,
                              module,
                              image: imageNoDMC.value!,
                            );
                          } else {
                            res = await DataService().sendApproveProblem(
                              model.uuid,
                              datePicked,
                              module,
                            );
                          }

                          if (res == "success") {
                            snackBarUtil(context, 'แจ้งปัญหาสำเร็จ');
                            isShowDialog = false;
                            imageNoDMC.value = null;
                            context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));
                          } else {
                            snackBarUtil(context, 'แจ้งปัญหาไม่สำเร็จ กรุณาลองใหม่อีกครั้ง');
                          }
                          setState(() {
                            _isProgressing = false;
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              if (_isProgressing)
                Container(
                  color: Colors.black.withOpacity(0.1), // Dimmed background
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        });
      },
    );
  }

  Future<void> showScanAndReleaseDialog({
    required bool isShowDialog,
    required ScanAndReleaseModel model,
    required BuildContext parentContext,
    required String datePicked,
    required GlobalKey<FormState> formKeyDialogConfirm,
    required ValueNotifier<File?> imageDialogConfirm,
    TypeDialogScanItems? typeDialogScan,
    int? statusCode,
    bool isDialog3 = false,
    String? nameReportBtn,
    String? remarkSuccess,
    String? remarkFailed,
    bool isGreen = false,
  }) {
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
                        // Navigator.of(parentContext).pushNamed("/report", arguments: {
                        //   "uuid": model.uuid,
                        //   "datePicked": datePicked,
                        //   "problemCode": "10",
                        // });
                        await showConfirmFindItemDialog(
                          isShowDialog: isShowDialog,
                          parentContext: parentContext,
                          uuid: model.uuid,
                          reportFormKey: formKeyDialogConfirm,
                          imageReport: imageDialogConfirm,
                          datePicked: datePicked,
                          module: "2",
                          problemCode: "10",
                        );
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
                Text("Item No: ${model.itemNo}"),
                Text("Consignee: ${model.consigneeName}"),
                Text("CTNS: ${model.ctns}"),
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

  Future<void> showConfirmFindItemDialog({
    required bool isShowDialog,
    required BuildContext parentContext,
    required String uuid,
    required GlobalKey<FormState> reportFormKey,
    required ValueNotifier<File?> imageReport,
    required String datePicked,
    required String module,
    String? problemCode = "08",
  }) async {
    TextEditingController _controllerRemark = TextEditingController();
    String? reasonValue;
    bool _isProgressing = false;

    Map<String, dynamic> result = await DataService().getProblemList(problemCode);
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
        return StatefulBuilder(builder: (context, setState) {
          return Stack(
            children: [
              AlertDialog(
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
                              setState(() {
                                _isProgressing = true;
                              });

                              if (reasonValue == "03") {
                                if (imageReport.value != null) {
                                  res = await DataService().sendReport(
                                    uuid,
                                    datePicked,
                                    reasonValue!,
                                    module,
                                    image: imageReport.value!,
                                    remark: _controllerRemark.text,
                                  );

                                  if (res == "success") {
                                    snackBarUtil(context, 'แจ้งปัญหาสำเร็จ');

                                    isShowDialog = false;
                                    imageReport.value = null;
                                    context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));
                                    setState(() {
                                      _isProgressing = false;
                                    });
                                    Navigator.of(context).pop();
                                  } else {
                                    setState(() {
                                      _isProgressing = false;
                                    });
                                    snackBarUtil(context, 'แจ้งปัญหาไม่สำเร็จ กรุณาลองใหม่อีกครั้ง');
                                  }
                                } else {
                                  setState(() {
                                    _isProgressing = false;
                                  });
                                  snackBarUtil(context, 'กรุณาถ่ายรูปสินค้าหรือพัสดุเพื่อแจ้งปัญหา');
                                }
                              } else {
                                if (imageReport.value != null) {
                                  res = await DataService().sendReport(
                                    uuid,
                                    datePicked,
                                    reasonValue!,
                                    module,
                                    image: imageReport.value!,
                                    remark: _controllerRemark.text,
                                  );
                                } else {
                                  res = await DataService().sendReport(
                                    uuid,
                                    datePicked,
                                    reasonValue!,
                                    module,
                                    remark: _controllerRemark.text,
                                  );
                                }
                                if (res == "success") {
                                  snackBarUtil(context, 'แจ้งปัญหาสำเร็จ');

                                  isShowDialog = false;
                                  imageReport.value = null;
                                  context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));
                                  Navigator.of(context).pop();
                                } else {
                                  snackBarUtil(context, 'แจ้งปัญหาไม่สำเร็จ กรุณาลองใหม่อีกครั้ง');
                                }
                              }
                            }
                          },
                        ),
                      ])
                    ],
                  )
                ],
              ),
              if (_isProgressing)
                Container(
                  color: Colors.black.withOpacity(0.1), // Dimmed background
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        });
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
  }) async {
    imageRepack.value = null;
    bool _isProgressing = false;

    if (isShowDialog) {
      Navigator.of(parentContext).pop();
      isShowDialog = false;
    }
    isShowDialog = true;
    return showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Stack(
            children: [
              AlertDialog(
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
                              setState(() {
                                _isProgressing = true;
                              });
                              await DataService().sendRepack(uuid, datePicked, imageRepack.value!).then((res) {
                                if (res == "success") {
                                  imageRepack.value = null;
                                  snackBarUtil(context, 'แจ้งการ Repack สำเร็จ');
                                  isShowDialog = false;
                                  context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));
                                  setState(() {
                                    _isProgressing = false;
                                  });
                                  Navigator.of(context).pop();
                                } else {
                                  snackBarUtil(context, 'แจ้งการ Repack ไม่สำเร็จ กรุณาลองใหม่อีกครั้ง');
                                  setState(() {
                                    _isProgressing = false;
                                  });
                                }
                              });
                            } else {
                              snackBarUtil(context, 'กรุณาถ่ายรูปเพื่อเปลี่ยนสถานะเป็น Repack');
                              setState(() {
                                _isProgressing = false;
                              });
                            }
                          },
                        ),
                      ])
                    ],
                  )
                ],
              ),
              if (_isProgressing)
                Container(
                  color: Colors.black.withOpacity(0.1), // Dimmed background
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        });
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

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackBarUtil(BuildContext context, String title) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(title),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
