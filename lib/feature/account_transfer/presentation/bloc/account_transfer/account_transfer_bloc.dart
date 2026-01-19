// lib/account_transfer/presentation/bloc/account_transfer/account_transfer_bloc.dart
import 'package:intl/intl.dart';
import '/core/configs/configs.dart';
import '/core/repositories/get_response.dart';
import '/core/repositories/post_response.dart';

import '../../../../accounts/data/model/account_active_model.dart';
import '../../../../common/data/models/api_response_mod.dart';
import '../../../../common/data/models/app_parse_json.dart';
import '../../../data/model/account_transfer_model.dart';

part 'account_transfer_event.dart';
part 'account_transfer_state.dart';

class AccountTransferBloc extends Bloc<AccountTransferEvent, AccountTransferState> {
  // Controllers
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController referenceNoController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  // Selected values
  AccountActiveModel? fromAccountModel;
  AccountActiveModel? toAccountModel;
  String selectedTransferType = 'internal';
  String selectedStatus = 'pending';

  // Lists
  List<AccountTransferModel> list = [];
  List<AccountActiveModel> activeAccounts = [];

  // Pagination
  int currentPage = 1;
  int totalPages = 1;
  bool hasMore = true;
  bool isLoadingMore = false;

  // Transfer types
  List<String> transferTypes = ['internal', 'external', 'adjustment'];

  AccountTransferBloc() : super(AccountTransferInitial()) {
    on<FetchAccountTransferList>(_onFetchAccountTransferList);
    on<FetchAvailableAccounts>(_onFetchAvailableAccounts);
    on<CreateAccountTransfer>(_onCreateAccountTransfer);
    on<ExecuteTransfer>(_onExecuteTransfer);
    on<ReverseTransfer>(_onReverseTransfer);
    on<CancelTransfer>(_onCancelTransfer);
    on<QuickTransfer>(_onQuickTransfer);
    on<ResetForm>(_onResetForm);
    on<LoadMoreTransfers>(_onLoadMoreTransfers);
  }
  Future<void> _onFetchAccountTransferList(
      FetchAccountTransferList event,
      Emitter<AccountTransferState> emit,
      ) async {
    emit(AccountTransferListLoading());

    try {
      /// -------------------------------
      /// 1️⃣ Build Query Parameters
      /// -------------------------------
      final Map<String, String> queryParams = {
        'page': event.pageNumber.toString(),
        'page_size': event.pageSize.toString(),
      };

      if (event.fromAccountId?.isNotEmpty == true) {
        queryParams['from_account_id'] = event.fromAccountId!;
      }
      if (event.toAccountId?.isNotEmpty == true) {
        queryParams['to_account_id'] = event.toAccountId!;
      }
      if (event.status?.isNotEmpty == true) {
        queryParams['status'] = event.status!;
      }
      if (event.transferType?.isNotEmpty == true) {
        queryParams['transfer_type'] = event.transferType!;
      }
      if (event.isReversal != null) {
        queryParams['is_reversal'] = event.isReversal!.toString();
      }

      final formatter = DateFormat('yyyy-MM-dd');
      if (event.startDate != null && event.endDate != null) {
        queryParams['start_date'] = formatter.format(event.startDate!);
        queryParams['end_date'] = formatter.format(event.endDate!);
      }

      debugPrint("📌 Query Parameters: $queryParams");

      final uri = Uri.parse('${AppUrls.baseUrl}/transfers/')
          .replace(queryParameters: queryParams);
      debugPrint("📌 Request URL: ${uri.toString()}");

      /// -------------------------------
      /// 2️⃣ API Call
      /// -------------------------------
      final res = await getResponse(
        url: uri.toString(),
        context: event.context,
      );
      debugPrint("📌 Raw API response: $res");

      /// -------------------------------
      /// 3️⃣ Decode JSON
      /// -------------------------------
      final Map<String, dynamic> resData = jsonDecode(res) as Map<String, dynamic>;

      final bool success = resData['status'] ?? false;
      final String message = resData['message'] ?? '';
      final Map<String, dynamic>? data =
      resData['data'] as Map<String, dynamic>?;

      debugPrint("📌 Success: $success");
      debugPrint("📌 Message: $message");
      debugPrint("📌 Data: $data");

      if (!success || data == null) {
        emit(AccountTransferListFailed(
          title: "Failed",
          content: message.isNotEmpty ? message : "Failed to load data",
        ));
        return;
      }

      /// -------------------------------
      /// 4️⃣ Extract Results & Map to Model
      /// -------------------------------
      final List results = (data['results'] as List?) ?? [];
      final int count = data['count'] is int ? data['count'] : results.length;
      final next = data['next'];

      debugPrint("📌 Number of transfers in this page: ${results.length}");
      if (results.isNotEmpty) debugPrint("📌 Sample transfer: ${results[0]}");

      final List<AccountTransferModel> transferList =
      results.map((e) => AccountTransferModel.fromJson(e)).toList();

      /// -------------------------------
      /// 5️⃣ Pagination & List Management
      /// -------------------------------
      if (event.pageNumber == 1) {
        list = transferList;
      } else {
        list.addAll(transferList);
      }

      currentPage = event.pageNumber;
      totalPages = event.pageSize > 0 ? (count / event.pageSize).ceil() : 1;
      hasMore = next != null;

      int from = 0;
      int to = 0;
      if (transferList.isNotEmpty) {
        from = (event.pageNumber - 1) * event.pageSize + 1;
        to = from + transferList.length - 1;
      }

      debugPrint(
          "📌 Pagination - from: $from, to: $to, currentPage: $currentPage, totalPages: $totalPages, hasMore: $hasMore");

      /// -------------------------------
      /// 6️⃣ Emit Success State
      /// -------------------------------
      emit(AccountTransferListSuccess(
        list: list,
        count: count,
        totalPages: totalPages,
        currentPage: currentPage,
        pageSize: event.pageSize,
        from: from,
        to: to,
      ));
    } catch (e, st) {
      debugPrint("⚠️ Exception caught: $e");
      debugPrint("⚠️ Stack trace: $st");
      emit(AccountTransferListFailed(
        title: "Error",
        content: e.toString(),
      ));
    }
  }

