part of 'release_items_bloc.dart';

sealed class ReleaseItemsState {}

final class ReleaseItemsInitial extends ReleaseItemsState {}

final class ReleasePageGetLoadingState extends ReleaseItemsState {}

final class ReleasePageGetLoadedState extends ReleaseItemsState {
  List<ReleaseRoundModel> model;

  ReleasePageGetLoadedState({required this.model});
}

final class ReleasePageScanSuccessState extends ReleaseItemsState {
  ReleaseRoundModel model;

  ReleasePageScanSuccessState({required this.model});
}

final class ReleasePageScanErrorState extends ReleaseItemsState {
  ReleaseRoundModel model;

  ReleasePageScanErrorState({required this.model});
}

final class ReleasePageGetErrorState extends ReleaseItemsState {}
