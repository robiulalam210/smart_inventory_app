import '/root.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/configs/configs.dart';
import '../../../auth/presentation/pages/login_scr.dart';
import '../bloc/splash/splash_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void dispose() {
    animationController.dispose(); // Dispose of the AnimationController
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final splashBloc = context.read<SplashBloc>();

    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.easeOut);
    animationController.forward();

    // Trigger visibility event after 500ms
    Future.delayed(const Duration(milliseconds: 900), () {
      splashBloc.add(ToggleVisibilityEvent());
    });

    // Trigger login data fetch
    context.read<SplashBloc>().add(GetLoginData());
  }

  @override
  Widget build(BuildContext context) {
    final Uri toLaunch = Uri(
      scheme: 'https',
      host: 'macrohealthplus.org',
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashNavigateToLogin) {
            AppRoutes.pushAndRemoveUntil(context, const LogInScreen());
          } else if (state is SplashNavigateToHome) {
            AppRoutes.pushAndRemoveUntil(context, const RootScreen());
          }
        },
        child: BlocBuilder<SplashBloc, SplashState>(
          builder: (context, state) {
            if (state is VisibilityChanged) {
// Update visibility when state changes
            }
            return Container(
              decoration: const BoxDecoration(color: AppColors.whiteColor),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: TextButton(
                          onPressed: () => _launchInBrowser(toLaunch),
                          child: const Text.rich(
                            TextSpan(
                              text: 'Developed by ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: "Macro Health Plus",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: Colors.indigoAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 1,
                        child: Lottie.asset(AppImages.splashLottie,
                            width: Responsive.isMobile(context)
                                ? AppSizes.width(context) * 0.80
                                : AppSizes.width(context) * 0.42),
                      ),

                      Text(
                        AppConstants.appName,
                        style: TextStyle(fontSize: 30),
                      ),
                      // ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }
}
