part of 'possale_bloc.dart';

sealed class PosSaleEvent {}

class FetchPosSaleList extends PosSaleEvent{
  BuildContext context;

  final String filterText;
  final String location;
  final String customer;
  final String seller;
  final String posType;
  final DateTime? startDate;
  final DateTime? endDate;
  final String dropdownFilter;
  final int pageNumber;

  FetchPosSaleList(this.context,{
    this.filterText = '',
    this.location = '',
    this.customer = '',
    this.seller = '',
    this.posType = '',
    this.startDate,
    this.endDate,
    this.dropdownFilter = '',
    this.pageNumber = 0});

}

class FetchCustomerSaleList extends PosSaleEvent{
  BuildContext context;

  final String filterText;
  final String location;
  final String customer;
  final String seller;
  final String posType;
  final DateTime? startDate;
  final DateTime? endDate;
  final String dropdownFilter;
  final int pageNumber;

  FetchCustomerSaleList(this.context,{
    this.filterText = '',
    this.location = '',
    this.customer = '',
    this.seller = '',
    this.posType = '',
    this.startDate,
    this.endDate,
    this.dropdownFilter = '',
    this.pageNumber = 0});

}



class UpdatePosSale extends PosSaleEvent {
  final Map<String,String>? body;
  final String? id;


  UpdatePosSale({this.body,this.id});
}

class DeletePosSale  extends PosSaleEvent {
  final String id;

  DeletePosSale(this.id);
}

sealed class PosSaleProductDetailsEvent {}

class FetchPosSaleProductDetailsList extends PosSaleProductDetailsEvent {
  final String id;
  BuildContext context;


  FetchPosSaleProductDetailsList(this.context,{this.id = ''});
}