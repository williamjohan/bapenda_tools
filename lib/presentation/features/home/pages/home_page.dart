import 'package:cekreklamemobile/core/services/update_service.dart';
import 'package:cekreklamemobile/di.dart';
import 'package:cekreklamemobile/presentation/features/home/widgets/capture_card_widget.dart';
import 'package:cekreklamemobile/presentation/features/home/widgets/greeting_card_widget.dart';
import 'package:cekreklamemobile/presentation/features/home/widgets/cek_reklame_card_widget.dart';
import 'package:cekreklamemobile/presentation/features/home/widgets/home_footer_widger.dart';
import 'package:cekreklamemobile/presentation/shared/widgets/custom_modal_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

// 👇 UBAH JADI STATEFUL WIDGET
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 👇 LOGIC OTOMATIS JALAN DISINI
  @override
  void initState() {
    super.initState();

    // Tunggu sampai UI selesai digambar frame pertama, baru cek update
    // Agar tidak error "setState called during build"
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performAutoUpdateCheck();
    });
  }

  // Fungsi Pengecekan Otomatis (Silent Check)
  void _performAutoUpdateCheck() {
    // Panggil Service yang sudah kita buat di Step 4
    final updateService = UpdateService(locator<Dio>());
    updateService.checkForUpdate(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
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
                      "Cek Pembaruan", // Ubah text biar lebih relevan
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

      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
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

                    // FOOTER
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

  // 👇 PERBAIKAN LOGIC MANUAL CHECK
  void _handleMenuSelection(BuildContext context, String value) async {
    if (value == 'update') {
      // OPSI A: Gunakan logic otomatis yang sama (Disarankan)
      // Jadi tombol ini benar-benar ngecek ke server Nextcloud, bukan dummy.
      final updateService = UpdateService(locator<Dio>());

      // Kita bungkus try-catch untuk memberi feedback kalau ternyata TIDAK ada update
      // Karena method checkForUpdate di Step 4 sifatnya "Silent" kalau tidak ada update.
      // (Opsional: Anda bisa modifikasi UpdateService agar mengembalikan status bool)

      // Untuk sekarang, kita panggil saja, nanti Dialog muncul kalau ada update.
      await updateService.checkForUpdate(context);

      // Note: Kalau Mas ingin menampilkan pesan "Anda sudah versi terbaru",
      // Mas perlu memodifikasi UpdateService agar mengembalikan nilai Boolean.
    } else {
      // ... Logic Lapor Kendala Tetap Sama ...
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
