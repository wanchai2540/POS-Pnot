import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'release_items_event.dart';
part 'release_items_state.dart';

class ReleaseItemsBloc extends Bloc<ReleaseItemsEvent, ReleaseItemsState> {
  ReleaseItemsBloc() : super(ReleaseItemsInitial()) {
    on<ReleaseItemsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
