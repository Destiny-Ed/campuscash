import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../providers/gig_provider.dart';
import '../../theme/app_theme.dart';

class EarnScreen extends StatefulWidget {
  const EarnScreen({super.key});

  @override
  State<EarnScreen> createState() => _EarnScreenState();
}

class _EarnScreenState extends State<EarnScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _categories = [
    {'key': null, 'label': 'All', 'icon': Iconsax.category},
    {'key': 'microTask', 'label': 'Micro Tasks', 'icon': Iconsax.task_square},
    {'key': 'tutoring', 'label': 'Tutoring', 'icon': Iconsax.teacher},
    {'key': 'projectWriting', 'label': 'Project Writing', 'icon': Iconsax.document_text},
    {'key': 'notes', 'label': 'Notes', 'icon': Iconsax.note_text},
    {'key': 'campusGig', 'label': 'Campus Gigs', 'icon': Iconsax.briefcase},
    {'key': 'skillGig', 'label': 'Skills', 'icon': Iconsax.code},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GigProvider>().loadGigs();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gigProvider = context.watch<GigProvider>();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Earn',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Iconsax.add_circle, size: 28),
                    color: AppTheme.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  final isSelected = gigProvider.activeFilter == cat['key'] ||
                      (gigProvider.activeFilter == null && cat['key'] == null);
                  return GestureDetector(
                    onTap: () => gigProvider.loadGigs(type: cat['key'] as String?),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primary : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          if (!isSelected)
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            cat['icon'] as IconData,
                            size: 18,
                            color: isSelected ? Colors.white : AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            cat['label'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : AppTheme.textPrimary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: gigProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      physics: const BouncingScrollPhysics(),
                      itemCount: gigProvider.gigs.isEmpty ? 3 : gigProvider.gigs.length,
                      itemBuilder: (context, i) {
                        // Demo data if empty
                        final demo = [
                          {
                            'title': 'History Research Paper',
                            'type': 'projectWriting',
                            'budget': 45.0,
                            'description': '1500-word essay on African independence movements',
                            'tags': ['essay', 'history'],
                          },
                          {
                            'title': 'CSC 201 Tutoring',
                            'type': 'tutoring',
                            'budget': 20.0,
                            'description': 'Help with data structures — 1 hour session',
                            'tags': ['tutoring', 'csc'],
                          },
                          {
                            'title': 'Campus Flyer Distribution',
                            'type': 'campusGig',
                            'budget': 15.0,
                            'description': 'Distribute 200 flyers around main campus',
                            'tags': ['gig'],
                          },
                        ];
                        final gig = gigProvider.gigs.isEmpty ? demo[i] : gigProvider.gigs[i];
                        return _GigCard(gig: gig)
                            .animate(delay: (i * 80).ms)
                            .fadeIn()
                            .slideY(begin: 0.1, curve: Curves.easeOutCubic);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GigCard extends StatelessWidget {
  final dynamic gig;
  const _GigCard({required this.gig});

  Color _typeColor(String? type) {
    switch (type) {
      case 'projectWriting':
        return AppTheme.accent;
      case 'tutoring':
        return const Color(0xFF8B5CF6);
      case 'microTask':
        return const Color(0xFF3B82F6);
      case 'notes':
        return const Color(0xFF10B981);
      default:
        return AppTheme.primary;
    }
  }

  String _typeLabel(String? type) {
    switch (type) {
      case 'projectWriting':
        return 'Project Writing';
      case 'tutoring':
        return 'Tutoring';
      case 'microTask':
        return 'Micro Task';
      case 'notes':
        return 'Notes';
      case 'campusGig':
        return 'Campus Gig';
      case 'skillGig':
        return 'Skill Gig';
      default:
        return 'Gig';
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = gig['type'] as String?;
    final color = _typeColor(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _typeLabel(type),
                  style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
              const Spacer(),
              Text(
                '\$${(gig['budget'] as num?)?.toStringAsFixed(0) ?? '0'}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            gig['title'] ?? '',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            gig['description'] ?? '',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Iconsax.clock, size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text('Posted recently', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
