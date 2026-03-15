import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/scan_repository.dart';
import 'scan_event.dart';
import 'scan_state.dart';

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final ScanRepository _scanRepository;

  ScanBloc({required ScanRepository scanRepository})
      : _scanRepository = scanRepository,
        super(const ScanState()) {
    on<ScanSubmitted>(_onScanSubmitted);
    on<ScanHistoryRequested>(_onScanHistoryRequested);
    on<ScanFavoriteToggled>(_onScanFavoriteToggled);
    on<ScanDeleted>(_onScanDeleted);
  }

  Future<void> _onScanSubmitted(
    ScanSubmitted event,
    Emitter<ScanState> emit,
  ) async {
    emit(state.copyWith(status: ScanStatus.analyzing));
    try {
      final scan = await _scanRepository.uploadScan(event.imageFile);
      emit(state.copyWith(
        status: ScanStatus.success,
        currentScan: scan,
        scansToday: state.scansToday + 1,
      ));
    } on ScanException catch (e) {
      emit(state.copyWithError(e.message));
    }
  }

  Future<void> _onScanHistoryRequested(
    ScanHistoryRequested event,
    Emitter<ScanState> emit,
  ) async {
    if (event.page == 1) {
      emit(state.copyWith(status: ScanStatus.loading));
    }
    try {
      final result = await _scanRepository.getScans(page: event.page);
      final updatedHistory = event.page == 1
          ? result.scans
          : [...state.scanHistory, ...result.scans];
      emit(state.copyWith(
        status: ScanStatus.success,
        scanHistory: updatedHistory,
        hasMore: result.hasMore,
      ));
    } on ScanException catch (e) {
      emit(state.copyWithError(e.message));
    }
  }

  Future<void> _onScanFavoriteToggled(
    ScanFavoriteToggled event,
    Emitter<ScanState> emit,
  ) async {
    try {
      final updatedScan = await _scanRepository.toggleFavorite(event.id);
      final newCurrentScan =
          state.currentScan?.id == event.id ? updatedScan : state.currentScan;
      final newHistory = state.scanHistory
          .map((s) => s.id == event.id ? updatedScan : s)
          .toList();
      emit(state.copyWith(
        currentScan: newCurrentScan,
        scanHistory: newHistory,
      ));
    } on ScanException catch (e) {
      emit(state.copyWithError(e.message));
    }
  }

  Future<void> _onScanDeleted(
    ScanDeleted event,
    Emitter<ScanState> emit,
  ) async {
    try {
      await _scanRepository.deleteScan(event.id);
      final newHistory =
          state.scanHistory.where((s) => s.id != event.id).toList();
      emit(state.copyWith(
        status: ScanStatus.success,
        scanHistory: newHistory,
        currentScan:
            state.currentScan?.id == event.id ? null : state.currentScan,
      ));
    } on ScanException catch (e) {
      emit(state.copyWithError(e.message));
    }
  }
}
