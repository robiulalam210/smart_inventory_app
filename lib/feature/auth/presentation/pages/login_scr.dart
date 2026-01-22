import 'dart:async';
import 'dart:ui';
import '../../../../core/core.dart';
import '../../../../core/database/login_local_storage.dart';
import '../../../../root.dart';
import '../../../feature.dart';
import '../../../profile/presentation/bloc/profile_bloc/profile_bloc.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final TextEditingController emailCon = TextEditingController();
  final TextEditingController passwordCon = TextEditingController();

  // Focus nodes for better keyboard navigation on mobile
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool hidePassword = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLogin();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _visible = true;
        });
      }
    });
  }

  Future<void> _loadSavedLogin() async {
    final data = await LoginLocalStorage.getSavedLogin();
    if (mounted) {
      setState(() {
        emailCon.text = data['username'] ?? "";
        passwordCon.text = data['password'] ?? "";
      });
    }
  }

  @override
  void dispose() {
    emailCon.dispose();
    passwordCon.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _dismissLoaderIfOpen() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _submitLoginForm() {
    final currentState = _formKey.currentState;
    if (currentState != null && currentState.validate()) {
      context.read<AuthBloc>().add(
        LoginRequested(
          username: emailCon.text.trim(),
          password: passwordCon.text.trim(),
        ),
      );
    }
  }

  double _getFormWidth(double screenWidth) {
    if (screenWidth >= 1200) return 500.0; // Desktop
    if (screenWidth >= 800) return 350.0; // Tablet
    return screenWidth * 0.9; // Mobile
  }

  double getImageWidth(double screenWidth, double keyboardInset) {
    // shrink image when keyboard is visible on mobile
    final base = screenWidth >= 1200
        ? 600.0
        : screenWidth >= 800
        ? 550.0
        : 350.0;
    if (keyboardInset > 0 && screenWidth < 800) {
      return base * 0.7;
    }
    return base;
  }

  Widget _buildForm(double screenWidth) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6.1, sigmaY: 6.1),
        child: Container(
          width: _getFormWidth(screenWidth),
          padding: const EdgeInsets.all(AppSizes.bodyTabPadding),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(233, 233, 233, 0.22),
            border: Border.all(color: const Color(0xFFE3E3E3)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 2,
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontSize: screenWidth >= 800 ? 28 : 20,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                AutofillGroup(
                  child: Column(
                    children: [
                      AppTextField(
                        textInputAction: TextInputAction.next,
                        labelText: "Username or Email",
                        isRequiredLabel: false,
                        isRequired: true,
                        hintText: "Enter username or email address",
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter username or email';
                          }
                          return null;
                        },
                        controller: emailCon,
                        focusNode: _emailFocus,
                        onFieldSubmitted: (_) {
                          _passwordFocus.requestFocus();
                        },
                      ),
                      AppTextField(
                        isRequiredLabel: false,
                        textInputAction: TextInputAction.done,
                        labelText: "Password",
                        isRequired: true,
                        hintText: "Password",
                        keyboardType: TextInputType.text,
                        validator: (value) =>
                        value!.trim().isEmpty ? 'Please enter password' : null,
                        controller: passwordCon,
                        obscureText: hidePassword,
                        focusNode: _passwordFocus,
                        suffixIcon: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                          icon: Icon(hidePassword ? Iconsax.eye_slash : Iconsax.eye),
                        ),
                        onFieldSubmitted: (_) => _submitLoginForm(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return isLoading
                        ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator.adaptive(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : AppButton(
                      size: screenWidth >= 800 ? 500.0 : double.infinity,
                      name: "Log In",
                      onPressed: _submitLoginForm,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: AppColors.bottomNavBg(context),
          body: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) async {
              if (state is AuthAuthenticated || state is AuthAuthenticatedOffline) {
                await LoginLocalStorage.saveLogin(
                  emailCon.text.trim(),
                  passwordCon.text.trim(),
                );
                _dismissLoaderIfOpen();
                showCustomToast(
                  context: context,
                  title: 'Success!',
                  description:
                  'Login successfully.'
                  ,
                  type: ToastificationType.success,
                  icon: Icons.check_circle,
                  primaryColor: Colors.green,
                );
                context.read<ProfileBloc>().add(FetchProfilePermission(context: context));

                AppRoutes.pushReplacement(context, RootScreen());
              } else if (state is AuthError) {
                _dismissLoaderIfOpen();
                appAlertDialog(
                  context,
                  state.message,
                  title: "Login Failed",
                  actions: [
                    TextButton(
                      onPressed: () => AppRoutes.pop(context),
                      child: const Text("Dismiss"),
                    ),
                  ],
                );
              }
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(gradient: AppColors.primaryGradient(context)),
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: keyboardInset),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 350),
                    opacity: _visible ? 1.0 : 0.0,
                    child: Builder(builder: (context) {
                      // Use Row on wide screens, Column on narrow screens to avoid overflow.
                      if (screenWidth >= 800) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: getImageWidth(screenWidth, keyboardInset),
                              child: Lottie.asset(AppImages.loginLottie, fit: BoxFit.contain),
                            ),
                            _buildForm(screenWidth),
                          ],
                        );
                      } else {
                        // Mobile: stack the image above the form to avoid horizontal overflow.
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // SizedBox(
                            //   width: getImageWidth(screenWidth, keyboardInset).clamp(0.0, screenWidth * 0.5),
                            //   child: Lottie.asset(AppImages.loginLottie, fit: BoxFit.contain),
                            // ),
                            _buildForm(screenWidth),
                          ],
                        );
                      }
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}