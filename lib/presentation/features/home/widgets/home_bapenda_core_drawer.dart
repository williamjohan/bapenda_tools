import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors_new.dart';

/// Drawer opened from the home header hamburger icon.
/// Placeholder items only — wire to GoRouter routes as needed.
class HomeBapendaCoreDrawer extends StatelessWidget {
  const HomeBapendaCoreDrawer({
    super.key,
    required this.userName,
    required this.userRole,
    this.onLogout,
  });

  final String userName;
  final String userRole;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppThemeColors.defaultSurface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(gradient: AppThemeColors.primaryGradient),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    userRole,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.home_outlined, color: AppThemeColors.secondaryText),
              title: const Text('Beranda'),
              onTap: () => Navigator.of(context).pop(),
            ),
            const Spacer(),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: AppThemeColors.danger),
              title: const Text(
                'Keluar',
                style: TextStyle(color: AppThemeColors.danger),
              ),
              onTap: onLogout,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
