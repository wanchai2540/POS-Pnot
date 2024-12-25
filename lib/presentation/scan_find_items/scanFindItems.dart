// ignore_for_file: avoid_unnecessary_containers

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos/data/api/api.dart';
import 'package:pos/button_listener.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/data/models/scanFindItems_model.dart';
import 'package:pos/presentation/scan_find_items/bloc/scan_find_items_page_bloc.dart';

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
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  List<String> list = ["ทั้งหมด", "เจอของ", "ของพร้อมปล่อย", "ปล่อยของ", "พบปัญหา", "อื่นๆ"];

  @override
  void didChangeDependencies() {
    _initialValueListDropdown();
    _onScannListener();
    _startEventTable();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        title: Text("Scan Page"),
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
                    "Scan HAWB (${datePicked})",
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
                          dropdownValue = "99";
                          context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked, type: "99"));
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
                        style: TextStyle(
                          color: Colors.green[200],
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

  void _onScannListener() {
    CustomButtonListener.onButtonPressed = (event) {
      setState(() {
        if (event != null) {
          context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked, barcode: event));
          // .add(ScanPageGetDataEvent(date: datePicked, type: dropdownValue, barcode: event));
          // _controller.text = event;
          // // _controller.text = "4294969872";
          // _focusNode.requestFocus();
          // _controller.addListener(() {
          //   // ทำต่อ เมื่อได้ value กลับมาแล้วให้ ยิง api ตรงนี้ และ refresh screen
          //   // API
          // });
        }
      });
    };
  }
}
