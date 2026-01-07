import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/app_show_info.dart';
import '../../../auth/presentation/pages/mobile_login_scr.dart';
import '../../../mobile_root_screen.dart';
import '../../../../core/configs/configs.dart';
import '../bloc/splash/splash_bloc.dart';

class MobileSplashScreen extends StatefulWidget {
  const MobileSplashScreen({super.key});

  @override
  State<MobileSplashScreen> createState() => _MobileSplashScreenState();
}

class _MobileSplashScreenState extends State<MobileSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Start the version & maintenance check flow for mobile.
    context.read<SplashBloc>().add(CheckAppVersionEvent(context));

    _animationController =
    AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final developerUrl = Uri(
      scheme: 'https',
      host: 'robi.meherinmart.xyz',
    );

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          // Maintenance: block UI
          if (state is AppPausedState) {
            appShowInfo(
              context,
              title: "Maintenance Mode",
              content:
              "This app is currently under maintenance. Please come back later.",
              defaultDismissAction: false,
              actions: [
                TextButton(
                  onPressed: () => exit(0),
                  child: const Text("Close"),
                ),
              ],
            );
          }

          // Force update
          else if (state is AppForceUpdateState) {
            appShowInfo(
              context,
              title: "Update Required",
              content:
              state.message ?? "You must update the app to continue using it.",
              defaultDismissAction: false,
              actions: [
                TextButton(
                  onPressed: () {
                    if (state.url != null && state.url!.isNotEmpty) {
                      appLaunchUrlPlay(state.url);
                    }
                  },
                  child: const Text("Update"),
                ),
              ],
            );
          }

          // Optional update
          else if (state is UpdateAvailableState) {
            appShowInfo(
              context,
              title: "New Version Available",
              content: state.message ?? "A new version of the app is available.",
              defaultDismissAction: false,
              actions: [
                TextButton(
                  onPressed: () {
                    // dismiss dialog and continue to login check
                    Navigator.pop(context);
                    context.read<SplashBloc>().add(CheckLoginStatusEvent());
                  },
                  child: const Text("Later"),
                ),
                TextButton(
                  onPressed: () {
                    if (state.url != null && state.url!.isNotEmpty) {
                      appLaunchUrlPlay(state.url);
                    }
                  },
                  child: const Text("Update"),
                ),
              ],
            );
          }

          // Navigation decisions
          else if (state is SplashNavigateToLogin) {
            AppRoutes.pushAndRemoveUntil(context, const MobileLoginScr());
          } else if (state is SplashNavigateToHome) {
            AppRoutes.pushAndRemoveUntil(context, const MobileRootScreen());
          }
        },
        child: Container(
          decoration: BoxDecoration(gradient: AppColors.primaryGradient),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Bottom developer credit
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: TextButton(
                      onPressed: () => _launchInBrowser(developerUrl),
                      child: const Text.rich(
                        TextSpan(
                          text: 'Developed by ',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                          children: [
                            TextSpan(
                              text: "Meherin Mart",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Center animation & name
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 1,
                    child: Lottie.asset(
                      AppImages.splashLottie,
                      width: Responsive.isMobile(context)
                          ? AppSizes.width(context) * 0.8
                          : AppSizes.width(context) * 0.42,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 30,
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}