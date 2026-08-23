import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: AppTheme.darkGreen,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 24,
          ),
          child: Column(
            children: [
              _brand(),
              const SizedBox(height: 45),
              _menu(context, Icons.home_rounded, 'Beranda', '/'),
	      _menu(context, Icons.library_books_rounded, 'Materi', '/materi'),
              _menu(
                context,
                Icons.menu_book_rounded,
                'Tembung',
                '/tembung',
              ),
              _menu(
                context,
                Icons.edit_rounded,
                'Aksara Jawa',
                '/aksara',
              ),
              _menu(
                context,
                Icons.quiz_rounded,
                'Latihan',
                '/latihan',
              ),
              _menu(
                context,
                Icons.emoji_events_rounded,
                'Pencapaian',
                '/pencapaian',
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _brand() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.gold,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Center(
            child: Text(
              'ꦗ',
              style: TextStyle(
                color: Color(0xFF302318),
                fontSize: 28,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'JazLearn',
          style: TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _menu(
    BuildContext context,
    IconData icon,
    String title,
    String route,
  ) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final active = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _HoverMenu(
        active: active,
        icon: icon,
        title: title,
        onTap: () {
          if (!active) {
            Navigator.pushReplacementNamed(
              context,
              route,
            );
          }
        },
      ),
    );
  }
}

class _HoverMenu extends StatefulWidget {
  final bool active;
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _HoverMenu({
    required this.active,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  State<_HoverMenu> createState() => _HoverMenuState();
}

class _HoverMenuState extends State<_HoverMenu> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.active || hover;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => hover = true);
      },
      onExit: (_) {
        setState(() => hover = false);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: widget.active
                ? AppTheme.gold
                : hover
                    ? Colors.white.withOpacity(.08)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 21,
                color: widget.active
                    ? const Color(0xFF302318)
                    : Colors.white70,
              ),
              const SizedBox(width: 13),
              Text(
                widget.title,
                style: TextStyle(
                  color: widget.active
                      ? const Color(0xFF302318)
                      : Colors.white70,
                  fontSize: 14,
                  fontWeight: selected
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

