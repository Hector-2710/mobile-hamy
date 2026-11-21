import 'package:material_ui/material_ui.dart';

import '../../../../app/app_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../domain/entities/memory.dart';
import '../widgets/add_memory_sheet.dart';
import '../widgets/month_section.dart';
import 'memory_detail_page.dart';

class MemoriesHomePage extends StatefulWidget {
  const MemoriesHomePage({super.key});

  @override
  State<MemoriesHomePage> createState() => _MemoriesHomePageState();
}

class _MemoriesHomePageState extends State<MemoriesHomePage> {
  final List<Memory> _memories = List<Memory>.from(SeedMemories.items);

  Map<String, List<Memory>> get _groupedMemories {
    final sorted = List<Memory>.from(_memories)
      ..sort((a, b) => b.date.compareTo(a.date));
    final groups = <String, List<Memory>>{};
    for (final memory in sorted) {
      final month = DateFormatters.formatMonthYear(memory.date);
      groups.putIfAbsent(month, () => []).add(memory);
    }
    return groups;
  }

  Future<void> _openAddMemory() async {
    final title = await AddMemorySheet.show(context);
    if (title == null || !mounted) return;

    final memory = Memory(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      imageUrl: '',
      date: DateTime.now(),
      location: 'Ubicación pendiente',
      isPersonal: true,
    );

    setState(() => _memories.insert(0, memory));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('«${memory.title}» ya está en el álbum.'),
          action: SnackBarAction(
            label: 'Ver',
            onPressed: () => _openMemory(memory),
          ),
        ),
      );
  }

  void _openMemory(Memory memory) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    MemoryDetailPage.show(
      context,
      memory,
      onDelete: memory.isPersonal ? () => _deleteMemory(memory) : null,
    );
  }

  void _deleteMemory(Memory memory) {
    final index = _memories.indexWhere((item) => item.id == memory.id);
    if (index == -1) return;

    setState(() => _memories.removeAt(index));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('«${memory.title}» fuera del álbum.'),
          action: SnackBarAction(
            label: 'Deshacer',
            onPressed: () {
              if (!mounted) return;
              final target = index > _memories.length
                  ? _memories.length
                  : index;
              setState(() => _memories.insert(target, memory));
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupedMemories.entries.toList();
    final count = _memories.length;
    final months = _memories
        .map((memory) => '${memory.date.year}-${memory.date.month}')
        .toSet()
        .length;

    final user = AppScope.of(context).user;
    final initial = (user?.name.trim().isNotEmpty ?? false)
        ? user!.name.trim()[0].toUpperCase()
        : 'J';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ColoredBox(
            color: AppColors.surface,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _Header(
                    initial: initial,
                    count: count,
                    months: months,
                    onLogout: () => AppScope.of(context).logout(),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 132),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _SectionHeader(count: count),
                      const SizedBox(height: AppSpacing.xxl),
                      if (groups.isEmpty)
                        const _EmptyAlbum()
                      else
                        for (var i = 0; i < groups.length; i++) ...[
                          MonthSection(
                            monthLabel: groups[i].key,
                            memories: groups[i].value,
                            index: i,
                            onMemoryTap: _openMemory,
                          ),
                          if (i < groups.length - 1)
                            const SizedBox(height: AppSpacing.section),
                        ],
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddMemory,
        tooltip: 'Guardar un nuevo recuerdo',
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Nuevo recuerdo'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.initial,
    required this.count,
    required this.months,
    required this.onLogout,
  });

  final String initial;
  final int count;
  final int months;
  final VoidCallback onLogout;

  String get _summary {
    if (count == 0) return 'Todo empieza aquí';
    final recuerdos = count == 1 ? '1 recuerdo' : '$count recuerdos';
    final meses = months == 1 ? '1 mes' : '$months meses';
    return '$recuerdos · $meses juntos';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: -110,
          top: -150,
          child: IgnorePointer(
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.blush.withValues(alpha: 0.95),
                    AppColors.blush.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: -120,
          top: 150,
          child: IgnorePointer(
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.leafSoft.withValues(alpha: 0.65),
                    AppColors.leafSoft.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _CoupleAvatars(initial: initial),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'hamy',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Text(
                            'Nuestro álbum',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textMeta),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Más opciones',
                      icon: const Icon(Icons.more_horiz_rounded),
                      onSelected: (value) {
                        if (value == 'logout') onLogout();
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout_rounded, size: 18),
                              SizedBox(width: 10),
                              Text('Cerrar sesión'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 34),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nuestra vida,',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          Text('en fotos.', style: AppTypography.heroEmphasis),
                          const SizedBox(height: 14),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 290),
                            child: Text(
                              'Pequeños momentos que siempre querremos recordar.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _summary,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: AppColors.textMeta),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Transform.rotate(
                      angle: 0.07,
                      child: const AppLogo(size: 70),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CoupleAvatars extends StatelessWidget {
  const _CoupleAvatars({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 66,
      height: 38,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 2,
            child: _AvatarCircle(label: initial, color: AppColors.accent),
          ),
          const Positioned(
            left: 28,
            top: 2,
            child: _AvatarCircle(
              icon: Icons.favorite_rounded,
              color: AppColors.leaf,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({this.label, this.icon, required this.color});

  final String? label;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 2),
      ),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, color: Colors.white, size: 14)
          : Text(
              label ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count == 1 ? '1 recuerdo' : '$count recuerdos';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Recuerdos', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(width: 12),
        const Expanded(child: Divider(color: AppColors.borderSoft)),
        const SizedBox(width: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppColors.textMeta),
        ),
      ],
    );
  }
}

class _EmptyAlbum extends StatelessWidget {
  const _EmptyAlbum();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
      child: Column(
        children: [
          const AppLogo(size: 92),
          const SizedBox(height: 24),
          Text(
            'El álbum está esperando\nsu primer recuerdo.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Text(
            'Toca «Nuevo recuerdo» para guardar una foto con su título, '
            'la fecha y el lugar.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
