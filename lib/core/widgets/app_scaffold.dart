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

        final overlayColor =  AppColors.background(context);

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

          ],
        );
      },
    );
  }
}