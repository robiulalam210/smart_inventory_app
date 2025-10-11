import 'package:flutter/foundation.dart';


import '../../../../../core/configs/configs.dart';
import '../../../../../core/repositories/get_response.dart';
import '../../../data/models/all_setup_model/all_setup_model.dart';


part 'all_setup_event.dart';

part 'all_setup_state.dart';

class AllSetupBloc extends Bloc<AllSetupEvent, AllSetupState> {

  // Modify constructor to accept DatabaseHelper
  AllSetupBloc() : super(AllSetupInitial()) {
    on<FetchAllSetupEvent>(_fetchAllSetupData);
  }

  Future<void> _fetchAllSetupData(
    FetchAllSetupEvent event,
    Emitter<AllSetupState> emit,
  ) async {
    emit(AllSetupLoading());
    try {
      final response = await getResponse(
        context: event.context,
        url: AppUrls.setUpData,
      );

      final allSetupModel = allSetupModelFromJson(response);

      if (allSetupModel.statusCode == 200) {

        emit(AllSetupLoaded(allSetupModel));
      } else {
        emit(AllSetupError(allSetupModel.message ?? ""));

      }
    } catch (e, s) {
      emit(AllSetupError(e.toString()));

      if (kDebugMode) {
        print('Error in AllSetupBloc: $e $s');
      }
    }
  }


}
