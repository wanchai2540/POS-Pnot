import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'scan_and_release_event.dart';
part 'scan_and_release_state.dart';

class ScanAndReleaseBloc extends Bloc<ScanAndReleaseEvent, ScanAndReleaseState> {
  ScanAndReleaseBloc() : super(ScanAndReleaseInitial()) {
    on<ScanAndReleaseEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
