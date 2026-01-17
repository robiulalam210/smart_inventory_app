
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/configs/configs.dart';
import '../../data/model/profile_perrmission_model.dart';
import '../bloc/profile_bloc/profile_bloc.dart';

class PermissionAction {
  final String label;
  final bool allowed;

  PermissionAction(this.label, this.allowed);
}

class PermissionModule {
  final String title;
  final IconData icon;
  final List<PermissionAction> actions;

  PermissionModule({
    required this.title,
    required this.icon,
    required this.actions,
  });
}

List<PermissionModule> buildPermissionModules(ProfilePermissionModel data) {
  final p = data.data?.permissions;
  if (p == null) return [];

  return [
    PermissionModule(
      title: 'dashboard'.tr(),
      icon: Icons.dashboard,
      actions: [
        PermissionAction('view'.tr(), p.dashboard?.view ?? false),
      ],
    ),

    PermissionModule(
      title: 'sales'.tr(),
      icon: Icons.shopping_cart,
      actions: _crudActions(p.moneyReceipt),
    ),

    PermissionModule(
      title: 'money_receipt'.tr(),
      icon: Icons.receipt,
      actions: _crudActions(p.moneyReceipt),
    ),

    PermissionModule(
      title: 'accounts'.tr(),
      icon: Icons.account_balance,
      actions: _crudActions(p.accounts),
    ),

    PermissionModule(
      title: 'reports'.tr(),
      icon: Icons.bar_chart,
      actions: [
        PermissionAction('view'.tr(), p.reports?.view ?? false),
        PermissionAction('create'.tr(), p.reports?.create ?? false),
        PermissionAction('export'.tr(), p.reports?.reportsExport ?? false),
      ],
    ),

    PermissionModule(
      title: 'settings'.tr(),
      icon: Icons.settings,
      actions: [
        PermissionAction('view'.tr(), p.settings?.view ?? false),
        PermissionAction('edit'.tr(), p.settings?.edit ?? false),
      ],
    ),
  ];
}
List<PermissionAction> _crudActions(dynamic module) {
  if (module == null) return [];

  return [
    PermissionAction('view'.tr(), module.view ?? false),
    PermissionAction('create'.tr(), module.create ?? false),
    PermissionAction('edit'.tr(), module.edit ?? false),
    PermissionAction('delete'.tr(), module.delete ?? false),
  ];
}


void showPermissionsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfilePermissionSuccess) {
            return _buildPermissionsDialog(state.permissionData,context);
          }
          return const Center(child: CircularProgressIndicator());
        },
      );
    },
  );
}

Widget _buildPermissionsDialog(ProfilePermissionModel permissionData,BuildContext context) {
  final modules = buildPermissionModules(permissionData);

  return AlertDialog(
    backgroundColor: AppColors.bottomNavBg(context),
    title: Text('module_permissions'.tr()),
    content: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'module_permissions_desc'.tr(),
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 16),

          if (modules.isEmpty)
            emptyPermissionView()
          else
            ...modules.map((module) => buildPermissionModuleView(module, context)),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('close'.tr()),
      ),
    ],
  );
}
Widget buildPermissionModuleView(PermissionModule module,BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(module.icon, size: 20,color: AppColors.text(context),),
            const SizedBox(width: 8),
            Text(
              module.title,
              style:  TextStyle(
                fontWeight: FontWeight.w600,color: AppColors.text(context),
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: module.actions.map((a) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  a.allowed ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: a.allowed ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(a.label,style: AppTextStyle.body(context),),
              ],
            );
          }).toList(),
        ),
      ],
    ),
  );
}
Widget emptyPermissionView() {
  return Center(
    child: Column(
      children: [
        Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
        const SizedBox(height: 12),
        Text(
          'no_permissions_data'.tr(),
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    ),
  );
}