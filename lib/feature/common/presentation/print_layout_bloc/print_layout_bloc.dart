import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../data/models/print_layout_model.dart';
import '../../data/repositories/print_layout_repo_db.dart';

part 'print_layout_event.dart';
part 'print_layout_state.dart';
class PrintLayoutBloc extends Bloc<PrintLayoutEvent, PrintLayoutState> {
  final PrintLayoutRepoDb repo;
   PrintLayoutModel? layoutModel;

  PrintLayoutBloc(this.repo) : super(PrintLayoutInitial()) {
    on<FetchPrintLayout>((event, emit) async {
      emit(PrintLayoutLoading());

      try {
        final layout = await repo.fetchPrintLayout();


        if (layout != null) {
          layoutModel=layout;
          emit(PrintLayoutLoaded(layout));
        } else {
          emit(PrintLayoutError("No layout found."));
        }
      } catch (e) {
        emit(PrintLayoutError(e.toString()));
      }
    });
  }
}