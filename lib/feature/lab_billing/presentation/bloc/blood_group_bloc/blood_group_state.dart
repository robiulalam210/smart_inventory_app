part of 'blood_group_bloc.dart';

sealed class BloodGroupState {}

final class BloodGroupInitial extends BloodGroupState {}
class BloodGroupLoading extends BloodGroupState {}
class BloodGroupLoaded extends BloodGroupState {
  final List<BloodGroupLocalModel> bloodGroups;
   BloodGroupLoaded(this.bloodGroups);
}
class BloodGroupError extends BloodGroupState {
  final String message;
   BloodGroupError(this.message);
}
