import 'dart:math';

import 'package:equatable/equatable.dart';
import '/feature/transactions/data/models/invoice_local_model.dart';
import 'package:intl/intl.dart';
import 'package:phone_form_field/phone_form_field.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/app_input_widgets.dart';
import '../../../../lab_dashboard/data/models/invoice_server_response_model.dart';
import '../../../data/models/common_model.dart';
import '../../../data/models/doctors_model/doctor_model.dart';
import '../../../data/models/inventory_model/inventory_model.dart';
import '../../../data/models/patient_model/patient_model.dart';
import '../../../data/models/tests_model/test_categories_model.dart';
import '../../../data/models/tests_model/tests_model.dart';
import '../../../data/repositories/lab_billing_db_repo.dart';


part 'lab_billing_event.dart';

part 'lab_billing_state.dart';

class LabBillingBloc extends Bloc<LabBillingEvent, LabBillingState> {
  final LabBillingRepository repository=LabBillingRepository();

  // Patient Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController commentsController = TextEditingController();
  String visitType = "In";

  PhoneController phoneCController = phoneCountryController('') ??
      PhoneController(initialValue: PhoneNumber(isoCode: IsoCode.BD, nsn: ''));

  String get fullNumber => '+${phoneCController.value.countryCode}${phoneCController.value.nsn}';


  final TextEditingController yearController = TextEditingController();
  final TextEditingController monthController = TextEditingController();
  final TextEditingController dayController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController otherController = TextEditingController();

  GenderLocalModel? gender;

  BloodGroupLocalModel? bloodGroup;

  String referredBy = 'Self';
  PatientLocalModel? patientModel;
  DoctorLocalModel? doctorModel;

  // Test-related data
  TestType? selectedTestType = TestType.testItem;
  ValueNotifier<TestCategoriesLocalModel?> selectedCategoriesTest = ValueNotifier<TestCategoriesLocalModel?>(null);
  ValueNotifier<TestLocalModel?> selectedTest = ValueNotifier<TestLocalModel?>(null);
  String? selectedItem;
  String? selectedTestItem;
  InventoryLocalProduct? selectedInventory;
  double selectedRate = 0;
  int quantity = 1;
   List<Map<String, dynamic>> testItems = [];

  final TextEditingController patientTypeAheadController = TextEditingController();
  final TextEditingController testTypeAheadController = TextEditingController();
  final FocusNode patientFocusNode = FocusNode();
  final FocusNode testFocusNode = FocusNode();

  // Payment & delivery
  String selectedPaymentMethod = 'Cash';
  final TextEditingController dateDeliveryReport = TextEditingController();
  final TextEditingController timeDeliveryReport = TextEditingController();
  final TextEditingController discountController =
      TextEditingController();
  final TextEditingController paidAmountController =
      TextEditingController();
  bool isDiscountApplied = true;
  String selectedOverallDiscountType = 'fixed';
  double discountAmount = 0.0;
  double paidAmount = 0.0;
  double dueAmount = 0.0;
  double discountAmountPercentage = 0.0;

  double get inventoryTotal => testItems
          .where((item) => item['type'] == 'Inventory')
          .fold(0.0, (sum, item) {


        final price = double.tryParse(item['total']?.toString() ?? '0') ?? 0;
        // final qty = double.tryParse(item['qty']?.toString() ?? '0') ?? 0;
        return sum + price;
      });

  double get testTotal =>
      testItems.where((item) => item['type'] == 'Test').fold(0.0, (sum, item) {

        final price = double.tryParse(item['total']?.toString() ?? '0') ?? 0;
        // final qty = double.tryParse(item['qty']?.toString() ?? '0') ?? 0;
        return sum + price;
      });
  double get testTotalDiscountApply => testItems
      .where((item) =>
  item['type'] == 'Test' && (item['discountApplied'] ?? 0) == 1)
      .fold(0.0, (sum, item) {
    final price = double.tryParse(item['total']?.toString() ?? '0') ?? 0;
    return sum + price;
  });

  int get testTotalCount =>
      testItems.where((item) => item['type'] == 'Test').length;


  double get totalAmount => inventoryTotal + testTotal;

  double get totalDue {
    final paid = double.tryParse(paidAmountController.text) ?? 0.0;
    return (totalAmount - paid).clamp(0.0, double.infinity);
  }

