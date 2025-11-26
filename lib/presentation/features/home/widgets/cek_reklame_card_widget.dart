import 'package:cekreklamemobile/core/services/map_service.dart';
import 'package:cekreklamemobile/di.dart';
import 'package:cekreklamemobile/presentation/shared/widgets/custom_modal_widget.dart';
import 'package:cekreklamemobile/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
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
        context.pushNamed(AppRoutes.camera);
      }
    }
  }

  // 💡 HELPER BARU: Logic Update Map yang dapat dipanggil oleh Stream
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

    // 💡 SET LOADING AWAL: Penting agar skeleton muncul saat fetch data.
    if (mounted) {
      setState(() => _isLoading = true);
    }

    // 1. Cek Status Service GPS
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    // 2. Jika service mati, matikan loading dan set status
    if (!serviceEnabled) {
      // 🛑 Jika service mati: Update status dan matikan loading
      if (mounted) {
        setState(() {
          _isLocationServiceEnabled = false; // Status mati
          _isLoading = false; // Hentikan loading
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
          // Hanya matikan loading jika fetch awal gagal
          _isLocationServiceEnabled = true;
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
        padding: const EdgeInsets.all(18),
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
            // Tampilan Peta Statis
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    // 🟢 KOREKSI: Jika service mati, TAMPILKAN PLACEHOLDER
                    : !_isLocationServiceEnabled
                    ? _buildServiceDisabledPlaceholder(context)
                    // Status 3: Service Aktif DAN Lokasi Ditemukan
                    : _mapImageUrl != null
                    ? Image.network(
                        _mapImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildServiceDisabledPlaceholder(
                              context,
                              message: "Gagal memuat peta.",
                            ),
                      )
                    // Status 4: Service Aktif tapi _mapImageUrl masih null (gagal fetch awal)
                    : _buildServiceDisabledPlaceholder(context),
              ),
            ),
            if (!_isLoading && _currentPosition != null) ...[
              Text(
                'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}, Long: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
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
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/map_inactive.png', width: 75, height: 75),
          const SizedBox(height: 8),
          Text(
            message ?? "Lokasi diperlukan \n untuk menampilkan peta.",
            maxLines: 2,
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
