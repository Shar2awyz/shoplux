import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shoplux/constants/AppColors.dart';
import 'location_picker_page.dart';
import 'package:shoplux/core/app_color_scheme.dart';
import 'package:shoplux/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:shoplux/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:shoplux/features/profile/presentation/states/edit_profile_state.dart';
import 'package:shoplux/features/profile/presentation/viewmodels/edit_profile_cubit.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  static Route<bool> route() => MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => EditProfileCubit(
            repository: ProfileRepositoryImpl(
              dataSource: ProfileRemoteDataSourceImpl(
                client: Supabase.instance.client,
              ),
            ),
          )..loadProfile(),
          child: const EditProfilePage(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: const _EditProfileBody(),
    );
  }
}

class _EditProfileBody extends StatefulWidget {
  const _EditProfileBody();

  @override
  State<_EditProfileBody> createState() => _EditProfileBodyState();
}

class _EditProfileBodyState extends State<_EditProfileBody> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _fieldsPopulated = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _populateFields(EditProfileState state) {
    if (_fieldsPopulated || state.profile == null) return;
    _fieldsPopulated = true;
    final p = state.profile!;
    _nameController.text = p.name;
    _emailController.text = p.email;
    _phoneController.text = p.phone;
    _addressController.text = p.address;
  }

  Future<void> _openLocationPicker() async {
    final address = await LocationPickerPage.pick(context);
    if (address != null && address.isNotEmpty) {
      _addressController.text = address;
    }
  }

  void _onSave() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showSnackBar('Name cannot be empty.', isError: true);
      return;
    }

    context.read<EditProfileCubit>().saveChanges(
          name: name,
          phone: _phoneController.text,
          address: _addressController.text,
          email: _emailController.text.trim(),
        );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditProfileCubit, EditProfileState>(
      listener: (context, state) {
        _populateFields(state);

        if (state.isSuccess) {
          _showSnackBar('Profile updated successfully.');
          context.read<EditProfileCubit>().resetStatus();
          Navigator.of(context).pop(true);
        } else if (state.emailConfirmationSent) {
          _showSnackBar(
            'Profile saved. Check your inbox to confirm the new email.',
          );
          context.read<EditProfileCubit>().resetStatus();
          Navigator.of(context).pop(true);
        } else if (state.isError && state.error != null) {
          _showSnackBar(state.error!, isError: true);
          context.read<EditProfileCubit>().resetStatus();
        }
      },
      builder: (context, state) {
        _populateFields(state);

        final colors = context.colors;
        final hPadding = MediaQuery.of(context).size.width * 0.05;
        final userName = state.profile?.name ?? '';
        final initial =
            userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: colors.background,
              surfaceTintColor: Colors.transparent,
              pinned: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new,
                    color: colors.text, size: 20),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              title: Text(
                'Edit Profile',
                style: TextStyle(
                  color: colors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 28),

                    Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    _SectionLabel('Personal Info'),
                    const SizedBox(height: 12),

                    _ProfileField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 12),

                    _ProfileField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),

                    _ProfileField(
                      controller: _addressController,
                      label: 'Address',
                      icon: Icons.location_on_outlined,
                      keyboardType: TextInputType.streetAddress,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _openLocationPicker,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.my_location,
                              color: AppColors.primary, size: 14),
                          SizedBox(width: 5),
                          Text(
                            'Detect my location',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    _SectionLabel('Account'),
                    const SizedBox(height: 12),

                    _ProfileField(
                      controller: _emailController,
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        'Changing your email will send a confirmation link to the new address.',
                        style: TextStyle(
                          color: colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: state.isLoading ? null : _onSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor:
                              AppColors.primary.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: state.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Section label ────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: context.colors.grey,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }
}

// ── Profile field ─────────────────────────────────────────────

class _ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final int maxLines;

  const _ProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.fieldBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.fieldBorder, width: 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        maxLines: maxLines,
        style: TextStyle(
          color: colors.text,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          labelText: label,
          labelStyle: TextStyle(
            color: colors.grey,
            fontSize: 13,
          ),
          floatingLabelStyle: TextStyle(
            color: AppColors.primary.withValues(alpha: 0.9),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
