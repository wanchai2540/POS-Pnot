part of 'home_bloc.dart';

sealed class HomeEvent {}

class HomeLoadingEvent extends HomeEvent {
  String date;
  HomeLoadingEvent({required this.date});
}
