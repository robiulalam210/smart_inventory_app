// lib/account_transfer/presentation/bloc/account_transfer/account_transfer_bloc.dart
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:meherin_mart/core/configs/configs.dart';
import 'package:meherin_mart/core/repositories/get_response.dart';
import 'package:meherin_mart/core/repositories/post_response.dart';
import 'package:meherin_mart/core/repositories/patch_response.dart';
import 'package:meherin_mart/core/repositories/delete_response.dart';

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
      // Build query parameters
      Map<String, String> queryParams = {
        'page': event.pageNumber.toString(),
        'page_size': event.pageSize.toString(),
      };

      if (event.fromAccountId != null && event.fromAccountId!.isNotEmpty) {
        queryParams['from_account_id'] = event.fromAccountId!;
      }
      if (event.toAccountId != null && event.toAccountId!.isNotEmpty) {
        queryParams['to_account_id'] = event.toAccountId!;
      }
      if (event.status != null && event.status!.isNotEmpty) {
        queryParams['status'] = event.status!;
      }
      if (event.transferType != null && event.transferType!.isNotEmpty) {
        queryParams['transfer_type'] = event.transferType!;
      }
      if (event.isReversal != null) {
        queryParams['is_reversal'] = event.isReversal!.toString();
      }
      // if (event.startDate != null && event.endDate != null) {
      //   final format = DateTimeFormat('yyyy-MM-dd');
      //   queryParams['start_date'] = format.format(event.startDate!);
      //   queryParams['end_date'] = format.format(event.endDate!);
      // }

      final DateFormat formatter = DateFormat('yyyy-MM-dd');

      if (event.startDate != null && event.endDate != null) {
        queryParams['start_date'] = formatter.format(event.startDate!);
        queryParams['end_date'] = formatter.format(event.endDate!);
      }

      String baseUrl = '${AppUrls.baseUrl}/transfers/';
      Uri uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

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
        emit(AccountTransferListSuccess(
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
      final count = responseData['count'] ?? results.length;
      final next = responseData['next'];
      final previous = responseData['previous'];

      List<AccountTransferModel> transferList = [];
      if (results is List) {
        transferList = List<AccountTransferModel>.from(
          results.map((x) => AccountTransferModel.fromJson(x)),
        );
      }

      // Handle pagination
      if (event.pageNumber == 1) {
        list = transferList;
      } else {
        list.addAll(transferList);
      }

      currentPage = event.pageNumber;
      totalPages = (count / event.pageSize).ceil();
      hasMore = next != null;

      // Calculate from/to for display
      int from = (event.pageNumber - 1) * event.pageSize + 1;
      int to = from + transferList.length - 1;
      if (transferList.isEmpty) {
        from = 0;
        to = 0;
      }

      emit(AccountTransferListSuccess(
        list: transferList,
        count: count,
        totalPages: totalPages,
        currentPage: currentPage,
        pageSize: event.pageSize,
        from: from,
        to: to,
      ));
    } catch (error) {
      emit(AccountTransferListFailed(
        title: "Error",
        content: error.toString(),
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
        url: '/api/transfers/available_accounts/',
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
      final res = await postResponse(
        url: '${AppUrls.baseUrl}/transfers/',
        payload: event.body,
      );
      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString,
            (data) => AccountTransferModel.fromJson(data),
      );

      if (response.success == false) {
        emit(AccountTransferAddFailed(
          title: 'Error',
          content: response.message ?? "",
        ));
        return;
      }
      resetForm();
      emit(AccountTransferAddSuccess());
    } catch (error, st) {
      print(error);
      print(st);
      emit(AccountTransferAddFailed(
        title: "Error",
        content: error.toString(),
      ));
    }
  }

  Future<void> _onExecuteTransfer(
      ExecuteTransfer event,
      Emitter<AccountTransferState> emit,
      ) async {
    emit(ExecuteTransferLoading());

    try {
      final res = await postResponse(
        url: '${AppUrls.baseUrl}/transfers/${event.transferId}/execute/',
        payload: {},
      );
      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString,
            (data) => AccountTransferModel.fromJson(data),
      );

      if (response.success == false) {
        emit(ExecuteTransferFailed(
          title: 'Error',
          content: response.message ?? "",
        ));
        return;
      }

      // Update the transfer in the list
      final index = list.indexWhere((t) => t.id == event.transferId);
      if (index != -1) {
        list[index] = AccountTransferModel.fromJson(response.data!);
      }

      emit(ExecuteTransferSuccess());
    } catch (error, st) {
      print(error);
      print(st);
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
      }
      resetForm();

      // Add to list
      final transfer = AccountTransferModel.fromJson(response.data!);
      list.insert(0, transfer);

      emit(QuickTransferSuccess(transfer: transfer));
    } catch (error, st) {
      print(error);
      print(st);
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
      }

      emit(ReverseTransferSuccess());
    } catch (error, st) {
      print(error);
      print(st);
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