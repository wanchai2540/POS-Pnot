import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:kymscanner/data/api/api.dart';
import 'package:kymscanner/data/models/detailItemScan_model.dart';

part 'detail_item_scan_event.dart';
part 'detail_item_scan_state.dart';

class DetailItemScanBloc extends Bloc<DetailItemScanEvent, DetailItemScanState> {
  DetailItemScanBloc() : super(DetailItemScanInitialState()) {
    on<DetailItemScanLoadingEvent>((event, emit) async {
      emit(DetailItemScanLoadingState());
      var data = await DataService().getDetailItem(event.uuid);
      if (data["status"] == "success") {
        List<DetailitemScanModel> result = (data["data"] as List).map((item) {
          return DetailitemScanModel.fromJson(item);
        }).toList();
        emit(DetailItemScanLoadedState(model: result));
      } else {
        emit(DetailItemScanErrorState());
      }
    });
  }
}
