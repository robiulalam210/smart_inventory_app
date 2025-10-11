part of 'all_setup_bloc.dart';

sealed class AllSetupEvent {}

class FetchAllSetupEvent extends AllSetupEvent {
  BuildContext context;

  FetchAllSetupEvent(this.context);
}
