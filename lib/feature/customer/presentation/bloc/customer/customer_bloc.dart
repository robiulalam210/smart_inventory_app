



import '../../../../../core/configs/configs.dart';
import '../../../../../core/repositories/delete_response.dart';
import '../../../../../core/repositories/get_response.dart';
import '../../../../../core/repositories/patch_response.dart';
import '../../../../../core/repositories/post_response.dart';
import '../../../../common/data/models/api_response_mod.dart';
import '../../../../common/data/models/app_parse_json.dart';
import '../../../../products/soruce/data/model/source_model.dart';
import '../../../data/model/customer_model.dart';

part 'customer_event.dart';

part 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  List<CustomerModel> list = [];
  String selectedState = "";
  CustomerModel? customerModel;
  List<String> status = [
    "Active",
    "Inactive",
  ];
  String selectedStateBalanceType = "";
  List<String> statusBalanceType = [
    "Due",
    "Advance",
  ];

  SourceModel? sourceModel;

  TextEditingController filterTextController = TextEditingController();

  TextEditingController customerNameController = TextEditingController();
  TextEditingController customerNumberController = TextEditingController();
  TextEditingController customerEmailController = TextEditingController();

  TextEditingController customerOpeningBalanceController =
      TextEditingController();
  TextEditingController customerAdditionalNumberController =
      TextEditingController();
  TextEditingController customerAdditionalEmailController =
      TextEditingController();
  TextEditingController addressController = TextEditingController();

  CustomerBloc() : super(CustomerInitial()) {
    on<FetchCustomerList>(_onFetchCustomerList);
    on<AddCustomer>(_onCreateCustomerList);
    on<UpdateCustomer>(_onUpdateCustomerList);
    on<UpdateSwitchCustomer>(_onUpdateSwitchCustomerList);
    on<DeleteCustomer >(_onDeleteCustomer);
  }
  //
  // Future<void> _onFetchCustomerList(
  //     FetchCustomerList event,
  //     Emitter<CustomerState> emit,
  //     ) async {
  //   emit(CustomerListLoading());
  //
  //   try {
  //     final res = await getResponse(url: AppUrls.customer, context: event.context);
  //
  //     ApiResponse response = appParseJson(
  //       res,
  //           (data) => List<CustomerModel>.from(
  //         data.map((x) => CustomerModel.fromJson(x)),
  //       ),
  //     );
  //
  //     // Check if API response is successful
  //     if (response.success == true) {
  //       final List<CustomerModel> customerList = response.data ?? [];
  //
  //       if (customerList.isEmpty) {
  //         emit(CustomerSuccess(list: []));
  //         return;
  //       }
  //
  //       // Filter customers
  //       final filteredCustomers = await _filterCustomers(
  //         customerList,
  //         event.filterText,
  //         event.status,
  //       );
  //       list=filteredCustomers;
  //
  //       emit(CustomerSuccess(list: filteredCustomers));
  //     } else {
  //       emit(CustomerListFailed(
  //         title: "Error",
  //         content: response.message ?? "Unknown Error",
  //       ));
  //     }
  //   } catch (error) {
  //     emit(CustomerListFailed(
  //       title: "Error",
  //       content: error.toString(),
  //     ));
  //   }
  // }
  Future<void> _onFetchCustomerList(
      FetchCustomerList event,
      Emitter<CustomerState> emit,
      ) async {
    emit(CustomerListLoading());

    try {
      // Build query parameters with pagination and filters
      Map<String, dynamic> queryParams = {
        'page': event.pageNumber.toString(),
        'page_size': event.pageSize.toString(),
      };

      // Add filters if provided
      if (event.filterText.isNotEmpty) {
        queryParams['search'] = event.filterText;
      }
      if (event.status.isNotEmpty) {
        queryParams['status'] = event.status;
      }
      if (event.dropdownFilter.isNotEmpty) {
        // Parse existing dropdown filter and merge with new params
        final existingParams = Uri.parse(event.dropdownFilter).queryParameters;
        queryParams.addAll(existingParams);
      }

      // Build the complete URL with query parameters
      Uri uri = Uri.parse(AppUrls.customer).replace(
        queryParameters: queryParams,
      );

      final res = await getResponse(
        url: uri.toString(),
        context: event.context,
      );

      // Parse the response
      ApiResponse<Map<String, dynamic>> response = appParseJson<Map<String, dynamic>>(
        res,
            (data) => data,
      );

      final data = response.data;

      if (data == null) {
        emit(CustomerSuccess(
          list: [],
          count: 0,
          totalPages: 0,
          currentPage: 1,
          pageSize: event.pageSize,
          from: 0,
          to: 0,
        ));
        return;
      }

      // Extract pagination info from response
      final pagination = data['pagination'] ?? data;
      final results = data['results'] ?? data['data'] ?? data;

      // Parse the customer list
      List<CustomerModel> customerList = [];
      if (results is List) {
        customerList = List<CustomerModel>.from(
          results.map((x) => CustomerModel.fromJson(x)),
        );
      }

      // Calculate pagination values
      int count = pagination['count'] ?? pagination['total'] ?? customerList.length;
      int totalPages = pagination['total_pages'] ?? pagination['last_page'] ??
          ((count / event.pageSize).ceil());
      int currentPage = pagination['current_page'] ?? pagination['page'] ?? event.pageNumber;
      int pageSize = pagination['page_size'] ?? pagination['per_page'] ?? event.pageSize;
      int from = ((currentPage - 1) * pageSize) + 1;
      int to = from + customerList.length - 1;

      // Update the list in bloc if needed
      // list = customerList; // Remove this if it causes issues

      emit(CustomerSuccess(
        list: customerList,
        count: count,
        totalPages: totalPages,
        currentPage: currentPage,
        pageSize: pageSize,
        from: from,
        to: to,
      ));
    } catch (error) {
      emit(CustomerListFailed(
        title: "Error",
        content: error.toString(),
      ));
    }
  }



  Future<void> _onDeleteCustomer(
      DeleteCustomer event, Emitter<CustomerState> emit) async {
    emit(CustomerDeleteLoading());

    try {
      final res = await deleteResponse(
          url:
          "${AppUrls.customer}/${event.id.toString()}"); // Use the correct API URL

      ApiResponse response = appParseJson(
        res,
            (data) =>
        List<CustomerModel>.from(data.map((x) => CustomerModel.fromJson(x))),
      );
      if (response.success == false) {
        emit(CustomerSwitchFailed(
            title: 'Alert', content: response.message ?? ""));
        return;
      }
      //  clearData();
      emit(CustomerDeleteSuccess());
    } catch (error) {
      // clearData();
      emit(CustomerSwitchFailed(title: "Error", content: error.toString()));
    }
  }



  Future<void> _onCreateCustomerList(
      AddCustomer event, Emitter<CustomerState> emit) async {
    emit(CustomerAddLoading());

    try {
      final res = await postResponse(
          url: AppUrls.customer,
          payload: event.body); // Use the correct API URL

      ApiResponse response = appParseJson(
        res,
        (data) =>
            CustomerModel.fromJson(data), // Parse a single CustomerModel object
      );
      if (response.success == false) {
        emit(CustomerAddFailed(title: '', content: response.message ?? ""));
        return;
      }
      // clearData();
      emit(CustomerAddSuccess());
    } catch (error) {
      //     clearData();
      emit(CustomerAddFailed(title: "Error", content: error.toString()));
    }
  }

  Future<void> _onUpdateCustomerList(
      UpdateCustomer event, Emitter<CustomerState> emit) async {
    emit(CustomerSwitchLoading());

    try {
      final res = await patchResponse(
          url: AppUrls.customer + event.id.toString(),
          payload: event.body!); // Use the correct API URL

      ApiResponse response = appParseJson(
        res,
        (data) => List<CustomerModel>.from(
            data.map((x) => CustomerModel.fromJson(x))),
      );
      if (response.success == false) {
        emit(CustomerAddFailed(title: 'Json', content: response.message ?? ""));
        return;
      }
      clearData();
      emit(CustomerAddSuccess());
    } catch (error) {
      clearData();
      emit(CustomerAddFailed(title: "Error", content: error.toString()));
    }
  }

  Future<void> _onUpdateSwitchCustomerList(
      UpdateSwitchCustomer event, Emitter<CustomerState> emit) async {
    emit(CustomerSwitchLoading());

    try {
      final res = await patchResponse(
          url: AppUrls.customer + event.id.toString(),
          payload: event.body!); // Use the correct API URL

      ApiResponse response = appParseJson(
        res,
        (data) => List<CustomerModel>.from(
            data.map((x) => CustomerModel.fromJson(x))),
      );
      if (response.success == false) {
        emit(CustomerSwitchFailed(
            title: 'Json', content: response.message ?? ""));
        return;
      }
      clearData();
      emit(CustomerSwitchSuccess());
    } catch (error) {
      clearData();
      emit(CustomerSwitchFailed(title: "Error", content: error.toString()));
    }
  }

  clearData() {
    customerNameController.clear();
    customerNumberController.clear();
    customerEmailController.clear();
    customerAdditionalEmailController.clear();
    customerAdditionalNumberController.clear();
    customerOpeningBalanceController.clear();
    addressController.clear();
    selectedState="";
    selectedStateBalanceType="";
    sourceModel==null;

  }
}
