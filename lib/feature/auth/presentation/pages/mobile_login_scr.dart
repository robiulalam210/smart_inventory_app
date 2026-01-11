import 'dart:async';
import 'package:meherinMart/core/widgets/app_scaffold.dart';

import '../../../../core/core.dart';
import '../../../../core/database/login_local_storage.dart';
import '../../../feature.dart';
import '../../../mobile_root_screen.dart';

class MobileLoginScr extends StatefulWidget {
  const MobileLoginScr({super.key});

  @override
  State<MobileLoginScr> createState() => _MobileLoginScrState();
}

class _MobileLoginScrState extends State<MobileLoginScr> {
  final _formKey = GlobalKey<FormState>();

  final emailCon = TextEditingController();
  final passwordCon = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool hidePassword = true;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLogin();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  Future<void> _loadSavedLogin() async {
    final data = await LoginLocalStorage.getSavedLogin();
    emailCon.text = data['username'] ?? "";
    passwordCon.text = data['password'] ?? "";
  }

  @override
  void dispose() {
    emailCon.dispose();
    passwordCon.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginRequested(
          username: emailCon.text.trim(),
          password: passwordCon.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return AppScaffold(
      // backgroundColor: AppColors.bg,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthAuthenticated || state is AuthAuthenticatedOffline) {
            await LoginLocalStorage.saveLogin(
              emailCon.text.trim(),
              passwordCon.text.trim(),
            );

            showCustomToast(
              context: context,
              title: "Success",
              description:  "Login  in Successful",
              type: ToastificationType.success,
            );

            AppRoutes.pushReplacement(context, const MobileRootScreen());
          }

          if (state is AuthError) {
            appAlertDialog(
              context,
              state.message,
              title: "Login Failed",
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                )
              ],
            );
          }
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            // decoration: BoxDecoration(
            //   gradient: AppColors.primaryGradient,
            // ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: keyboardInset,
                top: 60,
              ),
              child: AnimatedOpacity(
                opacity: _visible ? 1 : 0,
                duration: const Duration(milliseconds: 350),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// 🔹 Lottie / Logo
                    SizedBox(
                      height: 220,
                      child: Lottie.asset(
                        AppImages.loginLottie,
                        fit: BoxFit.fitHeight,height: 200
                      ),
                    ),


                    /// 🔹 Login Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(20),
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Colors.black.withValues(alpha: 0.12),
                        //     blurRadius: 30,
                        //     offset: const Offset(0, 20),
                        //   )
                        // ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            /// Title
                            const Text(
                              "Welcome Back 👋",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Sign in to continue",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),

                            const SizedBox(height: 15),

                            /// Email
                            AppTextField(
                              labelText: "Username / Email",
                              hintText: "Enter your username or email",
                              controller: emailCon,
                              keyboardType: TextInputType.emailAddress,
                              focusNode: _emailFocus,
                              textInputAction: TextInputAction.next,
                              validator: (v) =>
                              v!.isEmpty ? "Required" : null,
                              onFieldSubmitted: (_) =>
                                  _passwordFocus.requestFocus(),
                            ),

                            const SizedBox(height: 8),
                            /// Password
                            AppTextField(
                              labelText: "Password",
                              hintText: "Enter password",
                              controller: passwordCon,
                              obscureText: hidePassword,
                              focusNode: _passwordFocus,
                              textInputAction: TextInputAction.done,
                              validator: (v) =>
                              v!.isEmpty ? "Required" : null,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  hidePassword
                                      ? Iconsax.eye_slash
                                      : Iconsax.eye,
                                ),
                                onPressed: () {
                                  setState(() {
                                    hidePassword = !hidePassword;
                                  });
                                },
                              ),
                              onFieldSubmitted: (_) => _submit(), keyboardType: TextInputType.text,
                            ),

                            /// Forgot
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: const Text("Forgot password?"),
                              ),
                            ),

                            const SizedBox(height: 10),

                            /// Login Button
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                final loading = state is AuthLoading;

                                return SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: loading ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: loading
                                        ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child:
                                      CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                        : const Text(
                                      "Log In",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 14),


                          ],
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
