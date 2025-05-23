// ignore_for_file: avoid_unnecessary_containers
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kymscanner/common.dart';
import 'package:kymscanner/constant.dart';
import 'package:kymscanner/core_log.dart';
import 'package:kymscanner/data/api/api.dart';
import 'package:kymscanner/button_listener.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kymscanner/data/models/release_model.dart';
import 'package:kymscanner/data/models/release_round_model.dart';
import 'package:kymscanner/presentation/release_items/bloc/release_items_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final _formKey = GlobalKey<FormState>();

  ValueNotifier<bool> _isShowDialog = ValueNotifier<bool>(false);
  final FocusNode _focusBarcodeField = FocusNode();
  final TextEditingController _textEditing = TextEditingController();
  final FocusNode _keyboardListenerFocusNode = FocusNode();
  int _countListType = 0;
  String roundName = "";
  String roundUUID = "";

  @override
  void initState() {
    CustomButtonListener.initialize();

    _onScannListener();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _startEventTable();
      context.read<ReleaseItemsBloc>().stream.listen((state) {
        if (state is ReleasePageGetLoadedState) {
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Row(
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
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            roundName,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "จำนวน: $_countListType",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  BlocListener<ReleaseItemsBloc, ReleaseItemsState>(
                    listener: (context, state) {
                      if (state is ReleasePageGetLoadedState) {
                        setState(() {
                          _countListType = state.model.length;
                        });
                      } else if (state is ReleasePageGetErrorState) {
                        setState(() {
                          _countListType = 0;
                        });
                      }
                    },
                    child: SizedBox(),
                  ),
                  BlocBuilder<ReleaseItemsBloc, ReleaseItemsState>(
                    builder: (context, state) {
                      if (state is ReleasePageGetLoadingState) {
                        return CircularProgressIndicator();
                      } else if (state is ReleasePageGetLoadedState && state.model.isNotEmpty) {
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

  Widget _tableListData(List<ReleaseRoundModel> model) {
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
                        "Created At",
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
                itemNo: data.itemNo.toString(),
                consigneeName: data.consigneeName,
                ctns: data.ctns.toString(),
                lastStatus: data.lastStatus,
                createdAt: data.createdAt,
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

  Future<void> _startEventTable() async {
    Map<String, dynamic> date = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    datePicked = date["datePick"];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      roundName = prefs.getString(releaseRoundName) ?? "";
      roundUUID = prefs.getString(releaseRoundUUID) ?? "";
    });
    context.read<ReleaseItemsBloc>().add(ReleasePageGetDataEvent(date: datePicked, releaseRoundUUID: roundUUID));
  }

  Future<void> _onScan({required BuildContext parentContext, required String hawb}) async {
    var dataGetScan = await DataService().getReleaseScanListener(hawb, datePicked, roundName, roundUUID);
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
            roundUUID: roundUUID,
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
            roundUUID: roundUUID,
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
          DialogScan().showScanNoHawbDialog(
              title: "สถานะไม่ถูกต้อง", isShowDialog: _isShowDialog, context: parentContext, datePicked: datePicked);
        }
      }
    } catch (e) {
      Exception(e);
      CoreLog().error("ReleaseItemPage _onScan: Exception occurred: $e");
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

  TableRow tableRowScan(
      {required BuildContext context,
      required String uuid,
      required String hawb,
      required String itemNo,
      required String consigneeName,
      required String ctns,
      required String lastStatus,
      required String createdAt,
      bool isSuspended = false,
      required Color colorsStatus}) {
    String dateCreateAt = createdAt.split(" ").last;
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
              dateCreateAt,
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
}
