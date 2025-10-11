import 'dart:async';

import 'package:flutter/cupertino.dart';
import '../../../../core/core.dart';
import '../../../feature.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  @override
  void initState() {
    super.initState();

    checkTokenAndLogoutIfExpired();
  }

  @override
  void dispose() {
    typeInventoryController.dispose();
    focusCategoryNode.dispose();
    focusInventoryNode.dispose();
    focusTestNode.dispose();
    super.dispose();
  }

  Future<void> checkTokenAndLogoutIfExpired() async {
    bool valid = await LocalDB.isTokenValid();
    if (!valid) {
      // Clear login info
      await LocalDB.delLoginInfo();
      if (mounted) {
        AppRoutes.pushReplacement(context, SplashScreen());
      }
    }
  }

  final TextEditingController typeInventoryController = TextEditingController();

  final FocusNode focusTestNode = FocusNode();
  final FocusNode focusCategoryNode = FocusNode();
  final FocusNode focusInventoryNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      child: SafeArea(child: _buildMainContent()),
    );
  }

  Widget _buildMainContent() {
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);

    return ResponsiveRow(
      spacing: 0,
      runSpacing: 0,
      children: [
        if (isBigScreen)
          ResponsiveCol(
            xs: 0,
            sm: 1,
            md: 1,
            lg: 2,
            xl: 2,
            child: Container(
              decoration: BoxDecoration(color: AppColors.whiteColor),
              child: isBigScreen ? const Sidebar() : const SizedBox.shrink(),
            ),
          ),
        ResponsiveCol(
          xs: 12,
          sm: 12,
          md: 12,
          lg: 10,
          xl: 10,
          child: Container(
            color: AppColors.bg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [SalesEntrySection()],
                    ),
                  ),
                ),
                gapH20,
                FutureBuilder<Widget>(
                  future: buildActionButtons(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return snapshot.data!;
                    }
                  },
                ),
                // buildActionButtons(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<Widget> buildActionButtons() async {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          children: [
            AppButton(name: 'Summery', onPressed: () {}, color: Colors.grey),
            gapW4,
            AppButton(
              name: 'Finder',
              onPressed: () {},
              color: Color(0xffff6347),
            ),

            gapW4,
            AppButton(
              name: 'Due Collection',
              onPressed: () {},
              color: Colors.black,
            ),
          ],
        ),
        Row(
          children: [
            const SizedBox(width: 10),
            AppButton(
              name: 'Preview',
              onPressed: () async {},
              color: const Color(0xff800000),
            ),
            const SizedBox(width: 10),
            AppButton(name: 'Submit', onPressed: () {}),
            const SizedBox(width: 5),
          ],
        ),
      ],
    );
  }
}
