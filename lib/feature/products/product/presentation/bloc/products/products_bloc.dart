

import '../../../../../../core/configs/configs.dart';
import '../../../../../../core/repositories/delete_response.dart';
import '../../../../../../core/repositories/get_response.dart';
import '../../../../../common/data/models/api_response_mod.dart';
import '../../../../../common/data/models/app_parse_json.dart';
import '../../../../categories/presentation/bloc/categories/categories_bloc.dart';
import '../../../../unit/presentation/bloc/unit/unti_bloc.dart';
import '../../../data/model/product_model.dart';

part 'products_event.dart';

part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  List<ProductModel> list = [];
  final int _itemsPerPage = 15;
  String selectedState = "";
  List<String> statesList = ["Active", "Inactive"];

  TextEditingController productNameController = TextEditingController();
  TextEditingController productPurchasePriceController =
      TextEditingController(text: "0");
  TextEditingController productSellingPriceController =
      TextEditingController(text: "0");
  TextEditingController productOpeningStockController =
      TextEditingController(text: "0");
  TextEditingController productAlertQuantityController =
      TextEditingController(text: "5");
  TextEditingController productDescriptionController = TextEditingController();
  TextEditingController productBarCodeController = TextEditingController();

  TextEditingController filterTextController = TextEditingController();

  clearDataAll(BuildContext context) {
    context.read<UnitBloc>().selectedState = "";
    context.read<CategoriesBloc>().selectedState = "";
    context.read<UnitBloc>().selectedState = "";
    // context.read<InventoryListBloc>().selectedLocation = "";
  }

  ProductsBloc() : super(ProductsInitial()) {
    on<FetchProductsList>(_onFetchProductList);
    on<AddProducts>(_onCreateProductList);
    on<UpdateProducts>(_onUpdateProductList);
    on<DeleteProducts>(_onDeleteProductList);
  }

  Future<void> _onFetchProductList(
      FetchProductsList event,
      Emitter<ProductsState> emit,
      ) async {
    emit(ProductsListLoading());

    try {
      final res = await getResponse(
        url: AppUrls.product,
        context: event.context,
      );

      // Parse API response
      ApiResponse response = appParseJson(
        res,
            (data) => List<ProductModel>.from(
          data.map((x) => ProductModel.fromJson(x)),
        ),
      );

      // ✅ success check
      if (response.success == true) {
        print(response.success);
        print(response.data);
        // Store product list
        list = response.data;

        // Filter and paginate






        emit(ProductsListSuccess(
          list: list,
          totalPages: 1,
          currentPage: event.pageNumber,
        ));
      } else {
        emit(ProductsListFailed(
          title: "Error",
          content: response.message ?? "Unknown Error",
        ));
      }
    } catch (error,st) {

      print(error);
      print(st);
      emit(ProductsListFailed(
        title: "Error",
        content: error.toString(),
      ));
    }
  }

// ✅ Cleaner filter method
  List<ProductModel> _filterProduct(
      List<ProductModel> list,
      String filterText,
      String state,
      String category,
      ) {
    return list.where((product) {
      final matchesText = filterText.isEmpty ||
          (product.name?.toLowerCase().contains(filterText.toLowerCase()) ?? false);

      final matchesCategory = category.isEmpty ||
          (product.name?.toLowerCase() == category.toLowerCase());

      final matchesState = state.isEmpty ||
          (product.name?.toString() == (state == 'Active' ? '1' : '0'));

      return matchesText && matchesCategory && matchesState;
    }).toList();
  }

