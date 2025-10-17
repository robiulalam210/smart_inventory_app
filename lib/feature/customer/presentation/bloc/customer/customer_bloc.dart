



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

  Future<void> _onFetchCustomerList(
      FetchCustomerList event,
      Emitter<CustomerState> emit,
      ) async {
    emit(CustomerListLoading());

    try {
      final res = await getResponse(url: AppUrls.customer, context: event.context);

      ApiResponse response = appParseJson(
        res,
            (data) => List<CustomerModel>.from(
          data.map((x) => CustomerModel.fromJson(x)),
        ),
      );

      // Check if API response is successful
      if (response.success == true) {
        final List<CustomerModel> customerList = response.data ?? [];

        if (customerList.isEmpty) {
          emit(CustomerSuccess(list: []));
          return;
        }

        // Filter customers
        final filteredCustomers = await _filterCustomers(
          customerList,
          event.filterText,
          event.status,
        );
        list=filteredCustomers;

        emit(CustomerSuccess(list: filteredCustomers));
      } else {
        emit(CustomerListFailed(
          title: "Error",
          content: response.message ?? "Unknown Error",
        ));
      }
    } catch (error) {
      emit(CustomerListFailed(
        title: "Error",
        content: error.toString(),
      ));
    }
  }

  Future<List<CustomerModel>> _filterCustomers(
      List<CustomerModel> customers,
      String filterText,
      String accountType,
      ) async {
    // Optional artificial delay
    await Future.delayed(const Duration(milliseconds: 100));

    // Apply filters
    final filteredCustomers = customers.where((customer) {
      final name = customer.name?.toLowerCase() ?? '';
      final phone = customer.phone?.toLowerCase() ?? '';

      final matchesText = filterText.isEmpty ||
          name.contains(filterText.toLowerCase()) ||
          phone.contains(filterText.toLowerCase());


      return matchesText;
    }).toList();

    // Sort by clientNo safely (avoid null crash)
    filteredCustomers.sort((a, b) {
      final aNo = int.tryParse(a.name?.toString() ?? '0') ?? 0;
      final bNo = int.tryParse(b.name?.toString() ?? '0') ?? 0;
      return aNo.compareTo(bNo);
    });

    return filteredCustomers;
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