  Future<void> _onFetchAvailableAccounts(
      FetchAvailableAccounts event,
      Emitter<AccountTransferState> emit,
      ) async {
    emit(AvailableAccountsLoading());

    try {
      final res = await getResponse(
        url: '${AppUrls.baseUrl}/transfers/available_accounts/',
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
        activeAccounts = accountList;
        emit(AvailableAccountsSuccess(list: accountList));
      } else {
        emit(
          AvailableAccountsFailed(
            title: "Error",
            content: response.message ?? "Unknown Error",
          ),
        );
      }
    } catch (error) {
      emit(AvailableAccountsFailed(
        title: "Error",
        content: error.toString(),
      ));
    }
  }


  Future<void> _onCreateAccountTransfer(
      CreateAccountTransfer event,
      Emitter<AccountTransferState> emit,
      ) async {
    emit(AccountTransferAddLoading());

    try {
      final Map<String, dynamic> res = await postResponse(
        url: '${AppUrls.baseUrl}/transfers/',
        payload: event.body,
      );

      debugPrint("✅ response: $res");
      debugPrint("✅ status: ${res['status']}");
      debugPrint("✅ message: ${res['message']}");

      if (res['status'] != true) {
        emit(AccountTransferAddFailed(
          title: 'Error',
          content: res['message'] ?? 'Failed',
        ));
        return;
      }

      // Optional: parse model
      final transfer = AccountTransferModel.fromJson(res['data']);

      resetForm();
      emit(AccountTransferAddSuccess());

    } catch (e, st) {
      debugPrint("❌ Exception: $e");
      debugPrintStack(stackTrace: st);

      emit(AccountTransferAddFailed(
        title: 'Error',
        content: e.toString(),
      ));
    }
  }


