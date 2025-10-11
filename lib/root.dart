import 'package:flutter/cupertino.dart';
import 'core/core.dart';
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
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);
    return SafeArea(
      child: Scaffold(
        key: _drawerKey,

        /// Drawer for smaller screens
        drawer: isSmallScreen ? const Drawer(child: TabSidebar()) : null,

        /// AppBar only for smaller screens
        appBar: isSmallScreen
            ? AppBar(
                backgroundColor: AppColors.bgSecondaryLight,
                title: Row(
                  children: [
                    /// App title
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                Responsive.isMobile(context) ? 8.0 : 16.0),
                        child: Text(
                          AppConstants.appName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryColor,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    BlocBuilder<AllSetupBloc, AllSetupState>(
                      builder: (context, setupState) {
                        return BlocBuilder<AllInvoiceSetupBloc,
                            AllInvoiceSetupState>(
                          builder: (context, invoiceSetupState) {
                            return BlocBuilder<SyncBloc, SyncState>(
                              builder: (context, syncState) {
                                return BlocBuilder<InvoiceUnSyncBloc,
                                    InvoiceUnSyncState>(
                                  builder: (context, invoiceUnSyncState) {
                                    final isLoading =
                                        setupState is AllSetupLoading ||
                                            invoiceSetupState
                                                is AllInvoiceSetupLoading ||
                                            syncState is SyncServerLoading ||
                                            invoiceUnSyncState
                                                is InvoiceUnSyncLoading ||
                                            invoiceUnSyncState
                                                is PostInvoiceUnSyncLoading;

                                    return AppButton(
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                        LabTechnologistRepoDb().fetchUnsyncedLabDataNested();
                                              // LabBillingRepository()
                                              //     .fetchAllOfflineInvoiceDetails();
                                              // context
                                              //     .read<InvoiceUnSyncBloc>()
                                              //     .add(LoadUnSyncInvoice());
                                            },
                                      color: Colors.orange,
                                      name: isLoading ? "Syncing..." : "Sync",
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),

                    gapW8,
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
                        );
                      },
                    ),

                    gapW8,

                    /// Sign out button
                    AppButton(
                      onPressed: () => _showLogoutConfirmation(context),
                      name: "Sign Out",
                      color: Colors.red,
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
              )
            : null,

        body: PopScope(
          canPop: false,
          // ignore: deprecated_member_use
          onPopInvoked: (v) async {
            return;
          },
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              int currentIndex = 0; // default fallback

              if (state is DashboardScreenChanged) {
                currentIndex = state.index;
              }

              final bloc = context.read<DashboardBloc>();
              return RefreshIndicator(
                onRefresh: () async {},
                child: ListView(
                  padding: EdgeInsets.zero,
                  physics: const ScrollPhysics(),
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
      content: const Text("Are you sure you want to sign out ?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            await LocalDB.delLoginInfo();

            AppRoutes.pushAndRemoveUntil(context, LogInScreen());
          },
          child: const Text(
            "Sign Out",
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}
