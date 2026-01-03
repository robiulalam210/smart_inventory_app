import '../../feature/splash/presentation/bloc/connectivity_bloc/connectivity_bloc.dart';
import '../../feature/splash/presentation/bloc/connectivity_bloc/connectivity_state.dart';
import '/core/core.dart';


class AppScaffold extends StatelessWidget {
  final Widget body;
  final Widget? drawer;
  final Widget? endDrawer;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final bool? resizeToAvoidBottomInset;
  final bool isCenterFAB;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.drawer,
    this.endDrawer,
    this.isCenterFAB = true,
    this.scaffoldKey,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityBloc, ConnectivityState>(
      builder: (context, state) {
        final isOffline = state is ConnectivityOffline;

        final overlayColor =  AppColors.background;

        return Stack(
          children: [
            Scaffold(
              key: scaffoldKey,
              backgroundColor: overlayColor,
              appBar: appBar,
              drawer: drawer,
              endDrawer: endDrawer,
              bottomNavigationBar: bottomNavigationBar,
              floatingActionButton: floatingActionButton,
              floatingActionButtonLocation: isCenterFAB
                  ? FloatingActionButtonLocation.centerDocked
                  : FloatingActionButtonLocation.endFloat,
              resizeToAvoidBottomInset: resizeToAvoidBottomInset ?? true,
              body: body,
            ),
            if (isOffline)
              Positioned.fill(
                child: Material(
                  color: Colors.black.withValues(alpha: 0.4), // semi-transparent overlay
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Lottie.asset(AppImages.noInternetJson),
                        const SizedBox(height: 24),
                        // Text(
                        //   "No Internet Connection",
                        //   textAlign: TextAlign.center,
                        //   style: AppTextStyle.headlineMedium(context)
                        //       .copyWith(color: themeState.primaryColor),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}