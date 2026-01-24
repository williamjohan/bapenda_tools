import 'package:cekreklamemobile/core/services/map_service.dart';
import 'package:cekreklamemobile/di.dart';
import 'package:cekreklamemobile/presentation/shared/widgets/custom_modal_widget.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class NearbyBillboardCard extends StatefulWidget {
  const NearbyBillboardCard({super.key});
  @override
  State<NearbyBillboardCard> createState() => _NearbyBillboardCardState();
}

class _NearbyBillboardCardState extends State<NearbyBillboardCard>
    with WidgetsBindingObserver {
  StreamSubscription<Position>? _positionSubscription;
  Position? _currentPosition;
  String? _mapImageUrl;
  bool _isLoading = true;
  bool _isLocationServiceEnabled = false;
  LocationPermission _locationPermissionStatus = LocationPermission.denied;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchLocationStatusAndMap();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isLoading = true;
    _fetchLocationStatusAndMap();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // --- Logic On Tap Card ---
  void _onTapCard() async {
    // 1. Cek Status Service GPS (Lagi, untuk memastikan tidak mati mendadak)
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (mounted) {
        // 2. Jika GPS mati, tampilkan modal error
        showAppModal(
          context: context,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/no_location.png',
                width: double.infinity,
                height: 150,
              ),
              SizedBox(height: 10),
              Text(
                "Untuk melanjutkan pengecekan reklame, mohon aktifkan layanan lokasi (GPS) pada perangkat Anda.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          primaryButton: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF175CFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openLocationSettings();
            },
            child: const Text("Buka Pengaturan Lokasi"),
          ),
          showCloseButton: false,
          isDismissible: true,
        );
      }
    }
  }

  // Logic Update Map yang dapat dipanggil oleh Stream
  void _updateMapAndLocation(Position position) {
    final mapService = locator<MapService>();
    final mapUrl = mapService.generateStaticMapUrl(
      lat: position.latitude,
      long: position.longitude,
    );

    if (mounted) {
      setState(() {
        _currentPosition = position;
        _mapImageUrl = mapUrl;
        _isLoading = false;
        _isLocationServiceEnabled = true;
      });
    }
  }

  // --- Logic Fetch Lokasi dan Status ---
  Future<void> _fetchLocationStatusAndMap() async {
    await _positionSubscription?.cancel();
    if (mounted) {
      setState(() => _isLoading = true);
    }

    // --- Cek Izin (Permission) ---
    final permissionStatus = await Geolocator.checkPermission();
    if (mounted) setState(() => _locationPermissionStatus = permissionStatus);

    if (permissionStatus == LocationPermission.denied ||
        permissionStatus == LocationPermission.deniedForever) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // --- Cek Service GPS ---
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    // Jika service mati, pastikan *semua* status non-positif diatur
    if (!serviceEnabled) {
      if (mounted) {
        setState(() {
          _isLocationServiceEnabled = false; // 👈 Status GPS Mati
          _isLoading = false;
        });
      }
      return;
    }

    // 3. Jika service aktif, ambil lokasi
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy
            .low, // Akurasi rendah lebih cepat untuk Home Screen
        // timeLimit: const Duration(seconds: 10),
      );

      // 🟢 Panggil update untuk lokasi awal (menggantikan logic URL/setState lama)
      _updateMapAndLocation(position);

      // 4. MULAI STREAM
      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.low,
              distanceFilter: 50, // Update jika pindah 50 meter
              // interval: Duration(minutes: 5), // HANYA jika ingin update berkala
            ),
          ).listen((newPosition) {
            // Stream akan memicu _updateMapAndLocation untuk update real-time
            _updateMapAndLocation(newPosition);
          });
    } catch (e) {
      // Gagal mengambil lokasi (misal timeout atau izin baru dicabut)
      if (mounted) {
        // 5. Gagal mengambil lokasi awal
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Gunakan Container pembungkus untuk shadow agar tidak terpotong InkWell
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: _onTapCard,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card: Title + Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Layanan Lokasi",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                    // Badge Status "Aktif" ala AI
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _isLocationServiceEnabled
                            ? const Color(0xFFE8F5E9) // Hijau sangat muda
                            : const Color(0xFFFFEBEE), // Merah sangat muda
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isLocationServiceEnabled
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isLocationServiceEnabled ? "Aktif" : "Mati",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _isLocationServiceEnabled
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),

                // Widget Map Image
                Container(
                  height: 160, // Sedikit lebih tinggi sesuai AI
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade50),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : !_isLocationServiceEnabled
                        ? _buildServiceDisabledPlaceholder(
                            context,
                            message:
                                "Layanan Lokasi (GPS) dimatikan. Mohon nyalakan.",
                            status: _locationPermissionStatus,
                            serviceEnabled: _isLocationServiceEnabled,
                          )
                        : _mapImageUrl != null
                        ? Image.network(
                            _mapImageUrl!,
                            fit: BoxFit.cover,
                            // Animasi halus saat gambar muncul
                            frameBuilder:
                                (
                                  context,
                                  child,
                                  frame,
                                  wasSynchronouslyLoaded,
                                ) {
                                  return AnimatedOpacity(
                                    opacity: frame == null ? 0 : 1,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeOut,
                                    child: child,
                                  );
                                },
                          )
                        : const Center(child: Text("Memuat Peta...")),
                  ),
                ),

                const SizedBox(height: 5),

                // Widget Koordinat
                Container(
                  height: 40,
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  // Kita hilangkan AnimatedSwitcher jika ingin teks "Lat: ..." langsung ada sejak awal
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          // Ikon berubah warna saat data sudah siap
                          color: (_isLoading || _currentPosition == null)
                              ? Colors.grey.shade400
                              : const Color(0xFFE53935),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          // LOGIKA TEKS: Jika loading/null tampilkan ..., jika ada tampilkan angkanya
                          (_isLoading || _isLocationServiceEnabled == false)
                              ? 'Lat: ..., Long: ...'
                              : 'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, Long: ${_currentPosition!.longitude.toStringAsFixed(4)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: (_isLoading || _currentPosition == null)
                                ? Colors.grey.shade400
                                : Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildServiceDisabledPlaceholder(
  BuildContext context, {
  String? message,
  required LocationPermission status,
  required bool serviceEnabled,
}) {
  // debugPrint(
  //   'Placeholder Status Check: Service=${serviceEnabled}, Permission=${status.name}',
  // );
  String finalMessage = message ?? "Informasi tidak tersedia.";

  // 1. Prioritas Tertinggi: Ditolak Permanen
  if (status == LocationPermission.deniedForever) {
    finalMessage = "Izin ditolak permanen. Aktifkan di Pengaturan Aplikasi.";
  }
  // 🟢 KOREKSI 1: Prioritaskan Izin Ditolak Sementara (Soft Denied)
  else if (status == LocationPermission.denied) {
    finalMessage =
        "Permission Lokasi belum diberikan. Klik 'Capture' untuk meminta izin.";
  }
  // 2. Prioritas Terakhir: Layanan GPS Dimatikan (Service Toggle)
  else if (!serviceEnabled) {
    finalMessage = "Layanan Lokasi (GPS) dimatikan. Mohon nyalakan.";
  }

  if (message != null &&
      message.isNotEmpty &&
      finalMessage.contains("Informasi tidak tersedia")) {
    finalMessage = message;
  }

  return Center(
    child: Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Column(
        // ...
        children: [
          Image.asset(
            'assets/images/map_inactive.png',
            width: 75,
            height: 75,
            opacity: AlwaysStoppedAnimation(0.5),
          ),
          const SizedBox(height: 8),
          Text(
            finalMessage, // ✅ Menggunakan pesan yang sudah ditentukan
            maxLines: 3,
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
