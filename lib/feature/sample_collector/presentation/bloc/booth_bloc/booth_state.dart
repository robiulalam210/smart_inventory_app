part of 'booth_bloc.dart';

@immutable
sealed class BoothState {}

final class BoothInitial extends BoothState {}
class BoothLoading extends BoothState {}

class BoothLoaded extends BoothState {
  final List<BoothLocalModel> boothLocalModel;

  BoothLoaded(this.boothLocalModel);

  List<Object> get props => [boothLocalModel];
}

class BoothError extends BoothState {
  final String message;

  BoothError(this.message);

  List<Object> get props => [message];
}
