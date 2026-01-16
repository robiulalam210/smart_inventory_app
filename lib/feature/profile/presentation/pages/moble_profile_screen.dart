import 'package:easy_localization/easy_localization.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';
import 'package:meherinMart/feature/auth/presentation/pages/mobile_login_scr.dart';
import '../../../../core/configs/configs.dart';
import '../../../../core/database/auth_db.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/show_custom_toast.dart';
import '../../../common/presentation/cubit/theme_cubit.dart';
import '../../data/model/profile_perrmission_model.dart';
import '../bloc/profile_bloc/profile_bloc.dart';
import '../widget/user_profile.dart';

final List<Map<String, dynamic>> colors = const [
  {'color': Color(0xff60DAFF), 'name': 'Default'},
  {'color': Color(0xff69B128), 'name': 'Default 2'},
  {'color': Colors.red, 'name': 'Red'},
  {'color': Colors.pink, 'name': 'Pink'},
  {'color': Colors.purple, 'name': 'Purple'},
  {'color': Colors.deepPurple, 'name': 'Deep Purple'},
  {'color': Colors.indigo, 'name': 'Indigo'},
  {'color': Colors.blue, 'name': 'Blue'},
  {'color': Colors.lightBlue, 'name': 'Light Blue'},
  {'color': Colors.cyan, 'name': 'Cyan'},
  {'color': Colors.teal, 'name': 'Teal'},
  {'color': Colors.green, 'name': 'Green'},
  {'color': Colors.lightGreen, 'name': 'Light Green'},
  {'color': Colors.lime, 'name': 'Lime'},
  {'color': Colors.yellow, 'name': 'Yellow'},
  {'color': Colors.amber, 'name': 'Amber'},
  {'color': Colors.orange, 'name': 'Orange'},
  {'color': Colors.deepOrange, 'name': 'Deep Orange'},
  {'color': Colors.brown, 'name': 'Brown'},
  {'color': Colors.grey, 'name': 'Grey'},
  {'color': Colors.blueGrey, 'name': 'Blue Grey'},
  {'color': Colors.black, 'name': 'Black'},
  {'color': Colors.white, 'name': 'White'},
];

class MobileProfileScreen extends StatefulWidget {
  const MobileProfileScreen({super.key});

  @override
  State<MobileProfileScreen> createState() => _MobileProfileScreenState();
}

