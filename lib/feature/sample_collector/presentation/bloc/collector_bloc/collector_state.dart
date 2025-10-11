part of 'collector_bloc.dart';

@immutable
sealed class CollectorState {}

final class CollectorInitial extends CollectorState {}

class CollectorLoading extends CollectorState {}

class CollectorLoaded extends CollectorState {
  final List<CollectorLocalModel> collector;

   CollectorLoaded(this.collector);

  List<Object> get props => [collector];
}

class CollectorError extends CollectorState {
  final String message;

   CollectorError(this.message);

  List<Object> get props => [message];
}
