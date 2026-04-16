import 'package:flutter/material.dart';

class ScheduleTile extends StatelessWidget {
  final String time;
  final String room;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isActive;

  const ScheduleTile({
    super.key,
    required this.time,
    required this.room,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isActive ? colorScheme.surfaceContainerLowest : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: isActive ? Border(left: BorderSide(color: colorScheme.primary, width: 4)) : null,
        boxShadow: isActive ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        ] : [],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    time,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive ? colorScheme.surfaceContainerHigh : colorScheme.surface.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      room,
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  fontSize: 18,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Positioned(
            bottom: -15,
            right: -15,
            child: Opacity(
              opacity: 0.05,
              child: Icon(icon, size: 100, color: colorScheme.onSurface),
            ),
          )
        ],
      ),
    );
  }
}
