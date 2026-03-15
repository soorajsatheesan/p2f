import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2f/models/user_profile.dart';
import 'package:p2f/models/weight_entry.dart';
import 'package:p2f/pages/profile_edit_page.dart';
import 'package:p2f/providers/motivation_quote_provider.dart';
import 'package:p2f/providers/user_profile_provider.dart';
import 'package:p2f/providers/weight_provider.dart';
import 'package:p2f/theme/theme.dart';

class HomeSection extends ConsumerStatefulWidget {
  const HomeSection({required this.onOpenProfile, super.key});

  final VoidCallback onOpenProfile;

  @override
  ConsumerState<HomeSection> createState() => _HomeSectionState();
}

class _HomeSectionState extends ConsumerState<HomeSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryLoadQuote());
  }

  void _tryLoadQuote({bool force = false}) {
    final profile = ref.read(userProfileProvider).profile;
    if (profile == null) return;
    ref
        .read(motivationQuoteProvider.notifier)
        .fetchForProfile(profile: profile, force: force);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).profile;
    final weightState = ref.watch(weightProvider);
    final quoteState = ref.watch(motivationQuoteProvider);

    ref.listen(userProfileProvider, (prev, next) {
      if (prev?.profile != next.profile && next.profile != null) {
        _tryLoadQuote();
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GreetingHeader(profile: profile),
        const SizedBox(height: 28),

        _StreakHeroCard(weightState: weightState),
        const SizedBox(height: 14),

        _WeightTrackerCard(weightState: weightState),
        const SizedBox(height: 14),

        _MiniStatsRow(profile: profile, weightState: weightState),
        const SizedBox(height: 28),

        const Divider(height: 1, thickness: 1, color: AppColors.border),
        const SizedBox(height: 24),

        _DailyPushBlock(
          profile: profile,
          quoteState: quoteState,
          onRefresh:
              profile == null ? null : () => _tryLoadQuote(force: true),
        ),

        if (profile == null) ...[
          const SizedBox(height: 16),
          _ProfileNudge(onTap: widget.onOpenProfile),
        ],

        const SizedBox(height: 40),
      ],
    );
  }
}

// ── Greeting Header ────────────────────────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.profile});

  final UserProfile? profile;

  String _timeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _dateTag() {
    final now = DateTime.now();
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${days[now.weekday - 1].toUpperCase()} · '
        '${now.day} ${months[now.month - 1].toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final firstName = profile?.name.split(' ').first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _dateTag(),
          style: AppTypography.tag.copyWith(
            color: AppColors.subtle,
            letterSpacing: 2.5,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          firstName != null
              ? '${_timeGreeting()},\n$firstName.'
              : '${_timeGreeting()}.',
          style: AppTypography.displaySmall.copyWith(
            fontSize: 44,
            height: 0.96,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

// ── Streak Hero Card ───────────────────────────────────────────────────────────

class _StreakHeroCard extends ConsumerWidget {
  const _StreakHeroCard({required this.weightState});

  final WeightState weightState;

  static const _amberBorder = Color(0x55FF9900);
  static const _amberText = Color(0xCCFF9900);

  String _motivation(int streak) {
    if (streak == 0) return 'Log your weight. Start the chain.';
    if (streak == 1) return 'Day one done — the hardest part is behind you.';
    if (streak < 4) return 'Early days build lifelong habits. Keep going.';
    if (streak < 7) return 'Building momentum. Don\'t break the chain.';
    if (streak < 14) return 'One full week. You\'re proving it to yourself.';
    if (streak < 21) return 'Two weeks in. Most people have already quit.';
    if (streak < 30) return 'Elite consistency. You\'re in rare company now.';
    return 'Legendary. $streak days of unbroken discipline.';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = weightState.streak;
    final hasStreak = streak > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: hasStreak
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1C0E00), Color(0xFF0E0800)],
              )
            : null,
        color: hasStreak ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasStreak ? _amberBorder : AppColors.border,
        ),
        boxShadow: hasStreak
            ? [
                BoxShadow(
                  color: const Color(0x22FF9900),
                  blurRadius: 24,
                  spreadRadius: -4,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Fire emoji in a circle
              Container(
                width: hasStreak ? 52 : 44,
                height: hasStreak ? 52 : 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasStreak
                      ? const Color(0x22FF9900)
                      : AppColors.surfaceElevated,
                  border: Border.all(
                    color: hasStreak
                        ? const Color(0x33FF9900)
                        : AppColors.border,
                  ),
                ),
                child: Center(
                  child: Text(
                    '🔥',
                    style: TextStyle(fontSize: hasStreak ? 24 : 18),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasStreak)
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$streak',
                              style: AppTypography.displaySmall.copyWith(
                                fontSize: 44,
                                height: 1,
                                letterSpacing: -2,
                                color: AppColors.foreground,
                              ),
                            ),
                            TextSpan(
                              text: streak == 1 ? '  day' : '  days',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.muted,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        'No streak yet',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    const SizedBox(height: 3),
                    Text(
                      _motivation(streak),
                      style: AppTypography.bodySmall.copyWith(
                        color: hasStreak ? _amberText : AppColors.subtle,
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasStreak)
                _StreakMilestoneIcon(streak: streak),
            ],
          ),
          const SizedBox(height: 20),
          _SevenDayDots(chartEntries: weightState.chartEntries),
        ],
      ),
    );
  }
}

