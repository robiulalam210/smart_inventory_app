import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../data/models/tests_model/tests_model.dart';
import '../../../data/repositories/test_repo_db.dart';


part 'test_event.dart';

part 'test_state.dart';

class TestBloc extends Bloc<TestEvent, TestState> {
  final TestRepository repository=TestRepository();

  List<TestLocalModel>? allTests; // Full unfiltered list from DB

  TestBloc() : super(TestInitial()) {
    on<LoadTests>(_onLoadTests);
  }

  Future<void> _onLoadTests(LoadTests event, Emitter<TestState> emit) async {
    emit(TestLoading());
    try {
      allTests = await repository.getTests();


      emit(TestLoaded(List.from(allTests??[])));
    } catch (e, s) {
      debugPrint(s.toString());
      emit(TestError(e.toString()));
    }
  }



}
