import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/closet_repository.dart';
import 'closet_state.dart';

class ClosetCubit extends Cubit<ClosetState> {
  final ClosetRepository _repo;

  ClosetCubit({required ClosetRepository repo})
      : _repo = repo,
        super(const ClosetState());

  Future<void> loadScans({bool refresh = false}) async {
    if (state.status == ClosetStatus.loading) return;
    emit(state.copyWith(
      status: ClosetStatus.loading,
      scans: refresh ? [] : state.scans,
      page: refresh ? 1 : state.page,
    ));
    try {
      final result = await _repo.getScans(
        page: 1,
        favoritesOnly: state.filter == ClosetFilter.favorites,
      );
      emit(state.copyWith(
        status: ClosetStatus.success,
        scans: result.scans,
        hasMore: result.hasMore,
        page: 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ClosetStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    emit(state.copyWith(isLoadingMore: true));
    try {
      final nextPage = state.page + 1;
      final result = await _repo.getScans(
        page: nextPage,
        favoritesOnly: state.filter == ClosetFilter.favorites,
      );
      emit(state.copyWith(
        scans: [...state.scans, ...result.scans],
        hasMore: result.hasMore,
        page: nextPage,
        isLoadingMore: false,
      ));
    } catch (_) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  Future<void> setFilter(ClosetFilter filter) async {
    if (state.filter == filter) return;
    emit(state.copyWith(filter: filter));
    await loadScans(refresh: true);
  }

  Future<void> toggleFavorite(String id) async {
    try {
      final updated = await _repo.toggleFavorite(id);
      final scans = state.scans.map((s) => s.id == id ? updated : s).toList();
      final filtered = state.filter == ClosetFilter.favorites
          ? scans.where((s) => s.isFavorite).toList()
          : scans;
      emit(state.copyWith(scans: filtered));
    } catch (_) {}
  }

  Future<void> deleteScan(String id) async {
    try {
      await _repo.deleteScan(id);
      emit(state.copyWith(
        scans: state.scans.where((s) => s.id != id).toList(),
      ));
    } catch (_) {}
  }
}
