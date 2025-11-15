part of 'categories_bloc.dart';

// @immutable
sealed class CategoriesState {}

final class CategoriesInitial extends CategoriesState {}

final class CategoriesListLoading extends CategoriesState {}

final class CategoriesListSuccess extends CategoriesState {
  String selectedState = "";

  final List<CategoryModel> list;

  CategoriesListSuccess({
    required this.list,
  });
}

final class CategoriesListFailed extends CategoriesState {
  final String title, content;

  CategoriesListFailed({required this.title, required this.content});
}

final class CategoriesAddInitial extends CategoriesState {}

final class CategoriesAddLoading extends CategoriesState {}

final class CategoriesAddSuccess extends CategoriesState {
  CategoriesAddSuccess();
}

final class CategoriesAddFailed extends CategoriesState {
  final String title, content;

  CategoriesAddFailed({required this.title, required this.content});
}




final class CategoriesSwitchInitial extends CategoriesState {}

final class CategoriesSwitchLoading extends CategoriesState {}

final class CategoriesSwitchSuccess extends CategoriesState {
  CategoriesSwitchSuccess();
}



final class CategoriesSwitchFailed extends CategoriesState {
  final String title, content;

  CategoriesSwitchFailed({required this.title, required this.content});
}



final class CategoriesDeleteInitial extends CategoriesState {}

final class CategoriesDeleteLoading extends CategoriesState {}

final class CategoriesDeleteSuccess extends CategoriesState {
  String message;
  CategoriesDeleteSuccess(this.message);
}

final class CategoriesDeleteFailed extends CategoriesState {
  final String title, content;

  CategoriesDeleteFailed({required this.title, required this.content});
}
