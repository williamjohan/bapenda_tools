import 'package:cekreklamemobile/core/services/map_service.dart';
import 'package:cekreklamemobile/di.dart';
import 'package:cekreklamemobile/presentation/shared/widgets/custom_modal_widget.dart';
import 'package:cekreklamemobile/presentation/features/home/home_handlers.dart';
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
                borderRadius: BorderRadius.circular(10),
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
    } else {
      // 3. Jika GPS aktif, navigasi ke CameraPage
      if (mounted) {
        handleCaptureTap(context);
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

      // 4. MULAI STREAM (Bug 2b)
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

  Widget _buildLocationStatus(BuildContext context) {
    final bool isActive = _isLocationServiceEnabled && !_isLoading;
    final Color color = isActive ? Colors.green : Colors.red;
    final String text = isActive ? "Aktif" : "Tidak Aktif";

    return Row(
      children: [
        // Indikator Dot
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        // Teks Status (Aktif/Tidak Aktif)
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 8),
        // Ikon Lokasi (Tambahan jika mati)
        if (!isActive) Icon(Icons.location_off, color: Colors.red, size: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _onTapCard, // Panggil logic tap
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 18, 18, 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    "Cek Reklame \nSekitar Anda",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _isLocationServiceEnabled
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _buildLocationStatus(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            //* ==========================================
            //*          WIDGET UNTUK MAP IMAGE
            //* ==========================================
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    // Kondisi 1 : Jika service mati, TAMPILKAN PLACEHOLDER
                    : !_isLocationServiceEnabled
                    ? _buildServiceDisabledPlaceholder(
                        context,
                        status: _locationPermissionStatus,
                        serviceEnabled: _isLocationServiceEnabled,
                      )
                    // Kondisi 2 :  Service Aktif DAN Lokasi Ditemukan
                    : _mapImageUrl != null
                    ? Image.network(
                        _mapImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildServiceDisabledPlaceholder(
                              context,
                              // Ini adalah pesan error jaringan/API (Service Active, tapi gagal muat)
                              message:
                                  "Gagal memuat peta. Periksa koneksi Anda.",
                              status: _locationPermissionStatus,
                              serviceEnabled: _isLocationServiceEnabled,
                            ),
                      )
                    // Kondisi 3 : Service Aktif tapi _mapImageUrl masih null (gagal fetch awal)
                    : _buildServiceDisabledPlaceholder(
                        context,
                        status: _locationPermissionStatus,
                        serviceEnabled: _isLocationServiceEnabled,
                        message: "Memuat lokasi...",
                      ),
              ),
            ),

            //* ==========================================
            //*      WIDGET UNTUK KOORDINAT LOKASI
            //* ==========================================
            if (!_isLoading &&
                _currentPosition != null &&
                _isLocationServiceEnabled) ...[
              const SizedBox(height: 8), // Padding setelah status badge
              Row(
                children: [
                  // Ikon Lokasi yang sedang aktif
                  Icon(
                    Icons.my_location,
                    size: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary, // Warna Biru Tema
                  ),
                  const SizedBox(width: 4),
                  // Teks Koordinat
                  Text(
                    'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}, Long: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ],
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
        "Akses Lokasi belum diberikan. Klik 'Capture' untuk meminta izin.";
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
