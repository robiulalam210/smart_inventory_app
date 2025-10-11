part of 'print_layout_bloc.dart';

@immutable
sealed class PrintLayoutState {}

final class PrintLayoutInitial extends PrintLayoutState {}
class PrintLayoutLoading extends PrintLayoutState {}

class PrintLayoutLoaded extends PrintLayoutState {
  final PrintLayoutModel layout;
  PrintLayoutLoaded(this.layout);
}

class PrintLayoutError extends PrintLayoutState {
  final String message;
  PrintLayoutError(this.message);
}