// lib/presentation/features/capture/pages/check_result_screen.dart
import 'package:cekreklamemobile/di.dart';
import 'package:cekreklamemobile/domain/entities/billboard_entity.dart';
import 'package:cekreklamemobile/domain/usecases/check_billboard_usecase.dart';
import 'package:cekreklamemobile/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 💡 Kita buat data dummy yang akan kita gunakan di UI (untuk tes tampilan)
// Nanti akan diganti dengan data dari Bloc/Cubit
final List<BillboardEntity> mockResults = [
  const BillboardEntity(
    id: 'SBY-001',
    name: 'Videotron Jl. Basuki Rahmat',
    type: 'Videotron',
    address: 'Jl. Basuki Rahmat No.1-7',
    latitude: -7.265,
    longitude: 112.738,
    distanceKm: 0.05,
    owner: 'PT Media Utama',
    isActive: true,
    imageUrl:
        'https://images.unsplash.com/photo-1543719958-9a4f66a2d2f7?fit=crop&w=300&q=80',
  ),
  const BillboardEntity(
    id: 'SBY-002',
    name: 'Billboard Embong Malang',
    type: 'Billboard',
    address: 'Jl. Embong Malang',
    latitude: -7.268,
    longitude: 112.739,
    distanceKm: 0.12,
    owner: 'Pemkot Surabaya',
    isActive: true,
    imageUrl:
        'https://images.unsplash.com/photo-1596752763375-7b51b75c8a98?fit=crop&w=300&q=80',
  ),
  const BillboardEntity(
    id: 'SBY-003',
    name: 'Billboard Tunjungan',
    type: 'Billboard',
    address: 'Jl. Tunjungan No.8',
    latitude: -7.271,
    longitude: 112.740,
    distanceKm: 0.25,
    owner: 'PT Iklan Cepat',
    isActive: false,
    imageUrl:
        'https://images.unsplash.com/photo-1597843812543-f8f4a1f1b0a8?fit=crop&w=300&q=80',
  ),
  // Catatan: SBY-004 akan disimulasikan sebagai item tanpa gambar
];

class CheckResultScreen extends StatefulWidget {
  // Data yang dikirim dari CaptureScreen (diambil dari GoRouter state)
  final String imagePath;
  final double latitude;
  final double longitude;

  const CheckResultScreen({
    super.key,
    required this.imagePath,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<CheckResultScreen> createState() => _CheckResultScreenState();
}

class _CheckResultScreenState extends State<CheckResultScreen> {
  List<BillboardEntity> results = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchResults();
  }

  Future<void> _fetchResults() async {
    // Panggil Use Case untuk mendapatkan data dummy (Mock)
    final useCase = locator<CheckBillboardUseCase>();
    try {
      final data = await useCase.call(
        latitude: widget.latitude,
        longitude: widget.longitude,
      );

      // Simulasikan kasus "No Billboards Found"
      // Jika data dikosongkan, Anda akan melihat UI No Billboards Found.
      // final simulatedResults = data.sublist(0, 3);
      // Hanya ambil 3 untuk demo

      setState(() {
        // Tambahkan item tanpa gambar untuk simulasi kasus SBY-004
        // simulatedResults.add(
        //   const BillboardEntity(
        //     id: 'SBY-004',
        //     name: 'Reklame Ahmad Yani',
        //     type: 'Billboard',
        //     address: 'Jl. Ahmad Yani',
        //     latitude: -7.28,
        //     longitude: 112.745,
        //     distanceKm: 0.40,
        //     owner: 'Swasta',
        //     isActive: true,
        //     imageUrl: '',
        //   ),
        // );
        if (data.length < 4) {
          // Tambahkan item tanpa gambar untuk simulasi kasus SBY-004 jika belum ada
          data.add(
            const BillboardEntity(
              id: 'SBY-004',
              name: 'Reklame Ahmad Yani',
              type: 'Billboard',
              address: 'Jl. Ahmad Yani',
              latitude: -7.28,
              longitude: 112.745,
              distanceKm: 0.40,
              owner: 'Swasta',
              isActive: true,
              imageUrl: '',
            ),
          );
        }

        results = data;
        isLoading = false;
      });
    } catch (e) {
      // Handle error jika mock gagal
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error fetching mock data: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Nearby Billboards",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : results.isEmpty
          ? _buildNoResults() // Tampilkan No Results
          : _buildResultsList(context, results), // Tampilkan Daftar
    );
  }

  // --------------------------------
  // BUILDERS UTAMA
  // --------------------------------
  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cancel_schedule_send, // Mengganti ikon di mockup
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          const Text(
            "No Billboards Found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "There are no registered billboards within this area. Try moving to a different location.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(BuildContext context, List<BillboardEntity> data) {
    return Column(
      children: [
        // Search Bar (Mockup)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search by name or address",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),

        // List Hasil
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return _buildResultCard(context, item);
            },
          ),
        ),
      ],
    );
  }

  // --------------------------------
  // WIDGET CARD ITEM
  // --------------------------------
  Widget _buildResultCard(BuildContext context, BillboardEntity billboard) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () {
          // Navigasi ke Detail Page dengan membawa Entity
          context.pushNamed(AppRoutes.detail, extra: billboard);
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Thumbnail (sesuai mockup)
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                  image: billboard.imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(billboard.imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: billboard.imageUrl.isEmpty
                    ? const Icon(
                        Icons.broken_image,
                        size: 30,
                        color: Colors.grey,
                      )
                    : null,
              ),
              const SizedBox(width: 16),

              // Info Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Billboard ID: ${billboard.id}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      billboard.address,
                      style: const TextStyle(color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Approx. ${billboard.distanceKm.toStringAsFixed(2)}km away",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
