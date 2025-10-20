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
      final res = await getResponse(
        url: AppUrls.account,
        context: event.context,
      );

      ApiResponse response = appParseJson(
        res,
        (data) =>
            List<AccountModel>.from(data.map((x) => AccountModel.fromJson(x))),
      );
      final data = response.data;

      if (response.success == true) {
        final data = response.data;
        if (data == null || data.isEmpty) {
          emit(
            AccountListSuccess(
              list: [],
              totalPages: 0,
              currentPage: event.pageNumber,
            ),
          );
          return;
        }

        // Filter and paginate accounts
        final filteredAccount = _filterData(
          data,
          event.filterText,
          event.accountType,
        );

        final paginatedAccounts = _paginatePage(
          filteredAccount,
          event.pageNumber,
        );

        final totalPages = (filteredAccount.length / _itemsPerPage)
            .ceil()
            .clamp(1, double.infinity)
            .toInt();
list=data;
        emit(
          AccountListSuccess(
            list: paginatedAccounts,
            totalPages: totalPages,
            currentPage: event.pageNumber,
          ),
        );
      } else {
        emit(
          AccountListFailed(
            title: "Error",
            content: response.message ?? "Unknown Error",
          ),
        );
      }
    } catch (error) {
      emit(AccountListFailed(title: "Error", content: error.toString()));
    }
  }

  List<AccountModel> _filterData(
    List<AccountModel> accounts,
    String filterText,
    String accountType,
  ) {
    return accounts.where((account) {
      final matchesText =
          filterText.isEmpty ||
          (account.acName?.toLowerCase().contains(filterText.toLowerCase()) ??
              false);
      final matchesType =
          accountType.isEmpty ||
          (account.acType?.toString().toLowerCase() ==
              accountType.toString().toLowerCase());
      return matchesText && matchesType;
    }).toList();
  }

  List<AccountModel> _paginatePage(
    List<AccountModel> accounts,
    int pageNumber,
  ) {
    final start = pageNumber * _itemsPerPage;
    final end = start + _itemsPerPage;
    if (start >= accounts.length) return [];
    return accounts.sublist(
      start,
      end > accounts.length ? accounts.length : end,
    );
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
