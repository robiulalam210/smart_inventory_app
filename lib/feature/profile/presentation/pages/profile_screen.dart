import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:meherinMart/feature/auth/presentation/pages/login_scr.dart';
import 'package:path/path.dart' as p;

import '../../../../core/configs/configs.dart';
import '../../../../core/database/auth_db.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/show_custom_toast.dart';
import '../../../common/presentation/cubit/theme_cubit.dart';
import '../../data/model/profile_perrmission_model.dart';
import '../../data/service/image_upload_service.dart';
import '../bloc/profile_bloc/profile_bloc.dart';
import '../widget/company_info.dart';
import '../widget/show_theme_color_bottom_sheet.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  int _currentSection = 0;

  // Image upload state (reused from mobile)
  final ImagePicker _picker = ImagePicker();
  final ImageUploadService _uploadService = ImageUploadService();
  bool _isUploading = false;
  double _uploadProgress = 0.0;

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
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);
    final themeCubit = context.read<ThemeCubit>();
    final themeState = context.watch<ThemeCubit>().state;
    final primary = themeState.primaryColor;
    final iconBg = primary.withValues(alpha: 0.11);

    return Container(
      color: AppColors.bottomNavBg(context),
      child: SafeArea(
        child: ResponsiveRow(
          children: [
            if (isBigScreen) _buildSidebar(),
            _buildContentArea(isBigScreen, themeCubit, themeState, primary, iconBg),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() => ResponsiveCol(
    xs: 0,
    sm: 1,
    md: 1,
    lg: 2,
    xl: 2,
    child: Container(color: Colors.white, child: const Sidebar()),
  );

  Widget _buildContentArea(bool isBigScreen, ThemeCubit themeCubit, ThemeState themeState, Color primary, Color iconBg) {
    final themeCubit = context.read<ThemeCubit>();
    final themeState = context.watch<ThemeCubit>().state;

    final primary = themeState.primaryColor;
    final iconBg = primary.withValues(alpha: 0.11);
    return ResponsiveCol(
      xs: 12,
      lg: 10,
      child: RefreshIndicator(
        onRefresh: () async {
          _loadProfileData();
        },
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            child: BlocConsumer<ProfileBloc, ProfileState>(
              listener: (context, state) {
                _handleStateChanges(context, state);
              },
              builder: (context, state) {
                if (state is ProfilePermissionLoading) {
                  return _buildLoadingState();
                } else if (state is ProfilePermissionSuccess) {
                  _populateFormFields(state.permissionData);
                  return _buildDesktopLayout(state.permissionData, state, themeCubit, themeState, primary, iconBg);
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

  Widget _buildDesktopLayout(ProfilePermissionModel p, ProfileState state, ThemeCubit themeCubit, ThemeState themeState, Color primary, Color iconBg) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sidebar Navigation - Fixed width
        SizedBox(
          width: 280,
          child: Column(
            children: [
              // Profile Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Column(
                    children: [
                      _buildProfilePicture(p, isLarge: true),
                      const SizedBox(height: 20),
                      Text(
                        p.data?.user?.fullName ?? "No Name",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '@${p.data?.user?.username ?? "No Username"}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor(context)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          p.data?.user?.role
                              ?.replaceAll('_', ' ')
                              .toUpperCase() ??
                              "NO ROLE",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _showEditProfileDialog(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: iconBg,
                            elevation: 0,
                            foregroundColor: primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'edit_profile_details'.tr(),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Navigation Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      _buildDesktopNavItem(
                        title: 'profile_information'.tr(),
                        icon: Icons.person,
                        isActive: _currentSection == 0,
                        onTap: () => _setSection(0),
                      ),
                      _buildDesktopNavItem(
                        title: 'permissions'.tr(),
                        icon: Icons.security,
                        isActive: _currentSection == 1,
                        onTap: () => _setSection(1),
                      ),
                      _buildDesktopNavItem(
                        title: 'security'.tr(),
                        icon: Icons.lock,
                        isActive: _currentSection == 2,
                        onTap: () => _setSection(2),
                      ),
                      const Divider(),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor(context),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.color_lens, color: Colors.white, size: 18),
                        ),
                        title: Text('theme_color'.tr()),
                        onTap: () => showThemeColorBottomSheet(context, themeCubit, themeState.primaryColor),
                      ),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor(context),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.logout, color: Colors.white, size: 18),
                        ),
                        title: Text('logout'.tr()),
                        onTap: () {
                          appAdaptiveDialog(
                            context: context,
                            title: 'logout'.tr(),
                            message: 'are_you_sure_you_want_to_log_out'.tr(),
                            actions: [
                              AdaptiveDialogAction(text: 'cancel'.tr(), onPressed: () => Navigator.pop(context)),
                              AdaptiveDialogAction(
                                text: 'yes'.tr(),
                                isDestructive: true,
                                onPressed: () async {
                                  await AuthLocalDB.clear();
                                  if (!context.mounted) return;
                                  AppRoutes.pushAndRemoveUntil(context, LogInScreen());
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // Main Content - Flexible width
        Expanded(
          child: Stack(
            children: [
              // Main content (switcher for sections)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _currentSection == 0
                    ? _buildProfileForm(p, themeState, primary, iconBg)
                    : _currentSection == 1
                    ? _buildPermissionsSection(state)
                    : _buildSecuritySection(),
              ),

              // Upload overlay (shows while uploading)
              if (_isUploading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.45),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 12),
                          Text(
                            '${'uploading'.tr()} ${_uploadProgress > 0 ? '${(_uploadProgress * 100).toStringAsFixed(0)}%' : ''}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopNavItem({
    required String title,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryColor(context) : Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: isActive ? Colors.white : AppColors.primaryColor(context),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.primaryColor(context) : Colors.grey[700],
            fontSize: 14,
          ),
        ),
        tileColor: isActive ? AppColors.primaryColor(context).withValues(alpha: 0.1) : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isActive ? AppColors.primaryColor(context) : Colors.transparent,
            width: 1,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildProfilePicture(ProfilePermissionModel profile, { bool isLarge = false }) {
    final profilePicture = profile.data?.user?.profilePicture;
    final hasProfilePicture = profilePicture != null && profilePicture.isNotEmpty;

    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryColor(context), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[200],
            backgroundImage: hasProfilePicture ? NetworkImage(profilePicture) : null,
            child: hasProfilePicture ? null : Icon(Icons.person, size: 50, color: Colors.grey[400]),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              _showImagePickerOptions(allowCompanyLogo: profile.data?.companyInfo != null);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor(context),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileForm(ProfilePermissionModel pp, ThemeState themeState, Color primary, Color iconBg) {
    final profile = pp.data?.user;
    final themeCubit = context.read<ThemeCubit>();
    final themeState = context.watch<ThemeCubit>().state;

    final primary = themeState.primaryColor;

    return SingleChildScrollView(
      key: const ValueKey('profileForm'),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('profile_information'.tr(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('update_personal_info_desc'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 24),

                // Company info card (with upload)
                CompanyProfileCardWithUpload(
                  company: pp.data?.companyInfo,
                  onUpdated: _loadProfileData,
                ),
                const SizedBox(height: 24),

                // Two Column Layout for Form Fields
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column - Personal Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('personal_information'.tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primaryColor(context))),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              labelText: 'first_name'.tr(),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(Icons.person),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) => (value == null || value.isEmpty) ? 'please_enter_first_name'.tr() : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              labelText: 'last_name'.tr(),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(Icons.person_outline),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) => (value == null || value.isEmpty) ? 'please_enter_last_name'.tr() : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            initialValue: profile?.username ?? "",
                            decoration: InputDecoration(
                              labelText: 'username'.tr(),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(Icons.alternate_email),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            readOnly: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 32),

                    // Right Column - Contact Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('contact_information'.tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primaryColor(context))),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'email_address'.tr(),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(Icons.email),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'please_enter_email_address'.tr();
                              if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'please_enter_valid_email_address'.tr();
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'phone_number'.tr(),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(Icons.phone),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            initialValue: profile?.role?.replaceAll('_', ' ').toUpperCase() ?? "NO ROLE",
                            decoration: InputDecoration(
                              labelText: 'role'.tr(),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(Icons.work),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            readOnly: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Theme mode and color controls (desktop)
                ExpansionTile(
                  title: Text('theme_mode'.tr(), style: AppTextStyle.body(context)),
                  initiallyExpanded: false,
                  children: [
                    RadioGroup<ThemeMode>(
                      groupValue: themeState.themeMode,
                      onChanged: (val) async {
                        if (val == null) return;
                        themeCubit.setThemeMode(val);
                        final modeStr = val == ThemeMode.light ? 'light' : val == ThemeMode.dark ? 'dark' : 'system';
                        await AuthLocalDB.saveThemeMode(modeStr);
                      },
                      child: Column(
                        children: ThemeMode.values.map((mode) {
                          final text = mode == ThemeMode.light ? "Light" : mode == ThemeMode.dark ? "Dark" : "System";
                          return RadioListTile<ThemeMode>(
                            title: Text(text, style: AppTextStyle.body(context)),
                            value: mode,
                            activeColor: primary,
                            groupValue: themeState.themeMode,
                            onChanged: (val) {
                              if (val != null) {
                                themeCubit.setThemeMode(val);
                                final modeStr = val == ThemeMode.light ? 'light' : val == ThemeMode.dark ? 'dark' : 'system';
                                AuthLocalDB.saveThemeMode(modeStr);
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.11),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.palette, color: primary),
                      ),
                      title: Text('theme_color'.tr()),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: primary),
                      onTap: () => showThemeColorBottomSheet(context, themeCubit, themeState.primaryColor),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Language dropdown
                languageDropdown(context),

                const SizedBox(height: 20),

                // Update Button
                Row(
                  children: [
                    SizedBox(
                      width: 180,
                      child: AppButton(
                        name: 'update_profile'.tr(),
                        onPressed: _updateProfile,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 180,
                      child: AppButton(
                        name: 'change_password'.tr(),
                        onPressed: _showSecurityDialog,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 180,
                      child: AppButton(
                        name: 'permissions'.tr(),
                        onPressed: () => showPermissionsDialog(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionsSection(ProfileState state) {
    if (state is ProfilePermissionSuccess) {
      return _buildPermissionsList(state.permissionData);
    } else if (state is ProfilePermissionLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ProfilePermissionFailed) {
      return _buildErrorState(state, _loadProfileData);
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildPermissionsList(ProfilePermissionModel permissionData) {
    final permissions = permissionData.data?.permissions;

    return SingleChildScrollView(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('module_permissions'.tr(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('your_access_permissions'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 24),

              if (permissions != null)
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: [
                    _buildPermissionCard('dashboard'.tr(), Icons.dashboard, [
                      _buildPermissionItem('view'.tr(), permissions.dashboard?.view ?? false),
                    ]),
                    _buildPermissionCard('sales'.tr(), Icons.shopping_cart, [
                      _buildPermissionItem('view'.tr(), permissions.sales?.view ?? false),
                      _buildPermissionItem('create'.tr(), permissions.sales?.create ?? false),
                      _buildPermissionItem('edit'.tr(), permissions.sales?.edit ?? false),
                      _buildPermissionItem('delete'.tr(), permissions.sales?.delete ?? false),
                    ]),
                    _buildPermissionCard('money_receipt'.tr(), Icons.receipt, [
                      _buildPermissionItem('view'.tr(), permissions.moneyReceipt?.view ?? false),
                      _buildPermissionItem('create'.tr(), permissions.moneyReceipt?.create ?? false),
                      _buildPermissionItem('edit'.tr(), permissions.moneyReceipt?.edit ?? false),
                      _buildPermissionItem('delete'.tr(), permissions.moneyReceipt?.delete ?? false),
                    ]),
                    // Add more permission cards as needed
                  ],
                )
              else
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('no_permissions_data'.tr(), style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard(String title, IconData icon, List<Widget> permissions) {
    return SizedBox(
      width: 280,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor(context).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: AppColors.primaryColor(context), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(spacing: 8, runSpacing: 8, children: permissions),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem(String action, bool hasPermission) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: hasPermission ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: hasPermission ? Colors.green : Colors.red, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(hasPermission ? Icons.check_circle : Icons.cancel, size: 16, color: hasPermission ? Colors.green : Colors.red),
          const SizedBox(width: 6),
          Text(action, style: TextStyle(color: hasPermission ? Colors.green : Colors.red, fontWeight: FontWeight.w500, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return SingleChildScrollView(
      key: const ValueKey('securitySection'),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _passwordFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('change_password'.tr(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('update_password_desc'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 24),

                Center(
                  child: SizedBox(
                    width: 480,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _currentPasswordController,
                          decoration: InputDecoration(
                            labelText: 'current_password'.tr(),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.lock),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          obscureText: true,
                          validator: (value) => (value == null || value.isEmpty) ? 'please_enter_current_password'.tr() : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _newPasswordController,
                          decoration: InputDecoration(
                            labelText: 'new_password'.tr(),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.lock_outline),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'please_enter_new_password'.tr();
                            if (value.length < 6) return 'password_min_length_6'.tr();
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'confirm_new_password'.tr(),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.lock_reset),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'please_confirm_new_password'.tr();
                            if (value != _newPasswordController.text) return 'passwords_do_not_match'.tr();
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        BlocBuilder<ProfileBloc, ProfileState>(
                          builder: (context, state) {
                            return SizedBox(
                              width: 200,
                              child: AppButton(
                                name: state is PasswordChanging ? 'changing_password'.tr() : 'change_password'.tr(),
                                onPressed: state is PasswordChanging ? null : _changePassword,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Loading / Error ----------------

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(dynamic state, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(AppImages.noData, width: 200, height: 200),
          const SizedBox(height: 24),
          Text(state.title ?? 'Error'.tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
          const SizedBox(height: 12),
          SizedBox(width: 400, child: Text(state.content ?? 'something_went_wrong'.tr(), textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[600]))),
          const SizedBox(height: 24),
          AppButton(name: 'try_again'.tr(), onPressed: onRetry, width: 200),
        ],
      ),
    );
  }

  // ---------------- Form / Actions ----------------

  void _setSection(int index) {
    setState(() {
      _currentSection = index;
    });
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

      context.read<ProfileBloc>().add(UpdateUserProfile(profileData: profileData, context: context));
    }
  }

  void _changePassword() {
    if (_passwordFormKey.currentState!.validate()) {
      context.read<ProfileBloc>().add(ChangePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        context: context,
      ));
    }
  }

  void _clearPasswordFields() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  void _handleStateChanges(BuildContext context, ProfileState state) {
    if (state is ProfileUpdateSuccess) {
      _loadProfileData();
      showCustomToast(context: context, title: 'success'.tr(), description: 'profile_updated_successfully'.tr(), icon: Icons.check_circle, primaryColor: Colors.green);
    } else if (state is ProfileUpdateFailed) {
      _loadProfileData();
      showCustomToast(context: context, title: state.title, description: state.content, icon: Icons.error, primaryColor: Colors.red);
    } else if (state is PasswordChangeSuccess) {
      _loadProfileData();
      showCustomToast(context: context, title: 'success'.tr(), description: 'password_changed_successfully'.tr(), icon: Icons.check_circle, primaryColor: Colors.green);
      _clearPasswordFields();
    } else if (state is PasswordChangeFailed) {
      _loadProfileData();
      showCustomToast(context: context, title: state.title, description: state.content, icon: Icons.error, primaryColor: Colors.red);
    }
  }

  // ---------------- Image pick & upload (desktop) ----------------

  Future<void> _showImagePickerOptions({required bool allowCompanyLogo}) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text('choose_from_gallery'.tr()),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUpload(ImageSource.gallery, allowCompanyLogo: allowCompanyLogo);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text('take_photo'.tr()),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUpload(ImageSource.camera, allowCompanyLogo: allowCompanyLogo);
                },
              ),
              if (allowCompanyLogo) ...[
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.business),
                  title: Text('update_company_logo'.tr()),
                  subtitle: Text('update_company_logo_desc'.tr()),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAndUpload(ImageSource.gallery, forCompanyLogo: true);
                  },
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUpload(ImageSource source, { bool forCompanyLogo = false, bool allowCompanyLogo = true }) async {
    try {
      final XFile? picked = await _picker.pickImage(source: source, imageQuality: 85, maxWidth: 1600, maxHeight: 1600);
      if (picked == null) return;
      final file = File(picked.path);
      if (forCompanyLogo) {
        await _uploadCompanyLogo(file);
      } else {
        await _uploadUserProfilePicture(file);
      }
    } catch (e, st) {
      debugPrint('Image pick/upload failed: $e\n$st');
      showCustomToast(context: context, title: 'error'.tr(), description: 'image_upload_failed'.tr(), icon: Icons.error, primaryColor: Colors.red);
    }
  }

  Future<void> _uploadUserProfilePicture(File file) async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    final token = await LocalDB.getLoginInfo();
    if (token == null) {
      if (mounted) setState(() => _isUploading = false);
      showCustomToast(context: context, title: 'error'.tr(), description: 'auth_token_missing'.tr(), icon: Icons.error, primaryColor: Colors.red);
      return;
    }

    final filename = p.basename(file.path);
    final formData = FormData.fromMap({
      'profile_picture': await MultipartFile.fromFile(file.path, filename: filename),
    });

    final url = '${AppUrls.baseUrlMain}/api/user/profile-picture/';

    try {
      final response = await _uploadService.uploadWithPatchFallback(
        url: url,
        token: token['token'],
        formData: formData,
        onProgress: (sent, total) {
          if (total != -1) if (mounted) setState(() => _uploadProgress = sent / total);
        },
      );

      debugPrint('Upload response code: ${response?.statusCode}');
      debugPrint('Upload response data: ${response?.data}');

      if (response != null && response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        // Clear cache so new image is fetched
        try {
          PaintingBinding.instance.imageCache.clear();
          PaintingBinding.instance.imageCache.clearLiveImages();
        } catch (_) {}
        _loadProfileData();
        showCustomToast(context: context, title: 'success'.tr(), description: 'profile_picture_updated'.tr(), icon: Icons.check_circle, primaryColor: Colors.green);
      } else {
        final msg = response?.data != null && response?.data['message'] != null ? response?.data['message'].toString() : 'upload_failed'.tr();
        showCustomToast(context: context, title: 'error'.tr(), description: msg ?? 'upload_failed'.tr(), icon: Icons.error, primaryColor: Colors.red);
      }
    } on DioError catch (dioErr) {
      debugPrint('DioError during user upload: ${dioErr.type} ${dioErr.message}');
      debugPrint('Response: ${dioErr.response?.statusCode} ${dioErr.response?.data}');
      final friendly = (dioErr.response?.statusCode == 404) ? 'not_found_endpoint'.tr() : (dioErr.message ?? 'image_upload_failed'.tr());
      showCustomToast(context: context, title: 'error'.tr(), description: friendly, icon: Icons.error, primaryColor: Colors.red);
    } catch (e, st) {
      debugPrint('Unexpected error during user upload: $e\n$st');
      showCustomToast(context: context, title: 'error'.tr(), description: 'image_upload_failed'.tr(), icon: Icons.error, primaryColor: Colors.red);
    } finally {
      if (mounted) setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
    }
  }

  Future<void> _uploadCompanyLogo(File file) async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    final token = await LocalDB.getLoginInfo();
    if (token == null) {
      if (mounted) setState(() => _isUploading = false);
      showCustomToast(context: context, title: 'error'.tr(), description: 'auth_token_missing'.tr(), icon: Icons.error, primaryColor: Colors.red);
      return;
    }

    final filename = p.basename(file.path);
    final formData = FormData.fromMap({
      'logo': await MultipartFile.fromFile(file.path, filename: filename),
    });

    final url = '${AppUrls.baseUrlMain}/api/company/logo/';

    try {
      final response = await _uploadService.uploadWithPatchFallback(
        url: url,
        token: token['token'],
        formData: formData,
        onProgress: (sent, total) {
          if (total != -1) if (mounted) setState(() => _uploadProgress = sent / total);
        },
      );

      debugPrint('Company upload response code: ${response?.statusCode}');
      debugPrint('Company upload data: ${response?.data}');

      if (response != null && response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        try {
          PaintingBinding.instance.imageCache.clear();
          PaintingBinding.instance.imageCache.clearLiveImages();
        } catch (_) {}
        _loadProfileData();
        showCustomToast(context: context, title: 'success'.tr(), description: 'company_logo_updated'.tr(), icon: Icons.check_circle, primaryColor: Colors.green);
      } else {
        final msg = response?.data != null && response?.data['message'] != null ? response?.data['message'].toString() : 'upload_failed'.tr();
        showCustomToast(context: context, title: 'error'.tr(), description: msg ?? 'upload_failed'.tr(), icon: Icons.error, primaryColor: Colors.red);
      }
    } on DioError catch (dioErr) {
      debugPrint('DioError during company upload: ${dioErr.type} ${dioErr.message}');
      debugPrint('Response: ${dioErr.response?.statusCode} ${dioErr.response?.data}');
      final friendly = (dioErr.response?.statusCode == 404) ? 'not_found_endpoint'.tr() : (dioErr.message ?? 'image_upload_failed'.tr());
      showCustomToast(context: context, title: 'error'.tr(), description: friendly, icon: Icons.error, primaryColor: Colors.red);
    } catch (e, st) {
      debugPrint('Unexpected error during company upload: $e\n$st');
      showCustomToast(context: context, title: 'error'.tr(), description: 'image_upload_failed'.tr(), icon: Icons.error, primaryColor: Colors.red);
    } finally {
      if (mounted) setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
    }
  }

  // ---------------- Dialogs and helpers ----------------

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
      backgroundColor: AppColors.bottomNavBg(context),
      title: Text('edit_profile'.tr()),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'first_name'.tr(), prefixIcon: const Icon(Icons.person)),
                validator: (value) => (value == null || value.isEmpty) ? 'please_enter_first_name'.tr() : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'last_name'.tr(), prefixIcon: const Icon(Icons.person_outline)),
                validator: (value) => (value == null || value.isEmpty) ? 'please_enter_last_name'.tr() : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'email_address'.tr(), prefixIcon: const Icon(Icons.email)),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'please_enter_email_address'.tr();
                  if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'please_enter_valid_email_address'.tr();
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'phone_number'.tr(), prefixIcon: const Icon(Icons.phone)),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr())),
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

  void _showSecurityDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.bottomNavBg(context),
          title: Text('change_password'.tr()),
          content: SingleChildScrollView(
            child: Form(
              key: _passwordFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _currentPasswordController,
                    decoration: InputDecoration(labelText: 'current_password'.tr(), prefixIcon: const Icon(Icons.lock)),
                    obscureText: true,
                    validator: (value) => (value == null || value.isEmpty) ? 'please_enter_current_password'.tr() : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: InputDecoration(labelText: 'new_password'.tr(), prefixIcon: const Icon(Icons.lock_outline)),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'please_enter_new_password'.tr();
                      if (value.length < 6) return 'password_min_length_6'.tr();
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(labelText: 'confirm_new_password'.tr(), prefixIcon: const Icon(Icons.lock_reset)),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'please_confirm_new_password'.tr();
                      if (value != _newPasswordController.text) return 'passwords_do_not_match'.tr();
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr())),
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
                  child: state is PasswordChanging ? const CircularProgressIndicator() : Text('change_password'.tr()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showPermissionsDialog(BuildContext context) async {
    final state = context.read<ProfileBloc>().state;
    if (state is ProfilePermissionSuccess) {
      await showDialog(
        context: context,
        builder: (ctx) {
          return Dialog(
            child: SizedBox(
              width: 900,
              height: 600,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildPermissionsList(state.permissionData),
              ),
            ),
          );
        },
      );
    } else {
      // If permissions not loaded, trigger reload and show simple alert
      _loadProfileData();
      showCustomToast(context: context, title: 'info'.tr(), description: 'permissions_loading'.tr(), icon: Icons.info, primaryColor: Colors.blue);
    }
  }

  /// LANGUAGE DROPDOWN (desktop)
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
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.translate, color: Theme.of(context).colorScheme.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text('language'.tr(), style: AppTextStyle.body(context))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(color: AppColors.bottomNavBg(context), borderRadius: BorderRadius.circular(8)),
            child: DropdownButton<String>(
              value: currentCode,
              underline: const SizedBox(),
              dropdownColor: Theme.of(context).cardColor,
              icon: const Icon(Icons.arrow_drop_down),
              items: languages.entries.map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value, style: AppTextStyle.body(context)))).toList(),
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
}