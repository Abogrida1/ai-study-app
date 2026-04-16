import 'dart:ui';
import 'package:flutter/material.dart';

class ModernNavBar extends StatelessWidget {
  final int currentIndex;
  final List<Map<String, dynamic>> items;
  final ValueChanged<int> onTap;

  const ModernNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const navBarHeight = 74.0;
    const topOverflow = 24.0;
    final totalHeight = navBarHeight + topOverflow + bottomPadding;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: currentIndex.toDouble()),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isRtl = Directionality.of(context) == TextDirection.rtl;
            final visualLoc = isRtl ? (items.length - 1 - animValue) : animValue;
            
            return SizedBox(
              height: totalHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // --- Shadow Layer ---
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: navBarHeight + bottomPadding,
                    child: CustomPaint(
                      painter: NavShadowPainter(
                        loc: visualLoc,
                        itemLength: items.length,
                        shadowColor: Colors.black.withOpacity(isDark ? 0.6 : 0.15),
                      ),
                    ),
                  ),

                  // --- Blurred Background With Notch ---
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: navBarHeight + bottomPadding,
                    child: ClipPath(
                      clipper: NavClipper(loc: visualLoc, itemLength: items.length),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          color: colorScheme.surface.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ),

                  // --- Delicate Top Border ---
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: navBarHeight + bottomPadding,
                    child: CustomPaint(
                      painter: NavBorderPainter(
                        loc: visualLoc,
                        itemLength: items.length,
                        borderColor: colorScheme.outlineVariant.withOpacity(0.15),
                      ),
                    ),
                  ),

                  // --- Sliding Indicator Island ---
                  Positioned(
                    top: 4,
                    left: (visualLoc + 0.5) * (screenWidth / items.length) - 28,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- Interactive Icons and Labels ---
                  Positioned(
                    bottom: bottomPadding,
                    left: 0,
                    right: 0,
                    height: navBarHeight,
                    child: Row(
                      children: List.generate(items.length, (index) {
                        double distance = (animValue - index).abs();
                        double jumpDistance = 0.75;
                        double progress = (1.0 - (distance / jumpDistance)).clamp(0.0, 1.0);
                        double smooth = Curves.easeInOut.transform(progress);
                        double yOffset = smooth * -24; // Elevates the icon perfectly into the island

                        Color iconColor = Color.lerp(
                          colorScheme.onSurfaceVariant,
                          colorScheme.primary,
                          progress,
                        )!;

                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onTap(index),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Transform.translate(
                                  offset: Offset(0, yOffset),
                                  child: Icon(items[index]['icon'], color: iconColor, size: 24),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  items[index]['label'],
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontSize: 10,
                                    fontWeight: progress > 0.5 ? FontWeight.bold : FontWeight.w600,
                                    color: progress > 0.5 ? colorScheme.primary : colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

Path getNavPath(Size size, double loc, int itemLength) {
  final itemWidth = size.width / itemLength;
  final curX = (loc + 0.5) * itemWidth;
  
  const dipWidth = 105.0; 
  const dipHeight = 44.0; 
  
  double start = curX - dipWidth / 2;
  double end = curX + dipWidth / 2;

  Path baseRect = Path()..addRRect(
    RRect.fromRectAndCorners(
      Offset.zero & size,
      topLeft: const Radius.circular(32),
      topRight: const Radius.circular(32),
    )
  );

  Path dipShape = Path();
  dipShape.moveTo(start, 0);
  dipShape.cubicTo(
    start + dipWidth * 0.20, 0.0,
    curX - dipWidth * 0.20, dipHeight,
    curX, dipHeight,
  );
  dipShape.cubicTo(
    curX + dipWidth * 0.20, dipHeight,
    end - dipWidth * 0.20, 0.0,
    end, 0.0,
  );
  dipShape.lineTo(end, -100);
  dipShape.lineTo(start, -100);
  dipShape.close();

  return Path.combine(PathOperation.difference, baseRect, dipShape);
}

class NavClipper extends CustomClipper<Path> {
  final double loc;
  final int itemLength;
  NavClipper({required this.loc, required this.itemLength});
  @override
  Path getClip(Size size) => getNavPath(size, loc, itemLength);
  @override
  bool shouldReclip(NavClipper oldClipper) => oldClipper.loc != loc || oldClipper.itemLength != itemLength;
}

class NavShadowPainter extends CustomPainter {
  final double loc;
  final int itemLength;
  final Color shadowColor;
  NavShadowPainter({required this.loc, required this.itemLength, required this.shadowColor});
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawShadow(getNavPath(size, loc, itemLength), shadowColor, 12.0, false);
  }
  @override
  bool shouldRepaint(NavShadowPainter oldDelegate) => oldDelegate.loc != loc || oldDelegate.shadowColor != shadowColor;
}

class NavBorderPainter extends CustomPainter {
  final double loc;
  final int itemLength;
  final Color borderColor;
  NavBorderPainter({required this.loc, required this.itemLength, required this.borderColor});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(getNavPath(size, loc, itemLength), paint);
  }
  @override
  bool shouldRepaint(NavBorderPainter oldDelegate) => oldDelegate.loc != loc || oldDelegate.borderColor != borderColor;
}
