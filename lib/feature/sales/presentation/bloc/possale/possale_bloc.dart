import '../../../../../core/configs/configs.dart';
import '../../../../../core/repositories/delete_response.dart';
import '../../../../../core/repositories/get_response.dart';
import '../../../../common/data/models/api_response_mod.dart';
import '../../../../common/data/models/app_parse_json.dart';
import '../../../data/models/pos_sale_model.dart';

part 'possale_event.dart';

part 'possale_state.dart';

class PosSaleBloc extends Bloc<PosSaleEvent, PosSaleState> {
  List<String> posTypeList = ["Sale", "Pos Sale"];
  List<PosSaleModel> list = [];

  PosSaleBloc() : super(PosSaleInitial()) {
    on<FetchPosSaleList>(_onFetchPosSaleList);
    on<FetchCustomerSaleList>(_onFetchCustomerSaleList);
  }

  Future<void> _onFetchPosSaleList(
    FetchPosSaleList event,
    Emitter<PosSaleState> emit,
  ) async {
    emit(PosSaleListLoading());
    list = [];

    try {
      final res = await getResponse(
        url: AppUrls.posSale + (event.dropdownFilter ?? ''),
        context: event.context,
      );

      // Parse and wrap response with ApiResponse
      ApiResponse response = appParseJson(
        res,
        (data) =>
            List<PosSaleModel>.from(data.map((x) => PosSaleModel.fromJson(x))),
      );

      if (response.success == true) {
        final data = response.data ?? [];

        if (data.isEmpty) {
          emit(PosSaleListFailed(title: "Error", content: "No data found"));
          return;
        }
        list=data;

        emit(PosSaleListSuccess(list: data));
      } else {
        emit(
          PosSaleListFailed(
            title: "Error",
            content: response.message ?? "Unknown error occurred",
          ),
        );
      }
    } catch (error, st) {
      print(error);
      print(st);
      emit(PosSaleListFailed(title: "Exception", content: error.toString()));
    }
  }

  Future<void> _onFetchCustomerSaleList(
      FetchCustomerSaleList event,
      Emitter<PosSaleState> emit,
      ) async {
    emit(PosSaleListLoading());
    list = [];

    try {
      final res = await getResponse(
        url: AppUrls.baseUrl + (event.dropdownFilter ?? ''),
        context: event.context,
      );

      // Parse and wrap response with ApiResponse
      ApiResponse response = appParseJson(
        res,
            (data) =>
        List<PosSaleModel>.from(data.map((x) => PosSaleModel.fromJson(x))),
      );

      if (response.success == true) {
        final data = response.data ?? [];

        if (data.isEmpty) {
          emit(PosSaleListFailed(title: "Error", content: "No data found"));
          return;
        }
        list=data;

        emit(PosSaleListSuccess(list: data));
      } else {
        emit(
          PosSaleListFailed(
            title: "Error",
            content: response.message ?? "Unknown error occurred",
          ),
        );
      }
    } catch (error, st) {
      print(error);
      print(st);
      emit(PosSaleListFailed(title: "Exception", content: error.toString()));
    }
  }

}
