import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kymscanner/common.dart';
import 'package:kymscanner/data/models/detailItemScan_model.dart';
import 'package:kymscanner/data/models/photoItemScan_model.dart';
import 'package:kymscanner/presentation/detail_items_scan/bloc/detail_item_scan_bloc.dart';

class DetailScanItemPage extends StatefulWidget {
  final String uuid;
  final String hawb;
  const DetailScanItemPage({super.key, required this.uuid, required this.hawb});

  @override
  State<DetailScanItemPage> createState() => _DetailScanItemPageState();
}

class _DetailScanItemPageState extends State<DetailScanItemPage> with TickerProviderStateMixin {
  List<DetailItemScanModel> detailData = [];
  List<PhotoItemScanModel> imageData = [];
  late final TabController _tabController;

  // List for images share
  final List<String> imagePaths = [];
  ValueNotifier<List<String>> selectedImages = ValueNotifier<List<String>>([]);
  ValueNotifier<bool> isSeletecting = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);

    context.read<DetailItemScanBloc>().add(DetailItemScanLoadingEvent(uuid: widget.uuid));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Scan'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Detail'),
              Tab(text: 'Photo'),
            ],
          ),
        ),
      ),
      body: BlocBuilder<DetailItemScanBloc, DetailItemScanState>(
        builder: (context, state) {
          if (state is DetailItemScanLoadingState) {
            return Center(child: CircularProgressIndicator());
          } else if (state is DetailItemScanLoadedState) {
            if (state.data["routes"] != null) {
              detailData = (state.data["routes"] as List).map((item) => DetailItemScanModel.fromJson(item)).toList();
            }
            if (state.data["images"] != null) {
              imageData = (state.data["images"] as List).map((item) => PhotoItemScanModel.fromJson(item)).toList();
            }

            return TabBarView(
              controller: _tabController,
              children: [
                _detailTabContent(),
                _photoTabContent(),
              ],
            );
          } else {
            return Center(child: Text("ไม่มีข้อมูล"));
          }
        },
      ),
    );
  }

  Widget _detailTabContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 30),
          _hawbHeader(),
          SizedBox(height: 30),
          detailData.isNotEmpty ? _tableDetailData(detailData) : Center(child: Text("ไม่มีข้อมูล")),
        ],
      ),
    );
  }

  Widget _photoTabContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 30),
          _hawbHeader(),
          SizedBox(height: 30),
          imageData.isNotEmpty ? _tablePhotoData(imageData) : Center(child: Text("ไม่มีข้อมูล")),
        ],
      ),
    );
  }

  Widget _hawbHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("HAWB", style: TextStyle(fontSize: 20)),
        SizedBox(width: 10),
        Text("(${widget.hawb})", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _tableDetailData(List<DetailItemScanModel> model) {
    if (model.isEmpty) {
      return Center(child: Text("ไม่พบข้อมูล"));
    }
    return SingleChildScrollView(
      child: Padding(
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
                      if (data.albums.length > 0 || data.remark != "")
                        IconButton(
                          onPressed: () {
                            _showDetailDialog(
                              context: context,
                              hawb: widget.hawb,
                              status: data.status,
                              remark: data.remark,
                              albums: data.albums,
                            );
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
      ),
    );
  }

  Widget _tablePhotoData(List<PhotoItemScanModel> model) {
    if (model.isEmpty) {
      return Center(child: Text("ไม่พบข้อมูล"));
    }
    return SingleChildScrollView(
      child: Padding(
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
                        "Location",
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
                        Text(data.location),
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
                  Builder(builder: (context) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (data.albums.length > 0)
                          IconButton(
                            onPressed: () {
                              _showPhotoDialog(context: context, albums: data.albums);
                            },
                            icon: Icon(Icons.warning, color: Colors.orange),
                          )
                        else
                          SizedBox(height: 48)
                      ],
                    );
                  }),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showDetailDialog({
    required BuildContext context,
    required String hawb,
    required String status,
    required String remark,
    required List albums,
  }) {
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
          content: SingleChildScrollView(
            child: Column(
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
                        text: status,
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                remark.isNotEmpty
                    ? RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 18),
                          children: [
                            TextSpan(
                              text: 'หมายเหตุ: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: remark,
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(),
                albums.isNotEmpty
                    ? Column(
                        children: [
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'รูปภาพ:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              )),
                          SizedBox(height: 16),
                          Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                height: 300,
                                child: GridView.builder(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 4.0,
                                    mainAxisSpacing: 4.0,
                                  ),
                                  itemCount: albums.length,
                                  itemBuilder: (context, index) {
                                    return ValueListenableBuilder(
                                      valueListenable: isSeletecting,
                                      builder: (context, isSeletecting, _) {
                                        if (isSeletecting) {
                                          return ImageUtils().overlaySelectImage(
                                            albums[index]["imageUrl"],
                                            ImageUtils().imageContent(albums[index]["imageUrl"]),
                                            selectedImages,
                                          );
                                        } else {
                                          return GestureDetector(
                                            onTap: () =>
                                                ImageUtils().showImagePreviewByURL(context, albums[index]["imageUrl"]),
                                            child: ImageUtils().imageContent(albums[index]["imageUrl"]),
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : SizedBox(),
              ],
            ),
          ),
          actions: [
            albums.isNotEmpty
                ? ValueListenableBuilder<bool>(
                    valueListenable: isSeletecting,
                    builder: (context, selecting, _) {
                      if (selecting) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () {
                                isSeletecting.value = false;
                                selectedImages.value = [];
                              },
                              child: const Text('ยกเลิก'),
                            ),
                            ValueListenableBuilder<List<String>>(
                              valueListenable: selectedImages,
                              builder: (context, selected, _) {
                                return TextButton(
                                  onPressed: selected.isEmpty
                                      ? null
                                      : () async {
                                          await ImageUtils().shareSelectedImages(context, selectedImages.value);
                                        },
                                  child: const Text('แชร์รูปภาพ'),
                                );
                              },
                            ),
                          ],
                        );
                      } else {
                        return TextButton(
                          onPressed: () {
                            isSeletecting.value = true;
                            selectedImages.value = [];
                          },
                          child: const Text('เลือกภาพ'),
                        );
                      }
                    },
                  )
                : SizedBox(),
            TextButton(
              onPressed: () {
                isSeletecting.value = false;
                selectedImages.value = [];
                Navigator.of(context).pop();
              },
              child: Text('ปิด'),
            ),
          ],
        );
      },
    );
  }

  void _showPhotoDialog({
    required BuildContext context,
    required List<dynamic> albums,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: SizedBox(),
          content: SizedBox(
            width: double.maxFinite,
            height: 300.0,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: albums.length,
              itemBuilder: (context, index) {
                return ValueListenableBuilder(
                  valueListenable: isSeletecting,
                  builder: (context, isSeletecting, _) {
                    if (isSeletecting) {
                      return ImageUtils().overlaySelectImage(
                        albums[index]["imageUrl"],
                        ImageUtils().imageContent(albums[index]["imageUrl"]),
                        selectedImages,
                      );
                    } else {
                      return GestureDetector(
                        onTap: () => ImageUtils().showImagePreviewByURL(context, albums[index]["imageUrl"]),
                        child: ImageUtils().imageContent(albums[index]["imageUrl"]),
                      );
                    }
                  },
                );
              },
            ),
          ),
          actions: [
            albums.isNotEmpty
                ? ValueListenableBuilder<bool>(
                    valueListenable: isSeletecting,
                    builder: (context, selecting, _) {
                      if (selecting) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () {
                                isSeletecting.value = false;
                                selectedImages.value = [];
                              },
                              child: const Text('ยกเลิก'),
                            ),
                            ValueListenableBuilder<List<String>>(
                              valueListenable: selectedImages,
                              builder: (context, selected, _) {
                                return TextButton(
                                  onPressed: selected.isEmpty
                                      ? null
                                      : () async {
                                          await ImageUtils().shareSelectedImages(context, selectedImages.value);
                                        },
                                  child: const Text('แชร์รูปภาพ'),
                                );
                              },
                            ),
                          ],
                        );
                      } else {
                        return TextButton(
                          onPressed: () {
                            isSeletecting.value = true;
                            selectedImages.value = [];
                          },
                          child: const Text('เลือกภาพ'),
                        );
                      }
                    },
                  )
                : SizedBox(),
            TextButton(
              onPressed: () {
                isSeletecting.value = false;
                selectedImages.value = [];
                Navigator.of(context).pop();
              },
              child: const Text('ปิด'),
            ),
          ],
        );
      },
    );
  }
}
