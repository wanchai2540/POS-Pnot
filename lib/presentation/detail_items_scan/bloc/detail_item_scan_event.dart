part of 'detail_item_scan_bloc.dart';

@immutable
sealed class DetailItemScanEvent {}

class DetailItemScanLoadingEvent extends DetailItemScanEvent {
  String uuid;
  String typeData;
  DetailItemScanLoadingEvent({required this.uuid,required this.typeData});
}
