import 'package:equatable/equatable.dart';

import '../../../models/scan_model.dart';

enum ClosetStatus { initial, loading, success, failure }

enum ClosetFilter { all, favorites }

class ClosetState extends Equatable {
  final ClosetStatus status;
  final List<ScanModel> scans;
  final bool hasMore;
  final int page;
  final ClosetFilter filter;
  final bool isLoadingMore;
  final String? errorMessage;

  const ClosetState({
    this.status = ClosetStatus.initial,
    this.scans = const [],
    this.hasMore = false,
    this.page = 1,
    this.filter = ClosetFilter.all,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  ClosetState copyWith({
    ClosetStatus? status,
    List<ScanModel>? scans,
    bool? hasMore,
    int? page,
    ClosetFilter? filter,
    bool? isLoadingMore,
    String? errorMessage,
  }) =>
      ClosetState(
        status: status ?? this.status,
        scans: scans ?? this.scans,
        hasMore: hasMore ?? this.hasMore,
        page: page ?? this.page,
        filter: filter ?? this.filter,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props =>
      [status, scans, hasMore, page, filter, isLoadingMore, errorMessage];
}
