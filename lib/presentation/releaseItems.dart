import 'package:flutter/material.dart';

class releaseItemsPage extends StatefulWidget {
  const releaseItemsPage({super.key});

  @override
  State<releaseItemsPage> createState() => _releaseItemsPageState();
}

class _releaseItemsPageState extends State<releaseItemsPage> {
  String datePicked = "";

  @override
  void didChangeDependencies() {
    setState(() {
      Map<String, dynamic> date = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      datePicked = date["datePick"];
    });
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
              Padding(
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
                      for (var i = 0; i < 10; i++)
                        TableRow(
                          decoration: BoxDecoration(color: Colors.white),
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("1Z58W37E0434300320", style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "ปล่อยของ",
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
                                        arguments: {"hawb": "1Z58W37E0434300320"});
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
