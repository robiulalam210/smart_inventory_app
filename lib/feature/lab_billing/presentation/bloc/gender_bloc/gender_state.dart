part of 'gender_bloc.dart';

sealed class GenderState {}

final class GenderInitial extends GenderState {}
class GenderLoading extends GenderState {}
class GenderLoaded extends GenderState {
  final List<GenderLocalModel> genders;
   GenderLoaded(this.genders);
}
class GenderError extends GenderState {
  final String message;
   GenderError(this.message);
}