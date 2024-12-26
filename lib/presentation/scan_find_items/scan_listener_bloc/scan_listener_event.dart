part of 'scan_listener_bloc.dart';

sealed class ScanListenerEvent {}

class ScanListenerLoadingEvent extends ScanListenerEvent {
  String date;
  String hawb;

  ScanListenerLoadingEvent({required this.date, required this.hawb});
}
