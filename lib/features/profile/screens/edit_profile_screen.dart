import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../bloc/profile_cubit.dart';
import '../bloc/profile_state.dart';

// Values must match backend enums exactly
const _kGenders = ['male', 'female', 'other', 'prefer_not_to_say'];
const _kStyles = [
  'streetwear',
  'casual',
  'formal',
  'minimalist',
  'bohemian',
  'athletic',
  'vintage',
];

String _fmtGender(String v) => switch (v) {
      'male' => 'Male',
      'female' => 'Female',
      'other' => 'Other',
      'prefer_not_to_say' => 'Prefer not to say',
      _ => v,
    };

String _fmtStyle(String v) =>
    v[0].toUpperCase() + v.substring(1);

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _bioCtrl;
  String? _gender;
  String? _stylePreference;
  File? _pendingAvatar;

  @override
  void initState() {
    super.initState();
    final user = context.read<ProfileCubit>().state.user;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _usernameCtrl = TextEditingController(text: user?.username ?? '');
    _bioCtrl = TextEditingController(text: user?.bio ?? '');
    _gender = user?.gender;
    _stylePreference = user?.stylePreference;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _pendingAvatar = File(picked.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<ProfileCubit>();

    if (_pendingAvatar != null) {
      await cubit.uploadAvatar(_pendingAvatar!);
    }

    await cubit.updateProfile(
      name: _nameCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
      gender: _gender,
      stylePreference: _stylePreference,
    );

    if (mounted && context.read<ProfileCubit>().state.errorMessage == null) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: AppColors.pureWhite,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Edit Profile',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.pureWhite),
        ),
      ),
      body: BlocListener<ProfileCubit, ProfileState>(
        listenWhen: (prev, curr) =>
            prev.errorMessage != curr.errorMessage &&
            curr.errorMessage != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        },
        child: BlocBuilder<ProfileCubit, ProfileState>(
          buildWhen: (prev, curr) => prev.isSaving != curr.isSaving,
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.paddingOf(context).bottom + 24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Avatar picker
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.border, width: 2),
                              color: AppColors.surface,
                            ),
                            child: ClipOval(
                              child: _buildAvatar(context),
                            ),
                          ),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.neonMint,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit,
                                size: 14, color: AppColors.deepCarbon),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    CustomTextField(
                      label: 'Name',
                      controller: _nameCtrl,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Username',
                      controller: _usernameCtrl,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (!RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(v)) {
                          return '3–20 chars: letters, numbers, _';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Bio',
                      controller: _bioCtrl,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    _DropdownField(
                      label: 'Gender',
                      value: _gender,
                      items: _kGenders,
                      labelBuilder: _fmtGender,
                      onChanged: (v) => setState(() => _gender = v),
                    ),
                    const SizedBox(height: 16),

                    _DropdownField(
                      label: 'Style Preference',
                      value: _stylePreference,
                      items: _kStyles,
                      labelBuilder: _fmtStyle,
                      onChanged: (v) =>
                          setState(() => _stylePreference = v),
                    ),
                    const SizedBox(height: 36),

                    CustomButton(
                      label: 'Save Changes',
                      isLoading: state.isSaving,
                      onPressed: state.isSaving ? null : _save,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    if (_pendingAvatar != null) {
      return Image.file(_pendingAvatar!, fit: BoxFit.cover);
    }
    final avatarUrl =
        context.read<ProfileCubit>().state.user?.avatarUrl;
    if (avatarUrl != null) {
      return CachedNetworkImage(
        imageUrl: avatarUrl,
        fit: BoxFit.cover,
        placeholder: (_, _) => Container(color: AppColors.surfaceVariant),
      );
    }
    return const Icon(Icons.person_outline,
        color: AppColors.textMuted, size: 36);
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final String Function(String) labelBuilder;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          hint: Text(
            'Select...',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textMuted),
          ),
          dropdownColor: AppColors.surfaceElevated,
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.pureWhite),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.neonMint, width: 1.5),
            ),
          ),
          items: items
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(labelBuilder(s)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
