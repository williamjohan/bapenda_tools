import 'package:cekreklamemobile/presentation/features/home/widgets/capture_card_widget.dart';
import 'package:cekreklamemobile/presentation/features/home/widgets/greeting_card_widget.dart';
import 'package:cekreklamemobile/presentation/features/home/widgets/cek_reklame_card_widget.dart';
import 'package:cekreklamemobile/presentation/features/home/widgets/home_footer_widger.dart';
import 'package:cekreklamemobile/presentation/shared/widgets/custom_modal_widget.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      // APP BAR TETAP SAMA
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 0,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              children: [
                Image.asset('assets/images/logosby.png', height: 50),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Cek Reklame",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "Kota Surabaya",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                // MENU TITIK TIGA
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  offset: const Offset(-20, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: Colors.black45,
                  ),
                  onSelected: (value) => _handleMenuSelection(context, value),
                  itemBuilder: (context) => [
                    _buildPopupItem(
                      'update',
                      Icons.system_update_alt_rounded,
                      "Perbarui Aplikasi",
                      Colors.blue,
                    ),
                    _buildPopupItem(
                      'report',
                      Icons.bug_report_outlined,
                      "Lapor Kendala",
                      Colors.redAccent,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      // 🚀 INI PERBAIKAN UTAMANYA (STICKY FOOTER LOGIC)
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              // Paksa tinggi minimal setinggi layar (viewport)
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  // SpaceBetween akan mendorong Footer ke bawah
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // KELOMPOK KONTEN ATAS
                    Column(
                      children: const [
                        GreetingCard(),
                        SizedBox(height: 12),
                        CaptureBillboardButton(),
                        SizedBox(height: 12),
                        NearbyBillboardCard(),
                        SizedBox(height: 12),
                      ],
                    ),

                    // FOOTER (Otomatis terdorong ke paling bawah)
                    const HomeFooter(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(
    String value,
    IconData icon,
    String title,
    Color color,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _handleMenuSelection(BuildContext context, String value) async {
    // ... Logika Handle Menu sama seperti sebelumnya ...
    if (value == 'update') {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;

      if (context.mounted) {
        showAppModal(
          context: context,
          title: "Pembaruan Aplikasi",
          content: Text(
            "Versi Anda sudah yang terbaru (Beta $currentVersion). Kami akan memberi tahu jika ada versi baru.",
            textAlign: TextAlign.center,
          ),
          primaryButton: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF175CFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Oke"),
          ),
          showCloseButton: false,
        );
      }
    } else {
      showAppModal(
        context: context,
        title: "Lapor Kendala",
        content: const Text(
          "Ada kendala teknis? Hubungi tim IT Bapenda Surabaya melalui WhatsApp atau Email.",
          textAlign: TextAlign.center,
        ),
        primaryButton: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF175CFF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text("Hubungi Tim IT"),
        ),
        showCloseButton: false,
      );
    }
  }
}
