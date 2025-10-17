part of 'create_pos_sale_bloc.dart';

@immutable
sealed class CreatePosSaleState {}

final class CreatePosSaleInitial extends CreatePosSaleState {}






final class CreatePosSaleLoading extends CreatePosSaleState {}

final class CreatePosSaleSuccess extends CreatePosSaleState {

  CreatePosSaleSuccess();
}



final class CreatePosSaleFailed extends CreatePosSaleState {
  final String title, content;

  CreatePosSaleFailed({required this.title, required this.content});
}