class _StreakMilestoneIcon extends StatelessWidget {
  const _StreakMilestoneIcon({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final (emoji, label) = switch (streak) {
      >= 30 => ('🏆', '30+'),
      >= 14 => ('⭐', '14+'),
      >= 7 => ('💪', '7+'),
      _ => ('', ''),
    };

    if (emoji.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            fontSize: 9,
            color: const Color(0x88FF9900),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// ── Seven-Day Dot Strip ────────────────────────────────────────────────────────

class _SevenDayDots extends StatelessWidget {
  const _SevenDayDots({required this.chartEntries});

  final List<WeightEntry> chartEntries;

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final days = List.generate(
      7,
      (i) => todayDate.subtract(Duration(days: 6 - i)),
    );

    final loggedDates = chartEntries
        .map(
          (e) =>
              DateTime(e.loggedAt.year, e.loggedAt.month, e.loggedAt.day),
        )
        .toSet();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = days[i];
        final isLogged = loggedDates.contains(day);
        final isToday = i == 6;
        final label = _dayLabels[day.weekday - 1];

        return _DayDot(label: label, isLogged: isLogged, isToday: isToday);
      }),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({
    required this.label,
    required this.isLogged,
    required this.isToday,
  });

  final String label;
  final bool isLogged;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (isToday && !isLogged)
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0x44FFFFFF),
                    width: 1.5,
                  ),
                ),
              ),
            Container(
              width: isToday ? 26 : 22,
              height: isToday ? 26 : 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isLogged
                    ? (isToday
                          ? AppColors.foreground
                          : const Color(0x33FFFFFF))
                    : Colors.transparent,
                border: isLogged
                    ? null
                    : Border.all(
                        color: isToday
                            ? const Color(0x55FFFFFF)
                            : const Color(0x1AFFFFFF),
                        width: 1,
                      ),
              ),
              child: isLogged
                  ? Icon(
                      Icons.check,
                      size: isToday ? 13 : 11,
                      color: isToday
                          ? AppColors.background
                          : const Color(0x88FFFFFF),
                    )
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: AppTypography.overline.copyWith(
            fontSize: 8.5,
            letterSpacing: 0,
            color: isToday ? AppColors.muted : AppColors.faint,
          ),
        ),
      ],
    );
  }
}

// ── Weight Tracker Card ────────────────────────────────────────────────────────

class _WeightTrackerCard extends ConsumerWidget {
  const _WeightTrackerCard({required this.weightState});

  final WeightState weightState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = weightState.chartEntries;
    final latest = weightState.latestWeight;
    final change = weightState.weekChange;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WEIGHT TRACKER',
                        style: AppTypography.tag.copyWith(
                          color: AppColors.faint,
                          letterSpacing: 2,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (latest != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: latest.toStringAsFixed(1),
                                    style: AppTypography.displaySmall.copyWith(
                                      fontSize: 40,
                                      height: 1,
                                      letterSpacing: -1.5,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' kg',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.subtle,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (change != null) ...[
                              const SizedBox(width: 10),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: _TrendBadge(change: change),
                              ),
                            ],
                          ],
                        )
                      else
                        Text(
                          'Not yet logged',
                          style: AppTypography.headlineSmall.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Chart ────────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: entries.isEmpty
                ? _EmptyChartPlaceholder()
                : entries.length == 1
                    ? _SingleEntryView(entry: entries.first)
                    : _WeightLineChart(entries: entries),
          ),

          const SizedBox(height: 12),

