import 'package:flutter/cupertino.dart';
import 'package:meherinMart/feature/auth/presentation/pages/mobile_login_scr.dart';
import 'package:meherinMart/feature/feature.dart';
import 'package:meherinMart/feature/splash/presentation/bloc/connectivity_bloc/connectivity_state.dart';

import '../core/configs/configs.dart';
import '../core/shared/widgets/sideMenu/mobile_tab_sidebar.dart';
import '../core/widgets/app_button.dart';


final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

class MobileRootScreen extends StatefulWidget {
  const MobileRootScreen({super.key});

  @override
  State<MobileRootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<MobileRootScreen> {
  @override
  void initState() {
    super.initState();
    // initialize blocs and services
    context.read<DashboardBloc>().add(ChangeDashboardScreen(index: 0));
    context.read<PrintLayoutBloc>().add(FetchPrintLayout());
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        key: _drawerKey,

        // Mobile/tablet drawer
        drawer: const Drawer(child: MobileTabSidebar()),

        // AppBar only for smaller screens
        appBar: _buildAppBar(context) ,

        body: PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            // Prevent default back behavior / handle back if necessary.
            if (didPop) return;
          },
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              int currentIndex = 0;
              if (state is DashboardScreenChanged) {
                currentIndex = state.index;
              }


              // Small screens: drawer + appbar layout (keeps previous behavior)
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<DashboardBloc>().add(
                    ChangeDashboardScreen(index: currentIndex),
                  );
                },
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.bodyPadding *
                            (Responsive.isMobile(context) ? 0.5 : 1.5),
                      ),
                      child: DashboardScreen(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // FAB not needed on desktop since sidebar is permanent.
        // If you still want a FAB on some screens, toggle it with isSmallScreen/isBigScreen.
        floatingActionButton: null,
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.bgSecondaryLight,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => _drawerKey.currentState?.openDrawer(),
      ),
      title: Row(
        children: [
          // App title
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.isMobile(context) ? 8.0 : 16.0,
              ),
              child: Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          gapW8,

          // Connectivity Status
          BlocBuilder<ConnectivityBloc, ConnectivityState>(
            builder: (context, state) {
              String status;
              if (state is ConnectivityOnline) {
                status = "Online";
              } else if (state is ConnectivityConnecting) {
                status = "Connecting";
              } else {
                status = "Offline";
              }

              return AppButton(
                onPressed: () {},
                color: getConnectivityColor(state),
                name: status,
                size: 100,
              );
            },
          ),

          gapW8,

          // Sign out button
          AppButton(
            onPressed: () => _showLogoutConfirmation(context),
            name: "Sign Out",
            color: Colors.red,
            size: 80,
          ),
        ],
      ),
    );
  }
}

Color getConnectivityColor(ConnectivityState state) {
  if (state is ConnectivityOnline) return Colors.green;
  if (state is ConnectivityOffline) return Colors.red;
  if (state is ConnectivityConnecting) return Colors.orange;
  return Colors.grey;
}

void _showLogoutConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: const Text("Sign Out"),
      content: const Text("Are you sure you want to sign out?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            await LocalDB.delLoginInfo();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MobileLoginScr()),
                  (route) => false,
            );
          },
          child: const Text("Sign Out", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}