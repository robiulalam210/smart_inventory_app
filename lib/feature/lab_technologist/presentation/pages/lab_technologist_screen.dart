import 'dart:async';

import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sidemenu/sidebar.dart';
import '../../../../core/utilities/app_date_time.dart';
import '../../../../core/utilities/app_debouncer.dart';
import '../../../../core/widgets/app_input_widgets.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/pagination_bar.dart';
import '../../../../core/widgets/show_custom_toast.dart';
import '../../../feature.dart';

class LabTechnologistScreen extends StatefulWidget {
  const LabTechnologistScreen({super.key});

  @override
  State<LabTechnologistScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<LabTechnologistScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  final ValueNotifier<DateTimeRange?> _dateRange =
      ValueNotifier<DateTimeRange?>(null);
  final ValueNotifier<List<SampleCollectorInvoice>> _filteredInvoices =
      ValueNotifier<List<SampleCollectorInvoice>>([]);
  final AppDebouncer _searchDebouncer = AppDebouncer(millisecond: 500);

  List<SampleCollectorInvoice> _allInvoices = [];
// default value
  int currentPage = 1;
  int itemsPerPage = 20;

  @override
  void initState() {
    super.initState();
    _loadInvoices();

    // Add search listener with debounce
    _searchController.addListener(() {
      _searchDebouncer.run(() {
        _applyFiltersAndFetch();
      });
    });

    // Add date range listener to refetch when date range changes
    _dateRange.addListener(() {
      _applyFiltersAndFetch();
    });
  }