          // ── Log Button ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: _LogWeightButton(
              hasLoggedToday: weightState.hasLoggedToday,
              latestWeight: weightState.latestWeight,
              isSaving: weightState.isSaving,
              onLog: (kg) => ref.read(weightProvider.notifier).logWeight(kg),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Trend Badge ───────────────────────────────────────────────────────────────

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.change});

  final double change;

  @override
  Widget build(BuildContext context) {
    final isGain = change > 0;
    final color =
        isGain ? const Color(0xFFFF6B6B) : const Color(0xFF4ADE80);
    final bg = isGain ? const Color(0xFF1F0A0A) : const Color(0xFF0A1F0F);
    final borderColor =
        isGain ? const Color(0x44FF6B6B) : const Color(0x4444DD88);
    final icon =
        isGain ? Icons.trending_up_rounded : Icons.trending_down_rounded;
    final sign = change > 0 ? '+' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            '$sign${change.toStringAsFixed(1)} kg',
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mini Stats Row ─────────────────────────────────────────────────────────────

class _MiniStatsRow extends StatelessWidget {
  const _MiniStatsRow({required this.profile, required this.weightState});

  final UserProfile? profile;
  final WeightState weightState;

  double? _bmi() {
    if (profile == null) return null;
    final hm = profile!.heightCm / 100;
    return profile!.weightKg / (hm * hm);
  }

  String _bmiCategory(double bmi) {
    if (bmi < 18.5) return 'underweight';
    if (bmi < 25) return 'healthy';
    if (bmi < 30) return 'overweight';
    return 'obese';
  }

  @override
  Widget build(BuildContext context) {
    final bmi = _bmi();
    final total = weightState.totalDaysLogged;

    return Row(
      children: [
        if (bmi != null) ...[
          Expanded(
            child: _MiniStatChip(
              emoji: '📊',
              label: 'BMI',
              value: '${bmi.toStringAsFixed(1)} · ${_bmiCategory(bmi)}',
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: _MiniStatChip(
            emoji: '📅',
            label: 'TOTAL LOGGED',
            value: '$total ${total == 1 ? 'day' : 'days'}',
          ),
        ),
      ],
    );
  }
}

class _MiniStatChip extends StatelessWidget {
  const _MiniStatChip({
    required this.emoji,
    required this.label,
    required this.value,
  });

  final String emoji;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 15)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 8.5,
                    color: AppColors.faint,
                    letterSpacing: 1.2,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 11.5,
                    color: AppColors.muted,
                    letterSpacing: 0.1,
                    height: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chart ──────────────────────────────────────────────────────────────────────

class _WeightLineChart extends StatelessWidget {
  const _WeightLineChart({required this.entries});

  final List<WeightEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          width: double.infinity,
          child: CustomPaint(
            painter: _WeightChartPainter(entries: entries),
          ),
        ),
        const SizedBox(height: 6),
        _ChartDateLabels(entries: entries),
      ],
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  const _WeightChartPainter({required this.entries});

  final List<WeightEntry> entries;

  static const _padH = 8.0;
  static const _padT = 12.0;
  static const _padB = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.length < 2) return;

    final weights = entries.map((e) => e.weightKg).toList();
    final minW = weights.reduce(math.min);
    final maxW = weights.reduce(math.max);
    final range = math.max(maxW - minW, 1.5);
    final yMin = minW - range * 0.4;
    final yMax = maxW + range * 0.4;

    final chartH = size.height - _padT - _padB;
    final chartW = size.width - _padH * 2;
    final n = entries.length;

    Offset ptAt(int i) {
      final x = _padH + chartW * i / (n - 1);
      final y =
          _padT + chartH * (1 - (entries[i].weightKg - yMin) / (yMax - yMin));
      return Offset(x, y);
    }

    final pts = List.generate(n, ptAt);

    // ── Grid ──────────────────────────────────────────────────────────────────
    final gridPaint = Paint()
      ..color = const Color(0x0CFFFFFF)
      ..strokeWidth = 1;
    for (int i = 1; i <= 3; i++) {
      final y = _padT + chartH * i / 4;
      canvas.drawLine(
        Offset(_padH, y),
        Offset(size.width - _padH, y),
        gridPaint,
      );
    }

    // ── Gradient fill ─────────────────────────────────────────────────────────
    final fillPath = _smoothPath(pts)
      ..lineTo(pts.last.dx, size.height)
      ..lineTo(pts.first.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x1AFFFFFF), Color(0x00FFFFFF)],
      ).createShader(Rect.fromLTWH(0, _padT, size.width, chartH));
    canvas.drawPath(fillPath, fillPaint);

    // ── Line ──────────────────────────────────────────────────────────────────
    final linePaint = Paint()
      ..color = const Color(0xCCFFFFFF)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(_smoothPath(pts), linePaint);

    // ── Dots ──────────────────────────────────────────────────────────────────
    final today = DateTime.now();
    for (int i = 0; i < n; i++) {
      final e = entries[i];
      final isToday =
          e.loggedAt.year == today.year &&
          e.loggedAt.month == today.month &&
          e.loggedAt.day == today.day;
      final isLatest = i == n - 1;

      if (isToday) {
        canvas.drawCircle(pts[i], 5, Paint()..color = Colors.white);
        canvas.drawCircle(
          pts[i],
          9,
          Paint()
            ..color = const Color(0x33FFFFFF)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      } else if (isLatest) {
        canvas.drawCircle(pts[i], 4, Paint()..color = Colors.white);
      } else {
        canvas.drawCircle(
          pts[i],
          2.5,
          Paint()..color = const Color(0x88FFFFFF),
        );
      }
    }
  }

  Path _smoothPath(List<Offset> pts) {
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final p0 = i > 0 ? pts[i - 1] : pts[i];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = i + 2 < pts.length ? pts[i + 2] : pts[i + 1];
      final cp1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
      );
      final cp2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
      );
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(_WeightChartPainter old) => old.entries != entries;
}

