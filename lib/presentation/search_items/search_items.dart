import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kymscanner/common.dart';
import 'package:kymscanner/data/models/detailItemScan_model.dart';
import 'package:kymscanner/data/models/photoItemScan_model.dart';
import 'package:kymscanner/data/models/search_model.dart';
import 'package:kymscanner/presentation/search_items/bloc/search_items_bloc.dart';

class SearchItems extends StatefulWidget {
  final String hawb;
  final String uuid;
  const SearchItems({super.key, required this.hawb, required this.uuid});

  @override
  State<SearchItems> createState() => _SearchItemsState();
}

class _SearchItemsState extends State<SearchItems> with TickerProviderStateMixin {
  // late SearchItemsModel? searchItemsModel;
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
    context.read<SearchItemsBloc>().add(SearchItemsLoadingEvent(hawb: widget.hawb, uuid: widget.uuid));
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
        title: Text("Result Search"),
      ),
      body: BlocBuilder<SearchItemsBloc, SearchItemsState>(
        builder: (context, state) {
          if (state is SearchItemsInitial) {
            return Center(child: Text("Please wait..."));
          } else if (state is SearchItemsLoadingState) {
            return Center(child: CircularProgressIndicator());
          } else if (state is SearchItemsErrorState) {
            return Center(child: Text(state.textError));
          } else if (state is SearchItemsLoadedState) {
            return SingleChildScrollView(
              child: sectionDetailSearch(state.resultSearch, state.resultDetail),
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("ไม่พบข้อมูล"),
              ],
            );
          }
        },
      ),
    );
  }

  Widget sectionDetailSearch(SearchItemsModel searchItemsModel, Map<String, dynamic>? detailItems) {
    return Column(
      children: [
        SizedBox(height: 10),
        Text("HAWB: ${searchItemsModel.hawb}"),
        if (searchItemsModel.productType == "G" || searchItemsModel.productType == "R")
          customBadgeSpecial(searchItemsModel.productType)
        else
          customTypeBadge(searchItemsModel.productType),
        Text("Pick Up: ${searchItemsModel.pickUpBy}"),
        Text("สถานะล่าสุด: ${searchItemsModel.lastStatus}"),
        ColoredBox(
          color: searchItemsModel.isSuspended ? Colors.yellow : Colors.transparent,
          child: Text("Item No: ${searchItemsModel.itemNo}"),
        ),
        Text(
          "Consignee: ${searchItemsModel.consigneeName}",
          textAlign: TextAlign.center,
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
        Text("CTNS: ${searchItemsModel.ctns.toString()}"),
        Text("วันที่: ${searchItemsModel.date.toString()}"),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Divider(thickness: 1, color: Colors.grey),
        ),
        SizedBox(height: 10),
        detailItems != null ? sectionTab(detailItems) : Text("ไม่ข้อมูลสถานะ"),
      ],
    );
  }

  Widget sectionTab(Map<String, dynamic>? detailItems) {
    if (detailItems != null && detailItems["routes"] != null) {
      detailData = (detailItems["routes"] as List).map((item) => DetailItemScanModel.fromJson(item)).toList();
    }
    if (detailItems != null && detailItems["images"] != null) {
      imageData = (detailItems["images"] as List).map((item) => PhotoItemScanModel.fromJson(item)).toList();
    }
    return SizedBox(
      height: 450,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Detail'),
              Tab(text: 'Photo'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _tableDetailData(detailData),
                _tablePhotoData(imageData),
              ],
            ),
          ),
        ],
      ),
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
              child: Text('ปิด'),
            ),
          ],
        );
      },
    );
  }
}
