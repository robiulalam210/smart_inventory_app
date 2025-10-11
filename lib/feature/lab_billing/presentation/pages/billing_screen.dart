import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../../../core/configs/pdf/lab_billing_dynamic_invoice.dart';
import '../../../../core/configs/pdf/lab_billing_preview_invoice.dart';
import '../../../../core/core.dart';
import '../../../common/data/models/print_layout_model.dart';
import '../../../feature.dart';
import '../../../splash/presentation/bloc/connectivity_bloc/connectivity_state.dart';
import '../widgets/bill_summery/bill_summery.dart';
import '../widgets/finder_invoice/finder_invoice.dart';
import '../widgets/invoice_due_collection/invoice_due_collection.dart';
import '../widgets/invoice_sticker/invoice_sticker.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  @override
  void initState() {
    super.initState();

    loadInitialData();
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

  bool _allSetupLoaded = false;

  Future<void> loadInitialData() async {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TestBloc>().add(LoadTests());
        context.read<TestCategoriesBloc>().add(LoadCategoriesTests());
        context.read<PatientBloc>().add(FetchPatients());
        context.read<DoctorBloc>().add(LoadDoctors());
        context.read<InventoryBloc>().add(LoadInventory());
        context.read<GenderBloc>().add(LoadGenders());
        context.read<BloodGroupBloc>().add(LoadBloodGroups());
        context.read<PrintLayoutBloc>().add(FetchPrintLayout());

      });

      // Set default values for LabBillingBloc
      final labBillingBloc = context.read<LabBillingBloc>();
      labBillingBloc.dateDeliveryReport.text =
          DateFormat('dd-MM-yyyy').format(DateTime.now());
      labBillingBloc.timeDeliveryReport.text = "7:00 PM";
    } catch (e) {
      debugPrint('Initial data loading error: $e');
      // Handle error appropriately
    }
  }

  @override
  Widget build(BuildContext context) {
    final labBillingBloc = context.read<LabBillingBloc>();
    final syncBloc = context.read<SyncBloc>();

    return BlocListener<AllSetupBloc, AllSetupState>(
      listener: (context, state) {
        if (state is AllSetupLoading) {
          const Center(child: CircularProgressIndicator());
        }

        if (state is AllSetupLoaded && !_allSetupLoaded) {
          _allSetupLoaded = true;
          loadInitialData(); // Now load the rest of the data
        }
      },
      child: BlocBuilder<LabBillingBloc, LabBillingState>(
          builder: (context, state) {
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
                BlocListener<InvoiceUnSyncBloc, InvoiceUnSyncState>(
                  listener: (context, state) async {
                    if (state is InvoiceUnSyncLoading) {
                      appLoader(
                          context, "Loading for un sync data , please wait...");
                    } else if (state is InvoiceUnSyncLoaded) {
                      AppRoutes.pop(context);
                      Timer(Duration(microseconds: 500), () {
                        context.read<InvoiceUnSyncBloc>().add(
                              PostUnSyncInvoice(
                                  body: state.invoices ?? [],
                                  invoiceCreate: false,
                                  isSingleSync: false),
                            );
                      });
                    } else if (state is InvoiceUnSyncEmpty) {
                      AppRoutes.pop(context);
                      Timer(Duration(microseconds: 500), () {
                        BlocProvider.of<AllSetupBloc>(context)
                            .add(FetchAllSetupEvent(context));

                        BlocProvider.of<AllInvoiceSetupBloc>(context)
                            .add(FetchAllInvoiceSetupEvent(context));
                      });
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
                      appLoader(context,
                          "Data Send Server Loading in, please wait...");
                    } else if (state is PostInvoiceUnSyncLoaded) {
                      AppRoutes.pop(context);

                      // If isCreate is true, we are creating a new invoice
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
                BlocListener<SyncBloc, SyncState>(
                  listener: (context, state) {
                    if (state is SyncSuccess) {
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
                      final invoiceNo = state.invoiceId.toString();

                      AppRoutes.pop(context);
                      if (state.isSingleSync == true) {
                        labBillingBloc.add(
                          LoadInvoiceDetails(invoiceNo,
                              isSyncing: state.isSingleSync, context: context),
                        );

                        labBillingBloc.add(ClearFormData());

                        showCustomToast(
                          context: context,
                          title: 'Success!',
                          description: 'Sync completed successfully.',
                          type: ToastificationType.success,
                          icon: Icons.check_circle,
                          primaryColor: Colors.green,
                        );
                      }
                    }
                    if (state is SyncServerFailure) {
                      labBillingBloc.add(ClearFormData());
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
                    if (state is PostInvoiceUnSyncLoading) {
                      appLoader(context, "Post Loading in, please wait...");
                    } else if (state is PostInvoiceUnSyncLoaded) {
                      AppRoutes.pop(context);
                      Timer(Duration(milliseconds: 500), () {
                        if (state.isCreate) {
                          for (var invoiceItem in state.invoices.data ?? []) {
                            syncBloc.add(SyncInvoiceAndPatientEvent(
                              invoice: invoiceItem.invoice!.toJson(),
                              patient: invoiceItem.patient!.toJson(),
                              moneyReceipt: (invoiceItem.moneyReceipt
                                  ?.map((e) => e.toJson())
                                  .cast<Map<String, dynamic>>()
                                  .toList() ??
                                  []),
                                    test:
                                        (invoiceItem.test?.map((e) => e.toJson()).toList() ?? [])
                                            .cast<Map<String, dynamic>>(),

                              inventory:
                                        (invoiceItem.inventory?.map((e) => e.toJson()).toList() ??
                                                [])
                                            .cast<Map<String, dynamic>>(),
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
                BlocListener<LabBillingBloc, LabBillingState>(
                  listener: (context, state) async {
                    if (state is InvoicesLoading) {
                      Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    } else if (state is InvoiceSaved) {
                      final labBillingBloc = context.read<LabBillingBloc>();

                      labBillingBloc.add(ClearFormData());
                      showCustomToast(
                        context: context,
                        title: 'Success!',
                        description: 'Invoice create successfully.',
                        type: ToastificationType.success,
                        icon: Icons.check_circle,
                        primaryColor: Colors.green,
                      );
                      loadInitialData();
                    } else if (state is InvoicesError) {
                      labBillingBloc.add(ClearFormData());
                      showCustomToast(
                        context: context,
                        title: 'Warning!',
                        description: state.error,
                        type: ToastificationType.warning,
                        icon: Icons.warning,
                        primaryColor: Colors.orange,
                      );
                    }

                    if (state is InvoiceDetailsLoaded) {
                      loadInitialData();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            backgroundColor: Colors.red,
                            body: PdfPreview.builder(
                              useActions: true,
                              allowSharing: false,
                              canDebug: false,
                              canChangeOrientation: false,
                              canChangePageFormat: false,
                              dynamicLayout: true,
                              build: (format) => generatePdfDynamic(
                                  context,
                                  state.invoiceDetails,
                                  false,
                                  context.read<PrintLayoutBloc>().layoutModel ??
                                      PrintLayoutModel()),
                              initialPageFormat: PdfPageFormat.a5,
                              pdfPreviewPageDecoration:
                                  const BoxDecoration(color: Colors.white),
                              actionBarTheme: PdfActionBarTheme(
                                backgroundColor: AppColors.primaryColor,
                                iconColor: Colors.white,
                                textStyle: const TextStyle(color: Colors.white),
                              ),
                              actions: [
                                IconButton(
                                  onPressed: () => AppRoutes.pop(context),
                                  icon: const Icon(Icons.cancel,
                                      color: Colors.red),
                                ),
                              ],
                              pagesBuilder: (context, pages) {
                                debugPrint('Rendering ${pages.length} pages');
                                return PageView.builder(
                                  itemCount: pages.length,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (context, index) {
                                    final page = pages[index];
                                    return Container(
                                      color: Colors.grey,
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image(
                                          image: page.image,
                                          fit: BoxFit.contain),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
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
              // child: _buildMainContent(),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMainContent() {
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);
    final labBillingBloc = context.read<LabBillingBloc>();

    return BlocBuilder<LabBillingBloc, LabBillingState>(
      builder: (context, labBillingState) {
        return BlocBuilder<TestBloc, TestState>(
          builder: (context, testState) {
            return BlocBuilder<PatientBloc, PatientState>(
              builder: (context, patientState) {
                return BlocBuilder<DoctorBloc, DoctorState>(
                  builder: (context, doctorState) {
                    // Show loading if any state is loading
                    if (patientState is PatientLoading ||
                        doctorState is DoctorLoading ||
                        testState is TestLoading) {
                      return const Center(
                          child: CircularProgressIndicator.adaptive());
                    }

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
                                        PatientInfoSection(),
                                        BlocBuilder<LabBillingBloc,
                                            LabBillingState>(
                                          builder: (context, state) {
                                            return Column(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: AppColors.whiteColor,
                                                    border: Border.all(
                                                      color: AppColors.border
                                                          .withValues(
                                                              alpha: 0.5),
                                                      width: 0.5,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(AppSizes
                                                          .borderRadiusSize),
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        AppSizes.paddingInside,
                                                    vertical: 10,
                                                  ),
                                                  margin: EdgeInsets.symmetric(
                                                    horizontal: Responsive
                                                            .isMobile(context)
                                                        ? AppSizes
                                                                .paddingInside /
                                                            2
                                                        : AppSizes
                                                                .paddingInside /
                                                            2,
                                                  ),
                                                  width:
                                                      AppSizes.width(context),
                                                  child: Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(AppSizes
                                                            .borderRadiusSize),
                                                      ),
                                                    ),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        // Radio buttons for test type selection
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SizedBox(
                                                              width: AppSizes.width(
                                                                      context) *
                                                                  0.15,
                                                              child:
                                                                  RadioListTile<
                                                                      TestType>(
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                selectedTileColor:
                                                                    AppColors
                                                                        .primaryColor,
                                                                activeColor:
                                                                    AppColors
                                                                        .primaryColor,
                                                                title: Text(
                                                                  "Test Item",
                                                                  style: AppTextStyle
                                                                      .labelDropdownTextStyle(
                                                                          context),
                                                                ),
                                                                value: TestType
                                                                    .testItem,
                                                                groupValue: context
                                                                    .read<
                                                                        LabBillingBloc>()
                                                                    .selectedTestType,
                                                                onChanged:
                                                                    (TestType?
                                                                        value) {
                                                                  if (value !=
                                                                      null) {
                                                                    setState(
                                                                        () {
                                                                      context
                                                                          .read<
                                                                              LabBillingBloc>()
                                                                          .selectedTestType = value;
                                                                    });
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: AppSizes.width(
                                                                      context) *
                                                                  0.20,
                                                              child:
                                                                  RadioListTile<
                                                                      TestType>(
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                selectedTileColor:
                                                                    AppColors
                                                                        .primaryColor,
                                                                activeColor:
                                                                    AppColors
                                                                        .primaryColor,
                                                                title: Text(
                                                                  "Inventory Test",
                                                                  style: AppTextStyle
                                                                      .labelDropdownTextStyle(
                                                                          context),
                                                                ),
                                                                value: TestType
                                                                    .inventory,
                                                                groupValue: context
                                                                    .read<
                                                                        LabBillingBloc>()
                                                                    .selectedTestType,
                                                                onChanged:
                                                                    (TestType?
                                                                        value) {
                                                                  if (value !=
                                                                      null) {
                                                                    setState(
                                                                        () {
                                                                      context
                                                                          .read<
                                                                              LabBillingBloc>()
                                                                          .selectedTestType = value;
                                                                    });
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),

                                                        // Test/Inventory selection fields

                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              flex: 2,
                                                              child: context
                                                                          .read<
                                                                              LabBillingBloc>()
                                                                          .selectedTestType ==
                                                                      TestType
                                                                          .inventory
                                                                  ? _buildInventorySearch(
                                                                      context)
                                                                  : TestSearchWidget(),
                                                            ),
                                                            const SizedBox(
                                                                width: 16),
                                                            if (context
                                                                    .read<
                                                                        LabBillingBloc>()
                                                                    .selectedTestType !=
                                                                TestType
                                                                    .inventory)
                                                              Expanded(
                                                                flex: 1,
                                                                child:
                                                                    // inside your build method
                                                                    BlocBuilder<
                                                                        TestCategoriesBloc,
                                                                        TestCategoriesState>(
                                                                  builder:
                                                                      (context,
                                                                          state) {
                                                                    if (state
                                                                        is TestCategoriesLoading) {
                                                                      return const Center(
                                                                          child:
                                                                              CircularProgressIndicator());
                                                                    } else if (state
                                                                        is TestCategoriesLoaded) {
                                                                      return TestCategorySearch(
                                                                        controller:
                                                                            labBillingBloc.typeCategoryController,
                                                                        focusNode:
                                                                            focusCategoryNode,
                                                                        selectedCategoryNotifier:
                                                                            labBillingBloc.selectedCategoriesTest,
                                                                        categories:
                                                                            state.categories,
                                                                        onCategorySelected:
                                                                            (category) {
                                                                          setState(
                                                                              () {
                                                                            if (category?.name ==
                                                                                'All') {
                                                                              labBillingBloc.selectedCategoriesTest.value = null;
                                                                            } else {
                                                                              labBillingBloc.selectedCategoriesTest.value = category;
                                                                            }
                                                                            labBillingBloc.typeCategoryController.text =
                                                                                category?.name ?? '';
                                                                          });
                                                                          FocusScope.of(context)
                                                                              .unfocus();
                                                                        },
                                                                      );
                                                                    } else if (state
                                                                        is TestCategoriesError) {
                                                                      return Center(
                                                                          child:
                                                                              Text('Failed to load categories: ${state.message}'));
                                                                    }

                                                                    return const SizedBox
                                                                        .shrink(); // or loader if you want
                                                                  },
                                                                ),
                                                              ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                TestItemTable(),
                                              ],
                                            );
                                          },
                                        ),
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
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildInventorySearch(BuildContext context) {
    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, state) {
        if (state is InventoryLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is InventoryLoaded) {
          final labBillingBloc = context.read<LabBillingBloc>();
          return InventorySearchField(
            inventoryList: state.inventory,
            labBillingBloc: labBillingBloc,
            controller: typeInventoryController,
            focusNode: focusInventoryNode,
          );
        } else if (state is InventoryError) {
          return Center(child: Text("Error: ${state.message}"));
        }
        return const Center(child: Text("No data available"));
      },
    );
  }

  Future<Widget> buildActionButtons() async {
    final labBillingBloc = context.read<LabBillingBloc>();
    final token = await LocalDB.getLoginInfo();
    final DatabaseHelper dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    final userId = token?['userId'];
    final userName = token?['userName'];
    final countTotalInvoiceResult = db.select('''
  SELECT COUNT(*) AS countMyInvoice FROM invoices WHERE created_by_user_id = ?
''', [userId]);

    final totalInvoice = countTotalInvoiceResult.first['countMyInvoice'] as int;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.start,
          children: [
            gapW4,
            gapW4,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                  border: Border.all(color: Color(0xff018000), width: 1)),
              child: Text(
                "$totalInvoice",
                style: TextStyle(
                    color: Color(0xff018000), fontWeight: FontWeight.w700),
              ),
            ),
            gapW4,
            Container(
              constraints: BoxConstraints(
                maxWidth: 250, // set your desired max width
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radius),
                border: Border.all(color: Color(0xff018000), width: 1),
              ),
              child: Text(
                userName ?? "", maxLines: 2,
                style: const TextStyle(
                  color: Color(0xff018000),
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis, // prevents overflow
              ),
            )
          ],
        ),
        Wrap(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                  border: Border.all(color: Color(0xff018000), width: 1)),
              child: Text(
                "${labBillingBloc.testTotalCount}",
                style: TextStyle(
                    color: Color(0xff018000), fontWeight: FontWeight.w700),
              ),
            ),
            gapW4,
            SizedBox(
              width: 160,
              child: CustomInputField(
                controller: labBillingBloc.commentsController,
                hintText: "Enter Your Comments  ",
                isRequiredLable: false,
                keyboardType: TextInputType.name,
                isRequired: true,
              ),
            ),
            gapW4,
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
              name: 'Sticker',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => SizedBox(
                    // width: 750,
                    // height: 600,
                    child: InvoiceStickerViewDialog(),
                  ),
                );
              },
              color: Color(0xff0c3475),
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
            AppButton(
              name: 'Clear',
              onPressed: () {
                setState(() {
                  context.read<LabBillingBloc>().add(ClearFormData());
                });
              },
              color: Colors.redAccent,
            ),
            const SizedBox(width: 10),
            AppButton(
              name: 'Preview',
              onPressed: () async {
                final labBillingBloc = context.read<LabBillingBloc>();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      backgroundColor: Colors.red,
                      body: PdfPreview.builder(
                        useActions: true,
                        allowSharing: false,
                        canDebug: false,
                        canChangeOrientation: false,
                        canChangePageFormat: false,
                        dynamicLayout: true,
                        build: (format) => generatePdf(
                            context,
                            labBillingBloc.nameController.text.isNotEmpty
                                ? labBillingBloc.nameController.text
                                : 'N/A',
                            labBillingBloc.fullNumber.isNotEmpty
                                ? labBillingBloc.fullNumber
                                : 'N/A',
                            "${labBillingBloc.yearController.text.isNotEmpty ? labBillingBloc.yearController.text : '0'}Y ${labBillingBloc.monthController.text.isNotEmpty ? labBillingBloc.monthController.text : '0'}M ${labBillingBloc.dayController.text.isNotEmpty ? labBillingBloc.dayController.text : '0'}D",
                            labBillingBloc.dobController.text.isNotEmpty
                                ? labBillingBloc.dobController.text
                                : 'N/A',
                            labBillingBloc.gender?.name ?? 'N/A',
                            labBillingBloc.referredBy == "Self"
                                ? "Self"
                                : (labBillingBloc.referredBy == "Doctor"
                                        ? labBillingBloc.doctorModel?.name
                                        : labBillingBloc.otherController.text)
                                    .toString(),
                            labBillingBloc.dateDeliveryReport.text.isNotEmpty
                                ? labBillingBloc.dateDeliveryReport.text
                                : 'N/A',
                            labBillingBloc.timeDeliveryReport.text.isNotEmpty
                                ? labBillingBloc.timeDeliveryReport.text
                                : 'N/A',
                            labBillingBloc.testItems,
                            formatNumberAll(labBillingBloc.dueAmount),
                            formatNumberAll(labBillingBloc.paidAmount),
                            formatNumberAll(labBillingBloc.totalAmount),
                            context.read<PrintLayoutBloc>().layoutModel ??
                                PrintLayoutModel()),
                        initialPageFormat: PdfPageFormat.a5,
                        pdfPreviewPageDecoration:
                            const BoxDecoration(color: Colors.white),
                        actionBarTheme: PdfActionBarTheme(
                          backgroundColor: AppColors.primaryColor,
                          iconColor: Colors.white,
                          textStyle: const TextStyle(color: Colors.white),
                        ),
                        actions: [
                          IconButton(
                            onPressed: () => AppRoutes.pop(context),
                            icon: const Icon(Icons.cancel, color: Colors.red),
                          ),
                        ],
                        pagesBuilder: (context, pages) {
                          debugPrint('Rendering ${pages.length} pages');

                          return PageView.builder(
                            itemCount: pages.length,
                            scrollDirection: Axis.vertical,
                            scrollBehavior: ScrollBehavior(),
                            itemBuilder: (context, index) {
                              final page = pages[index];
                              return Container(
                                decoration: BoxDecoration(color: Colors.grey),
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image(
                                      image: page.image, fit: BoxFit.contain),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
              color: const Color(0xff800000),
            ),
            const SizedBox(width: 10),
            AppButton(
              name: 'Payment',
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
    final labBillingBloc = context.read<LabBillingBloc>();
    final connectivityBloc = context.read<ConnectivityBloc>(); // ✅ fixed here
    final token = await LocalDB.getLoginInfo();

    if (labBillingBloc.selectedPaymentMethod.isEmpty) {
      showCustomToast(
        context: context,
        title: 'Warning!',
        description: 'Please select a Payment Method!',
        type: ToastificationType.warning,
        icon: Icons.warning,
        primaryColor: Colors.orange,
      );
    } else {
      if (connectivityBloc.state is ConnectivityOnline) {
        final patientMap = {
          "web_id": labBillingBloc.patientModel?.orgPatientId ?? "",
          "name": labBillingBloc.nameController.text,
          "phone": labBillingBloc.fullNumber.toString(),
          "age": labBillingBloc.yearController.text,
          "month": labBillingBloc.monthController.text,
          "day": labBillingBloc.dayController.text,
          "visit_type": labBillingBloc.visitType.toString(),
          "gender": labBillingBloc.gender?.originalId.toString() ?? "",
          "bloodGroup": labBillingBloc.bloodGroup?.originalId.toString() ?? "",
          "address": labBillingBloc.addressController.text,
          "dateOfBirth": DateFormat("dd-MM-yyyy")
              .parseStrict(labBillingBloc.dobController.text.trim())
              .toString(),
          "hn_number": labBillingBloc.patientModel?.hnNumber ?? "", // example
          "create_date": DateTime.now().toIso8601String(),
        };

        final invoiceDetails = labBillingBloc.testItems
            .where((item) => item['type'] == 'Test')
            .map((item) => {
                  "test_id": item['id'],
                })
            .toList();

        final inventoryItems = labBillingBloc.testItems
            .where((item) => item['type'] == 'Inventory')
            .map((item) => {
                  "id": item['id'],
                  "quantity": int.tryParse(item['qty'].toString()) ?? 1,
                  "price": double.tryParse(item['total'].toString()) ?? 0.0,
                  "name": item['name'] ?? '',
                })
            .toList();
        final isPercentage =
            labBillingBloc.selectedOverallDiscountType == 'percentage';

        final discountPercentage = isPercentage
            ? double.tryParse(labBillingBloc.discountController.text.trim()) ??
                0.0
            : (labBillingBloc.discountAmountPercentage.isNaN
                ? 0.0
                : labBillingBloc.discountAmountPercentage);

        final payload = labBillingBloc.generateInvoicePayload(
          deliveryDate: DateFormat("dd-MM-yyyy")
              .parseStrict(labBillingBloc.dateDeliveryReport.text.trim())
              .toString(),
          deliveryTime: labBillingBloc.timeDeliveryReport.text,
          createDate: DateTime.now().toIso8601String(),
          createdByUserId: "${token?['userId']}",
          // from token
          createdByName: token?['userName'],
          // from token
          totalAmount:
              double.tryParse(labBillingBloc.totalAmount.toString()) ?? 0.0,

          due: (double.tryParse(labBillingBloc.totalAmount.toString()) ?? 0.0) -
              (double.tryParse(labBillingBloc.paidAmountController.text) ??
                  0.0) -
              (labBillingBloc.discountAmount),

          paidAmount:
              double.tryParse(labBillingBloc.paidAmountController.text) ?? 0.0,
          discountType: labBillingBloc.selectedOverallDiscountType,
          discount: labBillingBloc.discountAmount,
          discountPercentage: discountPercentage,
          referType: labBillingBloc.referredBy,
          referreIdOrDesc: labBillingBloc.referredBy == "Self"
              ? ""
              : labBillingBloc.referredBy == "Doctor"
                  ? (labBillingBloc.doctorModel?.orgDoctorId?.toString() ?? "")
                  : labBillingBloc.otherController.text.trim(),
          branchId: int.tryParse(token?['branchId']) ?? 0,
          // dynamic if needed
          branchName: token?['branchName'],
          // dynamic if needed
          patient: patientMap,
          invoiceDetails: invoiceDetails,
          inventory: inventoryItems,
        );
        if (mounted) {
          context.read<InvoiceUnSyncBloc>().add(
                PostUnSyncInvoice(
                    body: [payload], invoiceCreate: true, isSingleSync: true),
              );
        }
      } else {
        if (labBillingBloc.patientModel != null) {
          context.read<LabBillingBloc>().add(
                SaveInvoice(
                    context: context,
                    isUpdate: true,
                    patientID: labBillingBloc.patientModel?.id.toString(),
                    patientWebId:
                        labBillingBloc.patientModel?.orgPatientId.toString()),
              );
        } else {
          context
              .read<LabBillingBloc>()
              .add(SaveInvoice(context: context, isUpdate: false));
        }
      }
    }
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
