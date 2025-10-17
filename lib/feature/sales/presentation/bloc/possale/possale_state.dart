part of 'possale_bloc.dart';

// @immutable
sealed class PosSaleState {}

final class PosSaleInitial extends PosSaleState {}

final class PosSaleListLoading extends PosSaleState {}

final class PosSaleListSuccess extends PosSaleState {
  String selectedState = "";

  final List<PosSaleModel> list;

  PosSaleListSuccess({
    required this.list,
  });
}

class CartUpdateInProgress extends PosSaleState {}





final class PosSaleListFailed extends PosSaleState {
  final String title, content;

  PosSaleListFailed({required this.title, required this.content});
}

final class PosSaleDeleteInitial extends PosSaleState {}

final class PosSaleDeleteLoading extends PosSaleState {}

final class PosSaleDeleteSuccess extends PosSaleState {
  PosSaleDeleteSuccess();
}

final class PosSaleDeleteFailed extends PosSaleState {
  final String title, content;

  PosSaleDeleteFailed({required this.title, required this.content});
}


