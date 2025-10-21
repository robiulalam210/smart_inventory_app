


import '../../../../../core/configs/configs.dart';
import '../../../../../core/repositories/get_response.dart';
import '../../../../common/data/models/api_response_mod.dart';
import '../../../../common/data/models/app_parse_json.dart';
import '../../../data/model/supplier_invoice_list_model.dart';

part 'supplier_invoice_event.dart';
part 'supplier_invoice_state.dart';

class SupplierInvoiceBloc extends Bloc<SupplierInvoiceEvent, SupplierInvoiceState> {
  List<SupplierInvoiceListModel> supplierListModel = [];
  String supplierInvoiceListModel='';
  final int _itemsPerPage = 10;
  String selectedState = "";
  List<String> statesList = ["Paid", "Due","Partially Paid"];

  TextEditingController filterTextController = TextEditingController();
  SupplierInvoiceBloc() : super(SupplierInvoiceInitial()) {
    on<FetchSupplierInvoiceList>(_onFetchSupplierInvoiceList);

  }




  Future<void> _onFetchSupplierInvoiceList(
      FetchSupplierInvoiceList event, Emitter<SupplierInvoiceState> emit) async {

    emit(SupplierInvoiceListLoading());

    try {
      final res  = await getResponse(url: AppUrls.supplierInvoiceList+event.dropdownFilter, context: event.context); // Use the correct API URL

      // final response=warehouseBranchModelFromJson(res);

      ApiResponse<List<SupplierInvoiceListModel>> response = appParseJson<List<SupplierInvoiceListModel>>(
        res,
            (data) => List<SupplierInvoiceListModel>.from(data.map((x) => SupplierInvoiceListModel.fromJson(x))),
      );
      final data = response.data;

      if (data == null || data.isEmpty) {
        emit(SupplierInvoiceListFailed(title: "Error",content: "No Data"));

        return;
      }
      // Store all warehouses for filtering and pagination
      supplierListModel = data;



      emit(SupplierInvoiceListSuccess(
        list: supplierListModel,
        totalPages: 1,
        currentPage: event.pageNumber,
      ));
    } catch (error) {
      emit(SupplierInvoiceListFailed(title: "Error",content: error.toString()));
    }
  }






}