  Map<String, dynamic> generateInvoicePayload({
    required String deliveryDate,
    required String deliveryTime,
    required String createDate,
    required String createdByUserId,
    required String createdByName,
    required double totalAmount,
    required double due,
    required double paidAmount,
    required String discountType,
    required double discount,
    required double discountPercentage,
    required String referType,
    required String referreIdOrDesc,
    required int branchId,
    required String branchName,
    required Map<String, dynamic> patient,
    required List<Map<String, dynamic>> invoiceDetails,
    required List<Map<String, dynamic>> inventory,
  }) {
    /// ✅ Correct invoice number generation
    String generateInvoiceNumber() {
      final now = DateTime.now();
      final timestampMillis = now.millisecondsSinceEpoch.toString();

      // Take last 4 digits from timestamp milliseconds
      final timePart = timestampMillis.substring(timestampMillis.length - 4);

      // Generate 3-digit random number (100-999)
      final randPart = (Random().nextInt(900) + 100).toString();

      return 'APP$timePart$randPart'; // APP + 4 + 3 = 10 chars total
    }

    final invoiceNumber = generateInvoiceNumber();
    // Generate money receipt number
    String generateReceiptNumber() {
      final date = DateFormat('MMddHHmm').format(DateTime.now()); // MMddHHmm = 8 digits
      final random = Random().nextInt(900) + 100; // 3-digit random
      return 'MR$date$random';
    }

    final moneyReceiptNumber = generateReceiptNumber();

    return {
      "web_id": null,
      "invoice_number": invoiceNumber,
      "delivery_date": deliveryDate,
      "delivery_time": deliveryTime,
      "create_date": createDate,
      "created_by_user_id": createdByUserId,
      "created_by_name": createdByName,
      "total_bill_amount": totalAmount,
      "due": due,
      "paid_amount": paidAmount,
      "discount_type": discountType,
      "discount": discount,
      "discount_percentage": discountPercentage,
      "refer_type": referType,
      "referre_id_or_desc": referreIdOrDesc,
      "billingComment": commentsController.text.trim(),
      "branch_id": branchId,
      "branch": branchName,
      "patient": patient,
      "invoice_details": invoiceDetails,
      "inventory": inventory,
      "money_receipts": [
        {
          'money_receipt_number':moneyReceiptNumber,
          'money_receipt_type': "add",
          'paid_amount': paidAmount,
          'due_amount':due,
          'total_amount_paid':totalAmount,
          'requested_amount':(totalAmount-discountAmount).toStringAsFixed(2),
        }
      ],

    };
  }
  double calculateDiscountedAmount(double price, double? discountPercentage) {
    if (discountPercentage == null || discountPercentage == 0) return price;
    return price - (price * (discountPercentage / 100));
  }
  LabBillingBloc() : super(LabBillingInitial()) {

    on<AddTestItem>((event, emit) {
      final isDuplicate = testItems.any(
            (item) => item['id'].toString() == event.id.toString(),
      );

      if (!isDuplicate) {
        final double price = double.tryParse(event.price.toString()) ?? 0;
        final double discountPercent = event.discountPercentage;
        final int qty = event.quantity;

        final double discountAmount = event.discountApplied == 0
            ? 0.0
            : price * (discountPercent / 100);

        final double total = (price - discountAmount) * qty;

        testItems.add(<String, dynamic>{
          'id': event.id,
          'name': event.name,
          'code': event.code,
          'type': event.type,
          'testGroupName': event.testGroupName,
          'rate': price,
          'amount': discountAmount,
          'total': total,
          'discountPercentage': discountPercent,
          'discountApplied': event.discountApplied,
          'qty': qty,
        });

        emit(LabBillingUpdated(testItems: List.from(testItems)));
      } else {
        emit(LabBillingUpdated(testItems: List.from(testItems)));
      }
    });

    on<UpdateTestItemQty>((event, emit) {
      debugPrint("🔁 Updating item at index: ${event.index} with qty: ${event.qty}");

      final updatedItems = List<Map<String, dynamic>>.from(testItems);

      if (event.index < 0 || event.index >= updatedItems.length) {
        debugPrint("❌ Invalid index");
        return;
      }

      final item = updatedItems[event.index];

      final double price = item['rate'] ?? 0.0;
      final double discountPercent = item['discountPercentage'] ?? 0.0;
      final int newQty = event.qty;

      final double discountAmount = item['discountApplied'] == 0
          ? 0.0
          : price * (discountPercent / 100);

      item['qty'] = newQty;
      item['amount'] = discountAmount;
      item['total'] = (price - discountAmount) * newQty;

      debugPrint("✅ Updated item: ${jsonEncode(item)}");

      testItems = updatedItems;

      emit(LabBillingUpdated(testItems: List.from(testItems)));
    });


    on<RemoveTestItem>((event, emit) {
      if (event.index >= 0 && event.index < testItems.length) {
        testItems.removeAt(event.index);
        emit(LabBillingUpdated(testItems: List.from(testItems)));
      } else {
      }
    });

    on<LoadInvoiceDetails>(_onLoadInvoiceDetails);
    on<SaveInvoice>(onSaveInvoice);
    on<ClearFormData>(_onClearFormData);
  }



