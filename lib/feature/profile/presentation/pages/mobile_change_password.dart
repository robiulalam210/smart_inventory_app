import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meherinMart/core/configs/configs.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';
import 'package:meherinMart/core/widgets/show_custom_toast.dart';
import 'package:meherinMart/feature/profile/presentation/bloc/profile_bloc/profile_bloc.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // 验证状态
  bool _hasMinLength = false;
  bool _hasLettersAndNumbers = false;
  bool _isNotEmailOrName = true;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newPasswordController.removeListener(_validatePassword);
    super.dispose();
  }

  void _validatePassword() {
    final password = _newPasswordController.text;

    setState(() {
      _hasMinLength = password.length >= 6;
      _hasLettersAndNumbers =
          RegExp(r'[a-zA-Z]').hasMatch(password) &&
              RegExp(r'[0-9]').hasMatch(password);
      // 这里需要获取用户的实际email和name进行验证
      // 暂时设为true，实际应用中需要从用户数据中获取
      _isNotEmailOrName = true;
    });
  }

  void _changePassword() {
    if (_formKey.currentState!.validate()) {
      // 额外的密码强度验证
      if (!_hasMinLength) {
        showCustomToast(
          context: context,
          title: 'error'.tr(),
          description: 'password_min_length_6'.tr(),
          icon: Icons.error,
          primaryColor: Colors.red,
        );
        return;
      }

      if (!_hasLettersAndNumbers) {
        showCustomToast(
          context: context,
          title: 'error'.tr(),
          description: 'password_must_contain_letters_and_numbers'.tr(),
          icon: Icons.error,
          primaryColor: Colors.red,
        );
        return;
      }

      context.read<ProfileBloc>().add(
        ChangePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
          context: context,
        ),
      );
    }
  }

  void _clearFields() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    setState(() {
      _hasMinLength = false;
      _hasLettersAndNumbers = false;
    });
  }

  String? _validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'please_enter_current_password'.tr();
    }
    if (value.length < 6) {
      return 'password_min_length_6'.tr();
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'please_enter_new_password'.tr();
    }
    if (value.length < 6) {
      return 'password_min_length_6'.tr();
    }
    if (!RegExp(r'[a-zA-Z]').hasMatch(value) || !RegExp(r'[0-9]').hasMatch(value)) {
      return 'password_must_contain_letters_and_numbers'.tr();
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'please_confirm_new_password'.tr();
    }
    if (value != _newPasswordController.text) {
      return 'passwords_do_not_match'.tr();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return AppScaffold(
      appBar: AppBar(
        title: Text('change_password'.tr()),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'update_your_password'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'choose_a_strong_password_to_keep_your_account_secure'.tr(),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.black45,
                ),
              ),
              const SizedBox(height: 30),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Current Password
                        _buildPasswordSection(
                          title: 'current_password'.tr(),
                          controller: _currentPasswordController,
                          obscureText: _obscureCurrentPassword,
                          hintText: 'enter_current_password'.tr(),
                          onToggleObscure: () {
                            setState(() {
                              _obscureCurrentPassword = !_obscureCurrentPassword;
                            });
                          },
                          validator: _validateCurrentPassword,
                        ),
                        const SizedBox(height: 24),

                        // New Password
                        _buildPasswordSection(
                          title: 'new_password'.tr(),
                          controller: _newPasswordController,
                          obscureText: _obscureNewPassword,
                          hintText: 'enter_new_password'.tr(),
                          onToggleObscure: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                          validator: _validateNewPassword,
                        ),
                        const SizedBox(height: 24),

                        // Confirm New Password
                        _buildPasswordSection(
                          title: 'confirm_new_password'.tr(),
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          hintText: 're_enter_new_password'.tr(),
                          onToggleObscure: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                          validator: _validateConfirmPassword,
                        ),
                        const SizedBox(height: 30),

                        // Password Requirements
                        _buildPasswordRequirements(),
                        const SizedBox(height: 40),

                        // Change Password Button
                        BlocConsumer<ProfileBloc, ProfileState>(
                          listener: (context, state) {
                            if (state is PasswordChangeSuccess) {
                              showCustomToast(
                                context: context,
                                title: 'success'.tr(),
                                description: 'password_changed_successfully'.tr(),
                                icon: Icons.check_circle,
                                primaryColor: Colors.green,
                              );
                              _clearFields();
                              Future.delayed(const Duration(milliseconds: 1500), () {
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              });
                            } else if (state is PasswordChangeFailed) {
                              showCustomToast(
                                context: context,
                                title: state.title,
                                description: state.content,
                                icon: Icons.error,
                                primaryColor: Colors.red,
                              );
                            }
                          },
                          builder: (context, state) {
                            final isLoading = state is PasswordChanging;

                            return SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _changePassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                    : Text(
                                  'change_password'.tr(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordSection({
    required String title,
    required TextEditingController controller,
    required bool obscureText,
    required String hintText,
    required VoidCallback onToggleObscure,
    required String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: IconButton(
              onPressed: onToggleObscure,
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'password_requirements'.tr(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildRequirementItem(
            checked: _hasMinLength,
            text: 'at_least_6_characters'.tr(),
          ),
          _buildRequirementItem(
            checked: _hasLettersAndNumbers,
            text: 'contains_letters_and_numbers'.tr(),
          ),
          _buildRequirementItem(
            checked: _isNotEmailOrName,
            text: 'not_your_email_or_name'.tr(),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem({required bool checked, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            checked ? Icons.check_circle : Icons.radio_button_unchecked,
            color: checked ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: checked
                    ? Theme.of(context).textTheme.bodyMedium?.color
                    : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}