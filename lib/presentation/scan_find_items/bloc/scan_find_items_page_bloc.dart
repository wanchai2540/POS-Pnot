import 'package:bloc/bloc.dart';
import 'package:kymscanner/data/api/api.dart';
import 'package:kymscanner/data/models/scanFindItems_model.dart';
import 'package:kymscanner/data/models/scan_listener_model.dart';

part 'scan_find_items_page_event.dart';
part 'scan_find_items_page_state.dart';

class ScanFindItemsPageBloc extends Bloc<ScanPageBlocEvent, ScanPageBlocState> {
  ScanFindItemsPageBloc() : super(ScanPageBlocInitialState()) {
    on<ScanPageGetDataEvent>((event, emit) async {
      emit(ScanPageGetLoadingState());
      var data = await DataService().getScanFindItems(event.date, event.type);
      if (data["status"] == "success") {
        List<ScanfinditemsModel> result = (data["data"] as List).map((item) {
          return ScanfinditemsModel.fromJson(item);
        }).toList();
        emit(ScanPageGetLoadedState(model: result));
      } else {
        emit(ScanPageGetErrorState());
      }
    });
  }
}
