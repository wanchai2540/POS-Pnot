import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kymscanner/data/models/detailItemScan_model.dart';
import 'package:kymscanner/presentation/detail_items_scan/bloc/detail_item_scan_bloc.dart';

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
      body: SingleChildScrollView(
        child: SizedBox(
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(data.status),
                    ],
                  ),
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
                          _showCustomDialog(context, detailData["hawb"], data);
                        },
                        icon: Icon(Icons.warning, color: Colors.orange),
                      )
                    else
                      SizedBox(height: 48)
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showCustomDialog(BuildContext context, String hawb, DetailitemScanModel model) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('รายละเอียด', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 18),
                  children: [
                    TextSpan(
                      text: 'HAWB: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: hawb,
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 18),
                  children: [
                    TextSpan(
                      text: 'สถานะ: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '${model.status}',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
              model.remark.isNotEmpty
                  ? RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.black, fontSize: 18),
                        children: [
                          TextSpan(
                            text: 'หมายเหตุ: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: '${model.remark}',
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(),
              model.imageUrl.isNotEmpty
                  ? Column(
                      children: [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'รูปภาพ:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            )),
                        SizedBox(height: 16),
                        Center(
                          child: Image.network(
                            model.imageUrl,
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/no-image.png",
                                    height: 200,
                                    width: 200,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : SizedBox(),
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
