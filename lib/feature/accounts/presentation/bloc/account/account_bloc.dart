import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_inventory/feature/accounts/data/model/create_account_model.dart';
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
      Map<String, dynamic> queryParams = {
        'page': event.pageNumber.toString(),
        'page_size': event.pageSize.toString(),
      };

      if (event.filterText.isNotEmpty) {
        queryParams['search'] = event.filterText;
      }
      if (event.accountType.isNotEmpty) {
        queryParams['account_type'] = event.accountType;
      }

      Uri uri = Uri.parse(AppUrls.account).replace(
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
          totalPages: 0,
          currentPage: 1,
          pageSize: event.pageSize,
          from: 0,
          to: 0,
        ));
        return;
      }

      final pagination = data['pagination'] ?? data;
      final results = data['results'] ?? data['data'] ?? data;

      List<AccountModel> accountList = [];
      if (results is List) {
        accountList = List<AccountModel>.from(
          results.map((x) => AccountModel.fromJson(x)),
        );
      }

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
        url: "${AppUrls.account}${event.id}/",
        payload: event.body!,
      );

      ApiResponse response = appParseJson(
        res,
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
        url: "${AppUrls.account}${event.id}/",
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