import 'dart:async';

import '../../../../core/core.dart';
import '../../../feature.dart';

class LabDashboardScreen extends StatefulWidget {
  const LabDashboardScreen({super.key});

  @override
  State<LabDashboardScreen> createState() => _LabDashboardScreenState();
}

class _LabDashboardScreenState extends State<LabDashboardScreen> {
  int selectedIndex = 1;
  List<String> labels = ['Today', 'Week', 'Month', 'Year'];

  DateRangeFilter _mapSelectedIndexToFilter(int index) {
    switch (index) {
      case 0:
        return DateRangeFilter.today;
      case 1:
        return DateRangeFilter.last7Days;
      case 2:
        return DateRangeFilter.last30Days;
      case 3:
        return DateRangeFilter.last365Days;
      default:
        return DateRangeFilter.all;
    }
  }

  @override
  void initState() {
    super.initState();

    context.read<DashboardBloc>().add(
        LoadDashboardData(filter: _mapSelectedIndexToFilter(selectedIndex)));
    context.read<PrintLayoutBloc>().add(FetchPrintLayout());

    checkTokenAndLogoutIfExpired();
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

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> drawerKey = GlobalKey<ScaffoldState>();
    final ScrollController scrollController = ScrollController();
    final syncBloc = context.read<SyncBloc>();

    return Container(
      color: AppColors.bg,
      key: drawerKey,
      child: SafeArea(
        child: SizedBox(
          height: AppSizes.height(context) * 0.95,
          child: MultiBlocListener(
            listeners: [
              BlocListener<AllSetupBloc, AllSetupState>(
                listener: (context, state) {
                  context.read<AllSetupCombinedCubit>().updateSetup(state);
                },
              ),
              BlocListener<AllInvoiceSetupBloc, AllInvoiceSetupState>(
                listener: (context, state) {
                  context.read<AllSetupCombinedCubit>().updateInvoice(state);
                },
              ),
              BlocListener<AllSetupCombinedCubit, AllSetupCombinedState>(
                listener: (context, state) {
                  if (state.setupState is AllSetupLoaded &&
                      state.invoiceState is AllInvoiceSetupLoaded) {
                    // AppRoutes.pop(context);
                    final setup = state.setupState as AllSetupLoaded;
                    final invoice = state.invoiceState as AllInvoiceSetupLoaded;

                    final doctorsList = setup.allSetupModel.data?.doctors ?? [];
                    final boothsList = setup.allSetupModel.data?.booths ?? [];
                    final collectorInfoList =
                        setup.allSetupModel.data?.collectorInfo ?? [];
                    final testParameterList =
                        setup.allSetupModel.data?.testParameterSetup ?? [];
                    final testNameConfigList =
                        setup.allSetupModel.data?.testNameConfigSetup ?? [];
                    final parameterGroupList =
                        setup.allSetupModel.data?.parameterGroupSetup ?? [];
                    final parameterList =
                        setup.allSetupModel.data?.parameterSetup ?? [];
                    final printLayout = setup.allSetupModel.data?.printLayout;
                    final categoriesList =
                        setup.allSetupModel.data?.testCategory ?? [];
                    final testNamesList =
                        setup.allSetupModel.data?.testName ?? [];
                    final gendersList = setup.allSetupModel.data?.gender ?? [];
                    final bloodGroupsList =
                        setup.allSetupModel.data?.bloodGroup ?? [];
                    final inventoryList =
                        setup.allSetupModel.data?.inventories ?? [];
                    final patientsList =
                        setup.allSetupModel.data?.patient ?? [];
                    final testGroupList =
                        setup.allSetupModel.data?.testGroup ?? [];
                    final specimenList =
                        setup.allSetupModel.data?.specimen ?? [];
                    final caseEffectList =
                        setup.allSetupModel.data?.caseEffect ?? [];
                    final marketerList =
                        setup.allSetupModel.data?.marketerList ?? [];
                    final invoices = invoice.allSetupModel.data ?? [];

                    context.read<SyncBloc>().add(SyncAllData(
                          doctors: doctorsList,
                          categories: categoriesList,
                          testNames: testNamesList,
                          genders: gendersList,
                          bloodGroups: bloodGroupsList,
                          patients: patientsList,
                          inventoryItems: inventoryList,
                          invoices: invoices,
                          booths: boothsList,
                          collectorInfo: collectorInfoList,
                          parameterGroupSetup: parameterGroupList,
                          parameterSetup: parameterList,
                          testParameterSetup: testParameterList,
                          testNameConfigSetup: testNameConfigList,
                          setupSpecimen: specimenList,
                          setupTestGroup: testGroupList,
                          printLayout: printLayout,
                          caseEffect: caseEffectList,
                          marketerList: marketerList,
                        ));
                  }

                  if (state.setupState is AllSetupError) {
                    // AppRoutes.pop(context);

                    final error = state.setupState as AllSetupError;
                    showCustomToast(
                      context: context,
                      title: 'Failed!',
                      description: 'Setup Error: ${error.message}',
                      type: ToastificationType.error,
                      icon: Icons.error,
                      primaryColor: Colors.red,
                    );
                  }

                  if (state.invoiceState is AllInvoiceSetupError) {
                    final error = state.invoiceState as AllInvoiceSetupError;
                    showCustomToast(
                      context: context,
                      title: 'Failed!',
                      description: 'Invoice Error: ${error.message}',
                      type: ToastificationType.error,
                      icon: Icons.error,
                      primaryColor: Colors.red,
                    );
                  }
                },
              ),
              BlocListener<SyncBloc, SyncState>(
                listener: (context, state) {
                  if (state is SyncSuccess) {
                    context.read<DashboardBloc>().add(LoadDashboardData(
                        filter: _mapSelectedIndexToFilter(selectedIndex)));

                    showCustomToast(
                      context: context,
                      title: 'Success!',
                      description: 'Sync completed successfully.',
                      type: ToastificationType.success,
                      icon: Icons.check_circle,
                      primaryColor: Colors.green,
                    );
                  } else if (state is SyncFailure) {
                    showCustomToast(
                      context: context,
                      title: 'Failed!',
                      description: state.error,
                      type: ToastificationType.error,
                      icon: Icons.error,
                      primaryColor: Colors.red,
                    );
                  }
                  if (state is SyncServerLoading) {
                    appLoader(context, "Loading in, please wait...");
                  }
                  if (state is SyncServerSuccess) {
                    AppRoutes.pop(context);
                    showCustomToast(
                      context: context,
                      title: 'Success!',
                      description: 'Sync completed successfully.',
                      type: ToastificationType.success,
                      icon: Icons.check_circle,
                      primaryColor: Colors.green,
                    );

                    BlocProvider.of<AllSetupBloc>(context)
                        .add(FetchAllSetupEvent(context));
                    BlocProvider.of<AllInvoiceSetupBloc>(context)
                        .add(FetchAllInvoiceSetupEvent(context));
                  }
                  if (state is SyncServerFailure) {
                    AppRoutes.pop(context);
                    showCustomToast(
                      context: context,
                      title: 'Failed!',
                      description: state.error,
                      type: ToastificationType.error,
                      icon: Icons.error,
                      primaryColor: Colors.red,
                    );
                  }
                },
              ),
              BlocListener<InvoiceUnSyncBloc, InvoiceUnSyncState>(
                listener: (context, state) async {
                  if (state is InvoiceUnSyncLoading) {
                    appLoader(
                        context, "Loading for un sync data , please wait...");
                  } else if (state is InvoiceUnSyncLoaded) {
                    AppRoutes.pop(context);
                    context.read<InvoiceUnSyncBloc>().add(
                          PostUnSyncInvoice(
                              body: state.invoices ?? [],
                              invoiceCreate: false,
                              isSingleSync: false),
                        );
                  } else if (state is InvoiceUnSyncEmpty) {
                    AppRoutes.pop(context);
                    BlocProvider.of<AllSetupBloc>(context)
                        .add(FetchAllSetupEvent(context));

                    BlocProvider.of<AllInvoiceSetupBloc>(context)
                        .add(FetchAllInvoiceSetupEvent(context));
                  } else if (state is InvoiceSyncError) {
                    AppRoutes.pop(context);
                    showCustomToast(
                      context: context,
                      title: 'Failed!',
                      description: state.error,
                      type: ToastificationType.error,
                      icon: Icons.error,
                      primaryColor: Colors.red,
                    );
                  } else if (state is PostInvoiceUnSyncLoading) {
                    appLoader(
                        context, "Data Send Server Loading in, please wait...");
                  } else if (state is PostInvoiceUnSyncLoaded) {
                    AppRoutes.pop(context);

                    Timer(Duration(milliseconds: 500), () {
                      if (!state.isCreate) {
                        for (var invoiceItem in state.invoices.data ?? []) {
                          syncBloc.add(SyncInvoiceAndPatientEvent(
                            invoice: invoiceItem.invoice!.toJson(),
                            patient: invoiceItem.patient!.toJson(),
                            moneyReceipt: List<Map<String, dynamic>>.from(
                                invoiceItem.moneyReceipt
                                        ?.map((e) => e.toJson()) ??
                                    []),
                            test: List<Map<String, dynamic>>.from(
                                invoiceItem.test?.map((e) => e.toJson()) ?? []),
                            inventory: List<Map<String, dynamic>>.from(
                                invoiceItem.inventory?.map((e) => e.toJson()) ??
                                    []),
                            isSingleSync: state.isSingleSync,
                          ));
                        }
                      }
                    });
                  } else if (state is PostInvoiceSyncError) {
                    AppRoutes.pop(context);
                    showCustomToast(
                      context: context,
                      title: 'Failed!',
                      description: 'Sync Server failed: ${state.error}',
                      type: ToastificationType.error,
                      icon: Icons.error,
                      primaryColor: Colors.red,
                    );
                  }
                },
              ),
            ],
            child: Stack(
              children: [
                _buildMainContent(context, drawerKey, scrollController),
                BlocBuilder<SyncBloc, SyncState>(
                  builder: (context, state) {
                    if (state is SyncInProgress) {
                      return Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Synchronizing Data',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: 200,
                                child: LinearProgressIndicator(
                                  value: state.percentage / 100,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${state.progress}/${state.total} (${state.percentage.toStringAsFixed(1)}%)',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              if (state.currentOperation.isNotEmpty)
                                Text(
                                  state.currentOperation,
                                  style: const TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    GlobalKey<ScaffoldState> drawerKey,
    ScrollController scrollController,
  ) {
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Lab Dashboard",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          ToggleButtons(
                            borderRadius: BorderRadius.circular(8),
                            borderColor: Colors.grey.shade300,
                            selectedBorderColor: Colors.blue,
                            fillColor: Colors.blue.shade50,
                            selectedColor: Colors.blue.shade700,
                            color: Colors.black,
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.w600),
                            isSelected: List.generate(labels.length,
                                (index) => selectedIndex == index),
                            onPressed: (index) {
                              setState(() {
                                selectedIndex = index;
                              });
                              final filter = _mapSelectedIndexToFilter(index);
                              context
                                  .read<DashboardBloc>()
                                  .add(LoadDashboardData(filter: filter));
                            },
                            children: labels
                                .map((label) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Text(label),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                      gapH16,
                      BlocBuilder<DashboardBloc, DashboardState>(
                        builder: (context, state) {
                          if (state is DashboardLoading) {
                            return CircularProgressIndicator();
                          }
                          if (state is DashboardLoaded) {
                            final data = state.data;
                            return Column(
                              children: [
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    dashboardCardItem(
                                      title: "Total Amount",
                                      value: data.totalAmount,
                                      icon: Icons.attach_money,
                                      color: Colors.orange,
                                      isCurrency: true,
                                    ),
                                    dashboardCardItem(
                                      title: "Total Patient",
                                      value: int.tryParse(
                                              data.totalPatients.toString()) ??
                                          0,
                                      icon: Icons.people,
                                      color: Colors.blue,
                                    ),
                                    dashboardCardItem(
                                      title: "Discount",
                                      value: data.totalDiscount,
                                      icon: Icons.attach_money,
                                      color: Colors.green,
                                      isCurrency: true,
                                    ),
                                    dashboardCardItem(
                                      title: "Total Due",
                                      value: data.totalDue,
                                      icon: Icons.money_off,
                                      color: Colors.green,
                                      isCurrency: true,
                                    ),
                                    dashboardCardItem(
                                      title: "Net Amount",
                                      value: (data.totalAmount -
                                          data.totalDiscount),
                                      icon: Icons.payments,
                                      color: Colors.orange,
                                      isCurrency: true,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    dashboardCardItem(
                                      itemsPerRow: 4,
                                      title: "Due Collection",
                                      value: data.dueCollection,
                                      icon: Icons.credit_score,
                                      color: Colors.green,
                                      isCurrency: true,
                                    ),
                                    dashboardCardItem(
                                      itemsPerRow: 4,
                                      title: "Total Received",
                                      value: data.totalReceived,
                                      icon: Icons.payment,
                                      color: Colors.green,
                                      isCurrency: true,
                                    ),
                                    dashboardCardItem(
                                      itemsPerRow: 4,
                                      title: "Total Test",
                                      value: int.tryParse(data.totalInvoiceTests
                                              .toString()) ??
                                          0,
                                      icon: Icons.science,
                                      color: Colors.orange,
                                    ),
                                    dashboardCardItem(
                                        itemsPerRow: 4,
                                        title: "Total Doctor",
                                        value: int.tryParse(
                                                data.totalDoctors.toString()) ??
                                            0,
                                        icon: Icons.medical_services,
                                        color: Colors.orange),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 250,
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: BillingChart(
                                              invoices: data.invoiceChart)),
                                      Expanded(
                                          child: RegisteredPatientChart(
                                              patients: data.patientChart)),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                          if (state is DashboardError) {
                            return Text(state.message);
                          }
                          return SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }
}