  Future<void> _loadInvoices({
    String? query,
    DateTime? from,
    DateTime? to,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {


    context.read<SampleCollectorBloc>().add(LoadSampleCollectorInvoices(
          query: query ?? '',
          fromDate: from,
          toDate: to,
          pageNumber: pageNumber,
          pageSize: pageSize,
        ));
  }

  void _applyFiltersAndFetch() {
    final query = _searchController.text.trim();
    final range = _dateRange.value;

    _filteredInvoices.value = []; // Clear old filtered list while loading
    _loadInvoices(
        query: query.isEmpty ? null : query,
        from: range?.start,
        to: range?.end,
        pageNumber: currentPage,
        pageSize: itemsPerPage);
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    _searchController.dispose();
    _filteredInvoices.dispose();
    _dateRange.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final syncBloc = context.read<SyncBloc>();
    return Container(
      color: AppColors.bg,
      child: SafeArea(
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
                  final invoice =
                  state.invoiceState as AllInvoiceSetupLoaded;

                  final doctorsList =
                      setup.allSetupModel.data?.doctors ?? [];
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
                  final gendersList =
                      setup.allSetupModel.data?.gender ?? [];
                  final bloodGroupsList =
                      setup.allSetupModel.data?.bloodGroup ?? [];
                  final inventoryList =
                      setup.allSetupModel.data?.inventories ?? [];
                  final patientsList = setup.allSetupModel.data?.patient ?? [];
                  final testGroupList = setup.allSetupModel.data?.testGroup ?? [];
                  final specimenList = setup.allSetupModel.data?.specimen ?? [];
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
                  _applyFiltersAndFetch();
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
                  _applyFiltersAndFetch();
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
                  appLoader(context, "Loading in, please wait...");
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
                  appLoader(context, "Post Loading in, please wait...");
                } else if (state is PostInvoiceUnSyncLoaded) {
                  AppRoutes.pop(context);

                  Timer(Duration(milliseconds: 500), () {
                    if (!state.isCreate) {
                      for (var invoiceItem in state.invoices.data ?? []) {
                        syncBloc.add(SyncInvoiceAndPatientEvent(
                          invoice: invoiceItem.invoice!.toJson(),
                          patient: invoiceItem.patient!.toJson(),
                          moneyReceipt: List<Map<String, dynamic>>.from(
                              invoiceItem.moneyReceipt?.map((e) => e.toJson()) ?? []),
                          test: List<Map<String, dynamic>>.from(
                              invoiceItem.test?.map((e) => e.toJson()) ?? []),
                          inventory: List<Map<String, dynamic>>.from(
                              invoiceItem.inventory?.map((e) => e.toJson()) ?? []),
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
              _buildMainContent(),
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
                                    fontSize: 18, fontWeight: FontWeight.bold)),
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
    );
  }


  Widget _buildMainContent() {
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);

    return ResponsiveRow(
      spacing: 0,
      runSpacing: 0,
      children: [
        if (isBigScreen) _buildSidebar(),
        _buildContentArea(isBigScreen),
      ],
    );
  }

  Widget _buildSidebar() {
    return ResponsiveCol(
      xs: 0,
      sm: 1,
      md: 1,
      lg: 2,
      xl: 2,
      child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: const Sidebar(),
      ),
    );
  }

  Widget _buildContentArea(bool isBigScreen) {
    return ResponsiveCol(
      xs: 12,
      sm: 12,
      md: 12,
      lg: 10,
      xl: 10,
      child: Container(
        color: AppColors.bg,
        child: _buildInvoiceContent(),
      ),
    );
  }

  Widget _buildInvoiceContent() {
    return BlocBuilder<SampleCollectorBloc,SampleCollectorState >(
      buildWhen: (previous, current) =>
    current is SampleCollectorInvoicesLoading ||
        current is SampleCollectorInvoicesError ||
        current is SampleCollectorInvoicesLoaded,
      builder: (context, state) {
        if (state is SampleCollectorInvoicesLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is SampleCollectorInvoicesError) {
          return Center(child: Text(state.error));
        }
        if (state is SampleCollectorInvoicesLoaded) {
          _allInvoices = state.invoices.invoices;

          _filteredInvoices.value = _allInvoices;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSearchAndFilterSection(),
                ValueListenableBuilder<List<SampleCollectorInvoice>>(
                  valueListenable: _filteredInvoices,
                  builder: (context, filteredInvoices, _) {
                    return _buildInvoiceTable(filteredInvoices);
                  },
                ),
                gapH8,
                if ((state.invoices.totalCount) > 0)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PaginationFooter(
                        currentPage: currentPage,
                        totalItems: state.invoices.totalCount,
                        itemsPerPage: itemsPerPage,
                        // ✅ use your local variable
                        onPageChanged: (newPage) {
                          setState(() {
                            currentPage = newPage;
                            _loadInvoices(
                              pageNumber: currentPage,
                              pageSize: itemsPerPage,
                            );
                          });
                        },
                        onPageSizeChanged: (newSize) {
                          setState(() {
                            itemsPerPage = newSize;
                            currentPage = 1; // ✅ reset to first page when page size changes
                            _loadInvoices(
                              pageNumber: currentPage,
                              pageSize: itemsPerPage,
                            );
                          });
                        },
                      ),
                    ],
                  )
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(color: Colors.white),
              child: CustomSearchTextFormField(
                onClear: () {
                  _searchController.clear();
                  _applyFiltersAndFetch();
                },
                controller: _searchController,
                hintText: "Search Name, Invoice No",
                onChanged: (String value) {
                  // No manual call needed, handled by listener + debounce
                },
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          _buildDateRangeFilter(),
          _buildClearFilterButton(),
        ],
      ),
    );
  }

  Widget _buildDateRangeFilter() {
    return StatusButtonWhite(
      isSelected: true,
      onPressed: () {
        appDateRangePicker(context, initialDateRange: _dateRange.value)
            .then((value) {
          if (value != null) {
            _dateRange.value = value;
          }
        });
      },
      child: ValueListenableBuilder<DateTimeRange?>(
        valueListenable: _dateRange,
        builder: (_, value, __) {
          return Text(
            "${formatDateTime(dateTime: value?.start, format: "dd MMM yyyy") ?? "From"} - ${formatDateTime(dateTime: value?.end, format: "dd MMM yyyy") ?? "To"}",
            style: AppSizes.normalBold(context)
                .copyWith(color: AppColors.primary(context)),
          );
        },
      ),
    );
  }

  Widget _buildClearFilterButton() {
    return TextButton(
      onPressed: () {
        _dateRange.value = null;
        _searchController.clear();
        _applyFiltersAndFetch();
      },
      child: const Text("Clear"),
    );
  }

  Widget _buildInvoiceTable(List<SampleCollectorInvoice> invoices) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: constraints.maxWidth * 1.5, // same trick here
          ),
          child: LabTechnologistInvoiceDataTable(
            invoices: invoices,
            verticalScrollController: _verticalScrollController,
            horizontalScrollController: _horizontalScrollController,
            onViewDetails: _showInvoiceDetails,
            onCollectPayment: _showPaymentDialog,
          ),
        );
      },
    );
  }

  void _showInvoiceDetails(InvoiceModelSync invoice) {
    showDialog(
      context: context,
      builder: (_) => InvoiceDetailsScreen(
        invoiceId: invoice.invoiceId.toString(),
        invoiceData: invoice,
      ),
    );
  }

  void _showPaymentDialog(
      InvoiceModelSync invoice, double dueAmount, double paidAmount) {
    showDialog(
      context: context,
      builder: (context) => SizedBox(
        width: 750,
        height: 500,
        child: InvoiceDueCollectionDialog(
          invoiceId: invoice.invoiceId.toString(),
          dueAmount: dueAmount,
          items: invoice,
          paidAmount: paidAmount,
        ),
      ),
    );
  }
}