class _ChartDateLabels extends StatelessWidget {
  const _ChartDateLabels({required this.entries});

  final List<WeightEntry> entries;

  @override
  Widget build(BuildContext context) {
    final n = entries.length;
    if (n < 2) return const SizedBox.shrink();

    const maxLabels = 4;
    final step = math.max(1, (n / maxLabels).ceil());
    final indices = <int>[];
    for (int i = 0; i < n; i += step) {
      indices.add(i);
    }
    if (!indices.contains(n - 1)) indices.add(n - 1);

    const padH = 8.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartW = constraints.maxWidth - padH * 2;
        return SizedBox(
          height: 14,
          child: Stack(
            children: [
              for (final i in indices)
                Positioned(
                  left: padH + chartW * i / (n - 1) - 22,
                  width: 44,
                  top: 0,
                  child: Text(
                    _fmt(entries[i].loggedAt),
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 9,
                      color: AppColors.faint,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _fmt(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }
}

class _EmptyChartPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
      ),
      child: CustomPaint(
        painter: _DashedGridPainter(),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.show_chart_rounded,
                size: 22,
                color: AppColors.faint,
              ),
              const SizedBox(height: 6),
              Text(
                'Start logging to see your curve',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.faint,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x0BFFFFFF)
      ..strokeWidth = 1;
    for (int i = 1; i <= 3; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(16, y), Offset(size.width - 16, y), paint);
    }
  }

  @override
  bool shouldRepaint(_DashedGridPainter old) => false;
}

class _SingleEntryView extends StatelessWidget {
  const _SingleEntryView({required this.entry});

  final WeightEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
      ),
      child: CustomPaint(
        painter: _DashedGridPainter(),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x66FFFFFF),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${entry.weightKg.toStringAsFixed(1)} kg',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.subtle,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Log more days to see your curve',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.faint,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Log Weight Button ──────────────────────────────────────────────────────────

class _LogWeightButton extends StatelessWidget {
  const _LogWeightButton({
    required this.hasLoggedToday,
    required this.latestWeight,
    required this.isSaving,
    required this.onLog,
  });

  final bool hasLoggedToday;
  final double? latestWeight;
  final bool isSaving;
  final ValueChanged<double> onLog;

  @override
  Widget build(BuildContext context) {
    if (isSaving) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.subtle),
              ),
            ),
            const SizedBox(width: 12),
            Text('Logging weight…', style: AppTypography.labelMedium),
          ],
        ),
      );
    }

    if (hasLoggedToday) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF081408),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x3344DD88)),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF0F2A1A),
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 15,
                color: Color(0xFF4ADE80),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Logged today",
                    style: AppTypography.labelLarge.copyWith(
                      color: const Color(0xFF4ADE80),
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Streak intact — come back tomorrow',
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0x664ADE80),
                      fontSize: 10.5,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.local_fire_department_rounded,
              size: 18,
              color: Color(0x55FF9900),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => _showLogSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFE8E8E8)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1AFFFFFF),
              blurRadius: 16,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x22000000),
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 20,
                color: AppColors.background,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Log today's weight",
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.background,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Keeps your streak alive',
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0x88000000),
                      fontSize: 11,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.background,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _LogWeightSheet(
        initialKg: latestWeight ?? 70.0,
        onLog: onLog,
      ),
    );
  }
}