class _MobileProfileScreenState extends State<MobileProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _currentPasswordController =
  TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    context.read<ProfileBloc>().add(FetchProfilePermission(context: context));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    final themeState = context.watch<ThemeCubit>().state;

    final primary = themeState.primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBg = primary.withOpacity(0.11);

    return AppScaffold(
      appBar: AppBar(
        title: const Text("profile").tr(),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _loadProfileData(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _loadProfileData();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: BlocConsumer<ProfileBloc, ProfileState>(
              listener: (context, state) {
                _handleStateChanges(context, state);
              },
              builder: (context, state) {
                if (state is ProfilePermissionLoading) {
                  return _buildLoadingState();
                } else if (state is ProfilePermissionSuccess) {
                  final my = state.permissionData;
                  _populateFormFields(state.permissionData);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildDoctorAvatar(
                            isMan: (my.data?.user?.username ?? "")
                                .toLowerCase()
                                .startsWith('m'),
                            imageUrl: my.data?.user?.profilePicture,
                            fullName: my.data?.user?.fullName ?? '',
                            context: context,
                            isDoctor: true,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 110,
                            height: 30,
                            decoration: BoxDecoration(
                              color: iconBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                "change_image".tr(),
                                style: TextStyle(
                                  color: primary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            my.data?.user?.username ?? '',
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            my.data?.user?.fullName ?? '',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            my.data?.user?.email ?? '',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _showEditProfileDialog(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: iconBg,
                                elevation: 0,
                                foregroundColor: primary,
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                "edit_profile_details".tr(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Quick Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionButton(
                              icon: Icons.security,
                              label: "permissions".tr(),
                              color: primary,
                              onTap: () => _showPermissionsDialog(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionButton(
                              icon: Icons.lock,
                              label: "security".tr(),
                              color: primary,
                              onTap: () => _showSecurityDialog(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      /// THEME MODE
                      Theme(
                        data: ThemeData(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          iconColor: primary,
                          collapsedIconColor: primary,
                          title: Row(
                            children: [
                              _iconBox(Icons.palette, primary, iconBg),
                              const SizedBox(width: 8),
                              Text('theme_mode'.tr(),
                                  style: AppTextStyle.body(context)),
                            ],
                          ),
                          children: [
                            RadioGroup<ThemeMode>(
                              groupValue: themeState.themeMode,
                              onChanged: (val) async {
                                if (val == null) return;
                                themeCubit.setThemeMode(val);
                                final modeStr = val == ThemeMode.light
                                    ? 'light'
                                    : val == ThemeMode.dark
                                    ? 'dark'
                                    : 'system';
                                await AuthLocalDB.saveThemeMode(modeStr);
                              },
                              child: Column(
                                children: ThemeMode.values.map((mode) {
                                  final text = mode == ThemeMode.light
                                      ? "Light"
                                      : mode == ThemeMode.dark
                                      ? "Dark"
                                      : "System";
                                  return RadioListTile<ThemeMode>(
                                    title: Text(text,
                                        style: AppTextStyle.body(context)),
                                    value: mode,
                                    activeColor: primary,
                                    groupValue: themeState.themeMode,
                                    onChanged: (val) {
                                      if (val != null) {
                                        themeCubit.setThemeMode(val);
                                        final modeStr = val == ThemeMode.light
                                            ? 'light'
                                            : val == ThemeMode.dark
                                            ? 'dark'
                                            : 'system';
                                        AuthLocalDB.saveThemeMode(modeStr);
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      /// THEME COLOR
                      InkWell(
                        onTap: () => _showThemeColorBottomSheet(
                          context,
                          themeCubit,
                          themeState.primaryColor,
                        ),
                        child: Row(
                          children: [
                            _iconBox(Icons.palette, primary, iconBg),
                            const SizedBox(width: 8),
                            Text("theme_color".tr(),
                                style: AppTextStyle.body(context)),
                            const Spacer(),
                            Builder(
                              builder: (context) {
                                final currentColor = context
                                    .watch<ThemeCubit>()
                                    .state
                                    .primaryColor;
                                final colorMap = colors.firstWhere(
                                      (c) => c['color'].value == currentColor.value,
                                  orElse: () => {
                                    'color': currentColor,
                                    'name': 'Custom',
                                  },
                                );
                                return Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: colorMap['color'],
                                        shape: BoxShape.circle,
                                        border:
                                        Border.all(color: Colors.black12),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(colorMap['name'],
                                        style: AppTextStyle.body(context)),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 16,
                                      color: primary,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      /// MENU ITEMS
                      languageDropdown(context),

                      InkWell(
                        onTap: () {
                          // TODO: Implement emergency support
                        },
                        child: _menuItem(
                          Icons.health_and_safety_rounded,
                          "emergency_support".tr(),
                          iconBg,
                          primary,
                          context,
                        ),
                      ),

                      InkWell(
                        onTap: () {
                          // TODO: Implement privacy policy
                        },
                        child: _menuItem(
                          Icons.shield_outlined,
                          "privacy_policy".tr(),
                          iconBg,
                          primary,
                          context,
                        ),
                      ),

                      InkWell(
                        onTap: () {
                          appAdaptiveDialog(
                            context: context,
                            title: "logout".tr(),
                            message: "are_you_sure_you_want_to_log_out".tr(),
                            actions: [
                              AdaptiveDialogAction(
                                text: "cancel".tr(),
                                onPressed: () => Navigator.pop(context),
                              ),
                              AdaptiveDialogAction(
                                text: "yes".tr(),
                                isDestructive: true,
                                onPressed: ()async {
                                  await AuthLocalDB.clear();
                                  if (!context.mounted) return;
                                  AppRoutes.pushAndRemoveUntil(context, MobileLoginScr());                                },
                              ),
                            ],
                          );
                        },
                        child: _menuItem(
                          Icons.logout,
                          "logout".tr(),
                          iconBg,
                          primary,
                          context,
                        ),
                      ),
                    ],
                  );
                } else if (state is ProfilePermissionFailed) {
                  return _buildErrorState(state, _loadProfileData);
                }
                return _buildLoadingState();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfilePermissionSuccess) {
              return _buildProfileDialog(state.permissionData);
            }
            return const Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }

  Widget _buildProfileDialog(ProfilePermissionModel pp) {
    return AlertDialog(
      title: Text('edit_profile'.tr()),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'first_name'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please_enter_first_name'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'last_name'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please_enter_last_name'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'email_address'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please_enter_email_address'.tr();
                  }
                  if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'please_enter_valid_email_address'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'phone_number'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _updateProfile();
              Navigator.pop(context);
            }
          },
          child: Text('update'.tr()),
        ),
      ],
    );
  }

  void _showPermissionsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfilePermissionSuccess) {
              return _buildPermissionsDialog(state.permissionData);
            }
            return const Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }

  Widget _buildPermissionsDialog(ProfilePermissionModel permissionData) {
    final permissions = permissionData.data?.permissions;

    return AlertDialog(
      title: Text('module_permissions'.tr()),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'module_permissions_desc'.tr(),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),

            if (permissions != null) ...[
              _buildDialogPermissionItem(
                'dashboard'.tr(),
                Icons.dashboard,
                permissions.dashboard?.view ?? false,
              ),
              const SizedBox(height: 12),
              _buildDialogPermissionItem(
                'sales',
                Icons.shopping_cart,
                [
                  _buildPermissionItem('view'.tr(),
                      permissions.moneyReceipt?.view ?? false),
                  _buildPermissionItem('create'.tr(),
                      permissions.moneyReceipt?.create ?? false),
                  _buildPermissionItem('edit'.tr(),
                      permissions.moneyReceipt?.edit ?? false),
                  _buildPermissionItem('delete'.tr(),
                      permissions.moneyReceipt?.delete ?? false),
                ],
              ),
              const SizedBox(height: 12),
              _buildDialogPermissionItem(
                'money_receipt'.tr(),
                Icons.receipt,
                [
                  _buildPermissionItem('view'.tr(),
                      permissions.moneyReceipt?.view ?? false),
                  _buildPermissionItem('create'.tr(),
                      permissions.moneyReceipt?.create ?? false),
                  _buildPermissionItem('edit'.tr(),
                      permissions.moneyReceipt?.edit ?? false),
                  _buildPermissionItem('delete'.tr(),
                      permissions.moneyReceipt?.delete ?? false),
                ],
              ),
            ] else
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'no_permissions_data'.tr(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
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

  Widget _buildDialogPermissionItem(
      String title,
      IconData icon,
      dynamic permissions,
      ) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (permissions is bool)
              _buildPermissionItem(
                  permissions ? 'allowed'.tr() : 'denied'.tr(), permissions)
            else if (permissions is List<Widget>)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: permissions,
              ),
          ],
        ),
      ),
    );
  }

  void _showSecurityDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('change_password'.tr()),
          content: SingleChildScrollView(
            child: Form(
              key: _passwordFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _currentPasswordController,
                    decoration: InputDecoration(
                      labelText: 'current_password'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'please_enter_current_password'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: InputDecoration(
                      labelText: 'new_password'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'please_enter_new_password'.tr();
                      }
                      if (value.length < 6) {
                        return 'password_min_length_6'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'confirm_new_password'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.lock_reset),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'please_confirm_new_password'.tr();
                      }
                      if (value != _newPasswordController.text) {
                        return 'passwords_do_not_match'.tr();
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
            BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: state is PasswordChanging
                      ? null
                      : () {
                    if (_passwordFormKey.currentState!.validate()) {
                      _changePassword();
                      Navigator.pop(context);
                    }
                  },
                  child: state is PasswordChanging
                      ? const CircularProgressIndicator()
                      : Text('change_password'.tr()),
                );
              },
            ),
          ],
        );
      },
    );
  }



  void _handleStateChanges(BuildContext context, ProfileState state) {
    if (state is ProfileUpdateSuccess) {
      _loadProfileData();
      showCustomToast(
        context: context,
        title: 'success'.tr(),
        description: 'profile_updated_successfully'.tr(),
        icon: Icons.check_circle,
        primaryColor: Colors.green,
      );
    } else if (state is ProfileUpdateFailed) {
      _loadProfileData();
      showCustomToast(
        context: context,
        title: state.title,
        description: state.content,
        icon: Icons.error,
        primaryColor: Colors.red,
      );
    } else if (state is PasswordChangeSuccess) {
      _loadProfileData();
      showCustomToast(
        context: context,
        title: 'success'.tr(),
        description: 'password_changed_successfully'.tr(),
        icon: Icons.check_circle,
        primaryColor: Colors.green,
      );
      _clearPasswordFields();
    } else if (state is PasswordChangeFailed) {
      _loadProfileData();
      showCustomToast(
        context: context,
        title: state.title,
        description: state.content,
        icon: Icons.error,
        primaryColor: Colors.red,
      );
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(50),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(dynamic state, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              state.title ?? 'Error'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              state.content ?? 'something_went_wrong'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: AppButton(
                name: "try_again".tr(),
                onPressed: onRetry,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _populateFormFields(ProfilePermissionModel p) {
    final profile = p.data?.user;
    if (_firstNameController.text != profile?.firstName) {
      _firstNameController.text = profile?.firstName ?? "";
    }
    if (_lastNameController.text != profile?.lastName) {
      _lastNameController.text = profile?.lastName ?? "";
    }
    if (_emailController.text != profile?.email) {
      _emailController.text = profile?.email ?? "";
    }
    if (_phoneController.text != profile?.phone) {
      _phoneController.text = profile?.phone ?? "";
    }
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      final profileData = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
      };

      context.read<ProfileBloc>().add(
        UpdateUserProfile(profileData: profileData, context: context),
      );
    }
  }

  void _changePassword() {
    if (_passwordFormKey.currentState!.validate()) {
      context.read<ProfileBloc>().add(
        ChangePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
          context: context,
        ),
      );
    }
  }

  void _clearPasswordFields() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'update_profile_picture'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'update_profile_picture_desc'.tr(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text('choose_from_gallery'.tr()),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement gallery image picker
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text('take_photo'.tr()),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement camera image picker
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

Widget _menuItem(
    IconData icon,
    String label,
    Color bg,
    Color iconColor,
    BuildContext context,
    ) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(width: 13),
        Expanded(child: Text(label, style: AppTextStyle.body(context))),
      ],
    ),
  );
}

Widget _iconBox(IconData icon, Color color, Color bg) {
  return Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, color: color),
  );
}

Widget _buildPermissionItem(String action, bool hasPermission) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: hasPermission
          ? Colors.green.withOpacity(0.1)
          : Colors.red.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: hasPermission ? Colors.green : Colors.red,
        width: 1,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          hasPermission ? Icons.check_circle : Icons.cancel,
          size: 14,
          color: hasPermission ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 6),
        Text(
          action,
          style: TextStyle(
            color: hasPermission ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
        ),
      ],
    ),
  );
}

void _showThemeColorBottomSheet(
    BuildContext context,
    ThemeCubit themeCubit,
    Color currentColor,
    ) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    backgroundColor: isDark ? const Color(0xFF23272B) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'choose_theme_color'.tr(),
              style:  TextStyle(
                fontSize: 18,
                color: AppColors.text(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: colors.map((c) {
                final selected = c['color'].value == currentColor.value;
                return GestureDetector(
                  onTap: () async {
                    themeCubit.setPrimaryColor(c['color']);
                    await AuthLocalDB.savePrimaryColor(
                        c['color'].value.toString());
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: c['color'],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? c['color']
                                : Colors.grey.shade300,
                            width: selected ? 3 : 1,
                          ),
                        ),
                        child: selected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        c['name'],
                        style: TextStyle(
                          fontSize: 10,
                          color: selected
                              ? c['color']
                              : isDark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}

/// LANGUAGE DROPDOWN
Widget languageDropdown(BuildContext context) {
  final Map<String, String> languages = {'en': 'English', 'bn': 'বাংলা'};

  final currentCode = context.locale.languageCode;

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.11),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.translate,
            color: Theme.of(context).colorScheme.primary,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text("language".tr(), style: AppTextStyle.body(context)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: AppColors.bottomNavBg(context),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: currentCode,
            underline: const SizedBox(),
            dropdownColor: Theme.of(context).cardColor,
            icon: const Icon(Icons.arrow_drop_down),
            items: languages.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value, style: AppTextStyle.body(context)),
              );
            }).toList(),
            onChanged: (value) async {
              if (value != null) {
                context.setLocale(Locale(value));
                await AuthLocalDB.saveLanguage(value);
              }
            },
          ),
        ),
      ],
    ),
  );
}