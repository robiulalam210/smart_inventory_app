


import '../../../../../core/configs/configs.dart';
import '../../../../../core/repositories/get_response.dart';
import '../../../../common/data/models/api_response_mod.dart';
import '../../../../common/data/models/app_parse_json.dart';
import '../../../data/model/user_model.dart';

part 'user_event.dart';

part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  List<UsersListModel> list = [];
  bool isChecked = false;

  UsersListModel? usersListModel;
  final int _itemsPerPage = 10;
  String selectedState = "";
  List<String> statesList = ["Active", "Inactive"];
  String selectedBloodGroup = "";

  List<String> bloodGroupList = [
    "A+",
    "A-",
    "B+",
    "B-",
    "AB+",
    "AB-",
    "O+",
    "O-"
  ];
  TextEditingController userNameController = TextEditingController();
  TextEditingController userEmailController = TextEditingController();
  TextEditingController userPhoneController = TextEditingController();
  TextEditingController userDesignationController = TextEditingController();
  TextEditingController userSalaryController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();
  TextEditingController userDOBController = TextEditingController();
  TextEditingController userAppointmentController = TextEditingController();
  TextEditingController userJoiningController = TextEditingController();
  TextEditingController userCommissionController = TextEditingController();
  TextEditingController userAddressController = TextEditingController();

  TextEditingController filterTextController = TextEditingController();


  UserBloc() : super(UserInitial()) {
    on<FetchUserList>(_onFetchUserList);

  }
  Future<void> _onFetchUserList(
      FetchUserList event, Emitter<UserState> emit) async {
    emit(UserListLoading());

    try {
      final res = await getResponse(
        url: AppUrls.administrationUser + event.dropdownFilter,
        context: event.context,
      );

      // Parse JSON response using your appParseJson helper
      ApiResponse response = appParseJson(
        res,
            (data) => List<UsersListModel>.from(
          data.map((x) => UsersListModel.fromJson(x)),
        ),
      );

      final data = response.data;

      if (response.success == true && data != null) {
        List<UsersListModel> productList = List<UsersListModel>.from(data);

        if (productList.isEmpty) {
          emit(UserListSuccess(
            list: [],
            totalPages: 0,
            currentPage: event.pageNumber,
          ));
          return;
        }

        // Store and filter users
        list = productList;

        final filteredUser = _filterData(list, event.filterText);
        final safeItemsPerPage = _itemsPerPage > 0 ? _itemsPerPage : 1;
        final paginatedUser = _paginatePage(filteredUser, event.pageNumber);
        final totalPages = (filteredUser.length / safeItemsPerPage).ceil();

        emit(UserListSuccess(
          list: paginatedUser,
          totalPages: totalPages,
          currentPage: event.pageNumber,
        ));
      } else {
        emit(UserListFailed(
          title: "Error",
          content: response.message ?? "Unknown Error",
        ));
      }
    } catch (error) {
      emit(UserListFailed(title: "Error", content: error.toString()));
    }
  }

  List<UsersListModel> _filterData(
      List<UsersListModel> list, String filterText) {
    return list.where((data) {
      final matchesText = filterText.isEmpty ||
          data.username!
              .toLowerCase()
              .contains(filterText.toLowerCase()) ||
          data.email!
              .toLowerCase()
              .contains(filterText.toLowerCase()) ;

      return matchesText;
    }).toList();
  }

  List<UsersListModel> _paginatePage(
      List<UsersListModel> list, int pageNumber) {
    final start = pageNumber * _itemsPerPage;
    final end = start + _itemsPerPage;
    if (start >= list.length) return [];
    return list.sublist(
        start, end > list.length ? list.length : end);
  }



  void clearData() {
    userNameController.clear();
    userEmailController.clear();
    userPhoneController.clear();
    userDesignationController.clear();
    userDOBController.clear();
    userSalaryController.clear();
    userAppointmentController.clear();
    userCommissionController.clear();
    userJoiningController.clear();
    userAddressController.clear();

    selectedBloodGroup="";

  }
}
