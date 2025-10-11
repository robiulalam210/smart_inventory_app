import 'package:equatable/equatable.dart';

import '../../../../../core/configs/configs.dart';
import '../../../data/models/all_setup_model/all_invoice_setup_model.dart';
import '../../../data/models/all_setup_model/all_setup_model.dart';
import '../../../data/repositories/setup_repo_sync_all/setup_repo_db_sync.dart';
import '../../../data/repositories/unsync_update_invoice_db/unsync_update_invoice_db.dart';

part 'synchronization_event.dart';

part 'synchronization_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SetupAllSyncRepo syncRepo;
  final UnSyncRepo unSyncRepo;

  static const int totalSteps = 18; // Number of sync operations in syncAll

  SyncBloc({required this.syncRepo, required this.unSyncRepo})
      : super(SyncInitial()) {
    on<SyncAllData>(_onSyncAllData);
    on<SyncSpecificData>(_onSyncSpecificData);
    on<SyncInvoiceAndPatientEvent>(_onSyncInvoiceAndPatientEvent);
    // on<SyncInvoiceAndPatient>(_onSyncInvoiceAndPatient);
    on<FullRefundInvoice>(_onFullRefundServerInvoice);
    // on<SyncCreateInvoiceAndPatient>(_onSyncCreateInvoiceAndPatient);
  }

  Future<void> _onFullRefundServerInvoice(
      FullRefundInvoice event, Emitter<SyncState> emit) async {
    emit(FullRefundServerInvoiceLoading());
    try {
      // First try to update existing invoice and patient
      final updateResult = await unSyncRepo.refundInvoiceThenPatientFromServer(
          fullInvoice: event.invoice, isFullRefund: event.isFullRefund);

      if (updateResult['status'] == 'success') {
        emit(FullRefundServerInvoiceSuccess(
            updateResult['message'] ?? 'Updated successfully',
            updateResult['invoice_number']));
      } else {
        // If update failed because invoice doesn't exist, create new record
        if ((updateResult['message'] ?? '').contains('not found')) {
          emit(FullRefundServerInvoiceFailure(
              updateResult['message'] ?? 'Update failed'));
        } else {
          emit(FullRefundServerInvoiceFailure(
              updateResult['message'] ?? 'Update failed'));
        }
      }
    } catch (e) {
      emit(FullRefundServerInvoiceFailure(e.toString()));
    }
  }

  // Future<void> _onSyncInvoiceAndPatient(
  //     SyncInvoiceAndPatient event, Emitter<SyncState> emit) async {
  //   emit(SyncServerLoading());
  //   try {
  //     // First try to update existing invoice and patient
  //     final updateResult = await unSyncRepo.syncInvoiceAndPatient(
  //       invoice: event.invoice,
  //       patient: event.patient,
  //       moneyReciptList: event.moneyReciptList,
  //     );
  //
  //     if (updateResult['status'] == 'success') {
  //       emit(SyncServerSuccess(
  //           updateResult['message'] ?? 'Updated successfully',
  //           updateResult['invoice_number']));
  //     } else {
  //       // If update failed because invoice doesn't exist, create new record
  //       if ((updateResult['message'] ?? '').contains('not found')) {
  //         emit(SyncServerFailure(updateResult['message'] ?? 'Update failed'));
  //       } else {
  //         emit(SyncServerFailure(updateResult['message'] ?? 'Update failed'));
  //       }
  //     }
  //   } catch (e) {
  //     emit(SyncServerFailure(e.toString()));
  //   }
  // }
  //
  // Future<void> _onSyncCreateInvoiceAndPatient(
  //     SyncCreateInvoiceAndPatient event, Emitter<SyncState> emit) async {
  //   emit(SyncServerLoading());
  //   try {
  //     // First try to update existing invoice and patient
  //     final updateResult = await unSyncRepo.createInvoiceThenPatientFromServer(
  //       invoice: event.invoice,
  //       patient: event.patient,
  //       test: event.test,
  //       inventory: event.inventory,
  //       moneyRecipt: event.moneyReceipt,
  //     );
  //
  //     if (updateResult['status'] == 'success') {
  //       emit(SyncServerSuccess(
  //           updateResult['message'] ?? 'Updated successfully',
  //           updateResult['invoice_number'],
  //           isSingleSync: event.isSingleSync));
  //     } else {
  //       // If update failed because invoice doesn't exist, create new record
  //       if ((updateResult['message'] ?? '').contains('not found')) {
  //         emit(SyncServerFailure(updateResult['message'] ?? 'Update failed'));
  //       } else {
  //         emit(SyncServerFailure(updateResult['message'] ?? 'Update failed'));
  //       }
  //     }
  //   } catch (e) {
  //     emit(SyncServerFailure(e.toString()));
  //   }
  // }
  Future<void> _onSyncInvoiceAndPatientEvent(
      SyncInvoiceAndPatientEvent event,
      Emitter<SyncState> emit,
      ) async {
    emit(SyncServerLoading());

    try {
      final result = await unSyncRepo.syncInvoiceAndPatient(
        invoice: event.invoice,
        patient: event.patient,
        moneyRecipts: event.moneyReceipt,
        testList: event.test,
        inventoryList: event.inventory,
      );

      if (result['status'] == 'success') {
        emit(SyncServerSuccess(
          result['message'] ?? 'Sync successful',
          result['invoice_number'],
          isSingleSync: event.isSingleSync,
        ));
      } else {
        emit(SyncServerFailure(result['message'] ?? 'Sync failed'));
      }
    } catch (e, stack) {
      debugPrint('❌ BLoC sync error: $e\n$stack');
      emit(SyncServerFailure(e.toString()));
    }
  }

  Future<void> _onSyncAllData(
    SyncAllData event,
    Emitter<SyncState> emit,
  ) async {
    try {
      emit(const SyncInProgress(
        progress: 0,
        total: totalSteps,
        currentOperation: 'Starting synchronization...',
      ));

      // Create a list of sync operations with their descriptions
      final syncOperations = [
        _SyncOperation(
          'Syncing genders...',
          () => syncRepo.syncGenders(event.genders ?? []),
        ),
        _SyncOperation(
          'Syncing blood groups...',
          () => syncRepo.syncBloodGroups(event.bloodGroups ?? []),
        ),
        _SyncOperation(
          'Syncing doctors...',
          () => syncRepo.syncDoctors(event.doctors ?? []),
        ),
        _SyncOperation(
          'Syncing patients...',
          () => syncRepo.syncPatients(event.patients ?? []),
        ),
        _SyncOperation(
          'Syncing test categories...',
          () => syncRepo.syncTestCategories(event.categories ?? []),
        ),
        _SyncOperation(
          'Syncing test names...',
          () => syncRepo.syncTestNames(event.testNames ?? []),
        ),
        _SyncOperation(
          'Syncing inventory...',
          () => syncRepo.syncInventory(event.inventoryItems ?? []),
        ),
        _SyncOperation(
          'Syncing invoices...',
          () => syncRepo.syncInvoices(event.invoices ?? []),
        ),
        _SyncOperation(
          'Syncing parameter groups...',
          () => syncRepo.syncParameterGroups(event.parameterGroupSetup ?? []),
        ),
        _SyncOperation(
          'Syncing parameter...',
          () => syncRepo.syncParameters(event.parameterSetup ?? []),
        ),
        _SyncOperation(
          'Syncing test name configs...',
          () => syncRepo.syncTestNameConfigs(event.testNameConfigSetup ?? []),
        ),
        _SyncOperation(
          'Syncing test parameter...',
          () => syncRepo.syncTestParameters(event.testParameterSetup ?? []),
        ),
        _SyncOperation(
          'Syncing booths...',
          () => syncRepo.syncBooths(event.booths ?? []),
        ),
        _SyncOperation(
          'Syncing collectors...',
          () => syncRepo.syncCollectors(event.collectorInfo ?? []),
        ),
        _SyncOperation(
          'Syncing specimen...',
          () => syncRepo.syncSpecimens(event.setupSpecimen ?? []),
        ),
        _SyncOperation(
          'Syncing test group...',
          () => syncRepo.syncTestGroups(event.setupTestGroup ?? []),
        ),
        _SyncOperation(
          'Syncing print layout...',
          () => syncRepo.syncPrintLayouts(event.printLayout ?? PrintLayout()),
        ),

        _SyncOperation(
          'Syncing case effects...',
              () => syncRepo.syncCaseEffects(event.caseEffect ?? []),
        ),
        _SyncOperation(
          'Syncing marketers...',
              () => syncRepo.syncMarketers(event.marketerList ?? []),
        ),
      ];

      // Execute each operation with progress updates
      for (int i = 0; i < syncOperations.length; i++) {
        final operation = syncOperations[i];

        emit(SyncInProgress(
          progress: i,
          total: totalSteps,
          currentOperation: operation.description,
        ));

        await operation.execute();

        // Small delay for smooth UI updates
        await Future.delayed(const Duration(milliseconds: 100));
      }

      emit(const SyncSuccess());
    } catch (e, stackTrace) {
      debugPrint('Sync error: $e\n$stackTrace');
      emit(SyncFailure(
        error: e.toString(),
        failedOperation: (state as SyncInProgress).currentOperation,
      ));
    }
  }

  // Future<void> _onAutoDailySyncRequested(
  //     AutoDailySyncRequested event, Emitter<SyncState> emit) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final lastSyncStr = prefs.getString('last_auto_sync_time');

  //   final now = DateTime.now();
  //   final today6am = DateTime(now.year, now.month, now.day, 6);

  //   if (now.isAfter(today6am)) {
  //     if (lastSyncStr != null) {
  //       final lastSync = DateTime.tryParse(lastSyncStr);
  //       if (lastSync != null &&
  //           lastSync.year == now.year &&
  //           lastSync.month == now.month &&
  //           lastSync.day == now.day) {
  //         // Already synced today
  //         return;
  //       }
  //     }

  //     // Check internet connection
  //     final connectivity = Connectivity();
  //     final result = await connectivity.checkConnectivity();

  //     final hasInternet = result == [ConnectivityResult.wifi, ConnectivityResult.mobile,ConnectivityResult.ethernet];

  //     if (hasInternet) {
  //       try {
  //         // যেমন: await syncRepo.syncAll(...);

  //         // সিঙ্ক সফল হলে সময় আপডেট করুন
  //         await prefs.setString('last_auto_sync_time', now.toIso8601String());

  //         emit(AutoSyncSuccess());
  //       } catch (e) {
  //         debugPrint("AutoSync Error: $e");
  //         emit(SyncFailure(error: e.toString(), failedOperation: 'Auto Daily Sync'));
  //       }
  //     }
  //   }
  // }

  // Future<void> _onSyncSpecificData(
  //   SyncSpecificData event,
  //   Emitter<SyncState> emit,
  // ) async {
  //   try {
  //     emit(SyncInProgress(
  //       type: event.type,
  //       currentOperation: 'Syncing ${event.type.name}...',
  //     ));
  //
  //     switch (event.type) {
  //       case SyncType.doctors:
  //         await syncRepo.syncDoctors(event.data as List<SetupDoctor>);
  //         break;
  //       case SyncType.testCategories:
  //         await syncRepo
  //             .syncTestCategories(event.data as List<SetupTestCategory>);
  //         break;
  //       case SyncType.testNames:
  //         await syncRepo.syncTestNames(event.data as List<SetupTestName>);
  //         break;
  //       case SyncType.genders:
  //         await syncRepo.syncGenders(event.data as List<SetupGender>);
  //         break;
  //       case SyncType.bloodGroups:
  //         await syncRepo.syncBloodGroups(event.data as List<SetupBloodGroup>);
  //         break;
  //       case SyncType.patients:
  //         await syncRepo.syncPatients(event.data as List<SetupPatient>);
  //         break;
  //       case SyncType.inventory:
  //         await syncRepo
  //             .syncInventory(event.data as List<SetupInventoryAllSetup>);
  //         break;
  //       case SyncType.invoices:
  //         await syncRepo.syncInvoices(event.data);
  //         break;
  //     }
  //
  //     emit(SyncSuccess(type: event.type));
  //   } catch (e, stackTrace) {
  //     debugPrint('Sync error: $e\n$stackTrace');
  //     emit(SyncFailure(
  //       type: event.type,
  //       error: e.toString(),
  //       failedOperation: 'Syncing ${event.type.name}',
  //     ));
  //   }
  // }

  Future<void> _onSyncSpecificData(
    SyncSpecificData event,
    Emitter<SyncState> emit,
  ) async {
    try {
      // Emit in-progress state with type
      emit(SyncInProgress(
        type: event.type,
        currentOperation: 'Syncing ${event.type.name}...',
      ));

      // Handle sync based on type
      switch (event.type) {
        case SyncType.doctors:
          await syncRepo.syncDoctors(event.data as List<SetupDoctor>);
          break;
        case SyncType.testCategories:
          await syncRepo
              .syncTestCategories(event.data as List<SetupTestCategory>);
          break;
        case SyncType.testNames:
          await syncRepo.syncTestNames(event.data as List<SetupTestName>);
          break;
        case SyncType.genders:
          await syncRepo.syncGenders(event.data as List<SetupGender>);
          break;
        case SyncType.bloodGroups:
          await syncRepo.syncBloodGroups(event.data as List<SetupBloodGroup>);
          break;
        case SyncType.patients:
          await syncRepo.syncPatients(event.data as List<SetupPatient>);
          break;
        case SyncType.inventory:
          await syncRepo
              .syncInventory(event.data as List<SetupInventoryAllSetup>);
          break;
        case SyncType.invoices:
          await syncRepo.syncInvoices(event.data);
          break;
        case SyncType.parameterGroups:
          await syncRepo.syncParameterGroups(event.data);
          break;
        case SyncType.parameters:
          await syncRepo.syncParameters(event.data);
          break;
        case SyncType.testNameConfigs:
          await syncRepo.syncTestNameConfigs(event.data);
          break;
        case SyncType.testParameters:
          await syncRepo.syncTestParameters(event.data);
          break;
        case SyncType.booths:
          await syncRepo.syncBooths(event.data);
          break;
        case SyncType.collectors:
          await syncRepo.syncCollectors(event.data);
          break;

        case SyncType.specimen:
          await syncRepo.syncSpecimens(event.data);
          break;
        case SyncType.testGroup:
          await syncRepo.syncTestGroups(event.data);
          break;
        case SyncType.printLayouts:
          await syncRepo.syncPrintLayouts(event.data ?? PrintLayout());
          break;
        case SyncType.caseEffect:
          await syncRepo.syncCaseEffects(event.data);
          break;
        case SyncType.marketerList:
          await syncRepo.syncMarketers(event.data);
          break;
      }

      // Emit success for this specific type
      emit(SyncSuccess(type: event.type));
    } catch (e, stackTrace) {
      debugPrint('Sync error for ${event.type.name}: $e\n$stackTrace');

      emit(SyncFailure(
        type: event.type,
        error: e.toString(),
        failedOperation: 'Syncing ${event.type.name}',
      ));
    }
  }
}

// Helper class to organize sync operations
class _SyncOperation {
  final String description;
  final Future<void> Function() execute;

  _SyncOperation(this.description, this.execute);
}