  // Future<void> _onCreateAccountTransfer(
  //     CreateAccountTransfer event,
  //     Emitter<AccountTransferState> emit,
  //     ) async {
  //   emit(AccountTransferAddLoading());
  //
  //   try {
  //     final res = await postResponse(
  //       url: '${AppUrls.baseUrl}/transfers/',
  //       payload: event.body,
  //     );
  //     final jsonString = jsonEncode(res);
  //
  //     ApiResponse response = appParseJson(
  //       jsonString,
  //           (data) => AccountTransferModel.fromJson(data),
  //     );
  //
  //     if (response.success == false) {
  //       emit(AccountTransferAddFailed(
  //         title: 'Error',
  //         content: response.message ?? "",
  //       ));
  //       return;
  //     }
  //     resetForm();
  //     emit(AccountTransferAddSuccess());
  //   } catch (error) {
  //     emit(AccountTransferAddFailed(
  //       title: "Error",
  //       content: error.toString(),
  //     ));
  //   }
  // }


  Future<void> _onExecuteTransfer(
      ExecuteTransfer event,
      Emitter<AccountTransferState> emit,
      ) async {
    emit(ExecuteTransferLoading());

    try {
      debugPrint("📌 Executing transfer ID: ${event.transferId}");
      final loginInfo = await LocalDB.getLoginInfo();
      if (loginInfo == null || loginInfo['userId'] == null) {
        throw Exception("User not logged in or userId missing");
      }

      final int userId = int.parse(loginInfo['userId']); // convert from String to int

      final payload = {
        "user_id": userId,
      };

      debugPrint("📌 Payload: $payload");
      // -------------------------------
      // 1️⃣ API Call (ensure payload is a JSON string)
      // -------------------------------
      final res = await postResponse(
        url: '${AppUrls.baseUrl}/transfers/${event.transferId}/execute/',
        payload: payload, // ✅ send nothing

      );

      debugPrint("📌 Raw API response: $res");

      // -------------------------------
      // 2️⃣ Parse Response Safely
      // -------------------------------
      final Map<String, dynamic> resData;

      if (res is String) {
        // Decode JSON string
        resData = res;
      } else {
        // Already a Map
      resData = res;
      }


      debugPrint("📌 Parsed response: $resData");

      debugPrint("📌 Parsed response: $resData");

      final bool success = resData['status'] ?? false;
      final String message = resData['message'] ?? '';
      final dynamic data = resData['data'];

      debugPrint("📌 Success: $success");
      debugPrint("📌 Message: $message");
      debugPrint("📌 Data: $data");

      if (!success || data == null) {
        emit(ExecuteTransferFailed(
          title: 'Error',
          content: message.isNotEmpty ? message : "Failed to execute transfer",
        ));
        return;
      }

      // -------------------------------
      // 3️⃣ Update Transfer in List
      // -------------------------------
      final executedTransfer = AccountTransferModel.fromJson(data);

      final index = list.indexWhere((t) => t.id.toString() == event.transferId);
      if (index != -1) {
        list[index] = executedTransfer;
        debugPrint("📌 Updated transfer in list at index $index");
      } else {
        debugPrint("📌 Transfer ID ${event.transferId} not found in list");
      }

      // -------------------------------
      // 4️⃣ Emit Success
      // -------------------------------
      emit(ExecuteTransferSuccess());
      debugPrint("✅ Transfer executed successfully");

    } catch (error, st) {
      debugPrint("⚠️ Exception caught: $error");
      debugPrint("⚠️ Stack trace: $st");
      emit(ExecuteTransferFailed(
        title: "Error",
        content: error.toString(),
      ));
    }
  }


