import 'package:bloc/bloc.dart';
import 'package:kymscanner/data/api/api.dart';
import 'package:kymscanner/data/models/release_round_model.dart';
import 'package:meta/meta.dart';

part 'release_items_event.dart';
part 'release_items_state.dart';

class ReleaseItemsBloc extends Bloc<ReleaseItemsEvent, ReleaseItemsState> {
  ReleaseItemsBloc() : super(ReleaseItemsInitial()) {
    on<ReleasePageGetDataEvent>((event, emit) async {
      emit(ReleasePageGetLoadingState());
      var data = await DataService()
          .getTableReleaseByRound(event.date, event.releaseRoundUUID);
      if (data["status"] == "success") {
        List<ReleaseRoundModel> result =
            ((data["data"] ?? []) as List).map((item) {
          return ReleaseRoundModel.fromJson(item);
        }).toList();
        emit(ReleasePageGetLoadedState(model: result));
      } else {
        emit(ReleasePageGetErrorState());
      }
    });
  }
}
