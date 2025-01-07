// ignore_for_file: avoid_unnecessary_containers, use_build_context_synchronously

import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos/data/api/api.dart';
import 'package:pos/button_listener.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/data/models/scanFindItems_model.dart';
import 'package:pos/data/models/scan_listener_model.dart';
import 'package:pos/presentation/scan_find_items/bloc/scan_find_items_page_bloc.dart';

typedef MenuEntry = DropdownMenuEntry<String>;

enum TypeDialogScanItems { dialog1, dialog2, dialog3, dialog4, dialog5 }

class ScanFindItemsPage extends StatefulWidget {
  ScanFindItemsPage({super.key});

  @override
  State<ScanFindItemsPage> createState() => _ScanFindItemsPageState();
}

class _ScanFindItemsPageState extends State<ScanFindItemsPage> {
  String datePicked = "";
  String dropdownLabel = "";
  String dropdownValue = "";
  List<MenuEntry> menuEntries = [];
  final TextEditingController _controller = TextEditingController();

  List<String> list = ["ทั้งหมด", "เจอของ", "ของพร้อมปล่อย", "ปล่อยของ", "พบปัญหา", "อื่นๆ"];
  final ValueNotifier<File?> _imageReport = ValueNotifier<File?>(null);
  final ValueNotifier<File?> _imageRepack = ValueNotifier<File?>(null);
  final _formKey = GlobalKey<FormState>();
  final _reportFormKey = GlobalKey<FormState>();
  bool _isShowDialog = false;
  FocusNode _focusBarcodeField = FocusNode();
  TextEditingController _textEditing = TextEditingController();