  Future<void> _onQuickTransfer(
      QuickTransfer event,
      Emitter<AccountTransferState> emit,
      ) async {
    emit(QuickTransferLoading());

    try {
      final res = await postResponse(
        url: '${AppUrls.baseUrl}/transfers/quick_transfer/',
        payload: event.body,
      );
      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString,
            (data) => AccountTransferModel.fromJson(data),
      );

      if (response.success == false) {
        emit(QuickTransferFailed(
          title: 'Error',
          content: response.message ?? "",
        ));
        return;
      }else{
        final transfer = AccountTransferModel.fromJson(response.data!);
        list.insert(0, transfer);

        emit(QuickTransferSuccess(transfer: transfer));
      }
      resetForm();

      // Add to list

    } catch (error) {
      emit(QuickTransferFailed(
        title: "Error",
        content: error.toString(),
      ));
    }
  }

  Future<void> _onReverseTransfer(
      ReverseTransfer event,
      Emitter<AccountTransferState> emit,
      ) async {
    emit(ReverseTransferLoading());

    try {
      final Map<String, dynamic> body = {};
      if (event.reason != null && event.reason!.isNotEmpty) {
        body['reason'] = event.reason!;
      }

      final res = await postResponse(
        url: '${AppUrls.baseUrl}/transfers/${event.transferId}/reverse/',
        payload: body,
      );
      final jsonString = jsonEncode(res);


      final ApiResponse response = appParseJson(
        jsonString,
            (_) => null, // ✅ no model parsing
      );

      if (response.success == false) {
        emit(ReverseTransferFailed(
          title: 'Error',
          content: response.message ?? "",
        ));
        return;
      }else{
        emit(ReverseTransferSuccess());

      }
    } catch (error) {
      emit(ReverseTransferFailed(
        title: "Error",
        content: error.toString(),
      ));
    }
  }

  Future<void> _onCancelTransfer(
      CancelTransfer event,
      Emitter<AccountTransferState> emit,
      ) async {
    emit(CancelTransferLoading());

    try {
      final Map<String, dynamic> body = {};
      if (event.reason?.isNotEmpty == true) {
        body['reason'] = event.reason;
      }

      final res = await postResponse(
        url: '${AppUrls.baseUrl}/transfers/${event.transferId}/cancel/',
        payload: body,
      );

      final jsonString = jsonEncode(res);

      final ApiResponse response = appParseJson(
        jsonString,
            (_) => null, // ✅ no model parsing
      );

      if (response.success != true) {
        emit(CancelTransferFailed(
          title: 'Error',
          content: response.message ?? 'Cancel failed',
        ));
        return;
      }

      emit(CancelTransferSuccess());
    } catch (error, st) {
      debugPrint(error.toString());
      debugPrintStack(stackTrace: st);
      emit(CancelTransferFailed(
        title: "Error",
        content: error.toString(),
      ));
    }
  }


  void _onResetForm(ResetForm event, Emitter<AccountTransferState> emit) {
    resetForm();
    emit(AccountTransferFormReset());
  }

  Future<void> _onLoadMoreTransfers(
      LoadMoreTransfers event,
      Emitter<AccountTransferState> emit,
      ) async {
    if (!hasMore || isLoadingMore) return;

    isLoadingMore = true;
    add(FetchAccountTransferList(
      context: event.context,
      pageNumber: currentPage + 1,
      pageSize: event.pageSize,
    ));
    isLoadingMore = false;
  }

  void resetForm() {
    amountController.clear();
    descriptionController.clear();
    referenceNoController.clear();
    remarksController.clear();
    dateController.clear();
    fromAccountModel = null;
    toAccountModel = null;
    selectedTransferType = 'internal';
    selectedStatus = 'pending';
  }

  @override
  Future<void> close() {
    amountController.dispose();
    descriptionController.dispose();
    referenceNoController.dispose();
    remarksController.dispose();
    dateController.dispose();
    return super.close();
  }
}