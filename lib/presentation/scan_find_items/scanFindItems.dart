// ignore_for_file: avoid_unnecessary_containers, use_build_context_synchronously

import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kymscanner/constant.dart';
import 'package:kymscanner/data/api/api.dart';
import 'package:kymscanner/button_listener.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kymscanner/data/models/scanFindItems_model.dart';
import 'package:kymscanner/data/models/scan_listener_model.dart';
import 'package:kymscanner/common.dart';
import 'package:kymscanner/data/models/scan_result_model.dart';
import 'package:kymscanner/presentation/scan_find_items/bloc/scan_find_items_page_bloc.dart';

typedef MenuEntry = DropdownMenuEntry<String>;

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

  List<String> list = ["ทั้งหมด", "สแกนแล้ว", "ยังไม่ได้สแกน", "ของพร้อมปล่อย", "ปล่อยของ", "พบปัญหา", "อื่นๆ"];
  final _formKey = GlobalKey<FormState>();
  final _reportFormKey = GlobalKey<FormState>();

  ValueNotifier<bool> _isShowDialog = ValueNotifier<bool>(false);

  final FocusNode _focusBarcodeField = FocusNode();
  final TextEditingController _textEditing = TextEditingController();
  final FocusNode _keyboardListenerFocusNode = FocusNode();

  ValueNotifier<File?> _imageNoDMC = ValueNotifier<File?>(null);
  ValueNotifier<File?> _imageReport = ValueNotifier<File?>(null);
  ValueNotifier<File?> _imageRepack = ValueNotifier<File?>(null);
  List<File?> _imageNoReason = [];

  int _countListType = 0;
  @override
  void initState() {
    CustomButtonListener.initialize();

    _initialValueListDropdown();
    _onScannListener();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startEventTable();
      // updateCountList();
      context.read<ScanFindItemsPageBloc>().stream.listen((state) {
        if (state is ScanPageGetLoadedState) {
          _countListType = state.model.length;
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    CustomButtonListener.dispose();
    _focusBarcodeField.dispose();
    _keyboardListenerFocusNode.dispose();
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
        child: KeyboardListener(
          focusNode: _keyboardListenerFocusNode,
          autofocus: true,
          onKeyEvent: (event) {
            if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
              // print('Enter key pressed!');
            }
          },
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                children: [
                  Center(
                    child: Text(
                      "งานของวันที่ $datePicked",
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DropdownMenu<String>(
                        initialSelection: list.first,
                        onSelected: (String? value) {
                          setState(() {
                            dropdownLabel = value!;
                            _handleDropdownSelection(value); // Moved logic to a separate function
                          });
                        },
                        dropdownMenuEntries: menuEntries,
                      ),
                      SizedBox(width: 10),
                      Text("จำนวน: $_countListType", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("HAWB ที่สแกน : ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(width: 10),
                        SizedBox(
                          width: MediaQuery.of(context).size.height * 0.27,
                          child: TextField(
                            focusNode: _focusBarcodeField,
                            controller: _textEditing,
                            onSubmitted: (String value) {
                              _textEditing.text = value;
                              _onScan(context, date: datePicked, hawb: value.trim());
                            },

                            // keyboardType: TextInputType.none,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  BlocListener<ScanFindItemsPageBloc, ScanPageBlocState>(
                    listener: (context, state) {
                      if (state is ScanPageGetLoadedState) {
                        setState(() {
                          _countListType = state.model.length;
                        });
                      } else if (state is ScanPageGetErrorState) {
                        setState(() {
                          _countListType = 0;
                        });
                      }
                    },
                    child: SizedBox(),
                  ),
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
                  ),
                  SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: floadting(context),
    );
  }

  void _handleDropdownSelection(String value) {
    switch (value) {
      case "ทั้งหมด":
        context.read<ScanFindItemsPageBloc>().add(
              ScanPageGetDataEvent(date: datePicked),
            );
        break;
      case "สแกนแล้ว":
        dropdownValue = "03";
        context.read<ScanFindItemsPageBloc>().add(
              ScanPageGetDataEvent(date: datePicked, type: "03"),
            );
        break;
      case "ยังไม่ได้สแกน":
        dropdownValue = "01";
        context.read<ScanFindItemsPageBloc>().add(
              ScanPageGetDataEvent(date: datePicked, type: "01"),
            );
        break;
      case "ของพร้อมปล่อย":
        dropdownValue = "04";
        context.read<ScanFindItemsPageBloc>().add(
              ScanPageGetDataEvent(date: datePicked, type: "04"),
            );
        break;
      case "ปล่อยของ":
        dropdownValue = "05";
        context.read<ScanFindItemsPageBloc>().add(
              ScanPageGetDataEvent(date: datePicked, type: "05"),
            );
        break;
      case "พบปัญหา":
        dropdownValue = "08";
        context.read<ScanFindItemsPageBloc>().add(
              ScanPageGetDataEvent(date: datePicked, type: "08"),
            );
        break;
      case "อื่นๆ":
        dropdownValue = "00";
        context.read<ScanFindItemsPageBloc>().add(
              ScanPageGetDataEvent(date: datePicked, type: "00"),
            );
        break;
      default:
    }
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
          border: TableBorder.all(color: Colors.black, style: BorderStyle.solid, width: 1),
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
              tableRowScan(
                context: context,
                uuid: data.uuid,
                hawb: data.hawb,
                itemNo: data.itemNo,
                consigneeName: data.consigneeName,
                ctns: data.ctns,
                lastStatus: data.lastStatus,
                colorsStatus: _colorStatus(data.lastStatus)!,
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
                        _onScan(ctx, date: datePicked, hawb: _controller.text.trim());
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

  void _startEventTable() {
    Map<String, dynamic> date = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    datePicked = date["datePick"];
    context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));
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
          // Dialog 6
          DialogScan().showScanDialog(
            isShowDialog: _isShowDialog,
            parentContext: parentContext,
            model: result,
            datePicked: datePicked,
            formKeyDialogConfirm: _reportFormKey,
            imageDialogConfirm: _imageReport,
            statusCode: 200,
            module: "1",
            nameReportBtn: "แจ้งปัญหา",
            typeDialogScan: TypeDialogScanItems.dialog6,
          );
        }
      } else if (dataGetScan["code"] == 400) {
        if (data["appCode"] == "02" && data["statusCode"] == "08" && data["subStatusCode"] != "03") {
          // Dialog 1
          ScanResultModel result = ScanResultModel.fromJson(data);
          DialogScan().showNoDMCDialog(
            isShowDialog: _isShowDialog,
            parentContext: parentContext,
            model: result,
            datePicked: datePicked,
            module: "1",
            remarkFailed: 'เป็นงาน "${result.reason}"' + "\nต้องการยืนยันการตรวจสอบ",
            imageNoDMC: _imageNoDMC,
          );
        } else if (data["appCode"] == "03") {
          // Dialog 2
          DialogScan().showScanNoHawbDialog(isShowDialog: _isShowDialog, context: context, datePicked: datePicked);
        } else if (data["appCode"] == "02" &&
            (data["statusCode"] == "04" ||
                data["statusCode"] == "05" ||
                data["statusCode"] == "10" ||
                data["statusCode"] == "11")) {
          // Dialog 3
          DialogScan().showScanDialog(
            isShowDialog: _isShowDialog,
            parentContext: parentContext,
            model: result,
            datePicked: datePicked,
            formKeyDialogConfirm: _reportFormKey,
            imageDialogConfirm: _imageReport,
            statusCode: 400,
            module: "1",
            remarkFailed: "สถานะไม่ถูกต้อง",
            typeDialogScan: TypeDialogScanItems.dialog3,
          );
        } else if (data["appCode"] == "02" && data["statusCode"] == "08" && data["subStatusCode"] == "03") {
          // Dialog 4
          DialogScan().showScanDialog(
            isShowDialog: _isShowDialog,
            parentContext: parentContext,
            model: result,
            datePicked: datePicked,
            formKeyDialogConfirm: _reportFormKey,
            imageDialogConfirm: _imageRepack,
            statusCode: 400,
            module: "1",
            typeDialogScan: TypeDialogScanItems.dialog4,
            nameReportBtn: "ยืนยัน\nRepack",
            remarkFailed: "เป็นงาน DMC คุณต้องการยืนยันการ\nRepack(หากยืนยันบังคับถ่ายรูป)",
          );
        } else if (data["appCode"] == "02" &&
            (data["statusCode"] == "03" || data["statusCode"] == "06" || data["statusCode"] == "09")) {
          // Dialog 5
          DialogScan().showScanDialog(
            isShowDialog: _isShowDialog,
            parentContext: parentContext,
            model: result,
            datePicked: datePicked,
            formKeyDialogConfirm: _reportFormKey,
            imageDialogConfirm: _imageReport,
            statusCode: 400,
            module: "1",
            remarkFailed: "HAWB นี้ถูกสแกนไปแล้ว",
            nameReportBtn: "แจ้งปัญหา",
            typeDialogScan: TypeDialogScanItems.dialog5,
          );
        }
      }
    } catch (e) {
      Exception(e);
    }
  }

  void _onScannListener() {
    CustomButtonListener.onButtonPressed = (event) {
      if (event != null) {
        _textEditing.text = "";
        _focusBarcodeField.requestFocus();
      }
    };
  }
}
