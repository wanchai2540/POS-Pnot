import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:kymscanner/data/api/api.dart';

part 'detail_item_scan_event.dart';
part 'detail_item_scan_state.dart';

class DetailItemScanBloc extends Bloc<DetailItemScanEvent, DetailItemScanState> {
  DetailItemScanBloc() : super(DetailItemScanInitialState()) {
    on<DetailItemScanLoadingEvent>((event, emit) async {
      emit(DetailItemScanLoadingState());
      var data = await DataService().getDetailItem(event.uuid);
      
      if (data["status"] == "success") {
        Map<String,dynamic>? result = data["data"];
        if (result != null) {
          emit(DetailItemScanLoadedState(data: result));
        } else {
          emit(DetailItemScanErrorState());
        }
      } else {
        emit(DetailItemScanErrorState());
      }
    });
  }
}
