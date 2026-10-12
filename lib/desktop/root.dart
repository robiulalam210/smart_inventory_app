import 'package:meherinMart/core/widgets/page_guide_widgets.dart';
import 'package:meherinMart/core/widgets/page_guides.dart';
import 'package:meherinMart/feature/auth/presentation/desktop/login_scr.dart';
import 'package:meherinMart/desktop/widgets/header.dart';
import 'package:meherinMart/desktop/desktop_screens.dart';
import 'package:flutter/cupertino.dart';
import '../core/core.dart';
import 'widgets/tab_sidebar.dart';
import 'widgets/sidebar.dart' show Sidebar, kSidebarWidth;
import 'widgets/quick_jump.dart';
import '../feature/feature.dart';
import '../feature/profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import '../feature/splash/presentation/bloc/connectivity_bloc/connectivity_state.dart';

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

    // Ctrl+K / ⌘K — যেকোনো page এ নাম লিখে সরাসরি যাওয়া
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () =>
            showQuickJump(context),
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () =>
            showQuickJump(context),
      },
      child: Focus(
        autofocus: true,
        child: SafeArea(
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
            // শুধু screen বদলালে rebuild — আগে dashboard data load এর
            // Loading/Loaded state এও rebuild হতো, তখন index 0 ধরে
            // অন্য screen থেকে হঠাৎ Dashboard এ চলে আসত
            buildWhen: (prev, curr) => curr is DashboardScreenChanged,
            builder: (context, state) {
              int currentIndex = 0;
              if (state is DashboardScreenChanged) {
                currentIndex = state.index;
              }

              // Desktop: উপরে Header, নিচে বাঁয়ে স্থায়ী Sidebar (নিজস্ব scroll),
              // ডানে content। আগে প্রতিটা screen নিজের ভেতরে sidebar বসাত আর
              // sidebar content এর সাথে scroll হয়ে উঠে যেত।
              if (isBigScreen) {
                return Column(
                  children: [
                    Header(drawerKey: _drawerKey),
                    Expanded(
                      child: PermanentSidebarScope(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(width: kSidebarWidth, child: Sidebar()),
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: () async {
                                  context.read<DashboardBloc>().add(
                                    ChangeDashboardScreen(index: currentIndex),
                                  );
                                },
                                child: SingleChildScrollView(
                                  child: _withGuide(currentIndex),
                                ),
                              ),
                            ),
                          ],
                        ),
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
                      child: _withGuide(currentIndex),
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
        ),
      ),
    );
  }

  /// প্রতিটা desktop পেজের মাথায় "কীভাবে কাজ করবেন" গাইড-কার্ড
  Widget _withGuide(int index) {
    final key = index >= 0 && index < kDesktopGuideKeys.length ? kDesktopGuideKeys[index] : '';
    final screen = desktopScreens[index];
    if (!kPageGuides.containsKey(key)) return screen;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [PageGuideCard(guideKey: key), screen],
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
            color: AppColors.danger,
            size: 80,
          ),
        ],
      ),
    );
  }
}

Color getConnectivityColor(ConnectivityState state) {
  if (state is ConnectivityOnline) return AppColors.success;
  if (state is ConnectivityOffline) return AppColors.danger;
  if (state is ConnectivityConnecting) return AppColors.warning;
  return Colors.grey;
}

void _showLogoutConfirmation(BuildContext context) {
  showAppPopover(
    context: context,
    builder: (context) => AppPopoverCard(
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
          child: const Text("Sign Out", style: TextStyle(color: AppColors.danger)),
        ),
      ],
    ),
  );
}