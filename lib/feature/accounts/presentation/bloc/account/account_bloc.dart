import 'package:smart_inventory/feature/accounts/data/model/create_account_model.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/repositories/get_response.dart';
import '../../../../../core/repositories/post_response.dart';
import '../../../../common/data/models/api_response_mod.dart';
import '../../../../common/data/models/app_parse_json.dart';
import '../../../data/model/account_model.dart';

part 'account_event.dart';

part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountModel? selectedAccountFrom;
  AccountModel? selectedAccountTo;
  List<AccountModel> list = [];
  final int _itemsPerPage = 15;
  String selectedState = "";
  String selectedStateId = "";
  String selectedGroups = "";
  String selectedLocation = " ";
  String selectedId = "";

  List<String> accountType = ["Bank", "Cash", "Mobile Bank"];

  TextEditingController filterTextController = TextEditingController();

  TextEditingController accountNameController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();
  TextEditingController bankNameController = TextEditingController();
  TextEditingController branchNameController = TextEditingController();
  TextEditingController routingNameController = TextEditingController();
  TextEditingController accountOpeningBalanceController =
      TextEditingController();
  TextEditingController shortNameController = TextEditingController();

  AccountBloc() : super(AccountInitial()) {
    on<FetchAccountList>(_onFetchAccountList);
    on<AddAccount>(_onCreateAccountList);
  }
  Future<void> _onFetchAccountList(
      FetchAccountList event,
      Emitter<AccountState> emit,
      ) async {
    emit(AccountListLoading());

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
      if (event.accountType.isNotEmpty) {
        queryParams['account_type'] = event.accountType;
      }

      // Build the complete URL with query parameters
      Uri uri = Uri.parse(AppUrls.account).replace(
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
        emit(AccountListSuccess(
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

      // Parse the account list
      List<AccountModel> accountList = [];
      if (results is List) {
        accountList = List<AccountModel>.from(
          results.map((x) => AccountModel.fromJson(x)),
        );
      }

      // Calculate pagination values
      int count = pagination['count'] ?? pagination['total'] ?? accountList.length;
      int totalPages = pagination['total_pages'] ?? pagination['last_page'] ??
          ((count / event.pageSize).ceil());
      int currentPage = pagination['current_page'] ?? pagination['page'] ?? event.pageNumber;
      int pageSize = pagination['page_size'] ?? pagination['per_page'] ?? event.pageSize;
      int from = ((currentPage - 1) * pageSize) + 1;
      int to = from + accountList.length - 1;

      emit(AccountListSuccess(
        list: accountList,
        count: count,
        totalPages: totalPages,
        currentPage: currentPage,
        pageSize: pageSize,
        from: from,
        to: to,
      ));
    } catch (error) {
      emit(AccountListFailed(title: "Error", content: error.toString()));
    }
  }



  Future<void> _onCreateAccountList(
    AddAccount event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountAddLoading());

    try {
      final res = await postResponse(
        url: AppUrls.account,
        payload: event.body,
      ); // Use the correct API URL

      ApiResponse response = appParseJson(
        res,
            (data) => List<AccountModel>.from(data.map((x) => AccountModel.fromJson(x))),
      );
      if (response.success == false) {
        emit(AccountAddFailed(title: '', content: response.message ?? ""));
        return;
      }
      clearData();
      emit(AccountAddSuccess());
    } catch (error) {
      clearData();
      emit(AccountAddFailed(title: "Error", content: error.toString()));
    }
  }

  // Future<void> _onUpdateBranchList(
  //     UpdateCategories event, Emitter<CategoriesState> emit) async {
  //
  //   emit(CategoriesAddLoading());
  //
  //   try {
  //     final res  = await patchResponse(url: AppUrls.category+event.id.toString(),payload: event.body!); // Use the correct API URL
  //
  //     print(res);
  //     ApiResponse response = appParseJson(
  //       res,
  //           (data) => List<CategoryModel>.from(data.map((x) => CategoryModel.fromJson(x))),
  //     );
  //     if (response.success == false) {
  //       emit(CategoriesAddFailed(title: 'Json', content: response.message??""));
  //       return;
  //     }
  //     clearData();
  //     emit(CategoriesAddSuccess(
  //
  //     ));
  //   } catch (error,stack) {
  //     print(stack);
  //     clearData();
  //     emit(CategoriesAddFailed(title: "Error",content: error.toString()));
  //
  //   }
  // }

  clearData() {
    accountOpeningBalanceController.clear();
    accountNumberController.clear();
    accountNameController.clear();
    selectedState = "";
  }
}
