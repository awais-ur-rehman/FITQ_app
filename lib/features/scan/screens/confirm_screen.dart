import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/image_utils.dart';
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
  String? _errorMessage;

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
        setState(() {
          _currentFile = File(croppedFile.path);
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Could not crop image. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isCropping = false);
    }
  }

  Future<void> _analyze(BuildContext ctx) async {
    setState(() => _errorMessage = null);
    HapticFeedback.mediumImpact();
    final compressed = await ImageUtils.compress(_currentFile);
    if (!ctx.mounted) return;
    ctx.read<ScanBloc>().add(ScanSubmitted(compressed));
  }

  void _showScanLimitSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.neonMint.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('⚡', style: TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Daily limit reached',
              style: AppTextStyles.titleLarge
                  .copyWith(color: AppColors.pureWhite),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ve used all your free scans for today. Upgrade to Pro for unlimited scans, priority analysis, and exclusive styles.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Upgrade to Pro — Coming Soon'),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Maybe later',
                style:
                    TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
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
          final msg = state.errorMessage ?? 'Analysis failed';
          if (msg.toLowerCase().contains('scan limit') ||
              msg.toLowerCase().contains('daily limit')) {
            _showScanLimitSheet(context);
          } else {
            setState(() => _errorMessage = msg);
          }
        }
      },
      child: BlocBuilder<ScanBloc, ScanState>(
        buildWhen: (prev, curr) =>
            curr.status == ScanStatus.analyzing ||
            prev.status == ScanStatus.analyzing ||
            prev.status != curr.status,
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
                // Image preview
                SizedBox(
                  width: double.infinity,
                  height: size.height,
                  child: Image.file(_currentFile, fit: BoxFit.cover),
                ),

                // Bottom gradient + actions
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

                        // Inline error message
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.error.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline,
                                    size: 16, color: AppColors.error),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),
                        Row(
                          children: [
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
                            Expanded(
                              child: CustomButton(
                                label: isAnalyzing
                                    ? 'Analyzing...'
                                    : _errorMessage != null
                                        ? 'Try Again'
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
