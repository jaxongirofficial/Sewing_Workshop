import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/app_colors.dart';
import '../../../features/dashboard/presentation/providers/fab_position_provider.dart';

/// Suzuvchi va sudralib bo'ladigan FAB.
///
/// — Qisqa bosish → [onTap] chaqiriladi (masalan, modal ochish).
/// — Uzoq bosib turib → drag rejimi yoqiladi, FAB ni ekran bo'ylab
///   istalgan joyga ko'chirish mumkin. Joy [fabPositionProvider]
///   ichida saqlanadi.
class DraggableBrandFab extends ConsumerStatefulWidget {
  const DraggableBrandFab({
    super.key,
    required this.icon,
    required this.onTap,
    required this.bottomReserved,
    required this.topReserved,
    this.tooltip,
    this.size = 60,
    this.edgePadding = 16,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final double size;

  /// Pastki suzuvchi nav bar va boshqa elementlar uchun zahira (px).
  final double bottomReserved;

  /// AppBar/status bar uchun yuqoridan zahira (px).
  final double topReserved;

  /// Ekran chetidan minimal masofa.
  final double edgePadding;

  @override
  ConsumerState<DraggableBrandFab> createState() => _DraggableBrandFabState();
}

class _DraggableBrandFabState extends ConsumerState<DraggableBrandFab>
    with SingleTickerProviderStateMixin {
  bool _dragging = false;
  Offset _dragStart = Offset.zero;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Offset _clamp(Offset raw, Size area) {
    final maxX = area.width - widget.size - widget.edgePadding;
    final minX = widget.edgePadding;
    final maxY = area.height - widget.bottomReserved - widget.size;
    final minY = widget.topReserved;
    return Offset(
      raw.dx.clamp(minX, maxX < minX ? minX : maxX),
      raw.dy.clamp(minY, maxY < minY ? minY : maxY),
    );
  }

  Offset _defaultPosition(Size area) {
    // O'ng pastdagi joy — bottom bar dan biroz tepada,
    // nav dock va kontent orasiga to'g'ri tushadi.
    return Offset(
      area.width - widget.size - widget.edgePadding,
      area.height - widget.bottomReserved - widget.size - 40,
    );
  }

  @override
  Widget build(BuildContext context) {
    final saved = ref.watch(fabPositionProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final area = Size(constraints.maxWidth, constraints.maxHeight);
        final position = saved == null
            ? _defaultPosition(area)
            : _clamp(saved, area);

        return Stack(
          children: [
            AnimatedPositioned(
              duration: Duration(milliseconds: _dragging ? 0 : 220),
              curve: Curves.easeOutCubic,
              left: position.dx,
              top: position.dy,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  widget.onTap();
                },
                onLongPressStart: (_) {
                  HapticFeedback.heavyImpact();
                  _dragStart = position;
                  _pulse.forward();
                  setState(() => _dragging = true);
                },
                onLongPressMoveUpdate: (details) {
                  final newPos = _dragStart + details.offsetFromOrigin;
                  ref.read(fabPositionProvider.notifier).state =
                      _clamp(newPos, area);
                },
                onLongPressEnd: (_) {
                  HapticFeedback.selectionClick();
                  _pulse.reverse();
                  setState(() => _dragging = false);
                },
                onLongPressCancel: () {
                  _pulse.reverse();
                  setState(() => _dragging = false);
                },
                child: AnimatedScale(
                  scale: _dragging ? 1.12 : 1.0,
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOutBack,
                  child: _FabVisual(
                    icon: widget.icon,
                    size: widget.size,
                    dragging: _dragging,
                    tooltip: widget.tooltip,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FabVisual extends StatelessWidget {
  const _FabVisual({
    required this.icon,
    required this.size,
    required this.dragging,
    this.tooltip,
  });

  final IconData icon;
  final double size;
  final bool dragging;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final visual = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            Color.lerp(scheme.primary, Colors.black, isDark ? 0.14 : 0.28)!,
          ],
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.85),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: dragging ? 0.65 : 0.55),
            blurRadius: dragging ? 28 : 22,
            offset: const Offset(0, 10),
            spreadRadius: dragging ? 2 : -4,
          ),
          BoxShadow(
            color: (dragging ? Colors.black : AppColors.shadow)
                .withValues(alpha: isDark ? 0.45 : 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.46),
    );

    return tooltip == null ? visual : Tooltip(message: tooltip!, child: visual);
  }
}
