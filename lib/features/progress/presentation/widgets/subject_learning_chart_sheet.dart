import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:noteforge/core/theme/app_colors.dart';
import 'package:noteforge/core/theme/app_spacing.dart';
import 'package:noteforge/core/theme/app_text_styles.dart';

/// Single point in the subject learning timeline.
class LearningDataPoint {
  final double hour; // 0..24
  final double minutesLearned;

  const LearningDataPoint({required this.hour, required this.minutesLearned});
}

/// Bottom sheet with a market-style chart for subject learning activity.
class SubjectLearningChartSheet extends StatelessWidget {
  final String subject;
  final List<LearningDataPoint> points;

  const SubjectLearningChartSheet({
    super.key,
    required this.subject,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;
    final cardColor = isDark
        ? AppColorsDark.background
        : AppColorsLight.background;
    final mutedText = isDark
        ? AppColorsDark.secondaryText
        : AppColorsLight.secondaryText;
    final totalMinutes = points.fold<double>(
      0,
      (sum, point) => sum + point.minutesLearned,
    );
    final peak = points.reduce(
      (a, b) => a.minutesLearned >= b.minutesLearned ? a : b,
    );

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('$subject Learning Chart', style: AppTextStyles.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Intraday learning movement (minutes learned by time).',
                style: AppTextStyles.bodySmall.copyWith(color: mutedText),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _StatChip(
                    label: 'Total',
                    value: '${totalMinutes.toStringAsFixed(0)} min',
                  ),
                  _StatChip(
                    label: 'Peak',
                    value:
                        '${peak.minutesLearned.toStringAsFixed(0)} min @ ${_formatHour(peak.hour)}',
                  ),
                  _StatChip(label: 'Sessions', value: '${points.length}'),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                height: 240,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: CustomPaint(
                  painter: _MarketChartPainter(
                    points: points,
                    lineColor: isDark
                        ? AppColorsDark.primaryText
                        : AppColorsLight.primaryText,
                    gridColor: borderColor,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _AxisLabel(text: '06:00'),
                  _AxisLabel(text: '10:00'),
                  _AxisLabel(text: '14:00'),
                  _AxisLabel(text: '18:00'),
                  _AxisLabel(text: '22:00'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatHour(double hour) {
    final h = hour.floor().toString().padLeft(2, '0');
    return '$h:00';
  }
}

class _AxisLabel extends StatelessWidget {
  final String text;

  const _AxisLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      text,
      style: AppTextStyles.label.copyWith(
        color: isDark
            ? AppColorsDark.secondaryText
            : AppColorsLight.secondaryText,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('$label: $value', style: AppTextStyles.label),
    );
  }
}

class _MarketChartPainter extends CustomPainter {
  final List<LearningDataPoint> points;
  final Color lineColor;
  final Color gridColor;

  const _MarketChartPainter({
    required this.points,
    required this.lineColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) {
      return;
    }

    // Draw reference grid first so the chart reads like a trading screen.
    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    const verticalLines = 4;
    const horizontalLines = 4;

    for (int i = 0; i <= verticalLines; i++) {
      final x = (size.width / verticalLines) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (int i = 0; i <= horizontalLines; i++) {
      final y = (size.height / horizontalLines) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final maxMinutes = points
        .map((point) => point.minutesLearned)
        .reduce(math.max)
        .clamp(1, double.infinity);

    Offset mapPoint(LearningDataPoint point) {
      final x = (point.hour / 24) * size.width;
      final normalizedY = point.minutesLearned / maxMinutes;
      final y = size.height - (normalizedY * size.height);
      return Offset(x, y);
    }

    final mapped = points.map(mapPoint).toList();
    final linePath = Path()..moveTo(mapped.first.dx, mapped.first.dy);

    for (int i = 1; i < mapped.length; i++) {
      final previous = mapped[i - 1];
      final current = mapped[i];
      final controlX = (previous.dx + current.dx) / 2;
      linePath.cubicTo(
        controlX,
        previous.dy,
        controlX,
        current.dy,
        current.dx,
        current.dy,
      );
    }

    // Fill area under the line with subtle gradient glow.
    final areaPath = Path.from(linePath)
      ..lineTo(mapped.last.dx, size.height)
      ..lineTo(mapped.first.dx, size.height)
      ..close();
    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.30),
          lineColor.withValues(alpha: 0.03),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(areaPath, areaPaint);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = lineColor.withValues(alpha: 0.5);
    for (final point in mapped) {
      canvas.drawCircle(point, 2.5, dotPaint);
    }

    final latest = mapped.last;
    final latestOuter = Paint()..color = lineColor.withValues(alpha: 0.25);
    final latestInner = Paint()..color = lineColor;
    canvas.drawCircle(latest, 8, latestOuter);
    canvas.drawCircle(latest, 4, latestInner);
  }

  @override
  bool shouldRepaint(covariant _MarketChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor;
  }
}
