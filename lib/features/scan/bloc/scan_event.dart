import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class ScanEvent extends Equatable {
  const ScanEvent();

  @override
  List<Object?> get props => [];
}

class ScanSubmitted extends ScanEvent {
  final File imageFile;

  const ScanSubmitted(this.imageFile);

  @override
  List<Object?> get props => [imageFile.path];
}

class ScanHistoryRequested extends ScanEvent {
  final int page;

  const ScanHistoryRequested({this.page = 1});

  @override
  List<Object?> get props => [page];
}

class ScanFavoriteToggled extends ScanEvent {
  final String id;

  const ScanFavoriteToggled(this.id);

  @override
  List<Object?> get props => [id];
}

class ScanDeleted extends ScanEvent {
  final String id;

  const ScanDeleted(this.id);

  @override
  List<Object?> get props => [id];
}
