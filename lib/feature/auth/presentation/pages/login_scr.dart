import 'dart:async';
import 'dart:ui';
import '../../../../core/core.dart';
import '../../../../root.dart';
import '../../../feature.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final TextEditingController emailCon = TextEditingController();
  final TextEditingController passwordCon = TextEditingController();
  bool hidePassword = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _visible = !_visible;
      });
    });
  }

  @override
  void dispose() {
    emailCon.dispose();
    passwordCon.dispose();
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
      context.read<AuthBloc>().add(LoginRequested(
        username: emailCon.text.trim(),
        password: passwordCon.text.trim(),
      ));
    }
  }

  double _getFormWidth(double screenWidth) {
    if (screenWidth >= 1200) return 500; // Desktop
    if (screenWidth >= 800) return 350; // Tablet
    return screenWidth * 0.9; // Mobile
  }
  double getImageWidth(double screenWidth) {
    if (screenWidth >= 1200) return 600; // large desktop
    if (screenWidth >= 800) return 550;  // tablet / small desktop
    return 300;                           // mobile / mini desktop
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) async {
            if (state is AuthAuthenticated || state is AuthAuthenticatedOffline) {
              _dismissLoaderIfOpen();

              showCustomToast(
                context: context,
                title: 'Success!',
                description: state is AuthAuthenticated
                    ? 'Login Online successfully.'
                    : 'Login Offline successfully.',
                type: ToastificationType.success,
                icon: Icons.check_circle,
                primaryColor: Colors.green,
              );
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
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.loginBg),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Row(
                  mainAxisAlignment: screenWidth >= 800
                      ? MainAxisAlignment.spaceEvenly
                      : MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                      SizedBox(
                        width: getImageWidth(screenWidth),
                        child: Image.asset(
                          AppImages.loginIcon,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6.1, sigmaY: 6.1),
                        child: Container(
                          width: _getFormWidth(screenWidth),
                          padding: const EdgeInsets.all(AppSizes.bodyTabPadding),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(233, 233, 233, 0.22),
                            border: Border.all(color: Color(0xFFE3E3E3)),
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
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                AppTextField(
                                  textInputAction: TextInputAction.next,
                                  labelText: "Email",
                                  isRequiredLabel: false,
                                  isRequired: true,
                                  hintText: "Email Address",
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    return value!.trim().isEmpty
                                        ? 'Please enter email address'
                                        : AppConstants.emailRegex.hasMatch(value.trim())
                                        ? null
                                        : 'Invalid email address';
                                  },
                                  controller: emailCon,
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
                                  suffixIcon: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      setState(() {
                                        hidePassword = !hidePassword;
                                      });
                                    },
                                    icon: Icon(
                                      hidePassword ? Iconsax.eye_slash : Iconsax.eye,
                                    ),
                                  ),
                                  onFieldSubmitted: (_) => _submitLoginForm(),
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
                                        valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                        : AppButton(
                                      size: screenWidth >= 800 ? 500 : double.infinity,
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
