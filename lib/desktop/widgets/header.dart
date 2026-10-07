import 'package:meherinMart/feature/auth/presentation/desktop/login_scr.dart';
import 'package:flutter/cupertino.dart';

import '../../feature/feature.dart';
import '../../feature/splash/presentation/bloc/connectivity_bloc/connectivity_state.dart';
import '../../core/configs/configs.dart';
import '../../core/widgets/app_button.dart';
import '../../core/offline/offline_config.dart';
import '../../core/offline/sync_widgets.dart';
import 'sidebar.dart';

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

    // ------------------------------------------------------------
    // Header — বাঁয়ে brand (sidebar এর ঠিক উপরে, একই প্রস্থে), তারপর
    // বর্তমান page এর নাম ও breadcrumb ("Sales › Sale List")।
    // আগে শুধু "Meherin Mart" লেখা থাকত — কোন page এ আছি বোঝার উপায়
    // ছিল শুধু sidebar এর highlight।
    // ------------------------------------------------------------
    final bool isMobile = Responsive.isMobile(context);
    final Color border = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.borderLight;

    return Column(mainAxisSize: MainAxisSize.min, children: [Container(
      height: 64,
      padding: EdgeInsets.only(
          right: isMobile ? AppSizes.paddingInside / 2 : AppSizes.paddingInside),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(builder: (context, constraints) {
          // screen গুলো sidebar কে ১২ ভাগের ২ ভাগ দেয়, আর content এর দুই
          // পাশে bodyPadding × 1.5 ফাঁকা — তাই brand এর প্রস্থও সেভাবে
          const double sidePad = AppSizes.bodyPadding * 1.5;
          final double brandWidth =
              sidePad + (constraints.maxWidth - sidePad * 2) / 6;

          return Row(
          children: [
            SizedBox(
              width: brandWidth,
              child: Padding(
                padding: const EdgeInsets.only(left: sidePad + 12, right: 8),
                child: Row(
                  children: [
                    Flexible(
                      child: Image.asset(
                        AppImages.logo,
                        height: 34,
                        fit: BoxFit.contain,
                        alignment: Alignment.centerLeft,
                        errorBuilder: (_, __, ___) => Text(
                          AppConstants.appName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(width: 1, height: 32, color: border),
            const SizedBox(width: 16),
            const Expanded(child: _PageTitle()),
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

                  return SizedBox(
                    height: 34,
                    child: AppButton(
                      onPressed: () {},
                      color: getConnectivityColor(state),
                      name: status,
                    ),
                  );
                },
              ),


            gapW8,
            // Sign out button — আগে AppButton header এর পুরো উচ্চতা
            // (৬৪px) জুড়ে লাল block হয়ে যেত। এখন নির্দিষ্ট উচ্চতার
            // outlined বাটন, icon সহ; Sync chip এর সাথে একই লাইনে
            const _SignOutButton(),
          ],
        );
        }),
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


/// বর্তমান page এর নাম + breadcrumb। DashboardBloc এর শুধু screen বদলের
/// state শোনে — dashboard data load হওয়ার state এ নাম লাফায় না।
class _PageTitle extends StatelessWidget {
  const _PageTitle();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      buildWhen: (prev, curr) => curr is DashboardScreenChanged,
      builder: (context, state) {
        final int index = state is DashboardScreenChanged ? state.index : 0;
        final info = sidebarPageInfo(index);
        final Color primary = AppColors.primaryColor(context);
        final Color text = AppColors.text(context);

        return Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(info.icon, size: 19, color: primary),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (info.section != null)
                    Text(
                      '${info.section}  ›  ${info.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 11.5, color: text.withValues(alpha: 0.55)),
                    ),
                  Text(
                    info.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: text,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}


class _SignOutButton extends StatelessWidget {
  const _SignOutButton();

  /// বাটনের ঠিক নিচে ছোট confirm popover (পর্দার মাঝে বড় dialog নয়)।
  /// Sync না হওয়া entry থাকলে OfflineGuards আগে জানায়।
  Future<void> _signOut(BuildContext btnContext) async {
    final ok = await showConfirmPopover(
      btnContext,
      title: 'Sign out?',
      message: 'You will need to log in again to use the app.',
      confirmText: 'Sign Out',
      tone: PopoverTone.danger,
      icon: Icons.logout_rounded,
      mode: PopoverAnchorMode.anchored,
    );
    if (!ok || !btnContext.mounted) return;
    if (!await OfflineGuards.confirmLogout(btnContext)) return;
    await LocalDB.delLoginInfo();
    if (btnContext.mounted) {
      AppRoutes.pushAndRemoveUntil(btnContext, LogInScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (btnContext) => SizedBox(
        height: 36,
        child: OutlinedButton.icon(
          onPressed: () => _signOut(btnContext),
          icon: const Icon(Icons.logout_rounded, size: 17),
          label: const Text(
            'Sign Out',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.danger,
            side: BorderSide(color: AppColors.danger.withValues(alpha: 0.45)),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ).copyWith(
            overlayColor: WidgetStatePropertyAll(
              AppColors.danger.withValues(alpha: 0.08),
            ),
          ),
        ),
      ),
    );
  }
}
