import 'package:equatable/equatable.dart';

import '../../../models/scan_model.dart';

enum ScanStatus { initial, loading, analyzing, success, failure }

class ScanState extends Equatable {
  final ScanStatus status;
  final ScanModel? currentScan;
  final List<ScanModel> scanHistory;
  final int scansToday;
  final bool hasMore;
  final String? errorMessage;

  const ScanState({
    this.status = ScanStatus.initial,
    this.currentScan,
    this.scanHistory = const [],
    this.scansToday = 0,
    this.hasMore = true,
    this.errorMessage,
  });

  ScanState copyWith({
    ScanStatus? status,
    ScanModel? currentScan,
    List<ScanModel>? scanHistory,
    int? scansToday,
    bool? hasMore,
    String? errorMessage,
  }) =>
      ScanState(
        status: status ?? this.status,
        currentScan: currentScan ?? this.currentScan,
        scanHistory: scanHistory ?? this.scanHistory,
        scansToday: scansToday ?? this.scansToday,
        hasMore: hasMore ?? this.hasMore,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  ScanState copyWithError(String message) => ScanState(
        status: ScanStatus.failure,
        currentScan: currentScan,
        scanHistory: scanHistory,
        scansToday: scansToday,
        hasMore: hasMore,
        errorMessage: message,
      );

  @override
  List<Object?> get props => [
        status,
        currentScan,
        scanHistory,
        scansToday,
        hasMore,
        errorMessage,
      ];
}
