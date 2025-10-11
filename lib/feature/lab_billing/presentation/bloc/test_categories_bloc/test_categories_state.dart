part of 'test_categories_bloc.dart';

@immutable
sealed class TestCategoriesState {}

final class TestCategoriesInitial extends TestCategoriesState {}

class TestCategoriesLoading extends TestCategoriesState {}

class TestCategoriesLoaded extends TestCategoriesState {
  final List<TestCategoriesLocalModel> categories;

  TestCategoriesLoaded(this.categories);

  List<Object> get props => [categories];
}

class TestCategoriesError extends TestCategoriesState {
  final String message;

   TestCategoriesError(this.message);

  List<Object> get props => [message];
}
