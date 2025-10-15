part of 'brand_bloc.dart';

// @immutable
sealed class BrandState {}

final class BrandInitial extends BrandState {}

final class BrandListLoading extends BrandState {}

final class BrandListSuccess extends BrandState {
  String selectedState = "";

  final List<BrandModel> list;
  final int totalPages;
  final int currentPage;

  BrandListSuccess({
    required this.list,
    required this.totalPages,
    required this.currentPage,
  });
}

final class BrandListFailed extends BrandState {
  final String title, content;

  BrandListFailed({required this.title, required this.content});
}

final class BrandAddInitial extends BrandState {}

final class BrandAddLoading extends BrandState {}

final class BrandAddSuccess extends BrandState {
  BrandAddSuccess();
}

final class BrandAddFailed extends BrandState {
  final String title, content;

  BrandAddFailed({required this.title, required this.content});
}

final class BrandDeleteInitial extends BrandState {}

final class BrandDeleteLoading extends BrandState {}

final class BrandDeleteSuccess extends BrandState {
  BrandDeleteSuccess();
}

final class BrandDeleteFailed extends BrandState {
  final String title, content;

  BrandDeleteFailed({required this.title, required this.content});
}
