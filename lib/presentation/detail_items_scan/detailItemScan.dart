import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/data/models/detailItemScan_model.dart';
import 'package:pos/presentation/detail_items_scan/bloc/detail_item_scan_bloc.dart';

class DetailScanItemPage extends StatefulWidget {
  const DetailScanItemPage({super.key});

  @override
  State<DetailScanItemPage> createState() => _DetailScanItemPageState();
}

class _DetailScanItemPageState extends State<DetailScanItemPage> {
  Map<String, dynamic> detailData = {};

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startEventDetailTable();
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
        title: const Text('Detail Scan'),
      ),
      body: SizedBox(
        child: Column(
          children: [
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("HAWB", style: TextStyle(fontSize: 20)),
                SizedBox(width: 10),
                Text("(${detailData["hawb"]})", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 30),
            BlocBuilder<DetailItemScanBloc, DetailItemScanState>(
              builder: (context, state) {
                if (state is DetailItemScanLoadingState) {
                  return CircularProgressIndicator();
                } else if (state is DetailItemScanLoadedState) {
                  return _tableDetailData(state.model);
                } else {
                  return Center(child: Text("ไม่มีข้อมูล"));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableDetailData(List<DetailitemScanModel> model) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const <int, TableColumnWidth>{
          0: FlexColumnWidth(),
          1: FixedColumnWidth(180),
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
                      "Status",
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
            TableRow(
              decoration: BoxDecoration(color: Colors.white),
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(data.status),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data.createdAt,
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
                    if (data.imageUrl != "" || data.remark != "")
                      IconButton(
                        onPressed: () {
                          _showCustomDialog(context, detailData["hawb"], data.status, data.remark, data.imageUrl);
                        },
                        icon: Icon(Icons.warning, color: Colors.orange),
                      ),
                    SizedBox(height: 48)
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showCustomDialog(BuildContext context, String hwb, String status, String remark, [String? image]) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('พบปัญหา (DMC)'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$hwb : พบปัญหา (DMC)'),
              SizedBox(height: 16),
              Text('หมายเหตุ: ${!remark.isEmpty ? remark : "ไม่มี"}'),
              SizedBox(height: 16),
              image != null
                  ? Column(
                      children: [
                        Align(alignment: Alignment.centerLeft, child: Text('รูปภาพ:')),
                        SizedBox(height: 16),
                        Center(
                          child: Image.network(
                            image,
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    )
                  : SizedBox(),
              // Container(
              //   height: 100,
              //   width: double.infinity,
              //   decoration: BoxDecoration(
              //     border: Border.all(color: Colors.grey),
              //     borderRadius: BorderRadius.circular(8),
              //     color: Colors.grey[200],
              //   ),
              //   child: image == null
              //       ? SizedBox()
              //       : Center(
              //           child: Image.network(
              //             image,
              //             height: 200,
              //             width: 200,
              //             fit: BoxFit.cover,
              //           ),
              //         ),
              // ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('ปิด'),
            ),
          ],
        );
      },
    );
  }

  void _startEventDetailTable() {
    var result = ModalRoute.of(context)!.settings.arguments;
    setState(() {
      detailData = result as Map<String, dynamic>;
    });
    context.read<DetailItemScanBloc>().add(DetailItemScanLoadingEvent(uuid: detailData["uuid"]));
  }
}
