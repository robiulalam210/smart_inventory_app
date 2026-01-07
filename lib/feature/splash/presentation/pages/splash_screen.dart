import 'package:url_launcher/url_launcher.dart';

import '/root.dart';
import '../../../../core/configs/configs.dart';
import '../../../auth/presentation/pages/login_scr.dart';
import '../bloc/splash/splash_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // For desktop/web/large layouts we only need to check login status here.
    // The mobile flow (version checks etc.) is handled in MobileSplashScreen.
    context.read<SplashBloc>().add(CheckLoginStatusEvent());

    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // swallow or log error in release; throwing during UI navigation is not ideal
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
      body: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashNavigateToLogin) {
            AppRoutes.pushAndRemoveUntil(context, const LogInScreen());
          } else if (state is SplashNavigateToHome) {
            AppRoutes.pushAndRemoveUntil(context, const RootScreen());
          }
        },
        child: Container(
          decoration: BoxDecoration(gradient: AppColors.primaryGradient),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Bottom credit
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextButton(
                    onPressed: () => _launchInBrowser(developerUrl),
                    child: const Text.rich(
                      TextSpan(
                        text: 'Developed by ',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                        children: [
                          TextSpan(
                            text: 'Meherin Mart',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Center animation + app name
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
                    style: const TextStyle(
                      fontSize: 30,
                      color: Colors.white,
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