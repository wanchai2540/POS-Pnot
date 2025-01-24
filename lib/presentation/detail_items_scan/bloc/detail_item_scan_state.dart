part of 'detail_item_scan_bloc.dart';

@immutable
sealed class DetailItemScanState {}

final class DetailItemScanInitialState extends DetailItemScanState {}

final class DetailItemScanLoadingState extends DetailItemScanState {}

final class DetailItemScanLoadedState extends DetailItemScanState {
  List<dynamic> data;
  DetailItemScanLoadedState({required this.data});
}

final class DetailItemScanErrorState extends DetailItemScanState {}
