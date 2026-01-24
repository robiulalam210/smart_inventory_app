// features/products/sale_mode/presentation/bloc/price_tier_bloc.dart
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../common/data/models/api_response_mod.dart';
import '../../../../common/data/models/app_parse_json.dart';
import '../../../../../../core/repositories/delete_response.dart';
import '../../../../../../core/repositories/get_response.dart';
import '../../../../../../core/repositories/post_response.dart';
import '../../../../../../core/repositories/patch_response.dart';
import '../../../sale_mode/data/avliable_sales_model.dart';
import '../../../sale_mode/data/product_sale_mode_model.dart';
import '../../data/model/price_tier_model.dart';

part 'price_tier_event.dart';
part 'price_tier_state.dart';

class PriceTierBloc extends Bloc<PriceTierEvent, PriceTierState> {
  List<PriceTierModel> priceTiers = [];
  List<AvlibleSaleModeModel> availableSaleModes = [];

  PriceTierBloc() : super(PriceTierInitial()) {
    on<FetchAvailableSaleModes>(_onFetchAvailableSaleModes);

    on<LoadPriceTiers>(_onLoadPriceTiers);
    on<AddPriceTier>(_onAddPriceTier);
    on<UpdatePriceTier>(_onUpdatePriceTier);
    on<DeletePriceTier>(_onDeletePriceTier);
    on<ClearPriceTiers>(_onClearPriceTiers);
    on<CalculatePrice>(_onCalculatePrice);
  }


  Future<void> _onLoadPriceTiers(
      LoadPriceTiers event,
      Emitter<PriceTierState> emit,
      ) async {
    emit(PriceTierLoading());

    try {
      // Query params must be string
      final Map<String, String> queryParams = {
        if (event.productSaleModeId != null)
          'product_sale_mode_id': event.productSaleModeId.toString(),
        if (event.productId != null)
          'product_id': event.productId.toString(),
      };

      final res = await getResponse(
        url: AppUrls.priceTiers,
        context: event.context,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      // Decode JSON string
      final Map<String, dynamic> json = jsonDecode(res) as Map<String, dynamic>;

      if (json['results'] != null && json['results'] is List) {
        final List<PriceTierModel> priceTiers = (json['results'] as List)
            .map((e) => PriceTierModel.fromJson(e))
            .toList();

        emit(PriceTierListLoaded(priceTiers: priceTiers));
      } else {
        emit(const PriceTierListLoaded(priceTiers: []));
      }
    } catch (error, st) {
      print('❌ LoadPriceTiers Error: $error');
      print(st);
      emit(PriceTierOperationFailed(error: error.toString()));
    }
  }


  Future<void> _onFetchAvailableSaleModes(
      FetchAvailableSaleModes event,
      Emitter<PriceTierState> emit,
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


  Future<void> _onAddPriceTier(
      AddPriceTier event,
      Emitter<PriceTierState> emit,
      ) async {
    emit(PriceTierOperationLoading());

    try {
      // Add debug logging
      print('🔄 Creating price tier with data: ${event.priceTier}');
      print('📱 productSaleMode value: ${event.priceTier}');
      print('📱 productSaleMode type: ${event.priceTier.runtimeType}');

      final res = await postResponse(
        url: AppUrls.priceTiers,
        payload: event.priceTier,
      );

      final jsonString = jsonEncode(res);
      ApiResponse response = appParseJson(
        jsonString,
            (data) => PriceTierModel.fromJson(data),
      );

      if (response.success == true) {
        final newPriceTier = response.data as PriceTierModel;
        priceTiers.add(newPriceTier);
        priceTiers.sort((a, b) => (a.minQuantity ?? 0).compareTo(b.minQuantity ?? 0));

        emit(PriceTierOperationSuccess(
          message: 'Price tier added successfully',
          priceTier: newPriceTier,
        ));

        // Also update the list state
        emit(PriceTierListLoaded(priceTiers: List.from(priceTiers)));
      } else {
        emit(PriceTierOperationFailed(
          error: response.message ?? 'Failed to add price tier',
        ));
      }
    } catch (error) {
      print('❌ Error adding price tier: $error');
      emit(PriceTierOperationFailed(error: error.toString()));
    }
  }
  Future<void> _onUpdatePriceTier(
      UpdatePriceTier event,
      Emitter<PriceTierState> emit,
      ) async {
    emit(PriceTierLoading());

    try {
      final res = await patchResponse(
        url: '${AppUrls.priceTiers}${event.priceTier}/',
        payload: event.priceTier,
      );

      final jsonString = jsonEncode(res);
      ApiResponse response = appParseJson(
        jsonString,
            (data) => PriceTierModel.fromJson(data),
      );

      if (response.success == true) {
        final updatedPriceTier = response.data as PriceTierModel;
        final index = priceTiers.indexWhere((pt) => pt.id == updatedPriceTier.id);
        if (index != -1) {
          priceTiers[index] = updatedPriceTier;
          priceTiers.sort((a, b) => (a.minQuantity ?? 0).compareTo(b.minQuantity ?? 0));
        }

        emit(PriceTierOperationSuccess(
          message: 'Price tier updated successfully',
          priceTier: updatedPriceTier,
        ));

        // Also update the list state
        emit(PriceTierListLoaded(priceTiers: List.from(priceTiers)));
      } else {
        emit(PriceTierOperationFailed(
          error: response.message ?? 'Failed to update price tier',
        ));
      }
    } catch (error) {
      emit(PriceTierOperationFailed(error: error.toString()));
    }
  }

  Future<void> _onDeletePriceTier(
      DeletePriceTier event,
      Emitter<PriceTierState> emit,
      ) async {
    emit(PriceTierLoading());

    try {
      final res = await deleteResponse(
        url: '${AppUrls.priceTiers}${event.id}/',
      );

      final jsonString = jsonEncode(res);
      ApiResponse response = appParseJson(
        jsonString,
            (data) => data,
      );

      if (response.success == true) {
        priceTiers.removeWhere((pt) => pt.id == event.id);

        emit(PriceTierOperationSuccess(
          message: 'Price tier deleted successfully',
        ));

        // Also update the list state
        emit(PriceTierListLoaded(priceTiers: List.from(priceTiers)));
      } else {
        emit(PriceTierOperationFailed(
          error: response.message ?? 'Failed to delete price tier',
        ));
      }
    } catch (error) {
      emit(PriceTierOperationFailed(error: error.toString()));
    }
  }

  Future<void> _onCalculatePrice(
      CalculatePrice event,
      Emitter<PriceTierState> emit,
      ) async {
    emit(PriceTierLoading());

    try {
      final res = await postResponse(
        url: '${AppUrls.priceTiers}calculate_price/',
        payload: {
          'product_sale_mode_id': event.productSaleModeId,
          'quantity': event.quantity,
        },
      );

      final jsonString = jsonEncode(res);
      ApiResponse response = appParseJson(
        jsonString,
            (data) => data,
      );

      if (response.success == true && response.data != null) {
        final calculationData = response.data as Map<String, dynamic>;
        final price = calculationData['calculated_price']?.toDouble() ?? 0.0;

        emit(PriceCalculated(
          price: price,
          calculationData: calculationData,
        ));
      } else {
        emit(PriceTierOperationFailed(
          error: response.message ?? 'Failed to calculate price',
        ));
      }
    } catch (error) {
      emit(PriceTierOperationFailed(error: error.toString()));
    }
  }

  void _onClearPriceTiers(
      ClearPriceTiers event,
      Emitter<PriceTierState> emit,
      ) {
    priceTiers.clear();
    emit(PriceTierListLoaded(priceTiers: []));
  }
}