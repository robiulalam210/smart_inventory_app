// features/products/sale_mode/presentation/bloc/sale_mode/sale_mode_event.dart

part of 'sale_mode_bloc.dart';

abstract class SaleModeEvent extends Equatable {
  const SaleModeEvent();

  @override
  List<Object> get props => [];
}

class FetchSaleModeList extends SaleModeEvent {
  final BuildContext context;
  final String filterText;
  final int pageNumber;
  final String? baseUnitId;

  const FetchSaleModeList(
      this.context, {
        this.filterText = '',
        this.pageNumber = 0,
        this.baseUnitId,
      });

  @override
  List<Object> get props => [context, filterText, pageNumber];
}

class AddSaleMode extends SaleModeEvent {
  final Map<String, dynamic> body;

  const AddSaleMode({required this.body});

  @override
  List<Object> get props => [body];
}

class UpdateSaleMode extends SaleModeEvent {
  final String id;
  final Map<String, dynamic>? body;

  const UpdateSaleMode({required this.id, this.body});

  @override
  List<Object> get props => [id];
}

class DeleteSaleMode extends SaleModeEvent {
  final String id;

  const DeleteSaleMode({required this.id});

  @override
  List<Object> get props => [id];
}

class ClearSaleModeData extends SaleModeEvent {}