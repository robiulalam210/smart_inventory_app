import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/configs/app_colors.dart';
import '../../../../core/configs/app_sizes.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../responsive.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/low_stock.dart';
import '../widgets/top_selling.dart';
// import your needed packages and files

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 1;

  // Example for sales/purchase segmented control
  String selectedSalesOverviewType = 'current_day';
  String selectedPurchaseOverviewType = 'current_day';

  final GlobalKey<ScaffoldState> drawerKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);
    final ScrollController scrollController = ScrollController();
    return Container(
      color: AppColors.bg,
      key: drawerKey,
      child: SafeArea(
        child: SizedBox(
          height: AppSizes.height(context) * 0.95,
          child: ResponsiveRow(
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
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.7),
                        width: 0.5,
                      ),
                    ),
                    child: isBigScreen ? const Sidebar() : null,
                  ),
                ),
              ResponsiveCol(
                xs: 12,
                sm: 12,
                md: 12,
                lg: 10,
                xl: 10,
                child: SizedBox(
                  height: AppSizes.height(context) * 0.90,
                  child: Scrollbar(
                    controller: scrollController,
                    thickness: 8,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          // ==== DASHBOARD SUMMARY CARDS ====
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Lab Dashboard",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: AppSizes.width(context) * 0.25,
                                child: CupertinoSegmentedControl<String>(
                                  padding: EdgeInsets.zero,
                                  children: {
                                    'current_day': Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                        horizontal: 1.0,
                                      ),
                                      child: Text(
                                        'Today',
                                        style: TextStyle(
                                          fontFamily:
                                              GoogleFonts.playfairDisplay()
                                                  .fontFamily,
                                          color:
                                              selectedPurchaseOverviewType ==
                                                  'current_day'
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    'this_month': Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 0.0,
                                        horizontal: 1.0,
                                      ),
                                      child: Text(
                                        DateFormat(
                                          'MMMM',
                                        ).format(DateTime.now()),
                                        style: TextStyle(
                                          fontFamily:
                                              GoogleFonts.playfairDisplay()
                                                  .fontFamily,
                                          color:
                                              selectedPurchaseOverviewType ==
                                                  'this_month'
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    'lifeTime': Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 0.0,
                                        horizontal: 2.0,
                                      ),
                                      child: Text(
                                        'Life Time',
                                        style: TextStyle(
                                          fontFamily:
                                              GoogleFonts.playfairDisplay()
                                                  .fontFamily,
                                          color:
                                              selectedPurchaseOverviewType ==
                                                  'lifeTime'
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  },
                                  onValueChanged: (value) {
                                    setState(() {
                                      selectedPurchaseOverviewType = value;
                                      // _fetchApi(sFilter: selectedSalesOverviewType, pFilter: selectedPurchaseOverviewType);
                                    });
                                  },
                                  groupValue: selectedPurchaseOverviewType,
                                  unselectedColor: Colors.white54,
                                  selectedColor: AppColors.primaryColor,
                                  borderColor: AppColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // -- Lab stat cards
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              dashboardCardItem(
                                title: "Total Amount",
                                value: 55,
                                icon: Icons.attach_money,
                                color: Colors.orange,
                                isCurrency: true,
                              ),
                              dashboardCardItem(
                                title: "Total Patient",
                                value: 0,
                                icon: Icons.people,
                                color: Colors.blue,
                              ),
                              dashboardCardItem(
                                title: "Discount",
                                value: 4,
                                icon: Icons.attach_money,
                                color: Colors.green,
                                isCurrency: true,
                              ),
                              dashboardCardItem(
                                title: "Total Due",
                                value: 4,
                                icon: Icons.money_off,
                                color: Colors.green,
                                isCurrency: true,
                              ),
                              dashboardCardItem(
                                title: "Net Amount",
                                value: 4,
                                icon: Icons.payments,
                                color: Colors.orange,
                                isCurrency: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // ==== SALES OVERVIEW SEGMENTED CONTROL + CARDS ====
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6.0,
                                        horizontal: 6.0,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.white,
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Sales Overview",
                                                style: TextStyle(
                                                  fontFamily:
                                                      GoogleFonts.playfairDisplay()
                                                          .fontFamily,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize:
                                                      Responsive.isMobile(
                                                        context,
                                                      )
                                                      ? 14
                                                      : 18,
                                                ),
                                              ),
                                              SizedBox(
                                                width:
                                                    AppSizes.width(context) *
                                                    0.20,
                                                child: CupertinoSegmentedControl<String>(
                                                  padding: EdgeInsets.zero,
                                                  children: {
                                                    'current_day': Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 4.0,
                                                            horizontal: 1.0,
                                                          ),
                                                      child: Text(
                                                        'Today',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              GoogleFonts.playfairDisplay()
                                                                  .fontFamily,
                                                          color:
                                                              selectedSalesOverviewType ==
                                                                  'current_day'
                                                              ? Colors.white
                                                              : Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                    'this_month': Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 0.0,
                                                            horizontal: 1.0,
                                                          ),
                                                      child: Text(
                                                        DateFormat(
                                                          'MMMM',
                                                        ).format(
                                                          DateTime.now(),
                                                        ),
                                                        style: TextStyle(
                                                          fontFamily:
                                                              GoogleFonts.playfairDisplay()
                                                                  .fontFamily,
                                                          color:
                                                              selectedSalesOverviewType ==
                                                                  'this_month'
                                                              ? Colors.white
                                                              : Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                    'lifeTime': Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 0.0,
                                                            horizontal: 2.0,
                                                          ),
                                                      child: Text(
                                                        'Life Time',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              GoogleFonts.playfairDisplay()
                                                                  .fontFamily,
                                                          color:
                                                              selectedSalesOverviewType ==
                                                                  'lifeTime'
                                                              ? Colors.white
                                                              : Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  },
                                                  onValueChanged: (value) {
                                                    setState(() {
                                                      selectedSalesOverviewType =
                                                          value;
                                                      // _fetchApi(sFilter: selectedSalesOverviewType, pFilter: selectedPurchaseOverviewType);
                                                    });
                                                  },
                                                  groupValue:
                                                      selectedSalesOverviewType,
                                                  unselectedColor:
                                                      Colors.white54,
                                                  selectedColor:
                                                      AppColors.primaryColor,
                                                  borderColor:
                                                      AppColors.primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              StatsCardMonthly(
                                                title: "Total Sold Quantity\n",
                                                count: "0",
                                                //state.dashboard.salesData?.totalQuantitySold?.toStringAsFixed(2) ?? "0",
                                                color: Colors.pink,
                                                icon: "assets/images/sold.png",
                                              ),
                                              SizedBox(
                                                width:
                                                    Responsive.isMobile(context)
                                                    ? 5
                                                    : 10,
                                              ),
                                              StatsCardMonthly(
                                                title: "Total Amount",
                                                count: "0",
                                                //state.dashboard.salesData?.totalRevenue?.toStringAsFixed(2) ?? "0",
                                                color: Colors.purple,
                                                icon: "assets/images/gross.png",
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              StatsCardMonthly(
                                                title: "Total Expense",
                                                count: "0",
                                                //state.dashboard.salesData?.cost ?? "0",
                                                color: Colors.greenAccent,
                                                icon:
                                                    "assets/images/graphs.png",
                                              ),
                                              SizedBox(
                                                width:
                                                    Responsive.isMobile(context)
                                                    ? 5
                                                    : 20,
                                              ),
                                              StatsCardMonthly(
                                                title: "Profit / Loss",
                                                count: "0",
                                                //state.dashboard.salesData?.profitLoss?.toStringAsFixed(2) ?? "0",
                                                color: Colors.amber,
                                                icon:
                                                    "assets/images/expenses.png",
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6.0,
                                        horizontal: 3.0,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.white,
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Purchase Overview",
                                                style: TextStyle(
                                                  fontFamily:
                                                      GoogleFonts.playfairDisplay()
                                                          .fontFamily,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize:
                                                      Responsive.isMobile(
                                                        context,
                                                      )
                                                      ? 12
                                                      : 18,
                                                ),
                                              ),
                                              SizedBox(
                                                width:
                                                    AppSizes.width(context) *
                                                    0.20,
                                                child: CupertinoSegmentedControl<String>(
                                                  padding: EdgeInsets.zero,
                                                  children: {
                                                    'current_day': Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 4.0,
                                                            horizontal: 1.0,
                                                          ),
                                                      child: Text(
                                                        'Today',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              GoogleFonts.playfairDisplay()
                                                                  .fontFamily,
                                                          color:
                                                              selectedPurchaseOverviewType ==
                                                                  'current_day'
                                                              ? Colors.white
                                                              : Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                    'this_month': Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 0.0,
                                                            horizontal: 1.0,
                                                          ),
                                                      child: Text(
                                                        DateFormat(
                                                          'MMMM',
                                                        ).format(
                                                          DateTime.now(),
                                                        ),
                                                        style: TextStyle(
                                                          fontFamily:
                                                              GoogleFonts.playfairDisplay()
                                                                  .fontFamily,
                                                          color:
                                                              selectedPurchaseOverviewType ==
                                                                  'this_month'
                                                              ? Colors.white
                                                              : Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                    'lifeTime': Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 0.0,
                                                            horizontal: 2.0,
                                                          ),
                                                      child: Text(
                                                        'Life Time',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              GoogleFonts.playfairDisplay()
                                                                  .fontFamily,
                                                          color:
                                                              selectedPurchaseOverviewType ==
                                                                  'lifeTime'
                                                              ? Colors.white
                                                              : Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  },
                                                  onValueChanged: (value) {
                                                    setState(() {
                                                      selectedPurchaseOverviewType =
                                                          value;
                                                      // _fetchApi(sFilter: selectedSalesOverviewType, pFilter: selectedPurchaseOverviewType);
                                                    });
                                                  },
                                                  groupValue:
                                                      selectedPurchaseOverviewType,
                                                  unselectedColor:
                                                      Colors.white54,
                                                  selectedColor:
                                                      AppColors.primaryColor,
                                                  borderColor:
                                                      AppColors.primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              StatsCardMonthly(
                                                title:
                                                    "Total Purchase \nQuantity",
                                                count: "0",
                                                //state.dashboard.purchaseData?.numberOfQuantity ?? "0",
                                                color: Colors.blue,
                                                icon: "assets/images/buy.png",
                                              ),
                                              SizedBox(
                                                width:
                                                    Responsive.isMobile(context)
                                                    ? 5
                                                    : 20,
                                              ),
                                              StatsCardMonthly(
                                                title: "Total Amount \n",
                                                count: "0",
                                                //state.dashboard.purchaseData?.totalPurchaseAmount ?? "0",
                                                color: Colors.green,
                                                icon: "assets/images/gross.png",
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              StatsCardMonthly(
                                                title: "Total Due",
                                                count: "0",
                                                //state.dashboard.purchaseData?.totalPurchaseDue ?? "0",
                                                color: Colors.redAccent,
                                                icon:
                                                    "assets/images/cancel.png",
                                              ),
                                              SizedBox(
                                                width:
                                                    Responsive.isMobile(context)
                                                    ? 5
                                                    : 20,
                                              ),
                                              StatsCardMonthly(
                                                title: "Total Returns",
                                                count: "0",
                                                //state.dashboard.purchaseData?.purchaseReturn ?? "0",
                                                color: Colors.black,
                                                icon:
                                                    "assets/images/product_return.png",
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // ==== PURCHASE OVERVIEW SEGMENTED CONTROL + CARDS ====
                          const SizedBox(height: 16),

                          // ==== TABBED INVENTORY/ANALYTICS VIEW ====
                          // Container(
                          //   height: AppSizes.height(context) * 0.50,
                          //   decoration: BoxDecoration(
                          //     color: Colors.white,
                          //     borderRadius: BorderRadius.circular(8),
                          //   ),
                          //   child: DefaultTabController(
                          //     length: 6,
                          //     child: Column(
                          //       children: [
                          //         TabBar(
                          //           tabs: const [
                          //             Tab(text: 'Top Selling'),
                          //             Tab(text: 'Low Stock'),
                          //             Tab(text: 'Top Customers Due'),
                          //             Tab(text: 'Top Suppliers Due'),
                          //             Tab(text: 'Current Balance'),
                          //             Tab(text: 'Sales & Purchase Stats'),
                          //           ],
                          //           isScrollable: true,
                          //           dividerColor: Colors.transparent,
                          //           tabAlignment: TabAlignment.start,
                          //           labelColor: Colors.black,
                          //           indicatorColor: Colors.orangeAccent,
                          //           // labelStyle: AppTextStyle.cardLevelText(context),
                          //         ),
                          //         Expanded(
                          //           child: TabBarView(
                          //             children: [
                          //               SingleChildScrollView(
                          //                 child: topSelling(context, []),
                          //               ),
                          //               //state.dashboard.topProduct ?? []
                          //               SingleChildScrollView(
                          //                 child: lowStock(context, []),
                          //               ),
                          //               //state.dashboard.lowStockProducts ?? []
                          //               SingleChildScrollView(
                          //                 child: customer(
                          //                   context,
                          //                   itemName: "Customers",
                          //                   lowStockProducts: [],
                          //                 ),
                          //               ),
                          //               //state.dashboard.topClients ?? []
                          //               SingleChildScrollView(
                          //                 child: customer(
                          //                   context,
                          //                   itemName: "Supplier",
                          //                   lowStockProducts: [],
                          //                 ),
                          //               ),
                          //               //state.dashboard.topSuppliers ?? []
                          //               Padding(
                          //                 padding: const EdgeInsets.all(16.0),
                          //                 child: ListView.builder(
                          //                   shrinkWrap: true,
                          //                   physics:
                          //                       const NeverScrollableScrollPhysics(),
                          //                   itemCount: 0,
                          //                   //state.dashboard.accounts?.length ?? 0,
                          //                   itemBuilder: (_, index) {
                          //                     // final account = state.dashboard.accounts?[index];
                          //                     // return AccountCardDashbord(account: account!, index: index + 1);
                          //                     return SizedBox();
                          //                   },
                          //                 ),
                          //               ),
                          //               SingleChildScrollView(
                          //                 child: Container(
                          //                   padding: const EdgeInsets.all(8),
                          //                   decoration: BoxDecoration(
                          //                     color: Colors.white,
                          //                     borderRadius:
                          //                         BorderRadius.circular(8),
                          //                   ),
                          //                   child: Column(
                          //                     children: [
                          //                       // statisticsChart([]), //state.dashboard.revenueAndPurchase ?? []
                          //                       const Row(
                          //                         mainAxisAlignment:
                          //                             MainAxisAlignment.center,
                          //                         crossAxisAlignment:
                          //                             CrossAxisAlignment.center,
                          //                         children: [
                          //                           CircleAvatar(
                          //                             maxRadius: 5,
                          //                             backgroundColor:
                          //                                 Colors.blueAccent,
                          //                           ),
                          //                           SizedBox(width: 5),
                          //                           Text("Sales"),
                          //                           SizedBox(width: 5),
                          //                           CircleAvatar(
                          //                             maxRadius: 5,
                          //                             backgroundColor:
                          //                                 Colors.greenAccent,
                          //                           ),
                          //                           SizedBox(width: 5),
                          //                           Text("Purchase"),
                          //                         ],
                          //                       ),
                          //                     ],
                          //                   ),
                          //                 ),
                          //               ),
                          //             ],
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatsCardMonthly extends StatelessWidget {
  final String title;
  final String count;
  final Color color;
  final String icon;

  const StatsCardMonthly({
    super.key,
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            // BoxShadow(
            //   // color: Color.fromARGB(17, 0, 0, 0),
            //   // spreadRadius: 5,
            //   // blurRadius: 5,
            // ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          // Clip contents to the same radius as the container
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: Responsive.isMobile(context) ? 14 : 18,
                        fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          // decoration: BoxDecoration(
                          //   color: color.withValues(alpha: 0.5),
                          //   shape: BoxShape.circle,
                          // ),
                          // child: Image.asset(
                          //   icon,
                          //   color: Colors.white,
                          //   width: Responsive.isMobile(context)
                          //       ? 35
                          //       : 50, // Replace with your AppColors.whiteColor if defined
                          // ),
                        ),
                        const SizedBox(width: 3),
                        SizedBox(
                          // width: AppSizes.width(context) * 0.18,
                          child: Text(
                            count.toString(),
                            maxLines: 2,
                            style: TextStyle(
                              color: color,
                              fontFamily:
                                  GoogleFonts.playfairDisplay().fontFamily,
                              fontSize: Responsive.isMobile(context) ? 16 : 24,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: -40,
                // Adjust as needed to control circle's vertical position
                right: -40,
                // Adjust as needed to control circle's horizontal position
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
