import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../common/data/models/api_response_mod.dart';
import '../../../../common/data/models/app_parse_json.dart';
import '../../data/sale_mode_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:convert';

import '../../../../../../core/configs/configs.dart';
import '../../../../../../core/repositories/delete_response.dart';
import '../../../../../../core/repositories/get_response.dart';
import '../../../../../../core/repositories/patch_response.dart';
import '../../../../../../core/repositories/post_response.dart';

part 'sale_mode_event.dart';
part 'sale_mode_state.dart';

class SaleModeBloc extends Bloc<SaleModeEvent, SaleModeState> {
  List<SaleModeModel> saleModeModel = [];
  String selectedState = "Active";
  String selectedPriceType = "unit";
  String selectedId = "";
  TextEditingController filterTextController = TextEditingController();

  TextEditingController nameController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController conversionFactorController = TextEditingController();
  TextEditingController baseUnitController = TextEditingController();

  SaleModeBloc() : super(SaleModeInitial()) {
    on<FetchSaleModeList>(_onFetchSaleModeList);
    on<AddSaleMode>(_onCreateSaleModeList);
    on<UpdateSaleMode>(_onUpdateSaleModeList);
    on<DeleteSaleMode>(_onDeleteSaleModeList);
    on<ClearSaleModeData>(_onClearSaleModeData);
  }

  Future<void> _onFetchSaleModeList(
      FetchSaleModeList event,
      Emitter<SaleModeState> emit,
      ) async {
    emit(SaleModeListLoading());

    try {
      Map<String, dynamic> queryParams = {};
      if (event.baseUnitId != null && event.baseUnitId!.isNotEmpty) {
        queryParams['base_unit'] = event.baseUnitId;
      }

      final res = await getResponse(
        url: AppUrls.saleModes,
        context: event.context,
        queryParams: queryParams,
      );

      ApiResponse response = appParseJson(
        res,
            (data) =>
        List<SaleModeModel>.from(data.map((x) => SaleModeModel.fromJson(x))),
      );

      final data = response.data;
      if (data == null || data.isEmpty) {
        emit(
          SaleModeListSuccess(
            list: [],
            totalPages: 0,
            currentPage: event.pageNumber,
          ),
        );
        return;
      }

      saleModeModel = data;
      final filteredData = _filterSaleMode(saleModeModel, event.filterText);

      emit(
        SaleModeListSuccess(
          list: filteredData,
          totalPages: 1,
          currentPage: event.pageNumber,
        ),
      );
    } catch (error) {
      emit(SaleModeListFailed(title: "Error", content: error.toString()));
    }
  }

  List<SaleModeModel> _filterSaleMode(List<SaleModeModel> list, String filterText) {
    return list.where((data) {
      final matchesText = filterText.isEmpty ||
          (data.name?.toLowerCase().contains(filterText.toLowerCase()) ?? false) ||
          (data.code?.toLowerCase().contains(filterText.toLowerCase()) ?? false);
      return matchesText;
    }).toList();
  }

  Future<void> _onCreateSaleModeList(
      AddSaleMode event,
      Emitter<SaleModeState> emit,
      ) async {
    emit(SaleModeAddLoading());

    try {
      final res = await postResponse(
          url: AppUrls.saleModes,
          payload: event.body
      );

      final jsonString = jsonEncode(res);
      ApiResponse response = appParseJson(
        jsonString,
            (data) => SaleModeModel.fromJson(data),
      );

      if (response.success == false) {
        emit(SaleModeAddFailed(title: '', content: response.message ?? ""));
        return;
      }

      emit(SaleModeAddSuccess());
      clearData();
    } catch (error) {
      clearData();
      emit(SaleModeAddFailed(title: "Error", content: error.toString()));
    }
  }

  Future<void> _onUpdateSaleModeList(
      UpdateSaleMode event,
      Emitter<SaleModeState> emit,
      ) async {
    emit(SaleModeAddLoading());

    try {
      final res = await patchResponse(
        url: "${AppUrls.saleModes + event.id}/",
        payload: event.body!,
      );

      final jsonString = jsonEncode(res);
      ApiResponse response = appParseJson(
        jsonString,
            (data) => SaleModeModel.fromJson(data),
      );

      if (response.success == false) {
        emit(SaleModeAddFailed(title: 'Alert', content: response.message ?? ""));
        return;
      }

      clearData();
      emit(SaleModeAddSuccess());
    } catch (error) {
      clearData();
      emit(SaleModeAddFailed(title: "Error", content: error.toString()));
    }
  }

  Future<void> _onDeleteSaleModeList(
      DeleteSaleMode event,
      Emitter<SaleModeState> emit,
      ) async {
    emit(SaleModeDeleteLoading());

    try {
      final res = await deleteResponse(
        url: "${AppUrls.saleModes + event.id}/",
      );

      final jsonString = jsonEncode(res);
      ApiResponse response = appParseJson(
        jsonString,
            (data) => data,
      );

      if (response.success == false) {
        emit(SaleModeDeleteFailed(title: 'Json', content: response.message ?? ""));
        return;
      }

      clearData();
      emit(SaleModeDeleteSuccess(message: response.message ?? ""));
    } catch (error) {
      clearData();
      emit(SaleModeDeleteFailed(title: "Error", content: error.toString()));
    }
  }

  void _onClearSaleModeData(
      ClearSaleModeData event,
      Emitter<SaleModeState> emit,
      ) {
    clearData();
  }

  void clearData() {
    nameController.clear();
    codeController.clear();
    conversionFactorController.clear();
    baseUnitController.clear();
    selectedState = "Active";
    selectedPriceType = "unit";
    selectedId = "";
  }
}