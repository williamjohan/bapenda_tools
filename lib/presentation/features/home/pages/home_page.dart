import 'package:cekreklamemobile/core/services/app_logger_service.dart';
import 'package:cekreklamemobile/core/services/update_service.dart';
import 'package:cekreklamemobile/core/services/update_version_service.dart';
import 'package:cekreklamemobile/di.dart';
import 'package:cekreklamemobile/presentation/features/home/widgets/capture_card_widget.dart';
import 'package:cekreklamemobile/presentation/features/home/widgets/greeting_card_widget.dart';
import 'package:cekreklamemobile/presentation/features/home/widgets/cek_reklame_terdekat_widget.dart';
import 'package:cekreklamemobile/presentation/features/home/widgets/home_footer_widget.dart';
import 'package:cekreklamemobile/presentation/features/update/update_dialog.dart';
import 'package:cekreklamemobile/presentation/shared/widgets/custom_modal_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // State: Info update (null = gak ada update, not null = ada update)
  UpdateInfo? _updateInfo;

  // State: Loading check (biar gak flicker)
  bool _isChecking = true;

  Future<void> _checkUpdateStatus() async {
    final updateService = UpdateService(
      locator<Dio>(),
      locator<UpdateVersionService>(),
      locator<LoggerService>(),
    );

    // Panggil fungsi getAvailableUpdate (Bukan checkForUpdate yang lama)
    final info = await updateService.getAvailableUpdate();

    if (mounted) {
      setState(() {
        _updateInfo = info; // Simpan info update
        _isChecking = false;
      });

      // Auto-Show Dialog jika ada update
      if (_updateInfo != null) {
        showUpdateDialog(context, _updateInfo!);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Cek update otomatis saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUpdateStatus();
    });
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

                // 👇 MENU TITIK TIGA (SUDAH DI-OPTIMASI)
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

                  // Logic Klik Menu
                  onSelected: (value) {
                    if (value == 'update' && _updateInfo != null) {
                      // Panggil Dialog Update Manual pakai data _updateInfo
                      showUpdateDialog(context, _updateInfo!);
                    } else if (value == 'report') {
                      _showReportDialog(context);
                    }
                  },

                  itemBuilder: (context) => [
                    // ITEM MENU UPDATE
                    PopupMenuItem(
                      value: 'update',
                      // Menu aktif HANYA JIKA ada update
                      enabled: _updateInfo != null,
                      child: Row(
                        children: [
                          Icon(
                            Icons.system_update_alt_rounded,
                            size: 20,
                            // Warna Icon Abu-abu kalau gak ada update
                            color: _updateInfo != null
                                ? Colors.blue
                                : Colors.grey[400],
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Cek Pembaruan",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  // Warna Text Abu-abu kalau gak ada update
                                  color: _updateInfo != null
                                      ? Colors.black
                                      : Colors.grey[400],
                                ),
                              ),
                              // Text kecil status
                              Text(
                                _isChecking
                                    ? "Memeriksa..."
                                    : (_updateInfo != null
                                          ? "Versi baru tersedia"
                                          : "Sudah versi terbaru"),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _updateInfo != null
                                      ? Colors.orange
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ITEM MENU LAPOR (HELPER METHOD LAMA)
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

  // Helper untuk Dialog Lapor (Dipisah biar rapi)
  void _showReportDialog(BuildContext context) {
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
