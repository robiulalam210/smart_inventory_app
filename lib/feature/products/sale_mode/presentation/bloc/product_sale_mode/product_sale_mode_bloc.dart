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
  List<AvlibleSaleModeModel> availableSaleModes = [];

  ProductSaleModeBloc() : super(ProductSaleModeInitial()) {
    on<FetchProductSaleModeList>(_onFetchProductSaleModeList);
    on<FetchAvailableSaleModes>(_onFetchAvailableSaleModes);
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

      ApiResponse response = appParseJson(
        res,
            (data) => List<ProductSaleModeModel>.from(
          data.map((x) => ProductSaleModeModel.fromJson(x)),
        ),
      );

      final data = response.data;
      if (data == null || data.isEmpty) {
        emit(
          ProductSaleModeListSuccess(
            list: [],
            totalPages: 0,
            currentPage: event.pageNumber,
          ),
        );
        return;
      }

      productSaleModeModel = data;
      final filteredData = _filterProductSaleMode(productSaleModeModel, event.filterText);

      emit(
        ProductSaleModeListSuccess(
          list: filteredData,
          totalPages: 1,
          currentPage: event.pageNumber,
        ),
      );
    } catch (error) {
      emit(ProductSaleModeListFailed(title: "Error", content: error.toString()));
    }
  }

  Future<void> _onFetchAvailableSaleModes(
      FetchAvailableSaleModes event,
      Emitter<ProductSaleModeState> emit,
      ) async {
    emit(AvailableSaleModesLoading());

    try {
      final res = await getResponse(
        url: "${AppUrls.products}${event.productId}/available_sale_modes/",
        context: event.context,
      );

      ApiResponse response = appParseJson(
        res,
            (data) => data, // just pass data as-is
      );

      final data = response.data;

      if (data == null || (data as List).isEmpty) {
        emit(AvailableSaleModesSuccess(availableModes: []));
        return;
      }

      final dataList = data as List<dynamic>;

      // Map JSON to your model
      final modes = dataList
          .map((e) => AvlibleSaleModeModel.fromJson(e as Map<String, dynamic>))
          .toList();

      availableSaleModes = modes; // store locally if needed
      emit(AvailableSaleModesSuccess(availableModes: modes));
    } catch (error, st) {
      print(error);
      print(st);
      emit(AvailableSaleModesFailed(title: "Error", content: error.toString()));
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

      final jsonString = jsonEncode(res);
      ApiResponse response = appParseJson(
        jsonString,
            (data) => ProductSaleModeModel.fromJson(data),
      );

      if (response.success == false) {
        emit(ProductSaleModeAddFailed(title: '', content: response.message ?? ""));
        return;
      }

      emit(ProductSaleModeAddSuccess());
    } catch (error) {

      emit(ProductSaleModeAddFailed(title: "Error", content: error.toString()));
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

      final jsonString = jsonEncode(res);
      ApiResponse response = appParseJson(
        jsonString,
            (data) => ProductSaleModeModel.fromJson(data),
      );

      if (response.success == false) {
        emit(ProductSaleModeAddFailed(title: 'Alert', content: response.message ?? ""));
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
    availableSaleModes.clear();
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