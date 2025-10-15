part of 'source_bloc.dart';


sealed class SourceState {}

final class SourceInitial extends SourceState {}

final class SourceListLoading extends SourceState {}

final class SourceListSuccess extends SourceState {
  String selectedState = "";

  final List<SourceModel> list;
  final int totalPages;
  final int currentPage;

  SourceListSuccess({
    required this.list,
    required this.totalPages,
    required this.currentPage,
  });
}

final class SourceListFailed extends SourceState {
  final String title, content;

  SourceListFailed({required this.title, required this.content});
}

final class SourceAddInitial extends SourceState {}

final class SourceAddLoading extends SourceState {}

final class SourceAddSuccess extends SourceState {
  SourceAddSuccess();
}

final class SourceAddFailed extends SourceState {
  final String title, content;

  SourceAddFailed({required this.title, required this.content});
}
final class SourceUpdateInitial extends SourceState {}

final class SourceUpdateLoading extends SourceState {}

final class SourceUpdateSuccess extends SourceState {
  SourceUpdateSuccess();
}

final class SourceUpdateFailed extends SourceState {
  final String title, content;

  SourceUpdateFailed({required this.title, required this.content});
}

final class SourceDeleteInitial extends SourceState {}

final class SourceDeleteLoading extends SourceState {}

final class SourceDeleteSuccess extends SourceState {
  SourceDeleteSuccess();
}

final class SourceDeleteFailed extends SourceState {
  final String title, content;

  SourceDeleteFailed({required this.title, required this.content});
}
