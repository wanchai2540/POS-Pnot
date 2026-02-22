import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:kymscanner/data/api/api.dart';
import 'package:kymscanner/data/models/search_model.dart';

part 'search_items_event.dart';
part 'search_items_state.dart';

class SearchItemsBloc extends Bloc<SearchItemsEvent, SearchItemsState> {
  SearchItemsBloc() : super(SearchItemsInitial()) {
    on<SearchItemsLoadingEvent>((event, emit) async {
      emit(SearchItemsLoadingState());

      try {
        // Fetch search items with timeout
        final dataSearch = await DataService().getSearchItems(event.hawb).timeout(const Duration(seconds: 5));

        // Validate search response
        if (dataSearch["status"] != "success") {
          emit(SearchItemsErrorState("ไม่มีข้อมูล"));
          return;
        }

        // Parse search results
        final resultSearch = SearchItemsModel.fromJson(dataSearch["data"]);

        // Fetch detail items with timeout
        final dataDetail = await DataService().getDetailItem(event.uuid).timeout(const Duration(seconds: 5));

        // Parse detail results if available
        Map<String, dynamic>? resultDetail;
        if (dataDetail["status"] == "success") {
          resultDetail = dataDetail["data"];
        }

        emit(SearchItemsLoadedState(
          resultSearch: resultSearch,
          resultDetail: resultDetail,
        ));
      } on TimeoutException catch (_) {
        emit(SearchItemsErrorState("หมดเวลาการร้องขอ กรุณาลองใหม่อีกครั้ง"));
      } catch (e) {
        emit(SearchItemsErrorState("กรุณาลองใหม่อีกครั้ง"));
      }
    });
  }
}
