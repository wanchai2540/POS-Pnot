// ignore_for_file: avoid_unnecessary_containers

import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos/data/api/api.dart';
import 'package:pos/button_listener.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/data/models/scanAndRelease_model.dart';
import 'package:pos/data/models/scanFindItems_model.dart';
import 'package:pos/data/models/scan_listener_model.dart';
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
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  List<String> list = ["ทั้งหมด", "เจอของ", "ของพร้อมปล่อย", "ปล่อยของ", "พบปัญหา", "อื่นๆ"];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _initialValueListDropdown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startEventTable();
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        title: Text("สแกนพร้อมปล่อยของ"),
      ),
      backgroundColor: Colors.blue[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.blue[100],
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
      floatingActionButton: floadting(),
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
    } else if (lastStatus == "พบปัญหา") {
      return Colors.red[200];
    }
    return Colors.black;
  }

  Widget floadting() {
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
                        _onScan(date: datePicked, hawb: _controller.text);
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

  showScanNoHawbDialog() {
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  showScanDialog(ScanAndReleaseModel model,
      {int? statusCode,
      bool isDialog3 = false,
      String? nameReportBtn,
      String? remarkSuccess,
      String? remarkFailed,
      bool isGreen = false}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text("HAWB: ${model.hawb}"),
                Text("Type: ${model.productType}"),
                Text("Pick Up: ${model.pickupBy}"),
                Text("สถานะล่าสุด: ${model.lastStatus}"),
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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

  Future<void> _onScan({required String date, required String hawb}) async {
    var dataGetScan = await DataService().getPendingReleaseListener(date, hawb);
    var data = dataGetScan["body"];
    try {
      ScanAndReleaseModel result = ScanAndReleaseModel.fromJson(data);
      if (dataGetScan["code"] == 200) {
        if (data["appCode"] == "01" && data["statusCode"] == "04" || data["statusCode"] == "07") {
          // Dialog 1
          showScanDialog(result, remarkFailed: "สแกนของพร้อมปล่อยสำเร็จ", isGreen: true);
        }
      } else if (dataGetScan["code"] == 400) {
        if (data["appCode"] == "03") {
          // Dialog 5
          showScanNoHawbDialog();
        } else if (data["appCode"] == "02" && (data["statusCode"] == "04" || data["statusCode"] == "07")) {
          // Dialog 2
          showScanDialog(result, remarkFailed: "HAWB นี้ถูกสแกนไปแล้ว");
        } else if (data["appCode"] == "02" && data["statusCode"] == "08" && data["subStatusCode"] == "07") {
          // Dialog 3
          showScanDialog(result, remarkFailed: "HAWB ของไม่ครบ โปรดรอ Admin อนุมัติ");
        } else if (data["appCode"] == "02" &&
            (data["statusCode"] == "01" || data["statusCode"] == "02" || data["statusCode"] == "05")) {
          // Dialog 4
          showScanDialog(result, remarkFailed: "สถานะไม่ถูกต้อง");
        }
      }
    } catch (e) {
      Exception(e);
    }
  }
}
