import 'package:meherinMart/feature/auth/presentation/desktop/login_scr.dart';
import 'package:flutter/cupertino.dart';

import '../../feature/feature.dart';
import '../../feature/splash/presentation/bloc/connectivity_bloc/connectivity_state.dart';
import '../../core/configs/configs.dart';
import '../../core/widgets/app_button.dart';
import '../../core/offline/offline_config.dart';
import '../../core/offline/sync_widgets.dart';

class Header extends StatefulWidget {
  const Header({
    super.key,
    required this.drawerKey,
  });

  final GlobalKey<ScaffoldState> drawerKey;

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {

    return Column(mainAxisSize: MainAxisSize.min, children: [Container(
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.isMobile(context)
              ? AppSizes.paddingInside / 2
              : AppSizes.paddingInside,
          vertical: Responsive.isMobile(context)
              ? AppSizes.paddingInside / 2
              : AppSizes.paddingInside),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Menu button for mobile
            // App title
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Responsive.isMobile(context) ? 8.0 : 16.0),
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
            // Connectivity status
            if (OfflineConfig.enabled)
              const SyncStatusChip()
            else if (!Responsive.isMobile(context))
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
            // Sign out button
            AppButton(
              onPressed: () {
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
                          // Sync না হওয়া entry থাকলে আগে জানানো
                          if (!await OfflineGuards.confirmLogout(context)) return;
                          await LocalDB.delLoginInfo();
                          if (mounted) {
                            AppRoutes.pushAndRemoveUntil(
                                context, LogInScreen());
                          }
                        },
                        child: const Text(
                          "Sign Out",
                          style: TextStyle(color: AppColors.danger),
                        ),
                      ),
                    ],
                  ),
                );
              },
              color: AppColors.danger,
              name: "Sign Out",
            ),
          ],
        ),
      ),
    ), const OfflineBanner()]);
  }

  Color getConnectivityColor(ConnectivityState state) {
    if (state is ConnectivityOnline) return AppColors.success;
    if (state is ConnectivityOffline) return AppColors.danger;
    if (state is ConnectivityConnecting) return AppColors.warning;
    return Colors.grey;
  }

}
