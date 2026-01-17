import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path/path.dart' as p;

import 'package:meherinMart/core/widgets/app_scaffold.dart';
import 'package:meherinMart/feature/auth/presentation/pages/mobile_login_scr.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/database/auth_db.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/show_custom_toast.dart';
import '../../../common/presentation/cubit/theme_cubit.dart';
import '../../data/model/profile_perrmission_model.dart';
import '../../data/service/image_upload_service.dart';
import '../bloc/profile_bloc/profile_bloc.dart';
import '../widget/company_info.dart';
import '../widget/show_theme_color_bottom_sheet.dart';
import '../widget/user_profile.dart';
import 'buildPermissionModules.dart';

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

  bool _isUploading = false;
  double _uploadProgress = 0.0;

  final ImagePicker _picker = ImagePicker();
  final ImageUploadService _uploadService = ImageUploadService();

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

  // ---------------- Image pick & upload UI ----------------

  Future<void> _showImagePickerOptions({required bool allowCompanyLogo}) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text('choose_from_gallery'.tr()),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUpload(
                    ImageSource.gallery,
                    allowCompanyLogo: allowCompanyLogo,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text('take_photo'.tr()),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUpload(
                    ImageSource.camera,
                    allowCompanyLogo: allowCompanyLogo,
                  );
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

  Future<void> _pickAndUpload(
    ImageSource source, {
    bool forCompanyLogo = false,
    bool allowCompanyLogo = true,
  }) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (picked == null) return;

      final file = File(picked.path);

      if (forCompanyLogo) {
        await _uploadCompanyLogo(file);
      } else {
        await _uploadUserProfilePicture(file);
      }
    } catch (e, st) {
      debugPrint('Image pick/upload failed: $e\n$st');
      showCustomToast(
        context: context,
        title: 'error'.tr(),
        description: 'image_upload_failed'.tr(),
        icon: Icons.error,
        primaryColor: Colors.red,
      );
    }
  }

  Future<void> _uploadUserProfilePicture(File file) async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    final token = await LocalDB.getLoginInfo();
    if (token == null) {
      setState(() => _isUploading = false);
      showCustomToast(
        context: context,
        title: 'error'.tr(),
        description: 'auth_token_missing'.tr(),
        icon: Icons.error,
        primaryColor: Colors.red,
      );
      return;
    }

    final filename = p.basename(file.path);
    final formData = FormData.fromMap({
      'profile_picture': await MultipartFile.fromFile(
        file.path,
        filename: filename,
      ),
    });

    final url = '${AppUrls.baseUrlMain}/api/user/profile-picture/';

    try {
      final response = await _uploadService.uploadWithPatchFallback(
        url: url,
        token: token['token'],
        formData: formData,
        onProgress: (sent, total) {
          if (total != -1) setState(() => _uploadProgress = sent / total);
        },
      );

      debugPrint('Upload response code: ${response?.statusCode}');
      debugPrint('Upload response data: ${response?.data}');

      if (response != null &&
          response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        // Clear image cache so updated avatar is fetched immediately
        try {
          PaintingBinding.instance.imageCache.clear();
          PaintingBinding.instance.imageCache.clearLiveImages();
        } catch (_) {}

        _loadProfileData();
        showCustomToast(
          context: context,
          title: 'success'.tr(),
          description: 'profile_picture_updated'.tr(),
          icon: Icons.check_circle,
          primaryColor: Colors.green,
        );
      } else {
        final msg = response?.data != null && response?.data['message'] != null
            ? response?.data['message'].toString()
            : 'upload_failed'.tr();
        showCustomToast(
          context: context,
          title: 'error'.tr(),
          description: msg ?? 'upload_failed'.tr(),
          icon: Icons.error,
          primaryColor: Colors.red,
        );
      }
    } on DioError catch (dioErr) {
      debugPrint(
        'DioError during user upload: ${dioErr.type} ${dioErr.message}',
      );
      debugPrint(
        'Response: ${dioErr.response?.statusCode} ${dioErr.response?.data}',
      );
      final friendly = (dioErr.response?.statusCode == 404)
          ? 'not_found_endpoint'.tr()
          : (dioErr.message ?? 'image_upload_failed'.tr());
      showCustomToast(
        context: context,
        title: 'error'.tr(),
        description: friendly,
        icon: Icons.error,
        primaryColor: Colors.red,
      );
    } catch (e, st) {
      debugPrint('Unexpected error during user upload: $e\n$st');
      showCustomToast(
        context: context,
        title: 'error'.tr(),
        description: 'image_upload_failed'.tr(),
        icon: Icons.error,
        primaryColor: Colors.red,
      );
    } finally {
      setState(() {
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
      setState(() => _isUploading = false);
      showCustomToast(
        context: context,
        title: 'error'.tr(),
        description: 'auth_token_missing'.tr(),
        icon: Icons.error,
        primaryColor: Colors.red,
      );
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
          if (total != -1) {
            setState(() => _uploadProgress = sent / total);
          }
        },
      );

      debugPrint('Company upload response code: ${response?.statusCode}');
      debugPrint('Company upload data: ${response?.data}');

      if (response != null &&
          response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        // Clear image cache so updated logo is fetched immediately
        try {
          PaintingBinding.instance.imageCache.clear();
          PaintingBinding.instance.imageCache.clearLiveImages();
        } catch (_) {}

        _loadProfileData();
        showCustomToast(
          context: context,
          title: 'success'.tr(),
          description: 'company_logo_updated'.tr(),
          icon: Icons.check_circle,
          primaryColor: Colors.green,
        );
      } else {
        final msg = response?.data != null && response?.data['message'] != null
            ? response?.data['message'].toString()
            : 'upload_failed'.tr();
        showCustomToast(
          context: context,
          title: 'error'.tr(),
          description: msg ?? 'upload_failed'.tr(),
          icon: Icons.error,
          primaryColor: Colors.red,
        );
      }
    } on DioError catch (dioErr) {
      debugPrint(
        'DioError during company upload: ${dioErr.type} ${dioErr.message}',
      );
      debugPrint(
        'Response: ${dioErr.response?.statusCode} ${dioErr.response?.data}',
      );
      final friendly = (dioErr.response?.statusCode == 404)
          ? 'not_found_endpoint'.tr()
          : (dioErr.message ?? 'image_upload_failed'.tr());
      showCustomToast(
        context: context,
        title: 'error'.tr(),
        description: friendly,
        icon: Icons.error,
        primaryColor: Colors.red,
      );
    } catch (e, st) {
      debugPrint('Unexpected error during company upload: $e\n$st');
      showCustomToast(
        context: context,
        title: 'error'.tr(),
        description: 'image_upload_failed'.tr(),
        icon: Icons.error,
        primaryColor: Colors.red,
      );
    } finally {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
    }
  }

  // ---------------- UI & other handlers ----------------

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
        child: Stack(
          children: [
            RefreshIndicator(
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
                              GestureDetector(
                                onTap: () {
                                  _showImagePickerOptions(
                                    allowCompanyLogo:
                                        my.data?.companyInfo != null,
                                  );
                                },
                                child: buildDoctorAvatar(
                                  isMan: true,
                                  imageUrl: "${my.data?.user?.profilePicture}",
                                  fullName: my.data?.user?.fullName ?? '',
                                  context: context,
                                  isDoctor: true,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  if (my.data?.companyInfo != null) {
                                    _showImagePickerOptions(
                                      allowCompanyLogo: true,
                                    );
                                  }
                                },
                                child: Container(
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
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
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
                          const SizedBox(height: 8),
                          CompanyProfileCardWithUpload(
                            company: state.permissionData.data?.companyInfo,
                            onUpdated: _loadProfileData,
                          ),
                          const SizedBox(height: 10),

                          // Quick Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: _buildQuickActionButton(
                                  icon: Icons.security,
                                  label: "permissions".tr(),
                                  color: primary,
                                  onTap: () => showPermissionsDialog(context),
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

                          // Theme mode and color, language, menu items...
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
                                  Text(
                                    'theme_mode'.tr(),
                                    style: AppTextStyle.body(context),
                                  ),
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
                                        title: Text(
                                          text,
                                          style: AppTextStyle.body(context),
                                        ),
                                        value: mode,
                                        activeColor: primary,
                                        groupValue: themeState.themeMode,
                                        onChanged: (val) {
                                          if (val != null) {
                                            themeCubit.setThemeMode(val);
                                            final modeStr =
                                                val == ThemeMode.light
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

                          InkWell(
                            onTap: () => showThemeColorBottomSheet(
                              context,
                              themeCubit,
                              themeState.primaryColor,
                            ),
                            child: Row(
                              children: [
                                _iconBox(Icons.palette, primary, iconBg),
                                const SizedBox(width: 8),
                                Text(
                                  "theme_color".tr(),
                                  style: AppTextStyle.body(context),
                                ),
                                const Spacer(),
                                Builder(
                                  builder: (context) {
                                    final currentColor = context
                                        .watch<ThemeCubit>()
                                        .state
                                        .primaryColor;
                                    final colorMap = colors.firstWhere(
                                      (c) =>
                                          c['color'].value ==
                                          currentColor.value,
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
                                            border: Border.all(
                                              color: Colors.black12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          colorMap['name'],
                                          style: AppTextStyle.body(context),
                                        ),
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

                          languageDropdown(context),

                          InkWell(
                            onTap: () {
                              // TODO
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
                              // TODO
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
                                message: "are_you_sure_you_want_to_log_out"
                                    .tr(),
                                actions: [
                                  AdaptiveDialogAction(
                                    text: "cancel".tr(),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  AdaptiveDialogAction(
                                    text: "yes".tr(),
                                    isDestructive: true,
                                    onPressed: () async {
                                      await AuthLocalDB.clear();
                                      if (!context.mounted) return;
                                      AppRoutes.pushAndRemoveUntil(
                                        context,
                                        MobileLoginScr(),
                                      );
                                    },
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
            // Upload overlay
            if (_isUploading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.4),
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
    );
  }

  // ---------------- UI helpers ----------------

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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
      backgroundColor: AppColors.bottomNavBg(context),
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
                validator: (value) => (value == null || value.isEmpty)
                    ? 'please_enter_first_name'.tr()
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'last_name'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'please_enter_last_name'.tr()
                    : null,
              ),
              const SizedBox(height: 8),
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
                  if (!RegExp(
                    r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'please_enter_valid_email_address'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
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
                    decoration: InputDecoration(
                      labelText: 'current_password'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'please_enter_current_password'.tr()
                        : null,
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
                      if (value.length < 6) return 'password_min_length_6'.tr();
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

  // ---------------- Profile update handlers ----------------

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
            Icon(Icons.error_outline, size: 64, color: Colors.red),
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
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: AppButton(name: "try_again".tr(), onPressed: onRetry),
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
              items: languages.entries
                  .map(
                    (entry) => DropdownMenuItem(
                      value: entry.key,
                      child: Text(
                        entry.value,
                        style: AppTextStyle.body(context),
                      ),
                    ),
                  )
                  .toList(),
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
