part of 'all_setup_bloc.dart';

sealed class AllSetupState {}

final class AllSetupInitial extends AllSetupState {}

final class AllSetupLoading extends AllSetupState {}

final class AllSetupLoaded extends AllSetupState {
  AllSetupModel allSetupModel;

  AllSetupLoaded(this.allSetupModel);
}

final class AllSetupError extends AllSetupState {
  final String message;

  AllSetupError(this.message);
}



