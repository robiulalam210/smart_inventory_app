import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/core.dart';
import '../../../../core/database/login_local_storage.dart';
import '../../../feature.dart';
import '../../../mobile_root_screen.dart';

class MobileLoginScr extends StatefulWidget {
  const MobileLoginScr({super.key});

  @override
  State<MobileLoginScr> createState() => _MobileLoginScrState();
}

class _MobileLoginScrState extends State<MobileLoginScr>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final emailCon = TextEditingController();
  final passwordCon = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool hidePassword = true;
  bool _visible = false;

  late AnimationController _controller;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadSavedLogin();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _visible = true);
        _controller.forward();
      }
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
    _controller.dispose();
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
    return Scaffold(
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
              description: "Login Successful",
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
                ),
              ],
            );
          }
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 24,
                ),
                child: FadeTransition(
                  opacity: fadeAnimation,
                  child: SlideTransition(
                    position: slideAnimation,
                    child: Column(
                      children: [
                        const SizedBox(height: 30),

                        /// Logo Floating
                        AnimatedOpacity(
                          opacity: _visible ? 1 : 0,
                          duration: const Duration(milliseconds: 600),
                          child: AnimatedScale(
                            scale: _visible ? 1 : 0.7,
                            duration: const Duration(milliseconds: 600),
                            child: Image.asset(
                              "assets/images/logo.png",
                              height: 180,
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        const Text(
                          "Welcome Back 👋",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// Glass Card
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          padding: const EdgeInsets.all(24),

                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
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

                          AppTextField( labelText: "Password", hintText: "Enter password", controller: passwordCon, obscureText: hidePassword, focusNode: _passwordFocus, textInputAction: TextInputAction.done, validator: (v) => v!.isEmpty ? "Required" : null, suffixIcon: IconButton( icon: Icon( hidePassword ? Iconsax.eye_slash : Iconsax.eye, ), onPressed: () { setState(() { hidePassword = !hidePassword; }); }, ), onFieldSubmitted: (_) => _submit(), keyboardType: TextInputType.text, ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    child: const Text("Forgot password?"),
                                  ),
                                ),

                                const SizedBox(height: 6),

                                BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, state) {
                                    final loading = state is AuthLoading;

                                    return GestureDetector(
                                      onTap: loading ? null : _submit,
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        height: 48,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: loading
                                              ? Colors.indigo.shade200
                                              : Colors.indigo,
                                          borderRadius: BorderRadius.circular(
                                            12,
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
                                                style: TextStyle(
                                                  color: Colors.white,
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
                      ],
                    ),
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
