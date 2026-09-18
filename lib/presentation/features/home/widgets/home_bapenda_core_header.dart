import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors_new.dart';

class HomeBapendaCoreHeader extends StatelessWidget {
  const HomeBapendaCoreHeader({
    super.key,
    required this.userName,
    required this.userRole,
  });

  final String userName;
  final String userRole;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: const BoxDecoration(
        gradient: AppThemeColors.primaryGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Builder(
                  builder: (context) => InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.menu, color: Colors.white, size: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bapenda Kota Surabaya',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      'Bapenda Core',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    child: const Icon(Icons.person, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, $userName',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        userRole,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
