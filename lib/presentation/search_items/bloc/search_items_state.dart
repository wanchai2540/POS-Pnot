part of 'search_items_bloc.dart';

sealed class SearchItemsState {}

final class SearchItemsInitial extends SearchItemsState {}

final class SearchItemsLoadingState extends SearchItemsState {}

final class SearchItemsLoadedState extends SearchItemsState {
  SearchItemsModel resultSearch;
  Map<String, dynamic>? resultDetail;
  SearchItemsLoadedState({required this.resultSearch, required this.resultDetail});
}

final class SearchItemsErrorState extends SearchItemsState {
  final String textError;
  SearchItemsErrorState(this.textError);
}
