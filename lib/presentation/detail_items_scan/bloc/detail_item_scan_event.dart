part of 'detail_item_scan_bloc.dart';

@immutable
sealed class DetailItemScanEvent {}

class DetailItemScanLoadingEvent extends DetailItemScanEvent {
  String uuid;
  DetailItemScanLoadingEvent({required this.uuid});
}
