import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pos/data/api/api.dart';
import 'package:pos/data/models/scan_listener_model.dart';

part 'scan_listener_event.dart';
part 'scan_listener_state.dart';

class ScanListenerBloc extends Bloc<ScanListenerEvent, ScanListenerState> {
  ScanListenerBloc() : super(ScanListenerInitialState()) {
    on<ScanListenerLoadingEvent>((event, emit) async {
      emit(ScanListenerLoadingState());
      var dataGetScan = await DataService().getScanListener(event.date, event.hawb);
      var data = dataGetScan["body"];
      try {
        if (dataGetScan["code"] == 200) {
          if (data["appCode"] == "01" && data["statusCode"] == "03") {
            emit(ScanListenerDialog05State(data));
          }
        } else if (dataGetScan["code"] == 400) {
          if (data["appCode"] == "03") {
            emit(ScanListenerDialog01State());
          } else if (data["appCode"] == "02" && (data["statusCode"] == "04" || data["statusCode"] == "05")) {
            emit(ScanListenerDialog02State(data));
          } else if (data["appCode"] == "02" && data["statusCode"] == "08" && data["subStatusCode"] == "03") {
            emit(ScanListenerDialog03State(data));
          } else if (data["appCode"] == "02" &&
              (data["statusCode"] == "03" || data["statusCode"] == "06" || data["statusCode"] == "08")) {
            emit(ScanListenerDialog04State(data));
          }
        }
      } catch (e) {
        emit(ScanListenerErrorState());
      }
    });
  }
}
