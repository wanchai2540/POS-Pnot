import 'package:bloc/bloc.dart';
import 'package:pos/data/api/api.dart';
import 'package:pos/data/models/scanFindItems_model.dart';
import 'package:pos/data/models/scan_listener_model.dart';

part 'scan_find_items_page_event.dart';
part 'scan_find_items_page_state.dart';

class ScanFindItemsPageBloc extends Bloc<ScanPageBlocEvent, ScanPageBlocState> {
  ScanFindItemsPageBloc() : super(ScanPageBlocInitialState()) {
    on<ScanPageGetDataEvent>((event, emit) async {
      emit(ScanPageGetLoadingState());
      var data = await DataService().getscanFindItems(event.date, event.type);
      if (data["status"] == "success") {
        List<ScanfinditemsModel> result = (data["data"] as List).map((item) {
          return ScanfinditemsModel.fromJson(item);
        }).toList();
        emit(ScanPageGetLoadedState(model: result));
      } else {
        emit(ScanPageGetErrorState());
      }
    });

    // on<ScanPageScanEvent>((event, emit) async {
    //   emit(ScanPageGetLoadingState());
    //   var dataGetScan = await DataService().getScanListener(event.date, event.hawb);
    //   var data = dataGetScan["body"];
    //   try {
    //     if (dataGetScan["code"] == 200) {
    //       if (data["appCode"] == "01" && data["statusCode"] == "03") {
    //         ScanListenerModel result = ScanListenerModel.fromJson(data);
    //         emit(ScanPageScanSuccessState(model: result));
    //       }
    //     } else if (dataGetScan["code"] == 400) {
    //       ScanListenerModel result = ScanListenerModel.fromJson(data);
    //       emit(ScanPageScanErrorState(model: result));
    //     }
    //   } catch (e) {
    //     emit(ScanPageGetErrorState());
    //   }
    // });
  }
}
