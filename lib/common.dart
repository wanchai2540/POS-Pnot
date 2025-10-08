import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kymscanner/constant.dart';
import 'package:image/image.dart' as img;
import 'package:kymscanner/data/api/api.dart';
import 'package:kymscanner/data/models/release_model.dart';
import 'package:kymscanner/data/models/scanAndRelease_model.dart';
import 'package:kymscanner/data/models/scan_listener_model.dart';
import 'package:kymscanner/data/models/scan_result_model.dart';
import 'package:kymscanner/data/models/search_model.dart';
import 'package:kymscanner/presentation/release_items/bloc/release_items_bloc.dart';
import 'package:kymscanner/presentation/scan_find_items/bloc/scan_find_items_page_bloc.dart';
import 'package:watermark_unique/image_format.dart';
import 'package:watermark_unique/watermark_unique.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DialogScan {
  Future<void> showScanNoHawbDialog({
    required String title,
    required ValueNotifier<bool> isShowDialog,
    required BuildContext context,
    required String datePicked,
  }) {
    if (isShowDialog.value) {
      Navigator.of(context).pop();
      isShowDialog.value = false;
    }
    isShowDialog.value = true;
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: MediaQuery.of(context).size.height * 0.20,
            alignment: Alignment.center,
            child: Text(
              title,
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
                isShowDialog.value = false;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showScanDialog({
    required ValueNotifier<bool> isShowDialog,
    required BuildContext parentContext,
    required ScanListenerModel model,
    required String datePicked,
    required GlobalKey<FormState> formKeyDialogConfirm,
    required ValueNotifier<File?> imageDialogConfirm,
    required String module,
    int? statusCode,
    TypeDialogScanItems? typeDialogScan,
    String? nameReportBtn,
    String? remarkSuccess,
    String? remarkFailed,
  }) {
    if (isShowDialog.value) {
      Navigator.of(parentContext).pop();
      isShowDialog.value = false;
    }
    isShowDialog.value = true;
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
                          isShowDialog.value = false;
                          Navigator.of(context).pop();
                          await showConfirmFindItemDialog(
                            isShowDialog: isShowDialog,
                            parentContext: parentContext,
                            uuid: model.uuid,
                            reportFormKey: formKeyDialogConfirm,
                            imageReport: imageDialogConfirm,
                            datePicked: datePicked,
                            hawb: model.hawb,
                            module: module,
                          );
                        } else if (statusCode == 400 && typeDialogScan == TypeDialogScanItems.dialog4) {
                          isShowDialog.value = false;
                          Navigator.of(context).pop();
                          await showConfirmRepackDialog(
                            isShowDialog: isShowDialog,
                            parentContext: parentContext,
                            uuid: model.uuid,
                            repackFormKey: formKeyDialogConfirm,
                            datePicked: datePicked,
                            hawb: model.hawb,
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
                ColoredBox(
                  color: model.isSuspended ? Colors.yellow : Colors.transparent,
                  child: Text("Item No: ${model.itemNo}"),
                ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                typeDialogScan == TypeDialogScanItems.dialog5 || typeDialogScan == TypeDialogScanItems.dialog6
                    ? TextButton(
                        style: TextButton.styleFrom(
                          textStyle: Theme.of(context).textTheme.labelLarge,
                        ),
                        child: const Text('เพิ่มรูป'),
                        onPressed: () async {
                          isShowDialog.value = false;
                          Navigator.of(context).pop();
                          await dialogTakeAImage(
                            parentContext: parentContext,
                            isShowDialog: isShowDialog,
                            datePicked: datePicked,
                            uuid: model.uuid,
                            hawb: model.hawb,
                            module: module,
                            reason: model.reason,
                          );
                        },
                      )
                    : SizedBox(),
                Row(
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: Theme.of(context).textTheme.labelLarge,
                      ),
                      child: const Text('สแกนต่อ'),
                      onPressed: () {
                        context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));
                        isShowDialog.value = false;
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                )
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> showNoDMCDialog({
    required ValueNotifier<bool> isShowDialog,
    required BuildContext parentContext,
    required ScanResultModel model,
    required String datePicked,
    required String module,
    String? remarkFailed,
  }) {
    bool _isProgressing = false;

    if (isShowDialog.value) {
      Navigator.of(parentContext).pop();
      isShowDialog.value = false;
    }
    isShowDialog.value = true;
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
                      ColoredBox(
                        color: model.isSuspended ? Colors.yellow : Colors.transparent,
                        child: Text("Item No: ${model.itemNo}"),
                      ),
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
                        child: const Text('เพิ่มรูป'),
                        onPressed: () async {
                          isShowDialog.value = false;
                          Navigator.of(context).pop();
                          await dialogTakeAImage(
                            parentContext: parentContext,
                            isShowDialog: isShowDialog,
                            datePicked: datePicked,
                            uuid: model.uuid,
                            hawb: model.hawb,
                            module: module,
                            reason: model.reason,
                            isNoDMC: true,
                          );
                        },
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              isShowDialog.value = false;
                              context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));
                              Navigator.of(context).pop();
                            },
                            child: Text("ยกเลิก"),
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
                              res = await DataService().sendApproveProblem(
                                model.uuid,
                                datePicked,
                                module,
                              );

                              if (res == "success") {
                                snackBarUtil(context, 'แจ้งปัญหาสำเร็จ');
                              } else if (res == "tokenExpired") {
                                snackBarUtil(context, 'เซสชั่นหมดอายุ กรุณาเข้าสู่ระบบใหม่');
                              } else {
                                snackBarUtil(context, 'แจ้งปัญหาไม่สำเร็จ กรุณาลองใหม่อีกครั้ง');
                              }

                              setState(() {
                                _isProgressing = false;
                              });
                              isShowDialog.value = false;
                              context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));

                              Navigator.of(context).pop();
                            },
                          ),
                        ],
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
    required ValueNotifier<bool> isShowDialog,
    required ScanAndReleaseModel model,
    required BuildContext parentContext,
    required String datePicked,
    required GlobalKey<FormState> formKeyDialogConfirm,
    required ValueNotifier<File?> imageDialogConfirm,
    required String module,
    TypeDialogScanItems? typeDialogScan,
    int? statusCode,
    bool isDialog3 = false,
    String? nameReportBtn,
    String? remarkSuccess,
    String? remarkFailed,
    bool isGreen = false,
  }) {
    if (isShowDialog.value) {
      Navigator.of(parentContext).pop();
      isShowDialog.value = false;
    }
    isShowDialog.value = true;
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
                        isShowDialog.value = false;
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
                          hawb: model.hawb,
                          module: module,
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
                ColoredBox(
                  color: model.isSuspended ? Colors.yellow : Colors.transparent,
                  child: Text("Item No: ${model.itemNo}"),
                ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                typeDialogScan == TypeDialogScanItems.dialog1 || typeDialogScan == TypeDialogScanItems.dialog2
                    ? TextButton(
                        style: TextButton.styleFrom(
                          textStyle: Theme.of(context).textTheme.labelLarge,
                        ),
                        child: const Text('เพิ่มรูป'),
                        onPressed: () async {
                          isShowDialog.value = false;
                          Navigator.of(context).pop();
                          await dialogTakeAImage(
                            parentContext: parentContext,
                            isShowDialog: isShowDialog,
                            datePicked: datePicked,
                            uuid: model.uuid,
                            hawb: model.hawb,
                            module: module,
                            reason: model.reason,
                          );
                        },
                      )
                    : SizedBox(),
                Row(
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: Theme.of(context).textTheme.labelLarge,
                      ),
                      child: const Text('สแกนต่อ'),
                      onPressed: () {
                        context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));
                        isShowDialog.value = false;
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> showReleaseScanDialog({
    required BuildContext parentContext,
    required ReleaseModel model,
    required ValueNotifier<bool> isShowDialog,
    required String datePicked,
    String? roundUUID,
    int? statusCode,
    bool isDialog3 = false,
    String? nameReportBtn,
    String? remarkSuccess,
    String? remarkFailed,
    bool isGreen = false,
    TypeDialogScanItems? typeDialogScanItems,
  }) {
    if (isShowDialog.value) {
      Navigator.of(parentContext).pop();
      isShowDialog.value = false;
    }
    isShowDialog.value = true;
    return showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
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
                ColoredBox(
                  color: model.isSuspended ? Colors.yellow : Colors.transparent,
                  child: Text("Item No: ${model.itemNo}"),
                ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                typeDialogScanItems == TypeDialogScanItems.dialog1 || typeDialogScanItems == TypeDialogScanItems.dialog2
                    ? TextButton(
                        style: TextButton.styleFrom(
                          textStyle: Theme.of(context).textTheme.labelLarge,
                        ),
                        child: const Text('เพิ่มรูป'),
                        onPressed: () async {
                          isShowDialog.value = false;
                          Navigator.of(context).pop();
                          await dialogTakeAImage(
                            parentContext: parentContext,
                            isShowDialog: isShowDialog,
                            datePicked: datePicked,
                            uuid: model.uuid,
                            hawb: model.hawb,
                            module: "3",
                            reason: model.reason,
                          );
                        },
                      )
                    : SizedBox(),
                Row(
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: Theme.of(context).textTheme.labelLarge,
                      ),
                      child: const Text('สแกนต่อ'),
                      onPressed: () {
                        context
                            .read<ReleaseItemsBloc>()
                            .add(ReleasePageGetDataEvent(date: datePicked, releaseRoundUUID: roundUUID!));
                        isShowDialog.value = false;
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> showSearchItemDialog({required BuildContext parentContext, required SearchItemsModel model}) {
    return showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text("HAWB: ${model.hawb}"),
                if (model.productType == "G" || model.productType == "R")
                  customBadgeSpecial(model.productType)
                else
                  customTypeBadge(model.productType),
                Text("Pick Up: ${model.pickUpBy}"),
                Text("สถานะล่าสุด: ${model.lastStatus}"),
                ColoredBox(
                  color: model.isSuspended ? Colors.yellow : Colors.transparent,
                  child: Text("Item No: ${model.itemNo}"),
                ),
                Text(
                  "Consignee: ${model.consigneeName}",
                  textAlign: TextAlign.center,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
                Text("CTNS: ${model.ctns.toString()}"),
                Text("วันที่: ${model.date.toString()}"),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: Theme.of(context).textTheme.labelLarge,
                      ),
                      child: const Text('ปิด'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                )
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> dialogTakeAImage({
    required BuildContext parentContext,
    required ValueNotifier<bool> isShowDialog,
    required String datePicked,
    required String uuid,
    required String hawb,
    required String module,
    required String reason,
    bool isNoDMC = false,
  }) async {
    if (isShowDialog.value) {
      Navigator.of(parentContext).pop();
      isShowDialog.value = false;
    }
    isShowDialog.value = true;
    bool _isProgressing = false;
    ValueNotifier<List<File?>> _imagesGridView = ValueNotifier<List<File?>>([]);
    ValueNotifier<bool> _isProcessingImage = ValueNotifier<bool>(false);

    return await showDialog(
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
                      SizedBox(height: 10),
                      ValueListenableBuilder<List<File?>>(
                        valueListenable: _imagesGridView,
                        builder: (context, capturedImage, child) {
                          return SizedBox(
                            width: double.maxFinite,
                            height: 300.0,
                            child: GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 4.0,
                                mainAxisSpacing: 4.0,
                              ),
                              itemCount: capturedImage.length + (_isProcessingImage.value ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index < capturedImage.length) {
                                  return GestureDetector(
                                    onTap: () => showImagePreview(context, capturedImage[index]!),
                                    child: zoomImage(
                                      child: Image.file(
                                        capturedImage[index]!,
                                        height: 200,
                                        width: 200,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  );
                                } else {
                                  return Center(child: CircularProgressIndicator());
                                }
                              },
                            ),
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
                          _isProcessingImage.value = true;
                          setState(() {});
                          File? resultImageWaterMark = await takePhoto(hawb: hawb, module: module);
                          if (resultImageWaterMark != null) {
                            _imagesGridView.value = [..._imagesGridView.value, resultImageWaterMark];
                          }
                          _isProcessingImage.value = false;
                          setState(() {});
                        },
                      ),
                      Row(children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            textStyle: Theme.of(context).textTheme.labelLarge,
                          ),
                          child: const Text('ยกเลิก'),
                          onPressed: () {
                            isShowDialog.value = false;
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
                            if (_imagesGridView.value.isNotEmpty) {
                              setState(() {
                                _isProgressing = true;
                              });

                              String resultConfirmImage = "";
                              if (isNoDMC) {
                                resultConfirmImage = await DataService()
                                    .sendApproveProblem(uuid, datePicked, module, image: _imagesGridView.value);
                              } else {
                                resultConfirmImage =
                                    await DataService().sendOnlyImage(uuid, datePicked, _imagesGridView.value, module);
                              }

                              if (resultConfirmImage == "success") {
                                snackBarUtil(context, 'ยืนยันสำเร็จ');
                              } else if (resultConfirmImage == "tokenExpired") {
                                snackBarUtil(context, 'เซสชั่นหมดอายุ กรุณาเข้าสู่ระบบใหม่');
                              } else {
                                snackBarUtil(context, 'ไม่สามารถยืนยันได้ กรุณาลองใหม่อีกครั้ง');
                              }

                              setState(() {
                                _isProgressing = false;
                              });
                              isShowDialog.value = false;
                              _imagesGridView.value = [];
                              context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));

                              Navigator.of(context).pop();
                            } else {
                              setState(() {
                                _isProgressing = false;
                              });

                              snackBarUtil(context, "กรุณาถ่ายรูปเพื่อยืนยัน");
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
                  color: Colors.black.withOpacity(0.1),
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

  Future<void> showConfirmFindItemDialog({
    required ValueNotifier<bool> isShowDialog,
    required BuildContext parentContext,
    required String uuid,
    required GlobalKey<FormState> reportFormKey,
    required ValueNotifier<File?> imageReport,
    required String datePicked,
    required String module,
    required String hawb,
    String? problemCode = "08",
  }) async {
    TextEditingController _controllerRemark = TextEditingController();
    String? reasonValue;
    bool _isProgressing = false;
    ValueNotifier<List<File?>> _imagesGridView = ValueNotifier<List<File?>>([]);
    ValueNotifier<bool> _isProcessingImage = ValueNotifier<bool>(false);

    Map<String, dynamic> result = await DataService().getProblemList(problemCode);
    List<DropdownMenuEntry<String>> reasonList = (result['data'] as List)
        .map((item) => DropdownMenuEntry<String>(label: item['text'], value: item['value']))
        .toList();

    if (isShowDialog.value) {
      Navigator.of(parentContext).pop();
      isShowDialog.value = false;
    }
    isShowDialog.value = true;
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
                        ValueListenableBuilder<List<File?>>(
                          valueListenable: _imagesGridView,
                          builder: (context, capturedImage, child) {
                            return SizedBox(
                              width: double.maxFinite,
                              height: 300.0,
                              child: GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 4.0,
                                  mainAxisSpacing: 4.0,
                                ),
                                itemCount: capturedImage.length + (_isProcessingImage.value ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index < capturedImage.length) {
                                    return GestureDetector(
                                      onTap: () => showImagePreview(context, capturedImage[index]!),
                                      child: zoomImage(
                                        child: Image.file(
                                          capturedImage[index]!,
                                          height: 200,
                                          width: 200,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Center(child: CircularProgressIndicator());
                                  }
                                },
                              ),
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
                          if (reasonValue == null) {
                            snackBarUtil(context, "กรุณาเลือกสาเหตุ");
                          } else {
                            _isProcessingImage.value = true;
                            setState(() {});
                            String reasonLabel = _getLabelNameFromReasonList(reasonList, reasonValue!);
                            File? resultImageWaterMark = await takePhoto(
                              hawb: hawb,
                              module: module,
                              reason: reasonLabel,
                            );
                            if (resultImageWaterMark != null) {
                              _imagesGridView.value = [..._imagesGridView.value, resultImageWaterMark];
                            }
                            _isProcessingImage.value = false;
                            setState(() {});
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
                            isShowDialog.value = false;
                            _imagesGridView.value = [];
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
                                if (_imagesGridView.value.length > 0) {
                                  res = await DataService().sendReport(
                                    uuid,
                                    datePicked,
                                    reasonValue!,
                                    module,
                                    image: _imagesGridView.value,
                                    remark: _controllerRemark.text,
                                  );

                                  if (res == "success") {
                                    snackBarUtil(context, 'แจ้งปัญหาสำเร็จ');
                                  } else if (res == "tokenExpired") {
                                    snackBarUtil(context, 'เซสชั่นหมดอายุ กรุณาเข้าสู่ระบบใหม่');
                                  } else {
                                    snackBarUtil(context, 'แจ้งปัญหาไม่สำเร็จ กรุณาลองใหม่อีกครั้ง');
                                  }

                                  setState(() {
                                    _isProgressing = false;
                                  });
                                  isShowDialog.value = false;
                                  _imagesGridView.value = [];
                                  context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));

                                  Navigator.of(context).pop();
                                } else {
                                  setState(() {
                                    _isProgressing = false;
                                  });

                                  snackBarUtil(context, 'กรุณาถ่ายรูปสินค้าหรือพัสดุเพื่อแจ้งปัญหา');
                                }
                              } else {
                                if (_imagesGridView.value.length > 0) {
                                  res = await DataService().sendReport(
                                    uuid,
                                    datePicked,
                                    reasonValue!,
                                    module,
                                    image: _imagesGridView.value,
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
                                } else if (res == "tokenExpired") {
                                  snackBarUtil(context, 'เซสชั่นหมดอายุ กรุณาเข้าสู่ระบบใหม่');
                                } else {
                                  snackBarUtil(context, 'แจ้งปัญหาไม่สำเร็จ กรุณาลองใหม่อีกครั้ง');
                                }

                                setState(() {
                                  _isProgressing = false;
                                });
                                isShowDialog.value = false;
                                _imagesGridView.value = [];
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
    required ValueNotifier<bool> isShowDialog,
    required BuildContext parentContext,
    required String uuid,
    required GlobalKey<FormState> repackFormKey,
    required String datePicked,
    required String hawb,
  }) async {
    ValueNotifier<List<File?>> _imagesGridView = ValueNotifier<List<File?>>([]);
    ValueNotifier<bool> _isProcessingImage = ValueNotifier<bool>(false);
    bool _isProgressing = false;

    if (isShowDialog.value) {
      Navigator.of(parentContext).pop();
      isShowDialog.value = false;
    }
    isShowDialog.value = true;
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
                      ValueListenableBuilder<List<File?>>(
                        valueListenable: _imagesGridView,
                        builder: (context, capturedImage, child) {
                          return SizedBox(
                            width: double.maxFinite,
                            height: 300.0,
                            child: GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 4.0,
                                mainAxisSpacing: 4.0,
                              ),
                              itemCount: capturedImage.length + (_isProcessingImage.value ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index < capturedImage.length) {
                                  return GestureDetector(
                                    onTap: () => showImagePreview(context, capturedImage[index]!),
                                    child: zoomImage(
                                      child: Image.file(
                                        capturedImage[index]!,
                                        height: 200,
                                        width: 200,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  );
                                } else {
                                  return Center(child: CircularProgressIndicator());
                                }
                              },
                            ),
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
                          _isProcessingImage.value = true;
                          setState(() {});
                          File? resultImageWaterMark = await takePhoto(
                            hawb: hawb,
                            module: "1",
                          );
                          if (resultImageWaterMark != null) {
                            _imagesGridView.value = [..._imagesGridView.value, resultImageWaterMark];
                          }
                          _isProcessingImage.value = false;
                          setState(() {});
                        },
                      ),
                      Row(children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            textStyle: Theme.of(context).textTheme.labelLarge,
                          ),
                          child: const Text('ยกเลิก'),
                          onPressed: () {
                            isShowDialog.value = false;
                            _imagesGridView.value = [];
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
                            if (_imagesGridView.value.length > 0) {
                              setState(() {
                                _isProgressing = true;
                              });
                              await DataService().sendRepack(uuid, datePicked, _imagesGridView.value).then((res) {
                                if (res == "success") {
                                  snackBarUtil(context, 'แจ้งการ Repack สำเร็จ');
                                } else if (res == "tokenExpired") {
                                  snackBarUtil(context, 'เซสชั่นหมดอายุ กรุณาเข้าสู่ระบบใหม่');
                                } else {
                                  snackBarUtil(context, 'แจ้งการ Repack ไม่สำเร็จ กรุณาลองใหม่อีกครั้ง');
                                }

                                setState(() {
                                  _isProgressing = false;
                                });
                                isShowDialog.value = false;
                                _imagesGridView.value = [];
                                context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));

                                Navigator.of(context).pop();
                              });
                            } else {
                              setState(() {
                                _isProgressing = false;
                              });

                              snackBarUtil(context, 'กรุณาถ่ายรูปเพื่อเปลี่ยนสถานะเป็น Repack');
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

  void showImagePreview(BuildContext context, File imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: zoomImage(
              child: Image.file(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
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

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackBarUtil(BuildContext context, String title) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(title),
        duration: Duration(seconds: 3),
      ),
    );
  }

  String _getLabelNameFromReasonList(List<DropdownMenuEntry<String>> reasonList, String valueTarget) {
    return reasonList.firstWhere((data) {
      return data.value == valueTarget;
    }).label;
  }
}

Widget zoomImage({required Widget child}) {
  return InteractiveViewer(
      panEnabled: true,
      scaleEnabled: true,
      minScale: 1,
      maxScale: 4.0,
      // boundaryMargin: const EdgeInsets.all(0),
      child: child);
}

Future<File?> takePhoto({required String hawb, String reason = "", required String module}) async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.camera);
  String location = getNameModule(module);
  if (image != null) {
    // File? watermarkedImage = await addWaterMark(
    //     imageBeforeWaterMark: image.path, nameImage: image.name, hawb: hawb, location: location, reason: reason);
    File? imageNeedToReduce = File(image.path);
    XFile? reduceImage = await compressImage(imageNeedToReduce);
    File? finalImage = File(reduceImage.path);
    return finalImage;
  }
  return null;
}

String getNameModule(String module) {
  switch (module) {
    case "1":
      return "สแกนหาของ";
    case "2":
      return "สแกนของพร้อมปล่อย";
    case "3":
      return "ของพร้อมปล่อย";
    default:
      return "สแกนหาของ";
  }
}

Future<File?> addWaterMark({
  required String imageBeforeWaterMark,
  required String nameImage,
  required String hawb,
  required String location,
  required String reason,
}) async {
  final File imageFile = File(imageBeforeWaterMark);
  final img.Image? originalImage = img.decodeImage(imageFile.readAsBytesSync());

  if (originalImage != null) {
    int defaultX = 100;
    int fontSize = 170;
    int imageHeight = originalImage.height;
    if (reason.isNotEmpty) {
      defaultX = 210;
      reason = "เหตุผล: $reason";
    }

    final _watermarkPlugin = WatermarkUnique();
    String text = 'hawb: ${hawb.trim()}\nLocation: ${location.trim()}\n${reason.trim()}';
    // int axisY = (imageHeight - defaultX) - 24;
    final image = await _watermarkPlugin.addTextWatermark(
      filePath: imageBeforeWaterMark,
      text: text,
      x: 20,
      y: (imageHeight * 0.7).ceil(),
      textSize: fontSize,
      color: Colors.white,
      quality: 50,
      imageFormat: ImageFormat.png,
    );
    File finalFile = File(image!);

    return finalFile;
  }
  return null;
}

Future<XFile> compressImage(File file) async {
  if (!file.existsSync()) {
    throw Exception('File does not exist at the given path');
  }
  String nameImage = "";
  if (file.uri.pathSegments.last.endsWith(".png") || file.uri.pathSegments.last.endsWith(".jpg")) {
    nameImage = file.uri.pathSegments.last.substring(0, file.uri.pathSegments.last.length - 4);
  } else if (file.uri.pathSegments.last.endsWith(".jpeg")) {
    nameImage = file.uri.pathSegments.last.substring(0, file.uri.pathSegments.last.length - 5);
  }

  final compressedFile = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    '${file.parent.path}/converted_${nameImage}.jpg',
    quality: 70,
    minWidth: 800,
    minHeight: 800,
    format: CompressFormat.jpeg,
  );

  if (compressedFile != null) {
    return compressedFile;
  } else {
    throw Exception('Image compression failed.');
  }
}

TableRow tableRowScan(
    {required BuildContext context,
    required String uuid,
    required String hawb,
    required String itemNo,
    required String consigneeName,
    required String ctns,
    required String lastStatus,
    bool isSuspended = false,
    required Color colorsStatus}) {
  return TableRow(
    decoration: BoxDecoration(color: Colors.white),
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(
                  hawb,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            ColoredBox(
              color: isSuspended ? Colors.yellow : Colors.transparent,
              child: Row(
                children: [
                  Text(
                    "ItemNo: ",
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    itemNo,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  "Cons: ",
                  style: TextStyle(fontSize: 14),
                ),
                Expanded(
                  child: Text(
                    consigneeName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  "CTNS: ",
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  ctns,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            lastStatus,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorsStatus,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, "/detailItemScan", arguments: {"uuid": uuid, "hawb": hawb});
            },
            icon: Image.asset("assets/images/file.png", width: 25, height: 25),
          ),
        ],
      ),
    ],
  );
}

Future<String?> checkLogin() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.getString("accessToken");
  if (accessToken != null) {
    return accessToken;
  } else {
    return null;
  }
}

Future<void> showSessionExpiredDialog(BuildContext context, {ValueNotifier<bool>? isShowDialog}) async {
  if (isShowDialog != null && isShowDialog.value) {
    Navigator.pop(context);
  }
  isShowDialog?.value = true;
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Session Expired"),
        content: Text("เซสชั่นหมดอายุ กรุณาเข้าสู่ระบบใหม่", style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("ปิด"),
          ),
        ],
      );
    },
  );
}
