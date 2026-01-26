import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meherinMart/core/configs/configs.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';
import '../../data/model/user_model.dart';
import '../bloc/users/user_bloc.dart';

class UserPermissionScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const UserPermissionScreen({
    Key? key,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  State<UserPermissionScreen> createState() => _UserPermissionScreenState();
}

class _UserPermissionScreenState extends State<UserPermissionScreen> {
  Map<String, PermissionActionUser> _permissions = {};
  UserModel? _currentUser;

  final List<String> _modules = [
    'dashboard',
    'sales',
    'money_receipt',
    'purchases',
    'products',
    'accounts',
    'customers',
    'suppliers',
    'expense',
    'return',
    'reports',
    'users',
    'administration',
    'settings',
  ];

  final Map<String, String> _moduleNames = {
    'dashboard': 'Dashboard',
    'sales': 'Sales',
    'money_receipt': 'Money Receipt',
    'purchases': 'Purchases',
    'products': 'Products',
    'accounts': 'Accounts',
    'customers': 'Customers',
    'suppliers': 'Suppliers',
    'expense': 'Expense',
    'return': 'Return',
    'reports': 'Reports',
    'users': 'Users',
    'administration': 'Administration',
    'settings': 'Settings',
  };

  @override
  void initState() {
    super.initState();
    _fetchPermissions();
  }

  void _fetchPermissions() {
    context.read<UserBloc>().add(
      FetchUserPermissions(context, widget.userId),
    ); context.read<UserBloc>().add(
      FetchUserList(context, ),
    );
  }

  void _updatePermission(String module, String action, bool value) {
    setState(() {
      if (!_permissions.containsKey(module)) {
        _permissions[module] = PermissionActionUser();
      }

      // Get current permission
      final current = _permissions[module]!;

      // Update based on action
      switch (action) {
        case 'view':
          _permissions[module] = current.copyWith(view: value);
          break;
        case 'create':
          _permissions[module] = current.copyWith(create: value);
          break;
        case 'edit':
          _permissions[module] = current.copyWith(edit: value);
          break;
        case 'delete':
          _permissions[module] = current.copyWith(delete: value);
          break;
        case 'create_pos':
          _permissions[module] = current.copyWith(createPos: value);
          break;
        case 'create_short':
          _permissions[module] = current.copyWith(createShort: value);
          break;
        case 'export':
          _permissions[module] = current.copyWith(export: value);
          break;
      }
    });
  }

  void _savePermissions() {
    if (_permissions.isNotEmpty) {
      context.read<UserBloc>().add(
        UpdateUserPermissions(context, widget.userId, _permissions),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No permissions to save')),
      );
    }
  }

  void _resetPermissions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Permissions'),
        content: const Text('Are you sure you want to reset all permissions to role defaults?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<UserBloc>().add(
                ResetUserPermissions(context, widget.userId),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Helper method to extract permissions from API response
  Map<String, PermissionActionUser> _extractPermissionsFromState(
      Map<String, dynamic> permissionsMap) {
    final result = <String, PermissionActionUser>{};

    permissionsMap.forEach((module, value) {
      if (module == 'permission_source') return;

      if (value is Map<String, dynamic>) {
        try {
          result[module] = PermissionActionUser.fromJson(value);
        } catch (e) {
          print('Error parsing permissions for $module: $e');
          result[module] = PermissionActionUser();
        }
      }
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text('Permissions - ${widget.userName}',style: AppTextStyle.titleMedium(context),),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchPermissions,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: _resetPermissions,
            tooltip: 'Reset to Role Defaults',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePermissions,
            tooltip: 'Save Permissions',
          ),
        ],
      ),
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserPermissionsSuccess) {
            // Update local permissions from API
            setState(() {
              _currentUser = state.user;
              _permissions = _extractPermissionsFromState(state.permissions);
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permissions loaded successfully')),
            );
          } else if (state is PermissionUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permissions updated successfully')),
            );
            _fetchPermissions(); // Refresh to get updated data
          } else if (state is PermissionResetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permissions reset to role defaults')),
            );
            _fetchPermissions(); // Refresh to get reset data
          } else if (state is PermissionUpdateFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.content)),
            );
          } else if (state is PermissionResetFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.content)),
            );
          } else if (state is UserPermissionsFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.content)),
            );
          }
        },
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserPermissionsLoading ||
                state is PermissionUpdateLoading ||
                state is PermissionResetLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserPermissionsFailed) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 60, color: Colors.red),
                    const SizedBox(height: 20),
                    Text(
                      state.content,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _fetchPermissions,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else {
              return _buildPermissionsList();
            }
          },
        ),
      ),
    );
  }

  Widget _buildPermissionsList() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info card
            Card(
              color: AppColors.bottomNavBg(context),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentUser?.fullName ??
                                _currentUser?.username ??
                                widget.userName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Role: ${_currentUser?.role ?? 'N/A'}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            'Permission Source: ${_currentUser?.permissionSource ?? 'ROLE'}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Permissions list
            ..._modules.map((module) {
              final moduleName = _moduleNames[module] ?? module;
              final permission = _permissions[module] ?? PermissionActionUser();

              return Card(   color: AppColors.bottomNavBg(context),
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Text(
                    moduleName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: _buildPermissionSummary(permission),
                  initiallyExpanded: false,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          // Basic permissions
                          _buildPermissionRow('View', module, 'view', permission.view),
                          _buildPermissionRow('Create', module, 'create', permission.create),
                          _buildPermissionRow('Edit', module, 'edit', permission.edit),
                          _buildPermissionRow('Delete', module, 'delete', permission.delete),

                          // Special permissions for sales
                          if (module == 'sales') ...[
                            const Divider(),
                            _buildPermissionRow('Create POS', module, 'create_pos', permission.createPos ?? false),
                            _buildPermissionRow('Create Short', module, 'create_short', permission.createShort ?? false),
                          ],

                          // Export permission for reports
                          if (module == 'reports') ...[
                            const Divider(),
                            _buildPermissionRow('Export', module, 'export', permission.export ?? false),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 40),

            // Save button at bottom
            if (_permissions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: _savePermissions,
                    icon: const Icon(Icons.save),
                    label: const Text('Save All Permissions'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionSummary(PermissionActionUser permission) {
    final activeCount = [
      permission.view,
      permission.create,
      permission.edit,
      permission.delete,
      permission.createPos,
      permission.createShort,
      permission.export,
    ].where((p) => p == true).length;

    return Text(
      '$activeCount permissions active',
      style: TextStyle(
        fontSize: 12,
        color: activeCount > 0 ? Colors.green : Colors.grey,
      ),
    );
  }

  Widget _buildPermissionRow(String label, String module, String action, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) => _updatePermission(module, action, newValue),
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}