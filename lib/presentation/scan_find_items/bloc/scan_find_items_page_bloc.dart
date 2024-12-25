import 'package:bloc/bloc.dart';
import 'package:pos/data/api/api.dart';
import 'package:pos/data/models/scanFindItems_model.dart';

part 'scan_find_items_page_event.dart';
part 'scan_find_items_page_state.dart';

class ScanFindItemsPageBloc extends Bloc<ScanPageBlocEvent, ScanPageBlocState> {
  ScanFindItemsPageBloc() : super(ScanPageBlocInitialState()) {
    on<ScanPageGetDataEvent>((event, emit) async {
      emit(ScanPageGetLoadingState());
      var data = await DataService().getscanFindItems(event.date, event.type);
      if (data["status"] == "success") {
        print("james: ${data["data"].runtimeType}");
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
