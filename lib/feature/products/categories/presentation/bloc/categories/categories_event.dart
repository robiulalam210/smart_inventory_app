part of 'categories_bloc.dart';

sealed class CategoriesEvent {}

class FetchCategoriesList extends CategoriesEvent {
  BuildContext context;

  final String filterText;
  final String state;
  final String locationId;
  final int pageNumber;

  FetchCategoriesList(
      this.context,
      {this.filterText = '',
      this.state = '',
      this.locationId = '',
      this.pageNumber = 0});
}

class AddCategories extends CategoriesEvent {
  final Map<String, String>? body;

  AddCategories({this.body});
}

class UpdateCategories extends CategoriesEvent {
  final Map<String, String>? body;
  final String? id;

  UpdateCategories({this.body, this.id});
}

class UpdateSwitchCategories extends CategoriesEvent {
  final Map<String, String>? body;
  final String? id;

  UpdateSwitchCategories({this.body, this.id});
}

class DeleteCategories extends CategoriesEvent {
  final String? id;

  DeleteCategories({this.id});
}
