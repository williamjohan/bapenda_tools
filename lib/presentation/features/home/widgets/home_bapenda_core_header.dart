// lib/presentation/features/home/widgets/home_bapenda_core_header.dart
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors_new.dart';

class HomeBapendaCoreHeader extends StatelessWidget {
  const HomeBapendaCoreHeader({
    super.key,
    required this.userName,
    required this.userRole,
  });

  // Catatan: userName dan userRole tetap dipertahankan parameternya 
  // agar tidak error di home_page.dart, meskipun sementara tidak ditampilkan di UI.
  final String userName;
  final String userRole;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // Padding bawah (60) dilebarkan agar ada ruang sebelum tertimpa overlap Menu Card
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 60),
      decoration: const BoxDecoration(
        // Sesuaikan warna gradient ini dengan AppColors Anda jika sudah ada
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE59C00), // Warna emas/oranye terang
            Color(0xFFA65A00), // Warna oranye gelap/cokelat
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          // KUNCI UTAMA: Memisahkan elemen ke ujung kiri dan kanan
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ==========================================
            // SISI KIRI: Judul Aplikasi
            // ==========================================
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bapenda Tools',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Bapenda Kota Surabaya',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),

            // ==========================================
            // SISI KANAN: Tombol Hamburger (Drawer)
            // ==========================================
            Builder(
              builder: (context) => Material(
                borderRadius: BorderRadius.circular(10),
                color: AppThemeColors.defaultSurface.withValues(alpha: 0.1),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 28, // Sedikit diperbesar agar nyaman di-tap
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}