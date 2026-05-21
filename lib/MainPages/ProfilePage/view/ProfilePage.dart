import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shoplux/Auth/LoginPage/view/LoginPage.dart';
import 'package:shoplux/constants/AppColors.dart';
import 'package:shoplux/core/app_color_scheme.dart';
import 'package:shoplux/core/shared_prefs.dart';
import 'package:shoplux/core/theme_cubit.dart';
import 'package:shoplux/features/profile/presentation/view/edit_profile_page.dart';
import 'package:shoplux/features/orders/presentation/view/MyOrdersPage.dart';
import 'package:shoplux/features/payment_methods/presentation/view/PaymentMethodsPage.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    this.onLiveChatTap,
    this.onNotificationsTap,
    this.onWishlistTap,
  });

  final VoidCallback? onLiveChatTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onWishlistTap;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late bool _darkMode;
  int _ordersCount = 0;
  int _wishlistCount = 0;

  @override
  void initState() {
    super.initState();
    _darkMode = AppPrefs.isDarkMode;
    _loadStats();
  }

  Future<void> _loadStats() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final results = await Future.wait([
        Supabase.instance.client
            .from('orders')
            .select('id')
            .eq('user_id', userId),
        Supabase.instance.client
            .from('wishlists')
            .select('id')
            .eq('user_id', userId),
      ]);
      if (mounted) {
        setState(() {
          _ordersCount = results[0].length;
          _wishlistCount = results[1].length;
        });
      }
    } catch (_) {}
  }

  String get _userName {
    final meta = Supabase.instance.client.auth.currentUser?.userMetadata;
    return meta?['full_name'] as String? ??
        meta?['name'] as String? ??
        meta?['username'] as String? ??
        'User';
  }

  String get _userEmail =>
      Supabase.instance.client.auth.currentUser?.email ?? '';

  String get _userInitial =>
      _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U';

  Future<void> _toggleDarkMode(bool value) async {
    setState(() => _darkMode = value);
    context.read<ThemeCubit>().setDark(value);
  }

  Future<void> _signOut() async {
    final colors = context.colors;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.fieldBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Sign Out',
            style: TextStyle(color: colors.text, fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    await Supabase.instance.client.auth.signOut();
    await AppPrefs.clearUserId();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginPage()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hPadding = MediaQuery.of(context).size.width * 0.05;
    final colors = context.colors;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Avatar + user info ──────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(hPadding, 32, hPadding, 0),
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _userInitial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _userName,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userEmail,
                  style: TextStyle(color: colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xff1E1206),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Premium Member',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text('⭐', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Stats card ──────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hPadding),
            child: Container(
              decoration: BoxDecoration(
                color: colors.fieldBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: [
                  _StatItem(value: '$_ordersCount', label: 'Orders'),
                  Container(width: 1, height: 40, color: colors.divider),
                  _StatItem(value: '$_wishlistCount', label: 'Wishlist'),
                  Container(width: 1, height: 40, color: colors.divider),
                  const _StatItem(value: '4.9', label: 'Rating'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // ── ACCOUNT ─────────────────────────────────────
          _SectionBlock(
            hPadding: hPadding,
            label: 'ACCOUNT',
            children: [
              _SettingsItem(
                emoji: '👤',
                label: 'Edit Profile',
                onTap: () async {
                  final updated = await Navigator.of(context)
                      .push<bool>(EditProfilePage.route());
                  if (updated == true && mounted) setState(() {});
                },
              ),
              _SettingsItem(emoji: '📍', label: 'My Addresses', onTap: () {}),
              _SettingsItem(
                emoji: '💳',
                label: 'Payment Methods',
                onTap: () => Navigator.push(
                  context,
                  PaymentMethodsPage.route(),
                ),
              ),
              _SettingsItem(
                emoji: '📦',
                label: 'My Orders',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyOrdersPage()),
                ),
              ),
              _SettingsItem(
                emoji: '🤍',
                label: 'My Wishlist',
                onTap: () => widget.onWishlistTap?.call(),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── PREFERENCES ─────────────────────────────────
          _SectionBlock(
            hPadding: hPadding,
            label: 'PREFERENCES',
            children: [
              _SettingsItem(
                emoji: '🔔',
                label: 'Notifications',
                onTap: () => widget.onNotificationsTap?.call(),
              ),
              _SettingsToggle(
                emoji: '🌙',
                label: 'Dark Mode',
                value: _darkMode,
                onChanged: _toggleDarkMode,
              ),
              _SettingsItem(
                  emoji: '🌍', label: 'Language · English', onTap: () {}),
            ],
          ),

          const SizedBox(height: 28),

          // ── SUPPORT ─────────────────────────────────────
          _SectionBlock(
            hPadding: hPadding,
            label: 'SUPPORT',
            children: [
              _SettingsItem(
                emoji: '💬',
                label: 'Live Chat',
                onTap: () => widget.onLiveChatTap?.call(),
              ),
              _SettingsItem(
                  emoji: '⭐', label: 'Rate the App', onTap: () {}),
              _SettingsItem(
                emoji: '🚪',
                label: 'Sign Out',
                labelColor: AppColors.primary,
                showArrow: false,
                onTap: _signOut,
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Stat item ────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ── Section block (label + card) ─────────────────────────

class _SectionBlock extends StatelessWidget {
  final double hPadding;
  final String label;
  final List<Widget> children;

  const _SectionBlock({
    required this.hPadding,
    required this.label,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Material(
            color: colors.fieldBackground,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1)
                    Divider(
                      color: colors.divider,
                      height: 1,
                      thickness: 0.5,
                      indent: 52,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Settings row ─────────────────────────────────────────

class _SettingsItem extends StatelessWidget {
  final String emoji;
  final String label;
  final Color? labelColor;
  final bool showArrow;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.emoji,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: labelColor ?? colors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (showArrow)
              Icon(Icons.chevron_right, color: colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Settings toggle row ──────────────────────────────────

class _SettingsToggle extends StatelessWidget {
  final String emoji;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.emoji,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: colors.text,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: colors.grey.withValues(alpha: 0.3),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}
