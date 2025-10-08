import 'package:bloc/bloc.dart';
import 'package:kymscanner/data/api/api.dart';
import 'package:kymscanner/data/models/search_model.dart';
import 'package:meta/meta.dart';

part 'search_items_event.dart';
part 'search_items_state.dart';

class SearchItemsBloc extends Bloc<SearchItemsEvent, SearchItemsState> {
  SearchItemsBloc() : super(SearchItemsInitial()) {
    on<SearchItemsLoadingEvent>((event, emit) async {
      emit(SearchItemsLoadingState());
      var dataSearch = await DataService().getSearchItems(event.hawb);
      if (dataSearch["status"] == "success") {
        SearchItemsModel resultSearch = SearchItemsModel.fromJson(dataSearch["data"]);
        var dataDetail = await DataService().getDetailItem(event.hawb);
        Map<String, dynamic>? resultDetail;
        if (dataDetail["status"] == "success") {
          resultDetail = dataDetail["data"];
        }
        emit(SearchItemsLoadedState(resultSearch: resultSearch, resultDetail: resultDetail));
      } else {
        emit(SearchItemsErrorState());
      }
    });
  }
}
