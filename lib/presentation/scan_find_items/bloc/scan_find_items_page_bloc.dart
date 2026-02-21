import 'dart:async';

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

      try {
        // Fetch scan find items with timeout
        final data = await DataService().getScanFindItems(event.date, event.type).timeout(const Duration(seconds: 8));

        // Validate response
        if (data["status"] != "success") {
          emit(ScanPageGetErrorState("ไม่มีข้อมูล"));
          return;
        }

        // Parse results
        final result = (data["data"] as List).map((item) => ScanfinditemsModel.fromJson(item)).toList();

        emit(ScanPageGetLoadedState(model: result));
      } on TimeoutException catch (_) {
        emit(ScanPageGetErrorState("หมดเวลาการร้องขอ กรุณาลองใหม่อีกครั้ง"));
      } catch (e) {
        emit(ScanPageGetErrorState("กรุณาลองใหม่อีกครั้ง"));
      }
    });
  }
}
