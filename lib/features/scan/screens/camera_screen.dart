import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _hasPermission = false;
  bool _isCapturing = false;
  FlashMode _flashMode = FlashMode.off;
  int _cameraIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      ctrl.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) setState(() => _hasPermission = false);
      return;
    }

    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;

    if (mounted) setState(() => _hasPermission = true);
    await _startCamera(_cameraIndex);
  }

  Future<void> _startCamera(int index) async {
    await _controller?.dispose();
    final ctrl = CameraController(
      _cameras[index],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _controller = ctrl;
    try {
      await ctrl.initialize();
      await ctrl.setFlashMode(_flashMode);
      if (mounted) setState(() => _isInitialized = true);
    } on CameraException catch (_) {
      // Camera init failed — show fallback
    }
  }

  Future<void> _toggleFlash() async {
    final next = _flashMode == FlashMode.off
        ? FlashMode.auto
        : _flashMode == FlashMode.auto
            ? FlashMode.always
            : FlashMode.off;
    await _controller?.setFlashMode(next);
    if (mounted) setState(() => _flashMode = next);
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;
    setState(() => _isInitialized = false);
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _startCamera(_cameraIndex);
  }

  Future<void> _takePicture() async {
    if (!_isInitialized || _isCapturing || _controller == null) return;
    setState(() => _isCapturing = true);
    try {
      final xFile = await _controller!.takePicture();
      if (mounted) context.push(RouteNames.scanConfirm, extra: File(xFile.path));
    } on CameraException catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to capture photo')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    final xFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (xFile != null && mounted) {
      context.push(RouteNames.scanConfirm, extra: File(xFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_hasPermission) {
      return _PermissionView(onRetry: _initCamera);
    }

    return Stack(
      children: [
        // ── Camera preview ────────────────────────────
        if (_isInitialized && _controller != null)
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.previewSize?.height ?? 1,
                height: _controller!.value.previewSize?.width ?? 1,
                child: CameraPreview(_controller!),
              ),
            ),
          )
        else
          const Center(
            child: CircularProgressIndicator(color: AppColors.neonMint),
          ),

        // ── Top bar ───────────────────────────────────
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _IconBtn(
                  icon: Icons.close,
                  onTap: () => context.pop(),
                ),
                const Spacer(),
                _IconBtn(
                  icon: _flashIcon,
                  onTap: _toggleFlash,
                ),
              ],
            ),
          ),
        ),

        // ── Capture guide overlay ─────────────────────
        Center(
          child: Container(
            width: MediaQuery.sizeOf(context).width * 0.8,
            height: MediaQuery.sizeOf(context).width * 0.8 * 1.3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.pureWhite.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
        ),

        // ── Bottom controls ───────────────────────────
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              32,
              20,
              32,
              MediaQuery.paddingOf(context).bottom + 24,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Gallery
                _IconBtn(
                  icon: Icons.photo_library_outlined,
                  size: 28,
                  onTap: _pickFromGallery,
                ),

                // Shutter button
                GestureDetector(
                  onTap: _takePicture,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.pureWhite,
                        width: 3,
                      ),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.pureWhite,
                      ),
                    ),
                  ),
                ),

                // Flip camera
                _IconBtn(
                  icon: Icons.flip_camera_ios_outlined,
                  size: 28,
                  onTap: _flipCamera,
                ),
              ],
            ),
          ),
        ),

        // ── Capture flash feedback ────────────────────
        if (_isCapturing)
          const Positioned.fill(
            child: ColoredBox(color: Color(0x44FFFFFF)),
          ),
      ],
    );
  }

  IconData get _flashIcon => switch (_flashMode) {
        FlashMode.auto => Icons.flash_auto,
        FlashMode.always => Icons.flash_on,
        _ => Icons.flash_off,
      };
}

// ─────────────────────────────────────────────────────────────────
// Supporting widgets
// ─────────────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _IconBtn({required this.icon, required this.onTap, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.4),
        ),
        child: Icon(icon, color: AppColors.pureWhite, size: size),
      ),
    );
  }
}

class _PermissionView extends StatelessWidget {
  final VoidCallback onRetry;

  const _PermissionView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 56,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 20),
            Text(
              'Camera access required',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.pureWhite,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Allow FITQ to access your camera to rate your fits.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Allow Camera'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => openAppSettings(),
              child: Text(
                'Open Settings',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
