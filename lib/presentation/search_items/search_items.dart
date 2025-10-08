import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kymscanner/common.dart';
import 'package:kymscanner/data/models/detailItemScan_model.dart';
import 'package:kymscanner/data/models/photoItemScan_model.dart';
import 'package:kymscanner/data/models/search_model.dart';
import 'package:kymscanner/presentation/search_items/bloc/search_items_bloc.dart';

class SearchItems extends StatefulWidget {
  final String hawb;
  const SearchItems({super.key, required this.hawb});

  @override
  State<SearchItems> createState() => _SearchItemsState();
}

class _SearchItemsState extends State<SearchItems> with TickerProviderStateMixin {
  late SearchItemsModel? searchItemsModel;
  List<DetailItemScanModel> detailData = [];
  List<PhotoItemScanModel> imageData = [];
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    context.read<SearchItemsBloc>().add(SearchItemsLoadingEvent(hawb: widget.hawb));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
            return Center(child: Text("ไม่พบข้อมูล"));
          } else if (state is SearchItemsLoadedState) {
            searchItemsModel = state.resultSearch;
            return SingleChildScrollView(
              child: sectionSearch(),
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

  Widget sectionSearch() {
    return Column(
      children: [
        SizedBox(height: 10),
        Text("HAWB: ${searchItemsModel!.hawb}"),
        if (searchItemsModel!.productType == "G" || searchItemsModel!.productType == "R")
          customBadgeSpecial(searchItemsModel!.productType)
        else
          customTypeBadge(searchItemsModel!.productType),
        Text("Pick Up: ${searchItemsModel!.pickUpBy}"),
        Text("สถานะล่าสุด: ${searchItemsModel!.lastStatus}"),
        ColoredBox(
          color: searchItemsModel!.isSuspended ? Colors.yellow : Colors.transparent,
          child: Text("Item No: ${searchItemsModel!.itemNo}"),
        ),
        Text(
          "Consignee: ${searchItemsModel!.consigneeName}",
          textAlign: TextAlign.center,
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
        Text("CTNS: ${searchItemsModel!.ctns.toString()}"),
        Text("วันที่: ${searchItemsModel!.date.toString()}"),
        SizedBox(height: 30),
        sectionDetail(),
      ],
    );
  }

  Widget sectionDetail() {
    return SizedBox(
      height: 400, // Set a fixed height for TabBarView
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
                // Detail Tab
                ListView.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    // final detail = searchItemsModel!.detailItems[index];
                    return ListTile(
                      title: Text(
                          // detail.title
                          // ??
                          ''),
                      subtitle: Text(
                          // detail.description
                          // ??
                          ''),
                    );
                  },
                ),
                // Photo Tab
                ListView.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    // final photo = searchItemsModel!.photoItems[index];
                    return ListTile(
                      leading:
                          // photo.imageUrl != null
                          //   ? Image.network(photo.imageUrl!)
                          //   : const
                          Icon(Icons.image),
                      title: Text(
                          // photo.caption
                          // ??
                          ''),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