  Future<void> _onLoadInvoiceDetails(
      LoadInvoiceDetails event, Emitter<LabBillingState> emit) async {
    emit(InvoicesDetailsLoading());
    try {
      final invoice = await repository.fetchInvoiceDetails(event.invoiceId);

      emit(InvoiceDetailsLoaded(invoice));
    } catch (e, st) {
      debugPrint("Error loading invoice details: $e\n$st");
      emit(InvoicesDetailsError(
          "Failed to load invoice details: ${e.toString()}"));
    }
  }


  Future<void> onSaveInvoice(
      SaveInvoice event, Emitter<LabBillingState> emit) async {
    emit(InvoicesLoading());
    try {
      if (nameController.text.isEmpty || fullNumber.isEmpty) {
        throw Exception("Patient name and phone are required");
      }
      if (testItems.isEmpty) {
        throw Exception("At least one test item is required");
      }

      final result = await repository.managePatientAndInvoice(
          name: nameController.text,
          phone: fullNumber,
          age: yearController.text,
          month: monthController.text,
          day: dayController.text,
          dob: DateFormat("dd-MM-yyyy").parseStrict(dobController.text.trim()).toString(),

      gender: gender?.originalId.toString() ?? "",
          bloodGroup: bloodGroup?.originalId.toString() ?? "",
          address: addressController.text,
          referredBy: referredBy.toString(),
          visitType: visitType,
          referredById: referredBy == "Self"
              ? ""
              : referredBy == "Doctor"
                  ? (doctorModel?.orgDoctorId?.toString() ?? "")
                  : referredBy == "Other"
                      ? otherController.text.trim()
                      : "",
          deliveryDate:  DateFormat("dd-MM-yyyy").parseStrict(dateDeliveryReport.text.trim()).toString(),
          deliveryTime: timeDeliveryReport.text,
          totalAmount: totalAmount.toStringAsFixed(2),
          discount: discountController.text.isEmpty
              ? "0"
              : discountAmount.toStringAsFixed(2),
          paymentMethod: selectedPaymentMethod,
          discountType: selectedOverallDiscountType,
          paidAmount: paidAmountController.text,
          testItems: testItems,
          discountPercentage: selectedOverallDiscountType != 'percentage'
              ? discountAmountPercentage.toStringAsFixed(2)
              : discountController.text.toString(),
          isUpdate: event.isUpdate,
          patientID: event.patientID,
          patientWebId: event.patientWebId, billingComment: commentsController.text.trim());

      if (result['status'] == 'success') {
        // _showInvoicePreview(event.context,testItems);
        add(ClearFormData());

        emit(InvoiceSaved(result['invoiceNumber']));
        add(LoadInvoiceDetails(
            // ignore: use_build_context_synchronously
            result['invoiceNumber'].toString(), isSyncing: true, context: event.context));
      } else {
        emit(InvoicesError(result['message'] ?? "Failed to save invoice"));
        add(ClearFormData());
      }
    } catch (e, st) {
      add(ClearFormData());
      debugPrint("SaveInvoice Error: $e\n$st");
      emit(InvoicesError("Error saving invoice: ${e.toString()}"));
    }
  }

  final TextEditingController typeCategoryController = TextEditingController();
  final TextEditingController testSearchController = TextEditingController();

  void _onClearFormData(ClearFormData event, Emitter<LabBillingState> emit) {
    nameController.clear();
    phoneCController = phoneCountryController('') ??
        PhoneController(
            initialValue: PhoneNumber(isoCode: IsoCode.BD, nsn: ''));
    addressController.clear();
    yearController.clear();
    monthController.clear();
    dayController.clear();
    dobController.clear();
    gender = null;
    bloodGroup = null;
    referredBy = 'Self';
    patientModel = null;
    patientModel = null;
    doctorModel = null;
    testItems.clear();
    discountAmount = 0.0;
    discountAmountPercentage = 0.0;
    discountController.clear();
    paidAmountController.clear();
    selectedOverallDiscountType = 'fixed';
    selectedPaymentMethod = 'Cash';
    selectedTestType = TestType.testItem;
    isDiscountApplied = true;
    selectedTest.value = null;
    selectedItem = null;
    selectedTestItem = null;
    selectedInventory = null;
    selectedRate = 0;
    quantity = 1;
    testSearchController.clear();
    patientTypeAheadController.clear();
    typeCategoryController.clear();
    commentsController.clear();
    // patientFocusNode.unfocus();
    // dateDeliveryReport=   DateFormat('dd/MM/yyyy').format(DateTime.now());
    // timeDeliveryReport="7:00 PM";

    emit(LabBillingInitial());
  }
}

enum TestType { testItem, inventory }
