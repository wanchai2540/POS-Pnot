import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pos/data/api/api.dart';
import 'package:pos/data/models/home_model.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitialState()) {
    on<HomeLoadingEvent>((event, emit) async {
      emit(HomeLoadingState());
      // var data = await DataService().getDataHome(event.date);
      var data = await DataService().getDataHome("2024-12-05");
      try {
        if (data["status"] == "success") {
          HomeModel result = HomeModel.fromJson(data["data"]);
          emit(HomeLoadedState(model: result));
        } else {
          emit(HomeErrorState());
        }
      } catch (e) {
        emit(HomeErrorState());
      }
    });
  }
}
