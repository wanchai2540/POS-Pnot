part of 'home_bloc.dart';

sealed class HomeState {}

final class HomeInitialState extends HomeState {}

final class HomeLoadingState extends HomeState {}

final class HomeLoadedState extends HomeState {
  HomeModel model;
  HomeLoadedState({required this.model});
}

final class HomeErrorState extends HomeState {}