// ── Log Weight Sheet ───────────────────────────────────────────────────────────

class _LogWeightSheet extends StatefulWidget {
  const _LogWeightSheet({required this.initialKg, required this.onLog});

  final double initialKg;
  final ValueChanged<double> onLog;

  @override
  State<_LogWeightSheet> createState() => _LogWeightSheetState();
}

class _LogWeightSheetState extends State<_LogWeightSheet> {
  late double _weight;

  @override
  void initState() {
    super.initState();
    _weight = (widget.initialKg * 10).round() / 10;
  }

  void _adjust(double delta) {
    setState(() {
      _weight = math.max(20.0, math.min(300.0, _weight + delta));
      _weight = (_weight * 10).round() / 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.overlayFade,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.borderStrong),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceElevated,
                      border: Border.all(color: AppColors.borderStrong),
                    ),
                    child: const Icon(
                      Icons.monitor_weight_outlined,
                      size: 18,
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text("Today's weight", style: AppTypography.headlineSmall),
                ],
              ),

              const SizedBox(height: 28),

              Text(
                _weight.toStringAsFixed(1),
                style: AppTypography.displaySmall.copyWith(
                  fontSize: 64,
                  letterSpacing: -3,
                  height: 1,
                ),
              ),
              Text(
                'kilograms',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.faint,
                  letterSpacing: 1,
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _AdjBtn(label: '−1', onTap: () => _adjust(-1)),
                  const SizedBox(width: 8),
                  _AdjBtn(label: '−0.1', onTap: () => _adjust(-0.1)),
                  const SizedBox(width: 16),
                  _AdjBtn(label: '+0.1', onTap: () => _adjust(0.1)),
                  const SizedBox(width: 8),
                  _AdjBtn(label: '+1', onTap: () => _adjust(1)),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(height: 1, thickness: 1, color: AppColors.border),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                          color: AppColors.surface,
                        ),
                        child: Center(
                          child: Text(
                            'CANCEL',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.subtle,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {
                        widget.onLog(_weight);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: AppColors.foreground,
                        ),
                        child: Center(
                          child: Text(
                            'LOG  ${_weight.toStringAsFixed(1)} KG',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.background,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdjBtn extends StatelessWidget {
  const _AdjBtn({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(color: AppColors.subtle),
        ),
      ),
    );
  }
}

// ── Daily Push Block ───────────────────────────────────────────────────────────

class _DailyPushBlock extends StatelessWidget {
  const _DailyPushBlock({
    required this.profile,
    required this.quoteState,
    required this.onRefresh,
  });

  final UserProfile? profile;
  final MotivationQuoteState quoteState;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "TODAY'S PUSH",
              style: AppTypography.tag.copyWith(
                color: AppColors.faint,
                letterSpacing: 2,
                fontSize: 10,
              ),
            ),
            const Spacer(),
            if (onRefresh != null)
              GestureDetector(
                onTap: onRefresh,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Icon(
                    Icons.refresh_rounded,
                    size: 16,
                    color: quoteState.isLoading
                        ? AppColors.faint
                        : AppColors.subtle,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (quoteState.isLoading && quoteState.quote == null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.subtle),
                ),
              ),
              const SizedBox(width: 10),
              Text('Getting your push…', style: AppTypography.bodyMedium),
            ],
          )
        else if (quoteState.quote != null && quoteState.quote!.isNotEmpty)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 2,
                  decoration: BoxDecoration(
                    color: AppColors.borderStrong,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    quoteState.quote!,
                    style: AppTypography.headlineSmall.copyWith(
                      height: 1.42,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Text(
            profile == null
                ? 'Complete your profile to get a personalised daily push.'
                : 'Tap refresh to get your push.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
          ),
      ],
    );
  }
}

// ── Profile Nudge ──────────────────────────────────────────────────────────────

class _ProfileNudge extends StatelessWidget {
  const _ProfileNudge({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const ProfileEditPage()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceElevated,
                border: Border.all(color: AppColors.borderStrong),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 18,
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complete your profile',
                    style: AppTypography.labelLarge,
                  ),
                  Text(
                    'Unlock AI coaching, calorie targets, and your daily push',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.subtle,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.subtle,
            ),
          ],
        ),
      ),
    );
  }
}
