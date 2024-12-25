part of 'scan_find_items_page_bloc.dart';

sealed class ScanPageBlocEvent {}

class ScanPageLoadingEvent extends ScanPageBlocEvent {}

class ScanPageGetDataEvent extends ScanPageBlocEvent {
  String type;
  String date;
  String? barcode;
  ScanPageGetDataEvent({this.type = "all", required this.date, this.barcode});
}