import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final wallet = context.watch<WalletProvider>();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            children: [
              // Profile header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16)],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: AppTheme.primary.withOpacity(0.15),
                      child: Text(
                        (auth.user?['displayName'] ?? 'S')[0].toUpperCase(),
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.primary),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      auth.user?['displayName'] ?? 'Campus Student',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      auth.user?['email'] ?? 'student@university.edu',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StatChip(label: 'Rating', value: '4.8'),
                        const SizedBox(width: 20),
                        _StatChip(label: 'Completed', value: '12'),
                        const SizedBox(width: 20),
                        _StatChip(label: 'Balance', value: '\$${wallet.balance.toStringAsFixed(0)}'),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),

              const SizedBox(height: 24),

              _ProfileTile(icon: Iconsax.wallet, title: 'Wallet & Payouts', onTap: () {}),
              _ProfileTile(icon: Iconsax.setting_2, title: 'Settings', onTap: () {}),
              _ProfileTile(icon: Iconsax.notification, title: 'Notifications', onTap: () {}),
              _ProfileTile(icon: Iconsax.people, title: 'Referrals', onTap: () {}),
              _ProfileTile(icon: Iconsax.moon, title: 'Study Mode', trailing: Switch(value: false, onChanged: (_) {})),
              _ProfileTile(icon: Iconsax.info_circle, title: 'Help & Support', onTap: () {}),
              const SizedBox(height: 12),
              _ProfileTile(
                icon: Iconsax.logout,
                title: 'Sign Out',
                color: AppTheme.error,
                onTap: () async {
                  await auth.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
                  }
                },
              ),
            ].animate(interval: 40.ms).fadeIn(duration: 300.ms),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? color;

  const _ProfileTile({
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color ?? AppTheme.textPrimary),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color ?? AppTheme.textPrimary,
          ),
        ),
        trailing: trailing ?? const Icon(Iconsax.arrow_right_3, size: 18, color: AppTheme.textSecondary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