// ✅ Pagination stays same
  List<ProductModel> _paginatePage(List<ProductModel> list, int pageNumber) {
    final start = pageNumber * _itemsPerPage;
    final end = start + _itemsPerPage;
    if (start >= list.length) return [];
    return list.sublist(start, end > list.length ? list.length : end);
  }

  Future<void> _onCreateProductList(
      AddProducts event, Emitter<ProductsState> emit) async {
    emit(ProductsAddLoading());

    try {
      // final res = await addProductService(
      //   payload: event.body!, url: AppUrls.product, photoPath: event.photoPath,
      //   // photoPath: event.photoPath!
      // ); // Use the correct API URL

      // ApiResponse response = appParseJson(
      //   res,
      //   (data) =>
      //       List<ProductModel>.from(data.map((x) => ProductModel.fromJson(x))),
      // );
      // if (response.success == false) {
      //   emit(ProductsAddFailed(title: '', content: response.message ?? ""));
      //   return;
      // }
      clearData();
      emit(ProductsAddSuccess());
    } catch (error) {
      clearData();
      emit(ProductsAddFailed(title: "Error", content: error.toString()));
    }
  }

  Future<void> _onUpdateProductList(
      UpdateProducts event, Emitter<ProductsState> emit) async {
    emit(ProductsAddLoading());

    try {
      // final res = await updateService(
      //   payload: event.body!,
      //   url: "${AppUrls.product}/${event.id}",
      //   photoPath: event.photoPath,
      //   // photoPath: event.photoPath!
      // ); // Use the correct API URL
      //
      // ApiResponse response = appParseJson(
      //   res,
      //   (data) =>
      //       List<ProductModel>.from(data.map((x) => ProductModel.fromJson(x))),
      // );
      // if (response.success == false) {
      //   emit(ProductsAddFailed(title: '', content: response.message ?? ""));
      //   return;
      // }
      clearData();
      emit(ProductsAddSuccess());
    } catch (error) {
      clearData();
      emit(ProductsAddFailed(title: "Error", content: error.toString()));
    }
  }

  clearData() {
    productNameController.clear();
    productBarCodeController.clear();
    productPurchasePriceController.clear();
    productSellingPriceController.clear();
    productOpeningStockController.clear();
    productAlertQuantityController.clear();
    productDescriptionController.clear();
    // cat
  }

  Future<void> _onDeleteProductList(
      DeleteProducts event, Emitter<ProductsState> emit) async {
    emit(ProductsDeleteLoading());

    try {
      final res = await deleteResponse(
          url:
              "${AppUrls.product}/${event.id.toString()}"); // Use the correct API URL

      ApiResponse response = appParseJson(
        res,
        (data) =>
            List<ProductModel>.from(data.map((x) => ProductModel.fromJson(x))),
      );
      if (response.success == false) {
        emit(ProductsDeleteFailed(
            title: 'Json', content: response.message ?? ""));
        return;
      }
      //  clearData();
      emit(ProductsDeleteSuccess());
    } catch (error) {
      // clearData();
      emit(ProductsDeleteFailed(title: "Error", content: error.toString()));
    }
  }
}

// class ProductDetailsBloc
//     extends Bloc<FetchProductDetailsList, ProductDetailsState> {
// // Changed to InventoryProductDetailsModel
//   String selectedWarehouse = "";
//
//   ProductDetailsBloc() : super(ProductDetailsInitial()) {
//     on<FetchProductDetailsList>(_onFetchInventoryProductDetails);
//   }
//
//   Future<void> _onFetchInventoryProductDetails(
//       FetchProductDetailsList event, Emitter<ProductDetailsState> emit) async {
//     emit(ProductDetailsLoading());
//
//     try {
//       // Fetch the warehouse product details
//       final warehouseRes = await getResponse(
//           url: "${AppUrls.product}/${event.id.toString()}",
//           context: event.context);
//       ApiResponse<ProductDetailsModel> warehouseResponse =
//           appParseJson<ProductDetailsModel>(
//         warehouseRes,
//         (data) => ProductDetailsModel.fromJson(data),
//       );
//
//       final warehouseData = warehouseResponse.data;
//
//       if (warehouseData == null) {
//         emit(ProductDetailsFailed(title: "Error", content: "No Data"));
//         return;
//       }
//
//       emit(ProductDetailsSuccess(productDetailsModel: warehouseData));
//     } catch (error) {
//       emit(ProductDetailsFailed(title: "Error", content: error.toString()));
//     }
//   }
// }
