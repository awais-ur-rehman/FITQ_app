import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../models/scan_model.dart';
import '../widgets/score_card_widget.dart';

class ShareCardGenerator {
  ShareCardGenerator._();

  static Future<void> shareScore({
    required BuildContext context,
    required ScanModel scan,
    required String username,
  }) async {
    final controller = ScreenshotController();

    final imageBytes = await controller.captureFromWidget(
      InheritedTheme.captureAll(
        context,
        Material(
          color: Colors.transparent,
          child: ScoreCardWidget(scan: scan, username: username),
        ),
      ),
      pixelRatio: 2.0,
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/fitq_score_${scan.id}.png');
    await file.writeAsBytes(imageBytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text:
          'My outfit scored ${scan.score.toStringAsFixed(1)}/10 on FITQ! 🔥 Rate yours at fitq.app',
    );
  }
}
