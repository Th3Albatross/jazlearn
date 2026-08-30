import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_sidebar.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      drawer: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 900) {
            return const SizedBox.shrink();
          }
          return const Drawer(child: AppSidebar());
        },
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 900;

          if (desktop) {
            return Row(
              children: [
                const AppSidebar(),
                Expanded(child: child),
              ],
            );
          }

          return Stack(
            children: [
              child,
              Positioned(
                top: 20,
                left: 20,
                child: Builder(
                  builder: (context) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppTheme.darkGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        color: Colors.white,
                        icon: const Icon(Icons.menu_rounded),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

