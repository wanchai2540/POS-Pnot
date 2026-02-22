import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:kymscanner/data/api/api.dart';
import 'package:kymscanner/data/models/release_round_model.dart';

part 'release_items_event.dart';
part 'release_items_state.dart';

class ReleaseItemsBloc extends Bloc<ReleaseItemsEvent, ReleaseItemsState> {
  ReleaseItemsBloc() : super(ReleaseItemsInitial()) {
    on<ReleasePageGetDataEvent>((event, emit) async {
      emit(ReleasePageGetLoadingState());

      try {
        final data = await DataService()
            .getTableReleaseByRound(event.date, event.releaseRoundUUID)
            .timeout(const Duration(seconds: 5));

        if (data["status"] != "success") {
          emit(ReleasePageGetErrorState("ไม่มีข้อมูล"));
          return;
        }

        final result = ((data["data"] ?? []) as List).map((item) => ReleaseRoundModel.fromJson(item)).toList();

        emit(ReleasePageGetLoadedState(model: result));
      } on TimeoutException catch (_) {
        emit(ReleasePageGetErrorState("หมดเวลาการร้องขอ กรุณาลองใหม่อีกครั้ง"));
      } catch (e) {
        emit(ReleasePageGetErrorState("กรุณาลองใหม่อีกครั้ง"));
      }
    });
  }
}