  @override
  void initState() {
    _initialValueListDropdown();
    _onScannListener();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startEventTable();
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _onScannListener();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _focusBarcodeField.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF5ECD5),
        title: Text("สแกนหาของ"),
      ),
      backgroundColor: Color(0xFFFFFAEC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Center(
                  child: Text(
                    "งานของวันที่ ${datePicked}",
                    style: TextStyle(fontSize: 25),
                  ),
                ),
                SizedBox(height: 20),
                DropdownMenu<String>(
                  initialSelection: list.first,
                  onSelected: (String? value) {
                    setState(() {
                      switch (value) {
                        case "ทั้งหมด":
                          context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));
                        case "เจอของ":
                          dropdownValue = "03";
                          context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked, type: "03"));
                        case "ของพร้อมปล่อย":
                          dropdownValue = "04";
                          context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked, type: "04"));
                        case "ปล่อยของ":
                          dropdownValue = "05";
                          context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked, type: "05"));
                        case "พบปัญหา":
                          dropdownValue = "08";
                          context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked, type: "08"));
                        case "อื่นๆ":
                          dropdownValue = "00";
                          context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked, type: "00"));
                          break;
                        default:
                      }
                      dropdownLabel = value!;
                    });
                  },
                  dropdownMenuEntries: menuEntries,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("HAWB ล่าสุด : "),
                    SizedBox(width: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.height * 0.3,
                      child: TextField(
                        controller: _textEditing,
                        onChanged: (value) {
                          _onScan(context, date: datePicked, hawb: value);
                        },
                        keyboardType: TextInputType.none,
                        focusNode: _focusBarcodeField,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        // decoration: InputDecoration(
                        //   hintText: "ยังไม่มีการสแกน",
                        // ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                BlocBuilder<ScanFindItemsPageBloc, ScanPageBlocState>(
                  builder: (context, state) {
                    if (state is ScanPageGetLoadingState) {
                      return CircularProgressIndicator();
                    } else if (state is ScanPageGetLoadedState) {
                      return _tableListData(state.model);
                    } else {
                      return Center(child: Text("ไม่มีข้อมูล"));
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: floadting(context),
    );
  }

  Widget _tableListData(List<ScanfinditemsModel> model) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: <int, TableColumnWidth>{
            0: FixedColumnWidth(200),
            1: FlexColumnWidth(50),
            2: FixedColumnWidth(60),
          },
          border: TableBorder.all(color: Colors.black, style: BorderStyle.solid, width: 2),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.white),
              children: [
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: Center(
                      child: Text(
                        "HAWB",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: Center(
                      child: Text(
                        "Status",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                SizedBox(),
              ],
            ),
            for (var data in model)
              TableRow(
                decoration: BoxDecoration(color: Colors.white),
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("${data.hawb}", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${data.lastStatus}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _colorStatus(data.lastStatus),
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
                          Navigator.pushNamed(context, "/detailItemScan",
                              arguments: {"uuid": data.uuid, "hawb": data.hawb});
                        },
                        icon: Icon(Icons.zoom_in),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color? _colorStatus(String lastStatus) {
    if (lastStatus == "ปล่อยของ") {
      return Colors.green[200];
    } else if (lastStatus == "เจอของ") {
      return Colors.blue[200];
    } else if (lastStatus == "พบปัญหา [DMC (กล่องบุบ)]") {
      return Colors.red[200];
    }
    return Colors.black;
  }

  Widget floadting(BuildContext ctx) {
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
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ระบุเลขบาร์โค้ด',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _controller,
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
                      if (_formKey.currentState!.validate()) {
                        _onScan(ctx, date: datePicked, hawb: _controller.text);
                        Navigator.pop(context);
                      }
                      _controller.text = "";
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

  showScanNoHawbDialog() {
    if (_isShowDialog) {
      Navigator.of(context).pop();
      _isShowDialog = false;
    }
    _isShowDialog = true;
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
                _isShowDialog = false;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  showScanDialog(BuildContext parentContext, ScanListenerModel model,
      {int? statusCode,
      TypeDialogScanItems? typeDialogScan,
      String? nameReportBtn,
      String? remarkSuccess,
      String? remarkFailed}) {
    if (_isShowDialog) {
      Navigator.of(context).pop();
      _isShowDialog = false;
    }
    _isShowDialog = true;
    return showDialog(
      context: context,
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
                          _isShowDialog = false;
                          Navigator.of(context).pop();
                          // Navigator.of(parentContext)
                          //     .pushNamed("/report", arguments: {"uuid": model.uuid, "datePicked": datePicked});
                          await showConfirmFindItemDialog(model.uuid);
                        } else if (statusCode == 400 && typeDialogScan == TypeDialogScanItems.dialog3) {
                          _isShowDialog = false;
                          Navigator.of(context).pop();
                          await showConfirmRepackDialog(model.uuid);
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
                _isShowDialog = false;
                Navigator.of(context).pop();
              },
            ),
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
          width: 20,
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

  Future<void> showConfirmRepackDialog(String uuid) async {
    _imageRepack.value = null;

    if (_isShowDialog) {
      Navigator.of(context).pop();
      _isShowDialog = false;
    }
    _isShowDialog = true;
    return showDialog(
      context: context,
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
                      setState(() {
                        _imageRepack.value = File(image.path);
                      });
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
                      setState(() {
                        _imageRepack.value = null;
                      });
                      context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));
                      _isShowDialog = false;
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('ยืนยัน'),
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
                        _isShowDialog = false;
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
        );
      },
    );
  }

  Future<void> showConfirmFindItemDialog(String uuid) async {
    // _imageReport.value = null;
    TextEditingController _controllerRemark = TextEditingController();
    String? reasonValue;

    Map<String, dynamic> result = await DataService().getProblemList();
    List<DropdownMenuEntry<String>> reasonList = (result['data'] as List)
        .map((item) => DropdownMenuEntry<String>(label: item['text'], value: item['value']))
        .toList();

    if (_isShowDialog) {
      Navigator.of(context).pop();
      _isShowDialog = false;
    }
    _isShowDialog = true;
    return await showDialog(
      context: context,
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
                      setState(() {
                        _imageReport.value = File(image.path);
                      });
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
                      setState(() {
                        _imageReport.value = null;
                      });
                      context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));
                      _isShowDialog = false;
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
                      if (_reportFormKey.currentState!.validate()) {
                        if (reasonValue == "03") {
                          if (_imageReport.value != null) {
                            res = await DataService().sendReport(uuid, datePicked, reasonValue!,
                                image: _imageReport.value!, remark: _controllerRemark.text);

                            if (res == "success") {
                              snackBarUtil('แจ้งปัญหาสำเร็จ');
                            } else {
                              snackBarUtil('แจ้งปัญหาไม่สำเร็จ กรุณาลองใหม่อีกครั้ง');
                            }
                            _isShowDialog = false;
                            _imageReport.value = null;
                            context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));
                            Navigator.of(context).pop();
                            FocusScope.of(context).requestFocus(_focusBarcodeField);
                          } else {
                            snackBarUtil('กรุณาถ่ายรูปสินค้าหรือพัสดุเพื่อแจ้งปัญหา');
                          }
                        } else {
                          if (_imageReport.value != null) {
                            res = await DataService().sendReport(uuid, datePicked, reasonValue!,
                                image: _imageReport.value!, remark: _controllerRemark.text);
                          } else {
                            res = await DataService()
                                .sendReport(uuid, datePicked, reasonValue!, remark: _controllerRemark.text);
                          }
                          if (res == "success") {
                            snackBarUtil('แจ้งปัญหาสำเร็จ');
                          } else {
                            snackBarUtil('แจ้งปัญหาไม่สำเร็จ กรุณาลองใหม่อีกครั้ง');
                          }
                          _isShowDialog = false;
                          _imageReport.value = null;
                          context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));
                          Navigator.of(context).pop();
                          FocusScope.of(context).requestFocus(_focusBarcodeField);
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

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackBarUtil(String title) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(title),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _startEventTable() {
    Map<String, dynamic> date = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    setState(() {
      datePicked = date["datePick"];
      context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));
    });
  }

  void _initialValueListDropdown() {
    dropdownLabel = list.first;
    menuEntries = UnmodifiableListView<MenuEntry>(
      list.map<MenuEntry>((String name) => MenuEntry(value: name, label: name)),
    );
  }

  Future<void> _onScan(BuildContext parentContext, {required String date, required String hawb}) async {
    var dataGetScan = await DataService().getScanListener(date, hawb);
    var data = dataGetScan["body"];
    try {
      ScanListenerModel result = ScanListenerModel.fromJson(data);
      if (dataGetScan["code"] == 200) {
        if (data["appCode"] == "01" && data["statusCode"] == "03") {
          // Dialog 5
          showScanDialog(
            parentContext,
            result,
            statusCode: 200,
            nameReportBtn: "แจ้งปัญหา",
            typeDialogScan: TypeDialogScanItems.dialog5,
          );
        }
      } else if (dataGetScan["code"] == 400) {
        if (data["appCode"] == "03") {
          // Dialog 1
          showScanNoHawbDialog();
        } else if (data["appCode"] == "02" && (data["statusCode"] == "04" || data["statusCode"] == "05")) {
          // Dialog 2
          showScanDialog(parentContext, result, statusCode: 400, remarkFailed: "สถานะไม่ถูกต้อง");
        } else if (data["appCode"] == "02" && (data["statusCode"] == "08" && data["subStatusCode"] == "03")) {
          // Dialog 3
          showScanDialog(parentContext, result,
              statusCode: 400,
              typeDialogScan: TypeDialogScanItems.dialog3,
              nameReportBtn: "ยืนยัน\nRepack",
              remarkFailed: "เป็นงาน DMC คุณต้องการยืนยันการ\nRepack(หากยืนยันบังคับถ่ายรูป)");
        } else if (data["appCode"] == "02" &&
            (data["statusCode"] == "03" || data["statusCode"] == "06" || data["statusCode"] == "08")) {
          // Dialog 4
          showScanDialog(
            parentContext,
            result,
            statusCode: 400,
            remarkFailed: "HAWB นี้ถูกสแกนไปแล้ว",
            nameReportBtn: "แจ้งปัญหา",
            typeDialogScan: TypeDialogScanItems.dialog4,
          );
        }
      }
    } catch (e) {
      Exception(e);
    }
  }

  void _onScannListener() {
    CustomButtonListener.onButtonPressed = (event) {
      setState(() {
        if (event != null) {
          _textEditing.text = "";
          snackBarUtil("pre-test");
          FocusScope.of(context).requestFocus(_focusBarcodeField);
          _textEditing.text = "a101";
        }
      });
    };
  }
}
