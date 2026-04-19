import 'package:flutter/material.dart';

/// A shimmer-style loading placeholder for lists.
class AppLoadingIndicator extends StatelessWidget {
  final int itemCount;

  const AppLoadingIndicator({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E1E2E) : Colors.grey.shade200;
    final highlightColor =
        isDark ? const Color(0xFF2A2A3E) : Colors.grey.shade100;

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _ShimmerCard(
          baseColor: baseColor,
          highlightColor: highlightColor,
        );
      },
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  final Color baseColor;
  final Color highlightColor;

  const _ShimmerCard({
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: widget.baseColor,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.highlightColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: widget.highlightColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 10,
                        width: 120,
                        decoration: BoxDecoration(
                          color: widget.highlightColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Simple helper: AnimatedBuilder that proxies Listenable
class AnimatedBuilder extends StatelessWidget {
  final Listenable animation;
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder2(
      animation: animation,
      builder: builder,
      child: child,
    );
  }
}

/// Alias for Flutter's AnimatedBuilder
typedef AnimatedBuilder2 = AnimatedBuilder3;

class AnimatedBuilder3 extends StatefulWidget {
  final Listenable animation;
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const AnimatedBuilder3({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  @override
  State<AnimatedBuilder3> createState() => _AnimatedBuilder3State();
}

class _AnimatedBuilder3State extends State<AnimatedBuilder3> {
  @override
  void initState() {
    super.initState();
    widget.animation.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.animation.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.child);
  }
}
