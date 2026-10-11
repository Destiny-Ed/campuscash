import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/earnings_card.dart';
import '../../widgets/quick_action_chip.dart';
import '../../widgets/suggestion_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().loadBalance();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final wallet = context.watch<WalletProvider>();
    final name = auth.user?['displayName']?.toString().split(' ').first ?? 'Student';

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            pinned: false,
            backgroundColor: AppTheme.surface,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hey, $name',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Ready to earn today?',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Iconsax.notification, color: AppTheme.textPrimary),
              ),
              const SizedBox(width: 4),
            ],
          ),

          // Content
          AttributedSliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Earnings Card
                EarningsCard(balance: wallet.balance)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.15, curve: Curves.easeOutCubic),

                const SizedBox(height: 28),

                // Quick Actions
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 14),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      QuickActionChip(
                        icon: Iconsax.task_square,
                        label: 'Micro Task',
                        color: const Color(0xFF3B82F6),
                        onTap: () {},
                      ),
                      QuickActionChip(
                        icon: Iconsax.teacher,
                        label: 'Tutoring',
                        color: const Color(0xFF8B5CF6),
                        onTap: () {},
                      ),
                      QuickActionChip(
                        icon: Iconsax.document_text,
                        label: 'Project Writing',
                        color: AppTheme.accent,
                        onTap: () {},
                      ),
                      QuickActionChip(
                        icon: Iconsax.note_text,
                        label: 'Sell Notes',
                        color: const Color(0xFF10B981),
                        onTap: () {},
                      ),
                      QuickActionChip(
                        icon: Iconsax.location,
                        label: 'Add Pin',
                        color: const Color(0xFFEC4899),
                        onTap: () {},
                      ),
                      QuickActionChip(
                        icon: Iconsax.map_1,
                        label: 'Start Tour',
                        color: const Color(0xFF14B8A6),
                        onTap: () {},
                      ),
                    ]
                        .animate(interval: 60.ms)
                        .fadeIn(duration: 350.ms)
                        .slideX(begin: 0.2, curve: Curves.easeOutCubic),
                  ),
                ),

                const SizedBox(height: 32),

                // Smart Suggestions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Smart Suggestions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('See all', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 12),

                SuggestionCard(
                  title: '45 min free after CS101',
                  subtitle: '3 high-paying micro-tasks nearby',
                  icon: Iconsax.clock,
                  color: AppTheme.primary,
                  trailing: '\$4.50',
                ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1),

                const SizedBox(height: 12),

                SuggestionCard(
                  title: 'Project Writing Request',
                  subtitle: 'History essay • 1500 words • Due Friday',
                  icon: Iconsax.document_text,
                  color: AppTheme.accent,
                  trailing: '\$35',
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

                const SizedBox(height: 12),

                SuggestionCard(
                  title: 'New free study spot',
                  subtitle: 'Quiet zone near the library • just pinned',
                  icon: Iconsax.location,
                  color: const Color(0xFF10B981),
                  trailing: 'Free',
                ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1),

                const SizedBox(height: 32),

                // Campus Highlights
                const Text(
                  'Campus Highlights',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary.withOpacity(0.9),
                        AppTheme.primaryDark,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Invite classmates',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'You both get \$5 when they complete their first task',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Share invite',
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Iconsax.people, size: 56, color: Colors.white24),
                    ],
                  ),
                ).animate().fadeIn(delay: 450.ms).scale(begin: const Offset(0.95, 0.95)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper because SliverPadding doesn't take a named 'sliver' in older Flutter
class AttributedSliverPadding extends StatelessWidget {
  final EdgeInsets padding;
  final Widget sliver;
  const AttributedSliverPadding({super.key, required this.padding, required this.sliver});
  @override
  Widget build(BuildContext context) => SliverPadding(padding: padding, sliver: sliver);
}
