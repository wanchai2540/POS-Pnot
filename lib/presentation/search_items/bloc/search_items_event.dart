part of 'search_items_bloc.dart';

sealed class SearchItemsEvent {}

class SearchItemsLoadingEvent extends SearchItemsEvent {
  String hawb;
  String uuid;
  SearchItemsLoadingEvent({required this.hawb, required this.uuid});
}
