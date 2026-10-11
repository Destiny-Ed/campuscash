import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../providers/timetable_provider.dart';
import '../../providers/tour_provider.dart';
import '../../theme/app_theme.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimetableProvider>().load();
      context.read<TourProvider>().loadTours('demo-uni');
    });
  }

  @override
  Widget build(BuildContext context) {
    final timetable = context.watch<TimetableProvider>();
    final tours = context.watch<TourProvider>();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Schedule',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Iconsax.add_circle, size: 28, color: AppTheme.primary),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: const Text(
                  'My Timetable',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 140,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _DayCard(day: 'Mon', classes: ['CS101 9:00', 'MTH201 11:00']),
                    _DayCard(day: 'Tue', classes: ['PHY102 10:00']),
                    _DayCard(day: 'Wed', classes: ['CS101 9:00', 'ENG105 14:00']),
                    _DayCard(day: 'Thu', classes: ['MTH201 11:00']),
                    _DayCard(day: 'Fri', classes: ['Free day']),
                  ].animate(interval: 60.ms).fadeIn().slideX(begin: 0.15),
                ),
              ),
            ),
            const AttributedSliverPadding(
              padding: EdgeInsets.fromLTRB(20, 28, 20, 12),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Campus Tours',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            AttributedSliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _TourCard(
                    title: 'First Year Essentials',
                    desc: 'Library, admin, food courts & free study spots',
                    mins: 45,
                    isOfficial: true,
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 12),
                  _TourCard(
                    title: 'Quiet Study Zones',
                    desc: 'Best places to focus without distractions',
                    mins: 30,
                    isOfficial: false,
                  ).animate().fadeIn(delay: 180.ms),
                  const SizedBox(height: 12),
                  _TourCard(
                    title: 'Food & Free Resources',
                    desc: 'Affordable eats and free campus resources',
                    mins: 35,
                    isOfficial: true,
                  ).animate().fadeIn(delay: 260.ms),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final String day;
  final List<String> classes;
  const _DayCard({required this.day, required this.classes});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(day, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 10),
          ...classes.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(c, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              )),
        ],
      ),
    );
  }
}

class _TourCard extends StatelessWidget {
  final String title;
  final String desc;
  final int mins;
  final bool isOfficial;
  const _TourCard({required this.title, required this.desc, required this.mins, required this.isOfficial});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Iconsax.map_1, color: AppTheme.primary, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                    if (isOfficial)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Official', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 6),
                Text('$mins min', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AttributedSliverPadding extends StatelessWidget {
  final EdgeInsets padding;
  final Widget sliver;
  const AttributedSliverPadding({super.key, required this.padding, required this.sliver});
  @override
  Widget build(BuildContext context) => SliverPadding(padding: padding, sliver: sliver);
}
