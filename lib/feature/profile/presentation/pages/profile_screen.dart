
import '../../../../core/configs/configs.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/show_custom_toast.dart';
import '../../data/model/profile_perrmission_model.dart';
import '../bloc/profile_bloc/profile_bloc.dart';

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

  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  int _currentSection = 0;

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
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            _loadProfileData();
            showCustomToast(
              context: context,
              title: 'Success!',
              description: 'Profile updated successfully',
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
              title: 'Success!',
              description: 'Password changed successfully',
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
        },
        builder: (context, state) {
          print("Current State: $state");

          if (state is ProfilePermissionLoading) {
            return _buildLoadingState();
          } else if (state is ProfilePermissionSuccess) {
            _populateFormFields(state.permissionData);
            return _buildDesktopLayout(state.permissionData, state);
          } else if (state is ProfilePermissionFailed) {
            return _buildErrorState(state, _loadProfileData);
          }
          return _buildLoadingState();
        },
      ),
    );
  }

  Widget _buildDesktopLayout(ProfilePermissionModel p, ProfileState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sidebar Navigation - Fixed width
        SizedBox(
          width: 320,
          child: Column(
            children: [
              // Profile Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
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
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          p.data?.user?.role?.replaceAll('_', ' ').toUpperCase() ?? "NO ROLE",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Navigation Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildDesktopNavItem(
                        title: 'Profile Information',
                        icon: Icons.person,
                        isActive: _currentSection == 0,
                        onTap: () => _setSection(0),
                      ),
                      _buildDesktopNavItem(
                        title: 'Permissions',
                        icon: Icons.security,
                        isActive: _currentSection == 1,
                        onTap: () => _setSection(1),
                      ),
                      _buildDesktopNavItem(
                        title: 'Security',
                        icon: Icons.lock,
                        isActive: _currentSection == 2,
                        onTap: () => _setSection(2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 24),

        // Main Content - Flexible width
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _currentSection == 0
                ? _buildProfileForm(p)
                : _currentSection == 1
                ? _buildPermissionsSection(state)
                : _buildSecuritySection(),
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
            color: isActive ? AppColors.primaryColor : Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: isActive ? Colors.white : AppColors.primaryColor,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.primaryColor : Colors.grey[700],
            fontSize: 14,
          ),
        ),
        tileColor: isActive ? AppColors.primaryColor.withOpacity(0.1) : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isActive ? AppColors.primaryColor : Colors.transparent,
            width: 1,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildProfilePicture(ProfilePermissionModel profile, {bool isLarge = false}) {
    final profilePicture = profile.data?.user?.profilePicture;
    final hasProfilePicture = profilePicture != null && profilePicture.isNotEmpty;

    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryColor, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[200],
            backgroundImage: hasProfilePicture
                ? NetworkImage(profilePicture)
                : null,
            child: hasProfilePicture
                ? null
                : Icon(
              Icons.person,
              size: 50,
              color: Colors.grey[400],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _showImagePickerOptions,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileForm(ProfilePermissionModel pp) {
    final profile = pp.data?.user;
    return SingleChildScrollView(
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
                const Text(
                  'Profile Information',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Update your personal information and contact details',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),

                // Two Column Layout for Form Fields
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column - Personal Info
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              labelText: 'First Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.person),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter first name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              labelText: 'Last Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.person_outline),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter last name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: profile?.username ?? "",
                            decoration: InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                        children: [
                          const Text(
                            'Contact Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.email),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter email address';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.phone),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: profile?.role?.replaceAll('_', ' ').toUpperCase() ?? "No Role",
                            decoration: InputDecoration(
                              labelText: 'Role',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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

                const SizedBox(height: 40),

                // Update Button
                Center(
                  child: SizedBox(
                    width: 200,
                    child: AppButton(
                      name: "Update Profile",
                      onPressed: _updateProfile,
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
              const Text(
                'Module Permissions',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your access permissions for different system modules',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),

              if (permissions != null)
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: [
                    _buildPermissionCard(
                      'Dashboard',
                      Icons.dashboard,
                      [
                        _buildPermissionItem('View', permissions.dashboard?.view ?? false),
                      ],
                    ),
                    _buildPermissionCard(
                      'Sales',
                      Icons.shopping_cart,
                      [
                        _buildPermissionItem('View', permissions.sales?.view ?? false),
                        _buildPermissionItem('Create', permissions.sales?.create ?? false),
                        _buildPermissionItem('Edit', permissions.sales?.edit ?? false),
                        _buildPermissionItem('Delete', permissions.sales?.delete ?? false),
                      ],
                    ),
                    _buildPermissionCard(
                      'Money Receipt',
                      Icons.receipt,
                      [
                        _buildPermissionItem('View', permissions.moneyReceipt?.view ?? false),
                        _buildPermissionItem('Create', permissions.moneyReceipt?.create ?? false),
                        _buildPermissionItem('Edit', permissions.moneyReceipt?.edit ?? false),
                        _buildPermissionItem('Delete', permissions.moneyReceipt?.delete ?? false),
                      ],
                    ),
                    // Add more permission cards as needed
                  ],
                )
              else
                const Center(
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No permissions data available',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
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
                      color: AppColors.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: AppColors.primaryColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: permissions,
              ),
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
        color: hasPermission ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
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
            size: 16,
            color: hasPermission ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 6),
          Text(
            action,
            style: TextStyle(
              color: hasPermission ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return SingleChildScrollView(
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
                const Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Update your password to keep your account secure',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),

                // Password Fields in Center
                Center(
                  child: SizedBox(
                    width: 400,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _currentPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Current Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.lock),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter current password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _newPasswordController,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.lock_outline),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter new password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirm New Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.lock_reset),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm new password';
                            }
                            if (value != _newPasswordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        BlocBuilder<ProfileBloc, ProfileState>(
                          builder: (context, state) {
                            return SizedBox(
                              width: 200,
                              child: AppButton(
                                name: state is PasswordChanging ? "Changing Password..." : "Change Password",
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

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(dynamic state, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            AppImages.noData,
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 24),
          Text(
            state.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 400,
            child: Text(
              state.content,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            name: "Try Again",
            onPressed: onRetry,
            width: 200,
          ),
        ],
      ),
    );
  }

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

      context.read<ProfileBloc>().add(
        UpdateUserProfile(
          profileData: profileData,
          context: context,
        ),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Profile Picture'),
        content: const Text('Choose an option to update your profile picture'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement gallery image picker
            },
            child: const Text('Gallery'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement camera image picker
            },
            child: const Text('Camera'),
          ),
        ],
      ),
    );
  }
}