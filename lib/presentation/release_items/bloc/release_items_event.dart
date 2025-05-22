part of 'release_items_bloc.dart';

sealed class ReleaseItemsEvent {}

class ReleasePageLoadingEvent extends ReleaseItemsEvent {}

class ReleasePageGetDataEvent extends ReleaseItemsEvent {
  String date;
  String releaseRoundUUID;
  ReleasePageGetDataEvent({required this.date, required this.releaseRoundUUID});
}

class ReleasePageScanEvent extends ReleaseItemsEvent {
  String date;
  String hawb;
  ReleasePageScanEvent({required this.date, required this.hawb});
}
