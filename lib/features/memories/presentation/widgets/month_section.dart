import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/memory.dart';
import 'memory_card.dart';

class MonthSection extends StatelessWidget {
  const MonthSection({
    super.key,
    required this.monthLabel,
    required this.memories,
    required this.onMemoryTap,
    this.index = 0,
  });

  final String monthLabel;
  final List<Memory> memories;
  final ValueChanged<Memory> onMemoryTap;
  final int index;

  @override
  Widget build(BuildContext context) {
    final label = memories.length == 1
        ? '1 recuerdo'
        : '${memories.length} recuerdos';
    final dotColor = index == 0 ? AppColors.accent : AppColors.leaf;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor.withValues(alpha: 0.14),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(monthLabel, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(width: 12),
            const Expanded(child: Divider(color: AppColors.borderSoft)),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.textMeta),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _MonthGrid(memories: memories, onMemoryTap: onMemoryTap),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.memories, required this.onMemoryTap});

  final List<Memory> memories;
  final ValueChanged<Memory> onMemoryTap;

  bool _isFeatured(int index) => memories.length == 1 || index % 3 == 0;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    var i = 0;
    while (i < memories.length) {
      if (_isFeatured(i)) {
        final memory = memories[i];
        rows.add(
          MemoryCard(
            memory: memory,
            featured: true,
            onTap: () => onMemoryTap(memory),
          ),
        );
        i += 1;
      } else {
        final left = memories[i];
        final right = (i + 1 < memories.length && !_isFeatured(i + 1))
            ? memories[i + 1]
            : null;
        rows.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: MemoryCard(memory: left, onTap: () => onMemoryTap(left)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: right != null
                    ? MemoryCard(memory: right, onTap: () => onMemoryTap(right))
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
        i += right != null ? 2 : 1;
      }

      if (i < memories.length) {
        rows.add(const SizedBox(height: AppSpacing.md));
      }
    }

    return Column(children: rows);
  }
}
