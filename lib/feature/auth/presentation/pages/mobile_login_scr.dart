import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';

import '../../../../core/core.dart';
import '../../../../core/database/login_local_storage.dart';
import '../../../feature.dart';
import '../../../mobile_root.dart';

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
    return AppScaffold(
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
              title: "login_failed".tr(),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child:  Text("ok".tr()),
                ),
              ],
            );
          }
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: SingleChildScrollView(
              child: FadeTransition(
                opacity: fadeAnimation,
                child: SlideTransition(
                  position: slideAnimation,
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [languageDropdown(context)],
                      ),

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

                      const SizedBox(height: 5),

                       Text(
                        "welcome_back".tr(),
                        style: AppTextStyle.titleLarge(context)
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
                                labelText: "email".tr(),
                                hintText: "enter_email".tr(),
                                controller: emailCon,
                                keyboardType: TextInputType.emailAddress,
                                focusNode: _emailFocus,
                                textInputAction: TextInputAction.next,
                                validator: (v) =>
                                    v!.isEmpty ? 'enter_valid_email'.tr() : null,
                                onFieldSubmitted: (_) =>
                                    _passwordFocus.requestFocus(),
                              ),

                              AppTextField(
                                labelText: "password".tr(),
                                hintText: "enter_password".tr(),
                                controller: passwordCon,
                                obscureText: hidePassword,
                                focusNode: _passwordFocus,
                                textInputAction: TextInputAction.done,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'please_enter_password'.tr();
                                  }

                                  return null;
                                },
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
                                onFieldSubmitted: (_) => _submit(),
                                keyboardType: TextInputType.text,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child:  Text("forgot_password".tr()),
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
                                      height: 40,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        gradient: loading
                                            ? AppColors.primaryGradient(
                                                context,
                                              ).withOpacity(0.3)
                                            : AppColors.primaryGradient(
                                                context,
                                              ),
                                        // color: loading
                                        //     ? Colors.indigo.shade200
                                        //     : Colors.indigo,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: loading
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          :  Text(
                                              "login".tr(),
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
    );
  }
}

Widget languageDropdown(BuildContext context) {
  final currentCode = context.locale.languageCode;

  return PopupMenuButton<String>(
    initialValue: currentCode,
    tooltip: 'select_language'.tr(),
    onSelected: (value) {
      context.setLocale(Locale(value));
    },
    itemBuilder: (context) => [
      _languageMenuItem(
        context,
        value: 'en',
        title: 'English',
        groupValue: currentCode,
      ),
      _languageMenuItem(
        context,
        value: 'bn',
        title: 'বাংলা',
        groupValue: currentCode,
      ),
    ],
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        // color: Theme.of(context).highlightColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.translate, size: 18),
          const SizedBox(width: 6),
          Text(
            currentCode == 'bn' ? 'বাংলা' : 'English',
            style: AppTextStyle.body(context),
          ),
          // const Icon(Icons.arrow_drop_down),
        ],
      ),
    ),
  );
}

PopupMenuItem<String> _languageMenuItem(
  BuildContext context, {
  required String value,
  required String title,
  required String groupValue,
}) {
  return PopupMenuItem<String>(
    value: value,

    child: Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: groupValue,
          onChanged: (_) {}, // handled by PopupMenuButton
        ),
        Text(title, style: AppTextStyle.body(context)),
      ],
    ),
  );
}
