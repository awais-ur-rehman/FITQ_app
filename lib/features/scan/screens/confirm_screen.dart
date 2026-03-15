import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/custom_button.dart';
import '../bloc/scan_bloc.dart';
import '../bloc/scan_event.dart';
import '../bloc/scan_state.dart';

class ConfirmScreen extends StatefulWidget {
  final File imageFile;

  const ConfirmScreen({super.key, required this.imageFile});

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  late File _currentFile;
  bool _isCropping = false;

  @override
  void initState() {
    super.initState();
    _currentFile = widget.imageFile;
  }

  Future<void> _crop() async {
    setState(() => _isCropping = true);
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _currentFile.path,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Your Fit',
            toolbarColor: AppColors.background,
            toolbarWidgetColor: AppColors.pureWhite,
            backgroundColor: AppColors.background,
            activeControlsWidgetColor: AppColors.neonMint,
          ),
          IOSUiSettings(
            title: 'Crop Your Fit',
            cancelButtonTitle: 'Cancel',
            doneButtonTitle: 'Done',
          ),
        ],
      );
      if (croppedFile != null && mounted) {
        setState(() => _currentFile = File(croppedFile.path));
      }
    } finally {
      if (mounted) setState(() => _isCropping = false);
    }
  }

  void _analyze(BuildContext ctx) {
    ctx.read<ScanBloc>().add(ScanSubmitted(_currentFile));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return BlocListener<ScanBloc, ScanState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == ScanStatus.success) {
          context.go(RouteNames.scanScore);
        } else if (state.status == ScanStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Analysis failed'),
            ),
          );
        }
      },
      child: BlocBuilder<ScanBloc, ScanState>(
        buildWhen: (prev, curr) =>
            curr.status == ScanStatus.analyzing ||
            prev.status == ScanStatus.analyzing,
        builder: (context, state) {
          final isAnalyzing = state.status == ScanStatus.analyzing;

          return Scaffold(
            backgroundColor: AppColors.background,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                color: AppColors.pureWhite,
                onPressed: isAnalyzing ? null : () => context.pop(),
              ),
            ),
            body: Stack(
              children: [
                // ── Image preview ───────────────────────
                SizedBox(
                  width: double.infinity,
                  height: size.height,
                  child: Image.file(
                    _currentFile,
                    fit: BoxFit.cover,
                  ),
                ),

                // ── Bottom gradient + actions ───────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      28,
                      60,
                      28,
                      MediaQuery.paddingOf(context).bottom + 32,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.background.withValues(alpha: 0.9),
                          AppColors.background,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Looking good?',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.pureWhite,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Crop or adjust before we rate your fit.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            // Crop button
                            OutlinedButton.icon(
                              onPressed:
                                  (isAnalyzing || _isCropping) ? null : _crop,
                              icon: _isCropping
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        color: AppColors.pureWhite,
                                      ),
                                    )
                                  : const Icon(Icons.crop, size: 16),
                              label: const Text('Crop'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Analyze button
                            Expanded(
                              child: CustomButton(
                                label: isAnalyzing
                                    ? 'Analyzing...'
                                    : 'Analyze My Fit',
                                isLoading: isAnalyzing,
                                onPressed: isAnalyzing
                                    ? null
                                    : () => _analyze(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
