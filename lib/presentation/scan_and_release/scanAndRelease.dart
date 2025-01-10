// ignore_for_file: avoid_unnecessary_containers

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos/common.dart';
import 'package:pos/data/api/api.dart';
import 'package:pos/button_listener.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/data/models/scanAndRelease_model.dart';
import 'package:pos/data/models/scanFindItems_model.dart';
import 'package:pos/presentation/scan_find_items/bloc/scan_find_items_page_bloc.dart';

typedef MenuEntry = DropdownMenuEntry<String>;

class ScanAndReleasePage extends StatefulWidget {
  ScanAndReleasePage({super.key});

  @override
  State<ScanAndReleasePage> createState() => _ScanAndReleasePageState();
}

class _ScanAndReleasePageState extends State<ScanAndReleasePage> {
  String datePicked = "";
  String dropdownLabel = "";
  String dropdownValue = "";
  List<MenuEntry> menuEntries = [];
  final TextEditingController _controller = TextEditingController();
  List<String> list = ["ทั้งหมด", "สแกนแล้ว", "ยังไม่ได้สแกน", "ของพร้อมปล่อย", "ปล่อยของ", "พบปัญหา", "อื่นๆ"];
  final _formKey = GlobalKey<FormState>();

  bool _isShowDialog = false;
  final FocusNode _focusBarcodeField = FocusNode();
  final TextEditingController _textEditing = TextEditingController();
  final FocusNode _keyboardListenerFocusNode = FocusNode();

  @override
  void initState() {
    CustomButtonListener.initialize();

    _initialValueListDropdown();
    _onScannListener();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startEventTable();
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
        title: Text("สแกนพร้อมปล่อยของ"),
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
                            // onChanged: (value) {
                            //   _onScan(context,
                            //       date: datePicked, hawb: value.trim());
                            // },
                            onSubmitted: (String value) {
                              _textEditing.text = value;
                              _onScan(parentContext: context, date: datePicked, hawb: value.trim());
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
                        icon: Image.asset("assets/images/file.png", width: 25, height: 25),
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
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Color(0xFFF5ECD5),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _onScan(parentContext: ctx, date: datePicked, hawb: _controller.text);
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

  Future<void> _onScan({required BuildContext parentContext, required String date, required String hawb}) async {
    var dataGetScan = await DataService().getPendingReleaseListener(date, hawb);
    var data = dataGetScan["body"];
    try {
      ScanAndReleaseModel result = ScanAndReleaseModel.fromJson(data);
      if (dataGetScan["code"] == 200) {
        if (data["appCode"] == "01" && data["statusCode"] == "04" ||
            data["statusCode"] == "07" ||
            data["statusCode"] == "11") {
          // Dialog 1
          DialogScan().showScanAndReleaseDialog(
              isShowDialog: _isShowDialog,
              model: result,
              parentContext: parentContext,
              datePicked: datePicked,
              nameReportBtn: "แจ้งปัญหา",
              remarkFailed: "สแกนของพร้อมปล่อยสำเร็จ",
              isGreen: true);
        }
      } else if (dataGetScan["code"] == 400) {
        if (data["appCode"] == "03") {
          // Dialog 4
          DialogScan().showScanNoHawbDialog(
            isShowDialog: _isShowDialog,
            context: context,
            datePicked: datePicked,
          );
        } else if (data["appCode"] == "02" &&
            (data["statusCode"] == "04" || data["statusCode"] == "07" || data["statusCode"] == "11")) {
          // Dialog 2
          DialogScan().showScanAndReleaseDialog(
            isShowDialog: _isShowDialog,
            model: result,
            parentContext: parentContext,
            datePicked: datePicked,
            nameReportBtn: "แจ้งปัญหา",
            remarkFailed: "HAWB นี้ถูกสแกนไปแล้ว",
          );
        } else if (data["appCode"] == "02" &&
            (data["statusCode"] == "01" ||
                data["statusCode"] == "02" ||
                data["statusCode"] == "05" ||
                data["statusCode"] == "08")) {
          // Dialog 3
          DialogScan().showScanAndReleaseDialog(
            isShowDialog: _isShowDialog,
            model: result,
            parentContext: parentContext,
            datePicked: datePicked,
            remarkFailed: "สถานะไม่ถูกต้อง",
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
          _focusBarcodeField.requestFocus();
        }
      });
    };
  }
}
