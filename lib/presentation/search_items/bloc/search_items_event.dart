part of 'search_items_bloc.dart';

sealed class SearchItemsEvent {}

class SearchItemsLoadingEvent extends SearchItemsEvent {
  String hawb;
  SearchItemsLoadingEvent({required this.hawb});
}
