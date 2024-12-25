// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos/api/api.dart';
import 'package:pos/button_listener.dart';

class ScanListPage extends StatefulWidget {
  const ScanListPage({super.key});

  @override
  State<ScanListPage> createState() => _ScanListPageState();
}

class _ScanListPageState extends State<ScanListPage> {
  String datePicked = "";
  List<Map<String, dynamic>> listScanData = [];
  FocusNode _focusNode = FocusNode();
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    onScannListener();
    Map<String, dynamic> date = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    datePicked = date["datePick"];
    getListScanData(datePicked);

    super.didChangeDependencies();
  }

  Future<void> getListScanData(String date) async {
    var data = await DataService().getScanList(datePicked);
    setState(() {
      if (data["status"] == "success") {
        listScanData = data["data"];
      } else {
        listScanData = [];
      }
    });
  }

  void onScannListener() {
    CustomButtonListener.onButtonPressed = (event) {
      setState(() {
        if (event != null) {
          _controller.text = event;
          // _controller.text = "4294969872";
          _focusNode.requestFocus();
          _controller.addListener(() {
            // ทำต่อ เมื่อได้ value กลับมาแล้วให้ ยิง api ตรงนี้ และ refresh screen
            // API
          });
        }
      });
    };
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
                Visibility(
                  visible: true,
                  child: SizedBox(
                    width: 250,
                    child: TextFormField(
                      focusNode: _focusNode,
                      controller: _controller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                listScanData.length > 1
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Container(
                          child: Table(
                            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                            columnWidths: const <int, TableColumnWidth>{
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
                              for (var data in listScanData)
                                TableRow(
                                  decoration: BoxDecoration(color: Colors.white),
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text("${data["hawb"]}", style: TextStyle(fontSize: 16)),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "${data["lastStatus"]}",
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
                                                arguments: {"uuid": data["uuid"]});
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
                      )
                    : SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:pos/button_listener.dart';

// class ScanListPage extends StatefulWidget {
//   const ScanListPage({super.key});

//   @override
//   State<ScanListPage> createState() => _ScanListPageState();
// }

// class _ScanListPageState extends State<ScanListPage> {
//   FocusNode _focusNode = FocusNode();
//   TextEditingController _controller = TextEditingController();

//   @override
//   void initState() {
//     CustomButtonListener.onButtonPressed = (event) {
//       setState(() {
//         if (event != null) {
//           _controller.text = event;
//           // _controller.text = "4294969872";
//           _focusNode.requestFocus();
//           _controller.addListener(() {
//             // ทำต่อ เมื่อได้ value กลับมาแล้วให้ ยิง api ตรงนี้ และ refresh screen
//             // API
//           });
//         }
//       });
//     };
//     super.initState();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Title'),
//       ),
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         alignment: Alignment.center,
//         child: Column(
//           children: [
//             SizedBox(height: 30),
//             Visibility(
//               visible: true,
//               child: SizedBox(
//                 width: 250,
//                 child: TextFormField(
//                   focusNode: _focusNode,
//                   controller: _controller,
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
