import 'package:flutter/cupertino.dart';
import 'core/core.dart';
import 'core/shared/widgets/sideMenu/tab_sidebar.dart';
import 'feature/feature.dart';
import 'feature/profile/presentation/bloc/profile_bloc/profile_bloc.dart';
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
    super.initState();
    // initialize blocs and services
    context.read<ProfileBloc>().add(FetchProfilePermission(context: context));

    context.read<DashboardBloc>().add(ChangeDashboardScreen(index: 0));
    context.read<PrintLayoutBloc>().add(FetchPrintLayout());
    AutoTimerService().startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = Responsive.isMobile(context) ||
        Responsive.isTablet(context) ||
        Responsive.isSmallDesktop(context);
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);

    return SafeArea(
      child: Scaffold(
        key: _drawerKey,

        // Mobile/tablet drawer
        drawer: isSmallScreen ?  Drawer(child: TabSidebar()) : null,
        drawerEnableOpenDragGesture: isSmallScreen,

        // AppBar only for smaller screens
        appBar: isSmallScreen ? _buildAppBar(context) : null,

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
              final bloc = context.read<DashboardBloc>();

              // Desktop: permanent sidebar + content
              if (isBigScreen) {
                return Row(
                  children: [
                    // Permanent Sidebar
                    // const SizedBox(
                    //   width: 300, // adjust as needed
                    //   child: Sidebar(),
                    // ),

                    // Vertical divider (optional)
                    Container(width: 1, color: AppColors.text(context)),

                    // Main content area
                    Expanded(
                      child: Column(
                        children: [
                          // Header only on big screens
                           Header(drawerKey: _drawerKey,),

                          // Content area: refreshable scrollable view
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () async {
                                context.read<DashboardBloc>().add(
                                  ChangeDashboardScreen(index: currentIndex),
                                );
                              },
                              child: SingleChildScrollView(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSizes.bodyPadding *
                                      (Responsive.isMobile(context) ? 0.5 : 1.5),
                                ),
                                child: bloc.myScreens[currentIndex],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
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
      backgroundColor: AppColors.bottomNavBg(context),
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
                  color: AppColors.primaryColor(context),
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
              MaterialPageRoute(builder: (context) => LogInScreen()),
                  (route) => false,
            );
          },
          child: const Text("Sign Out", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}