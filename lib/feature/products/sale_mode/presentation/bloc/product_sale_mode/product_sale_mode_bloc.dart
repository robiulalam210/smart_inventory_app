// features/products/sale_mode/presentation/bloc/product_sale_mode/product_sale_mode_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:convert';

import '../../../../../../core/configs/configs.dart';
import '../../../data/avliable_sales_model.dart';
import '../../../data/product_sale_mode_model.dart';
import '../../../../../../core/repositories/delete_response.dart';
import '../../../../../../core/repositories/get_response.dart';
import '../../../../../../core/repositories/patch_response.dart';
import '../../../../../../core/repositories/post_response.dart';
import '../../../../../common/data/models/api_response_mod.dart';
import '../../../../../common/data/models/app_parse_json.dart';
import '../../../data/sale_mode_model.dart';

part 'product_sale_mode_event.dart';
part 'product_sale_mode_state.dart';

class ProductSaleModeBloc extends Bloc<ProductSaleModeEvent, ProductSaleModeState> {
  List<ProductSaleModeModel> productSaleModeModel = [];
  String selectedId = "";
  TextEditingController filterTextController = TextEditingController();

  ProductSaleModeBloc() : super(ProductSaleModeInitial()) {
    on<FetchProductSaleModeList>(_onFetchProductSaleModeList);
    on<AddProductSaleMode>(_onCreateProductSaleModeList);
    on<UpdateProductSaleMode>(_onUpdateProductSaleModeList);
    on<DeleteProductSaleMode>(_onDeleteProductSaleModeList);
    on<BulkUpdateProductSaleModes>(_onBulkUpdateProductSaleModes);
    on<ClearProductSaleModeData>(_onClearProductSaleModeData);
  }
  Future<void> _onFetchProductSaleModeList(
      FetchProductSaleModeList event,
      Emitter<ProductSaleModeState> emit,
      ) async {
    emit(ProductSaleModeListLoading());

    try {
      final res = await getResponse(
        url: AppUrls.productSaleModes,
        context: event.context,
        queryParams: {'product_id': event.productId},
      );

      final Map<String, dynamic> body = jsonDecode(res);

      final List<ProductSaleModeModel> data =
      (body['data'] as List<dynamic>)
          .map((e) => ProductSaleModeModel.fromJson(e))
          .toList();

      debugPrint(
        'Fetched Sale Modes (${data.length}): '
            '${data.map((e) => e.saleModeName).join(', ')}',
      );

      emit(
        ProductSaleModeListSuccess(
          list: data,
          totalPages: 1,
          currentPage: event.pageNumber,
        ),
      );
    } catch (e, stack) {
      debugPrint('❌ SaleMode Error: $e');
      debugPrintStack(stackTrace: stack);

      emit(
        ProductSaleModeListFailed(
          title: 'Error',
          content: e.toString(),
        ),
      );
    }
  }



  Future<void> _onCreateProductSaleModeList(
      AddProductSaleMode event,
      Emitter<ProductSaleModeState> emit,
      ) async {
    emit(ProductSaleModeAddLoading());

    try {
      final res = await postResponse(
        url: AppUrls.productSaleModes,
        payload: event.body,
      );

      print("RAW RESPONSE => $res");

      final bool success = res['status'] == true;

      if (!success) {
        /// 🔥 Handle Django validation error
        String message = res['message'] ?? 'Something went wrong';

        final data = res['data'];
        if (data is Map && data['data'] is Map) {
          final errors = data['data']['non_field_errors'];
          if (errors is List && errors.isNotEmpty) {
            message = errors.first.toString();
          }
        }

        emit(ProductSaleModeAddFailed(
          title: res['title'] ?? 'Error',
          content: message,
        ));
        return;
      }

      emit(ProductSaleModeAddSuccess());
    } catch (error, st) {
      print(error);
      print(st);

      emit(ProductSaleModeAddFailed(
        title: "Error",
        content: error.toString(),
      ));
    }
  }

  Future<void> _onUpdateProductSaleModeList(
      UpdateProductSaleMode event,
      Emitter<ProductSaleModeState> emit,
      ) async {
    emit(ProductSaleModeAddLoading());

    try {
      final res = await patchResponse(
        url: "${AppUrls.productSaleModes + event.id}/",
        payload: event.body!,
      );

      print("RAW RESPONSE => $res");

      final bool success = res['status'] == true;

      if (!success) {
        /// 🔥 Handle Django validation error
        String message = res['message'] ?? 'Something went wrong';

        final data = res['data'];
        if (data is Map && data['data'] is Map) {
          final errors = data['data']['non_field_errors'];
          if (errors is List && errors.isNotEmpty) {
            message = errors.first.toString();
          }
        }

        emit(ProductSaleModeAddFailed(
          title: res['title'] ?? 'Error',
          content: message,
        ));
        return;
      }

      emit(ProductSaleModeAddSuccess());
    } catch (error) {
      emit(ProductSaleModeAddFailed(title: "Error", content: error.toString()));
    }
  }

  Future<void> _onDeleteProductSaleModeList(
      DeleteProductSaleMode event,
      Emitter<ProductSaleModeState> emit,
      ) async {
    emit(ProductSaleModeDeleteLoading());

    try {
      final res = await deleteResponse(
        url: "${AppUrls.productSaleModes + event.id}/",
      );

      final jsonString = jsonEncode(res);
      ApiResponse response = appParseJson(
        jsonString,
            (data) => data,
      );

      if (response.success == false) {
        emit(ProductSaleModeDeleteFailed(title: 'Json', content: response.message ?? ""));
        return;
      }

      emit(ProductSaleModeDeleteSuccess(message: response.message ?? ""));
    } catch (error) {
      emit(ProductSaleModeDeleteFailed(title: "Error", content: error.toString()));
    }
  }

  Future<void> _onBulkUpdateProductSaleModes(
      BulkUpdateProductSaleModes event,
      Emitter<ProductSaleModeState> emit,
      ) async {
    emit(ProductSaleModeBulkUpdateLoading());

    try {
      final res = await postResponse(
        url: "${AppUrls.productSaleModes}bulk_update/",
        payload: {
          'product_id': event.productId,
          'sale_modes': event.saleModes,
        },
      );

      final jsonString = jsonEncode(res);
      ApiResponse response = appParseJson(
        jsonString,
            (data) => data,
      );

      if (response.success == false) {
        emit(ProductSaleModeBulkUpdateFailed(title: 'Error', content: response.message ?? ""));
        return;
      }

      emit(ProductSaleModeBulkUpdateSuccess());
    } catch (error) {
      emit(ProductSaleModeBulkUpdateFailed(title: "Error", content: error.toString()));
    }
  }

  void _onClearProductSaleModeData(
      ClearProductSaleModeData event,
      Emitter<ProductSaleModeState> emit,
      ) {
    productSaleModeModel.clear();
    filterTextController.clear();
    selectedId = "";
  }

  List<ProductSaleModeModel> _filterProductSaleMode(
      List<ProductSaleModeModel> list,
      String filterText,
      ) {
    return list.where((data) {
      final matchesText = filterText.isEmpty ||
          (data.saleModeName?.toLowerCase().contains(filterText.toLowerCase()) ?? false);
      return matchesText;
    }).toList();
  }
}