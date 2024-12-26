part of 'scan_listener_bloc.dart';

sealed class ScanListenerState {}

final class ScanListenerInitialState extends ScanListenerState {}

final class ScanListenerLoadingState extends ScanListenerState {}

final class ScanListenerLoadedState extends ScanListenerState {
  ScanListenerModel model;

  ScanListenerLoadedState({required this.model});
}

final class ScanListenerDialog01State extends ScanListenerState {}

final class ScanListenerDialog02State extends ScanListenerState {
  ScanListenerModel model;

  ScanListenerDialog02State(this.model);
}

final class ScanListenerDialog03State extends ScanListenerState {
  ScanListenerModel model;

  ScanListenerDialog03State(this.model);
}

final class ScanListenerDialog04State extends ScanListenerState {
  ScanListenerModel model;

  ScanListenerDialog04State(this.model);
}

final class ScanListenerDialog05State extends ScanListenerState {
  ScanListenerModel model;

  ScanListenerDialog05State(this.model);
}

final class ScanListenerErrorState extends ScanListenerState {}
