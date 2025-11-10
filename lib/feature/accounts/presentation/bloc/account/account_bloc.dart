
import '../../../../../core/configs/configs.dart';
import '../../../../../core/repositories/get_response.dart';
import '../../../../../core/repositories/post_response.dart';
import '../../../../../core/repositories/patch_response.dart';
import '../../../../../core/repositories/delete_response.dart';
import '../../../../common/data/models/api_response_mod.dart';
import '../../../../common/data/models/app_parse_json.dart';
import '../../../data/model/account_active_model.dart';
import '../../../data/model/account_model.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountActiveModel? selectedAccountFrom;
  AccountActiveModel? selectedAccountTo;
  List<AccountModel> list = [];
  List<AccountActiveModel> activeAccount = [];
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
  TextEditingController accountOpeningBalanceController = TextEditingController();
  TextEditingController shortNameController = TextEditingController();

  AccountBloc() : super(AccountInitial()) {
    on<FetchAccountList>(_onFetchAccountList);
    on<FetchAccountActiveList>(_onFetchAccountActiveList);
    on<AddAccount>(_onCreateAccountList);
    on<UpdateAccount>(_onUpdateAccountList);
    on<DeleteAccount>(_onDeleteAccount);
  }

  Future<void> _onFetchAccountActiveList(
      FetchAccountActiveList event,
      Emitter<AccountState> emit,
      ) async {
    emit(AccountActiveListLoading());

    try {
      final res = await getResponse(
        url: AppUrls.accountActive,
        context: event.context,
      );

      ApiResponse response = appParseJson(
        res,
            (data) => List<AccountActiveModel>.from(
          data.map((x) => AccountActiveModel.fromJson(x)),
        ),
      );

      if (response.success == true) {
        final List<AccountActiveModel> accountList = response.data ?? [];
        activeAccount = accountList;
        emit(AccountActiveListSuccess(list: accountList));
      } else {
        emit(
          AccountActiveListFailed(
            title: "Error",
            content: response.message ?? "Unknown Error",
          ),
        );
      }
    } catch (error) {
      emit(AccountActiveListFailed(title: "Error", content: error.toString()));
    }
  }

  Future<void> _onFetchAccountList(
      FetchAccountList event,
      Emitter<AccountState> emit,
      ) async {
    emit(AccountListLoading());

    try {
      // Build base URL without pagination parameters since API has no_pagination=true
      String baseUrl = AppUrls.accountNON;

      // Add filter parameters only
      Map<String, String> queryParams = {
        // "no_pagination": "true"  // Fixed syntax - use colon and string value
      };

      if (event.filterText.isNotEmpty) {
        queryParams['search'] = event.filterText;
      }
      if (event.accountType.isNotEmpty) {
        queryParams['ac_type'] = event.accountType;
      }

      Uri uri = Uri.parse(baseUrl).replace(
        queryParameters: queryParams,
      );

      final res = await getResponse(
        url: uri.toString(),
        context: event.context,
      );

      ApiResponse<Map<String, dynamic>> response = appParseJson<Map<String, dynamic>>(
        res,
            (data) => data,
      );

      final data = response.data;

      if (data == null) {
        emit(AccountListSuccess(
          list: [],
          count: 0,
          totalPages: 1,
          currentPage: 1,
          pageSize: event.pageSize,
          from: 0,
          to: 0,
        ));
        return;
      }

      // Extract data from response structure
      final responseData = data['data'] ?? data;
      final results = responseData['results'] ?? [];

      List<AccountModel> accountList = [];
      if (results is List) {
        accountList = List<AccountModel>.from(
          results.map((x) => AccountModel.fromJson(x)),
        );
      }

      // Since no_pagination=true, handle as single page with all results
      int totalCount = accountList.length;
      int totalPages = 1;
      int currentPage = 1;
      int pageSize = totalCount; // Show all items on one page

      // Calculate from/to for display (always show 1 to totalCount)
      int from = totalCount > 0 ? 1 : 0;
      int to = totalCount;

      emit(AccountListSuccess(
        list: accountList,
        count: totalCount,
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
      );
      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString,
            (data) => AccountModel.fromJson(data),
      );

      if (response.success == false) {
        emit(AccountAddFailed(title: 'Error', content: response.message ?? ""));
        return;
      }
      clearData();
      emit(AccountAddSuccess());
    } catch (error) {
      clearData();
      emit(AccountAddFailed(title: "Error", content: error.toString()));
    }
  }

  Future<void> _onUpdateAccountList(
      UpdateAccount event,
      Emitter<AccountState> emit,
      ) async {
    emit(AccountAddLoading());

    try {
      final res = await patchResponse(
        url: "${AppUrls.accountNON}${event.id}/",
        payload: event.body!,
      );
      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString,
            (data) => AccountModel.fromJson(data),
      );

      if (response.success == false) {
        emit(AccountAddFailed(title: 'Error', content: response.message ?? ""));
        return;
      }
      clearData();
      emit(AccountAddSuccess());
    } catch (error) {
      clearData();
      emit(AccountAddFailed(title: "Error", content: error.toString()));
    }
  }

  Future<void> _onDeleteAccount(
      DeleteAccount event,
      Emitter<AccountState> emit,
      ) async {
    emit(AccountAddLoading());

    try {
      final res = await deleteResponse(
        url: "${AppUrls.accountNON}${event.id}/",
      );      final jsonString = jsonEncode(res);


      // For delete operations, we don't need to parse the response data
      ApiResponse response = appParseJson(
        jsonString,
            (data) => data, // Just return data as-is for delete operations
      );

      if (response.success == false) {
        emit(AccountAddFailed(title: 'Error', content: response.message ?? ""));
        return;
      }
      emit(AccountAddSuccess());
    } catch (error) {
      emit(AccountAddFailed(title: "Error", content: error.toString()));
    }
  }

  clearData() {
    accountOpeningBalanceController.clear();
    accountNumberController.clear();
    accountNameController.clear();
    bankNameController.clear();
    branchNameController.clear();
    routingNameController.clear();
    shortNameController.clear();
    selectedState = "";
    selectedStateId = "";
    selectedGroups = "";
    selectedLocation = " ";
    selectedId = "";
  }
}