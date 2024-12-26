part of 'scan_find_items_page_bloc.dart';

sealed class ScanPageBlocState {}

final class ScanPageBlocInitialState extends ScanPageBlocState {}

final class ScanPageGetLoadingState extends ScanPageBlocState {}

final class ScanPageGetLoadedState extends ScanPageBlocState {
  List<ScanfinditemsModel> model;
  ScanPageGetLoadedState({required this.model});
}

final class ScanPageGetErrorState extends ScanPageBlocState {}