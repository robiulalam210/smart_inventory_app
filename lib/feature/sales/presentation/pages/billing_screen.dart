import 'dart:async';

import 'package:flutter/cupertino.dart';
import '../../../../core/core.dart';
import '../../../feature.dart';
import '../widgets/bill_summery/bill_summery.dart';
import '../widgets/finder_invoice/finder_invoice.dart';
import '../widgets/invoice_due_collection/invoice_due_collection.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
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
      child: SafeArea(
        child:_buildMainContent(),
      ),
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
              decoration:
              BoxDecoration(color: AppColors.whiteColor),
              child: isBigScreen
                  ? const Sidebar()
                  : const SizedBox.shrink(),
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
                    physics:
                    const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SalesEntrySection(),

                      ],
                    ),
                  ),
                ),
                gapH20,
                FutureBuilder<Widget>(
                  future: buildActionButtons(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return snapshot.data!;
                    }
                  },
                )
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

            AppButton(
              name: 'Summery',
              onPressed: () {
                showFullWidthDialog(context);
              },
              color: Colors.grey,
            ),
            gapW4,
            AppButton(
              name: 'Finder',
              onPressed: () {
                showFinderInvoiceWidthDialog(context);
              },
              color: Color(0xffff6347),
            ),


            gapW4,
            AppButton(
              name: 'Due Collection',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => SizedBox(
                    // width: 750,
                    // height: 600,
                    child: InvoiceDueCollectionViewDialog(),
                  ),
                );
              },
              color: Colors.black,
            ),
          ],
        ),
        Row(
          children: [

            const SizedBox(width: 10),
            AppButton(
              name: 'Preview',
              onPressed: () async {

              },
              color: const Color(0xff800000),
            ),
            const SizedBox(width: 10),
            AppButton(
              name: 'Submit',
              onPressed: () => _handlePayment(),
            ),
            const SizedBox(width: 5),
          ],
        ),
      ],
    );
  }

  void _handlePayment() {
    final labBillingBloc = context.read<LabBillingBloc>();

    if (labBillingBloc.patientModel == null &&
        labBillingBloc.nameController.text.isEmpty) {
      showCustomToast(
        context: context,
        title: 'Warning!',
        description: 'Please select or add patient name!',
        type: ToastificationType.warning,
        icon: Icons.warning,
        primaryColor: Colors.orange,
      );

      // appSnackBar(context, "Please select or add patient name!");
    } else if (labBillingBloc.patientModel == null &&
        labBillingBloc.phoneCController.value == "") {
      showCustomToast(
        context: context,
        title: 'Warning!',
        description: 'Please select or add patient mobile number!',
        type: ToastificationType.warning,
        icon: Icons.warning,
        primaryColor: Colors.orange,
      );
    } else if (labBillingBloc.patientModel == null &&
        labBillingBloc.yearController.text.isEmpty) {
      showCustomToast(
        context: context,
        title: 'Warning!',
        description: 'Please select or add patient age!',
        type: ToastificationType.warning,
        icon: Icons.warning,
        primaryColor: Colors.orange,
      );
    } else if (labBillingBloc.patientModel == null &&
        labBillingBloc.gender == null) {
      showCustomToast(
        context: context,
        title: 'Warning!',
        description: 'Please select or add patient gender!',
        type: ToastificationType.warning,
        icon: Icons.warning,
        primaryColor: Colors.orange,
      );
    } else if (labBillingBloc.testItems.isEmpty) {
      showCustomToast(
        context: context,
        title: 'Warning!',
        description: 'Please add test!',
        type: ToastificationType.warning,
        icon: Icons.warning,
        primaryColor: Colors.orange,
      );
    } else {
      final labBillingBloc = context.read<LabBillingBloc>();

      showDialog(
        context: context,
        useSafeArea: true,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return BlocProvider.value(
            value: labBillingBloc,
            child: Builder(
              builder: (innerContext) => AlertDialog(
                backgroundColor: AppColors.whiteColor,
                content: SizedBox(
                  width: 750,
                  height: 500,
                  child: PaymentScreen(),
                ),
                actions: [
                  AppButton(
                    size: 150,
                    name: "Cancel",
                    color: AppColors.redColor,
                    onPressed: () =>
                        _showCancelConfirmationDialog(innerContext),
                  ),
                  const SizedBox(width: 10),
                  AppButton(
                    name: "Save & Print",
                    size: 150,
                    color: AppColors.primaryColor,
                    onPressed: () => _handleSaveAndPrint(innerContext),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void _handleSaveAndPrint(BuildContext context) async {
    final connectivityBloc = context.read<ConnectivityBloc>(); // ✅ fixed here
    final token = await LocalDB.getLoginInfo();
    showCustomToast(
      context: context,
      title: 'Warning!',
      description: 'Please select a Payment Method!',
      type: ToastificationType.warning,
      icon: Icons.warning,
      primaryColor: Colors.orange,
    );

    AppRoutes.pop(context);
  }

  void _showCancelConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          // backgroundColor: AppColors.whiteColor,
          title: const Text('Cancel Payment'),
          content: const Text('Are you sure you want to cancel the payment?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'No',
                style: TextStyle(color: AppColors.error),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close confirmation
                Navigator.of(context).pop(); // Close payment dialog
                showCustomToast(
                  context: context,
                  title: 'Warning!',
                  description: 'Payment Cancelled!',
                  type: ToastificationType.warning,
                  icon: Icons.warning,
                  primaryColor: Colors.orange,
                );
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
