part of 'synchronization_bloc.dart';

abstract class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object> get props => [];
}
class SyncInvoiceAndPatientEvent extends SyncEvent {
  final Map<String, dynamic> invoice;
  final Map<String, dynamic> patient;
  final List<Map<String, dynamic>> moneyReceipt;
  final List<Map<String, dynamic>> inventory;
  final List<Map<String, dynamic>> test;
  final bool isSingleSync;

  const SyncInvoiceAndPatientEvent({
    required this.invoice,
    required this.patient,
    this.moneyReceipt = const [],
    this.inventory = const [],
    this.test = const [],
    this.isSingleSync = true,
  });
}

// class SyncInvoiceAndPatient extends SyncEvent {
//   final Map<String, dynamic> invoice;
//   final Map<String, dynamic> patient;
//   final List<Map<String, dynamic>> moneyReciptList;
//   final bool isSingleSync;
//
//   const SyncInvoiceAndPatient({
//     required this.invoice,
//     required this.patient,
//     required this.moneyReciptList,
//     required this.isSingleSync,
//   });
// }
//
class FullRefundInvoice extends SyncEvent {
  final Map<String, dynamic> invoice;
  final bool isFullRefund;

  const FullRefundInvoice({
    required this.invoice,
    required this.isFullRefund,
  });
}

// class SyncCreateInvoiceAndPatient extends SyncEvent {
//   final Map<String, dynamic> invoice;
//   final Map<String, dynamic> patient;
//   final List<Map<String, dynamic>> moneyReceipt; // ✅ FIXED
//   final List<Map<String, dynamic>> inventory; // ✅ FIXED
//   final List<Map<String, dynamic>> test; // ✅ FIXED
//   final bool isSingleSync;
//
//   const SyncCreateInvoiceAndPatient({
//     required this.invoice,
//     required this.patient,
//     required this.moneyReceipt,
//     required this.inventory,
//     required this.test,
//     required this.isSingleSync,
//   });
// }

class SyncAllData extends SyncEvent {
  final List<SetupGender>? genders;
  final List<SetupBloodGroup>? bloodGroups;
  final List<SetupDoctor>? doctors;
  final List<SetupPatient>? patients;
  final List<SetupTestCategory>? categories;
  final List<SetupTestName>? testNames;
  final List<SetupInventoryAllSetup>? inventoryItems;
  final List<AllInvoiceData>? invoices;
  final List<SetupParameter>? parameterSetup;
  final List<SetupParameterGroup>? parameterGroupSetup;
  final List<SetupTestParameter>? testParameterSetup;
  final List<SetupTestNameConfig>? testNameConfigSetup;
  final List<SetupBooth>? booths;
  final List<SetupCollector>? collectorInfo;
  final List<SetupSpecimen>? setupSpecimen;
  final List<SetupTestGroup>? setupTestGroup;
  final PrintLayout? printLayout;
  final List<SetupCaseEffect>? caseEffect;
  final List<SetupMarketer>? marketerList;


  const SyncAllData({
    this.genders,
    this.bloodGroups,
    this.doctors,
    this.patients,
    this.categories,
    this.testNames,
    this.inventoryItems,
    this.invoices,
    this.parameterSetup,
    this.parameterGroupSetup,
    this.testParameterSetup,
    this.testNameConfigSetup,
    this.booths,
    this.collectorInfo,
    this.setupSpecimen,
    this.setupTestGroup,
    this.printLayout,

    this.caseEffect,
    this.marketerList,
  });
}

class SyncSpecificData extends SyncEvent {
  final SyncType type;
  final dynamic data;

  const SyncSpecificData(this.type, this.data);

  @override
  List<Object> get props => [type, data];
}


enum SyncType {
  doctors,
  testCategories,
  testNames,
  genders,
  bloodGroups,
  patients,
  inventory,
  invoices,
  parameterGroups,
  parameters,
  testNameConfigs,
  testParameters,
  booths,
  collectors,
  specimen,
  testGroup,
  printLayouts,
  caseEffect,
  marketerList
}
