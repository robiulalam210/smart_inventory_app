import '../../../../../core/configs/configs.dart';
import '../../../data/models/tests_model/test_categories_model.dart';
import '../../../data/repositories/test_repo_db.dart';

part 'test_categories_event.dart';
part 'test_categories_state.dart';

class TestCategoriesBloc
    extends Bloc<TestCategoriesEvent, TestCategoriesState> {
  final TestRepository repository = TestRepository();
  List<TestCategoriesLocalModel>? categories;

  TestCategoriesBloc() : super(TestCategoriesInitial()) {
    on<LoadCategoriesTests>((event, emit) async {
      emit(TestCategoriesLoading());
      try {
        categories = await repository.getTestsCategories();

        emit(TestCategoriesLoaded(
            List<TestCategoriesLocalModel>.from(categories!)));
      } catch (e, k) {
        debugPrint(k.toString());
        emit(TestCategoriesError(e.toString()));
      }
    });
  }
}
