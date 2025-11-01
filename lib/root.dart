import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'core/core.dart';
import 'core/shared/widgets/sideMenu/sidebar.dart';
import 'core/shared/widgets/sideMenu/tab_sidebar.dart';
import 'feature/feature.dart';
import 'feature/splash/presentation/bloc/connectivity_bloc/connectivity_state.dart';

final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  @override
  void initState() {
    context.read<DashboardBloc>().add(ChangeDashboardScreen(index: 0));
    context.read<PrintLayoutBloc>().add(FetchPrintLayout());

    AutoTimerService().startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = Responsive.isMobile(context) ||
        Responsive.isTablet(context) ||
        Responsive.isSmallDesktop(context);
    final isBigScreen = Responsive.isDesktop(context) ||
        Responsive.isMaxDesktop(context);

    return SafeArea(
      child: Scaffold(
        key: _drawerKey,

        /// Drawer for different screen sizes
        drawer: isSmallScreen ? const Drawer(child: TabSidebar()) : null,
        drawerEnableOpenDragGesture: isSmallScreen,

        /// Sidebar for big screens (end drawer)
        endDrawer: isBigScreen ? const Drawer(child: Sidebar()) : null,
        endDrawerEnableOpenDragGesture: isBigScreen,

        /// AppBar only for smaller screens
        appBar: isSmallScreen ? _buildAppBar(context) : null,

        body: PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            // Handle back button if needed
            if (didPop) return;
            // Prevent default back behavior
          },
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              int currentIndex = 0;

              if (state is DashboardScreenChanged) {
                currentIndex = state.index;
              }

              final bloc = context.read<DashboardBloc>();
              return _buildBody(context, isBigScreen, bloc, currentIndex);
            },
          ),
        ),

        /// Floating Action Button for drawer on big screens
        floatingActionButton: isBigScreen ? _buildDrawerFAB() : null,
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
          /// App title
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

          /// Connectivity Status
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

          /// Sign out button
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

  Widget _buildBody(BuildContext context, bool isBigScreen, DashboardBloc bloc, int currentIndex) {
    return RefreshIndicator(
      onRefresh: () async {
        // Add refresh logic here if needed
        context.read<DashboardBloc>().add(ChangeDashboardScreen(index: currentIndex));
      },
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          if (isBigScreen) Header(drawerKey: _drawerKey),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.bodyPadding *
                  (Responsive.isMobile(context) ? 0.5 : 1.5),
            ),
            child: bloc.myScreens[currentIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerFAB() {
    return FloatingActionButton(
      onPressed: () => _drawerKey.currentState?.openEndDrawer(),
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      child: const Icon(Icons.menu),
      mini: true,
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
              MaterialPageRoute(builder: (context) => LogInScreen()),
                  (route) => false,
            );
          },
          child: const Text(
              "Sign Out",
              style: TextStyle(color: Colors.red)
          ),
        ),
      ],
    ),
  );
}