import 'package:meherinMart/core/widgets/app_scaffold.dart';
import '../../../../core/configs/configs.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/show_custom_toast.dart';
import '../../data/model/profile_perrmission_model.dart';
import '../bloc/profile_bloc/profile_bloc.dart';

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
    return AppScaffold(
      appBar: AppBar(
        title: const Text("Profile"),
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
                  _populateFormFields(state.permissionData);
                  return _buildMobileLayout(state.permissionData, state);
                } else if (state is ProfilePermissionFailed) {
                  return _buildErrorState(state, _loadProfileData);
                }
                return _buildLoadingState();
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildMobileLayout(ProfilePermissionModel p, ProfileState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Header Card
        _buildProfileHeaderCard(p),
        const SizedBox(height: 10),

        // Current Section Content
        _currentSection == 0
            ? _buildProfileForm(p)
            : _currentSection == 1
            ? _buildPermissionsSection(state)
            : _buildSecuritySection(),
      ],
    );
  }

  Widget _buildProfileHeaderCard(ProfilePermissionModel p) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            // Profile Picture
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryColor,
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: p.data?.user?.profilePicture != null &&
                        p.data!.user!.profilePicture!.isNotEmpty
                        ? NetworkImage(p.data!.user!.profilePicture!)
                        : null,
                    child: p.data?.user?.profilePicture == null ||
                        p.data!.user!.profilePicture!.isEmpty
                        ? Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey[400],
                    )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _showImagePickerOptions,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // User Info
            Text(
              p.data?.user?.fullName ?? "No Name",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            Text(
              '@${p.data?.user?.username ?? "No Username"}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
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
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileForm(ProfilePermissionModel pp) {
    final profile = pp.data?.user;

    return Card(
      elevation: 1,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Update your personal information',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),

              // Form Fields
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
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
                    borderRadius: BorderRadius.circular(8),
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
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
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
                  if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              TextFormField(
                initialValue: profile?.username ?? "",
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.alternate_email),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16),

              TextFormField(
                initialValue:
                profile?.role?.replaceAll('_', ' ').toUpperCase() ??
                    "No Role",
                decoration: InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.work),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                readOnly: true,
              ),
              const SizedBox(height: 24),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  name: "Update Profile",
                  onPressed: _updateProfile,
                ),
              ),
            ],
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

    return Card(
      elevation: 1,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Module Permissions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your access permissions for system modules',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),

            if (permissions != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMobilePermissionCard(
                    'Dashboard',
                    Icons.dashboard,
                    permissions.dashboard?.view ?? false,
                  ),
                  const SizedBox(height: 12),

                  _buildMobilePermissionCard(
                    'Sales',
                    Icons.shopping_cart,
                    [
                      _buildPermissionItem('View', permissions.sales?.view ?? false),
                      _buildPermissionItem('Create', permissions.sales?.create ?? false),
                      _buildPermissionItem('Edit', permissions.sales?.edit ?? false),
                      _buildPermissionItem('Delete', permissions.sales?.delete ?? false),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _buildMobilePermissionCard(
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
                      'No permissions data available',
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
    );
  }

  Widget _buildMobilePermissionCard(
      String title,
      IconData icon,
      dynamic permissions,
      ) {
    return Card(
      elevation: 1,
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (permissions is bool)
              _buildPermissionItem(permissions ? 'Allowed' : 'Denied', permissions)
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

  Widget _buildPermissionItem(String action, bool hasPermission) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: hasPermission
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
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

  Widget _buildSecuritySection() {
    return Card(
      elevation: 1,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _passwordFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Change Password',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Update your password to keep your account secure',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),

              // Password Fields
              TextFormField(
                controller: _currentPasswordController,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
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
              const SizedBox(height: 16),

              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
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
              const SizedBox(height: 16),

              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
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
              const SizedBox(height: 24),

              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      name: state is PasswordChanging
                          ? "Changing Password..."
                          : "Change Password",
                      onPressed: state is PasswordChanging
                          ? null
                          : _changePassword,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentSection,
      onTap: (index) {
        setState(() {
          _currentSection = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.security),
          label: 'Permissions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.lock),
          label: 'Security',
        ),
      ],
    );
  }

  void _handleStateChanges(BuildContext context, ProfileState state) {
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
              state.title ?? 'Error',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              state.content ?? 'Something went wrong',
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
                name: "Try Again",
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
              const Text(
                'Update Profile Picture',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose an option to update your profile picture',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement gallery image picker
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement camera image picker
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