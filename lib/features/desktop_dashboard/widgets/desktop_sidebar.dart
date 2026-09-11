import 'package:flutter/material.dart';

class DesktopSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const DesktopSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  static const List<_SidebarItem> _items = [
    _SidebarItem(
      routeIndex: 0,
      icon: Icons.dashboard_rounded,
      title: 'Ana Sayfa',
      subtitle: 'Gunluk komuta merkezi',
    ),
    _SidebarItem(
      routeIndex: 2,
      icon: Icons.psychology_alt_rounded,
      title: 'Hisse Merkezi',
      subtitle: 'Yapay zeka asistani',
    ),
    _SidebarItem(
      routeIndex: 3,
      icon: Icons.psychology_alt_rounded,
      title: 'Karar Merkezi',
      subtitle: 'CROC karar ve analiz merkezi',
    ),
    _SidebarItem(
      routeIndex: 6,
      icon: Icons.notifications_active_rounded,
      title: 'KAP Radar',
      subtitle: 'Sirket bildirim ve haber akisi',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 218,
      decoration: const BoxDecoration(
        color: Color(0xFF050D0B),
        border: Border(right: BorderSide(color: Color(0xFF173B30))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const _BrandHeader(),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 13),
              itemCount: _items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = _items[index];
                final selected = selectedIndex == item.routeIndex;

                return _SidebarButton(
                  item: item,
                  selected: selected,
                  onTap: () => onSelected(item.routeIndex),
                );
              },
            ),
          ),
          const _SystemStatus(),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          _BrandLogo(),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CROC AI',
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'powered by Broker OS',
                  maxLines: 1,
                  style: TextStyle(
                    color: Color(0xFF63F5A8),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFF020806),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2D8C61), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF43F39A).withValues(alpha: 0.14),
            blurRadius: 18,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Image.asset(
            'assets/brand/croc_logo.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFF65F5A8),
                  size: 25,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SidebarButton extends StatelessWidget {
  final _SidebarItem item;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 190),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF103E2C) : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected ? const Color(0xFF43E995) : Colors.transparent,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF27E88A).withValues(alpha: 0.13),
                      blurRadius: 20,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF1C5D41)
                      : const Color(0xFF0A1713),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  item.icon,
                  color: selected
                      ? const Color(0xFF74F9B1)
                      : const Color(0xFF7F948C),
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : const Color(0xFF9BAEA7),
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w900
                            : FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected
                            ? const Color(0xFF73DDA8)
                            : const Color(0xFF52675F),
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF68F2A9),
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SystemStatus extends StatelessWidget {
  const _SystemStatus();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 13),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF091915),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1C4A3A)),
      ),
      child: const Row(
        children: [
          _StatusDot(),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SİSTEM AKTİF',
                  style: TextStyle(
                    color: Color(0xFF68F2A9),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tüm servisler çevrimiçi',
                  style: TextStyle(color: Color(0xFF779087), fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: const Color(0xFF54F39D),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF54F39D).withValues(alpha: 0.55),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

class _SidebarItem {
  final int routeIndex;
  final IconData icon;
  final String title;
  final String subtitle;

  const _SidebarItem({
    required this.routeIndex,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
