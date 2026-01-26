


import 'package:equatable/equatable.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/repositories/delete_response.dart';
import '../../../../../core/repositories/get_response.dart';
import '../../../../../core/repositories/post_response.dart';
import '../../../../common/data/models/api_response_mod.dart';
import '../../../../common/data/models/app_parse_json.dart';
import '../../../../profile/presentation/pages/buildPermissionModules.dart' hide PermissionAction;
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

  // Permission management
  Map<String, PermissionActionUser> currentUserPermissions = {};
  UserModel? currentUserForPermissions;

  UserBloc() : super(UserInitial()) {
    on<FetchUserList>(_onFetchUserList);
    on<FetchUserPermissions>(_onFetchUserPermissions);
    on<UpdateUserPermissions>(_onUpdateUserPermissions);
    on<ResetUserPermissions>(_onResetUserPermissions);
    on<CheckPermission>(_onCheckPermission);
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

  Future<void> _onFetchUserPermissions(
      FetchUserPermissions event, Emitter<UserState> emit) async {
    emit(UserPermissionsLoading());

    try {
      // getResponse returns a String, not http.Response
      final responseString = await getResponse(
        url: '${AppUrls.userPermissions}/?user_id=${event.userId}',
        context: event.context,
      );

      print("Raw response string: $responseString");

      // Parse the string response
      final Map<String, dynamic> jsonResponse = json.decode(responseString);
      print("Parsed JSON: $jsonResponse");

      // Check if this is an error response from getResponse
      if (jsonResponse['success'] == false) {
        // This is an error response from getResponse itself
        emit(UserPermissionsFailed(
          title: jsonResponse['title'] ?? "Error",
          content: jsonResponse['message'] ?? "Failed to fetch permissions",
        ));
        return;
      }

      // If success is true, parse the actual API response
      if (jsonResponse['status'] == true) {
        final data = jsonResponse['data'] as Map<String, dynamic>;
        print("API Data: $data");

        // Create user from available data
        final user = UserModel(
          // id: event.userId,
          username: data['username'] as String? ?? 'Unknown',
          role: data['role'] as String? ?? '',
          permissionSource: data['permission_source'] as String? ?? 'ROLE',
          isSuperuser: data['is_superuser'] as bool? ?? false,
          isStaff: data['is_staff'] as bool? ?? false,
        );

        // Extract permissions
        Map<String, dynamic> permissions;
        if (data.containsKey('permissions')) {
          permissions = data['permissions'] as Map<String, dynamic>;
        } else {
          // Try to find permission-like fields
          permissions = {};
          data.forEach((key, value) {
            if (value is bool) {
              permissions[key] = value;
            }
          });
        }

        // Extract custom permissions if available
        List<UserPermissionModel> customPermissions = [];
        if (data.containsKey('custom_permissions')) {
          customPermissions = (data['custom_permissions'] as List<dynamic>)
              .map((x) => UserPermissionModel.fromJson(x as Map<String, dynamic>))
              .toList();
        }

        currentUserForPermissions = user;
        currentUserPermissions = _convertPermissionsToMap(permissions);

        emit(UserPermissionsSuccess(
          permissions: permissions,
          customPermissions: customPermissions,
          user: user,
        ));
      } else {
        emit(UserPermissionsFailed(
          title: "Error",
          content: jsonResponse['message'] ?? "Failed to fetch permissions",
        ));
      }
    } catch (error, st) {
      print("Error: $error");
      print("Stack trace: $st");
      emit(UserPermissionsFailed(
        title: "Error",
        content: error.toString(),
      ));
    }
  }



  Future<void> _onUpdateUserPermissions(
      UpdateUserPermissions event, Emitter<UserState> emit) async {
    emit(PermissionUpdateLoading());

    try {
      // Convert permissions to JSON
      final permissionsJson = {};
      event.permissions.forEach((module, action) {
        permissionsJson[module] = action.toJson();
      });

      final body = {
        'user_id': event.userId,
        'permissions': permissionsJson,
      };

      final res = await postResponse(
        url: AppUrls.updatePermissions,
      
        payload: body,
      );

      ApiResponse response = appParseJson(
        jsonEncode(res),
            (data) => UserModel.fromJson(data as Map<String, dynamic>),
      );

      if (response.success == true && response.data != null) {
        final user = response.data as UserModel;
        emit(PermissionUpdateSuccess(user: user));
      } else {
        emit(PermissionUpdateFailed(
          title: "Error",
          content: response.message ?? "Failed to update permissions",
        ));
      }
    } catch (error) {
      emit(PermissionUpdateFailed(
        title: "Error",
        content: error.toString(),
      ));
    }
  }

  Future<void> _onResetUserPermissions(
      ResetUserPermissions event, Emitter<UserState> emit) async {
    emit(PermissionResetLoading());

    try {
      final body = {
        'user_id': event.userId,
        'reset_to_default': true,
        'permissions': {},  // Send empty permissions object

        // Add this flag
      };

      // Change from deleteResponse to postResponse
      final res = await postResponse(
        url: AppUrls.updatePermissions,  // Use update endpoint instead of reset
        payload: body,
      );

      print("Reset permissions response: $res");

      ApiResponse response = appParseJson(
        jsonEncode(res),
            (data) {
          print("Reset parser data: $data");
          if (data is Map<String, dynamic>) {
            // Handle the response format
            if (data.containsKey('user')) {
              return UserModel.fromJson(data['user'] as Map<String, dynamic>);
            }
            return UserModel.fromJson(data);
          }
          return null;
        },
      );

      print("Reset API Response: ${response.success}, ${response.message}");

      if (response.success == true && response.data != null) {
        final user = response.data as UserModel;
        emit(PermissionResetSuccess(user: user));
      } else {
        emit(PermissionResetFailed(
          title: "Error",
          content: response.message ?? "Failed to reset permissions",
        ));
      }
    } catch (error, st) {
      print("Reset permissions error: $error");
      print("Stack trace: $st");
      emit(PermissionResetFailed(
        title: "Error",
        content: error.toString(),
      ));
    }
  }

  Future<void> _onCheckPermission(
      CheckPermission event, Emitter<UserState> emit) async {
    try {
      final body = {
        'module': event.module,
        if (event.action != null) 'action': event.action,
      };

      final res = await postResponse(
        url: AppUrls.checkPermission,
       
        payload
            : body,
      );

      ApiResponse response = appParseJson(
        jsonEncode(res),
            (data) => data['has_permission'] as bool,
      );

      if (response.success == true && response.data != null) {
        final hasPermission = response.data as bool;
        emit(PermissionCheckSuccess(hasPermission: hasPermission));
      } else {
        emit(PermissionCheckFailed(
          title: "Error",
          content: response.message ?? "Failed to check permission",
        ));
      }
    } catch (error) {
      emit(PermissionCheckFailed(
        title: "Error",
        content: error.toString(),
      ));
    }
  }

  Map<String, PermissionActionUser> _convertPermissionsToMap(Map<String, dynamic> permissions) {
    final Map<String, PermissionActionUser> result = {};

    permissions.forEach((module, modulePerms) {
      if (module == 'permission_source') return;

      if (modulePerms is Map<String, dynamic>) {
        result[module] = PermissionActionUser.fromJson(modulePerms);
      }
    });

    return result;
  }

  List<UsersListModel> _filterData(
      List<UsersListModel> list, String filterText) {
    return list.where((data) {
      final matchesText = filterText.isEmpty ||
          data.username!.toLowerCase().contains(filterText.toLowerCase()) ||
          data.email!.toLowerCase().contains(filterText.toLowerCase());

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
    selectedBloodGroup = "";
  }
}