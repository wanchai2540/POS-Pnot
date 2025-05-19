// ignore_for_file: avoid_unnecessary_containers

import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kymscanner/common.dart';
import 'package:kymscanner/constant.dart';
import 'package:kymscanner/data/api/api.dart';
import 'package:kymscanner/button_listener.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kymscanner/data/models/release_model.dart';
import 'package:kymscanner/data/models/scanFindItems_model.dart';
import 'package:kymscanner/presentation/scan_find_items/bloc/scan_find_items_page_bloc.dart';

typedef MenuEntry = DropdownMenuEntry<String>;

class ReleaseItemsPage extends StatefulWidget {
  ReleaseItemsPage({super.key});

  @override
  State<ReleaseItemsPage> createState() => _ReleaseItemsPageState();
}

class _ReleaseItemsPageState extends State<ReleaseItemsPage> {
  String datePicked = "";
  String dropdownLabel = "";
  String dropdownValue = "";
  List<MenuEntry> menuEntries = [];
  final TextEditingController _controller = TextEditingController();
  List<String> list = ["ทั้งหมด", "สแกนแล้ว", "ยังไม่ได้สแกน", "ของพร้อมปล่อย", "ปล่อยของ", "พบปัญหา", "อื่นๆ"];
  final _formKey = GlobalKey<FormState>();

  ValueNotifier<bool> _isShowDialog = ValueNotifier<bool>(false);
  final FocusNode _focusBarcodeField = FocusNode();
  final TextEditingController _textEditing = TextEditingController();
  final FocusNode _keyboardListenerFocusNode = FocusNode();
  int _countListType = 0;

  @override
  void initState() {
    CustomButtonListener.initialize();

    _initialValueListDropdown();
    _onScannListener();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startEventTable();
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
        title: Text("ปล่อยของ"),
      ),
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
                      "งานของวันที่ ${datePicked}",
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
                            _handleDropdownSelection(value);
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
                              _onScan(parentContext: context, hawb: value.trim());
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
                isSuspended: data.isSuspended,
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
    } else if (lastStatus == "พบปัญหา") {
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _onScan(parentContext: ctx, hawb: _controller.text);
                        Navigator.pop(context);
                      }
                      _controller.text = "";
                    },
                    child: Text('Submit'),
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

  Widget customBadgeSpecial(String productType) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Type:  "),
        Container(
          width: 30,
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
          width: 25,
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

  Future<void> _onScan({required BuildContext parentContext, required String hawb}) async {
    var dataGetScan = await DataService().getReleaseListener(hawb);
    var data = dataGetScan["body"];
    try {
      ReleaseModel result = ReleaseModel.fromJson(data);

      if (dataGetScan["code"] == 200) {
        if (data["appCode"] == "01" && data["statusCode"] == "05") {
          // Dialog 1
          DialogScan().showReleaseScanDialog(
            parentContext: parentContext,
            model: result,
            isShowDialog: _isShowDialog,
            datePicked: datePicked,
            remarkFailed: "สแกนปล่อยของสำเร็จ",
            isGreen: true,
            typeDialogScanItems: TypeDialogScanItems.dialog1,
          );
        }
      } else if (dataGetScan["code"] == 400) {
        if (data["appCode"] == "03") {
          // Dialog 4
          DialogScan().showScanNoHawbDialog(
              title: "ไม่พบ HAWB ในระบบ", isShowDialog: _isShowDialog, context: parentContext, datePicked: datePicked);
        } else if (data["appCode"] == "02" && data["statusCode"] == "05") {
          // Dialog 2
          DialogScan().showReleaseScanDialog(
            model: result,
            parentContext: parentContext,
            isShowDialog: _isShowDialog,
            datePicked: datePicked,
            remarkFailed: "HAWB นี้ถูกสแกนไปแล้ว",
            typeDialogScanItems: TypeDialogScanItems.dialog2,
          );
        } else if (data["appCode"] == "02" &&
            (data["statusCode"] == "01" ||
                data["statusCode"] == "02" ||
                data["statusCode"] == "03" ||
                data["statusCode"] == "06" ||
                data["statusCode"] == "08" ||
                data["statusCode"] == "09" ||
                data["statusCode"] == "10")) {
          // Dialog 3
          // DialogScan().showReleaseScanDialog(
          //   model: result,
          //   parentContext: parentContext,
          //   isShowDialog: _isShowDialog,
          //   datePicked: datePicked,
          //   remarkFailed: "สถานะไม่ถูกต้อง",
          // );
          DialogScan().showScanNoHawbDialog(
              title: "สถานะไม่ถูกต้อง", isShowDialog: _isShowDialog, context: parentContext, datePicked: datePicked);
        }
      }
    } catch (e) {
      Exception(e);
      print(e);
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
