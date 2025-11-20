import 'dart:typed_data';

import 'package:cekreklamemobile/domain/entities/billboard_entity.dart';
import 'package:flutter/material.dart';
import 'package:cekreklamemobile/core/utils/image_utils.dart';

class BillboardDetailScreen extends StatelessWidget {
  // 💡 Halaman ini HANYA menerima BillboardEntity.
  final BillboardEntity billboard;

  const BillboardDetailScreen({super.key, required this.billboard});

  @override
  Widget build(BuildContext context) {
    // Tentukan warna status
    final Uint8List? imageBytes = decodeBase64DataUrl(billboard.imageUrl);
    Color statusColor = billboard.isActive ? Colors.green : Colors.red;
    String statusText = billboard.isActive
        ? "Active (Terdaftar)"
        : "Inactive (Tidak Terdaftar)";

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          billboard.name, // Judul adalah nama Billboard
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------------------
            // FOTO BILLBOARD (Optional)
            // -------------------------------
            Container(
              height: 280,
              width: double.infinity,
              // 💡 Hapus BoxDecoration(image: DecorationImage(...))
              decoration: const BoxDecoration(
                color: Colors.black12, // Warna default jika gambar gagal
              ),
              child: imageBytes != null
                  ? Image.memory(
                      // 2. Tampilkan Image.memory jika data ada
                      imageBytes,
                      fit: BoxFit.cover,
                    )
                  : const Center(
                      // 3. Tampilkan Placeholder jika data Base64 kosong/gagal
                      child: Icon(
                        Icons.photo_size_select_actual_outlined,
                        color: Colors.grey,
                        size: 60,
                      ),
                    ),
            ),

            const SizedBox(height: 16),

            // -------------------------------
            // STATUS & INFORMASI UTAMA
            // -------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Status Card ---
                  _statusCard(statusText, statusColor),
                  const SizedBox(height: 20),

                  const Text(
                    "Detail Reklame Terdaftar",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),

                  _detailItem(
                    "Alamat Lokasi",
                    billboard.address,
                    Icons.location_on,
                  ),
                  _detailItem("Tipe", billboard.type, Icons.layers),
                  _detailItem(
                    "Status (Pajak/Izin)",
                    statusText,
                    Icons.verified,
                  ),

                  // Informasi Tambahan (dummy, karena belum ada di Entity)
                  _detailItem(
                    "Biaya Iklan",
                    "Rp 50.000.000,-/Bulan",
                    Icons.payments,
                  ),
                  _detailItem(
                    "Masa Aktif Pajak",
                    "Hingga 31 Des 2026",
                    Icons.date_range,
                  ),

                  // Koordinat (untuk debugging/verifikasi)
                  _detailItem(
                    "Koordinat",
                    "Lat: ${billboard.latitude.toStringAsFixed(5)}, Long: ${billboard.longitude.toStringAsFixed(5)}",
                    Icons.explore,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // -------------------------------
            // PETA LOKASI
            // -------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Lokasi Pada Peta",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  // Placeholder Map
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(14),
                    ),
                    // Jika ingin integrasi Google Maps:
                    // child: GoogleMap(initialCameraPosition: ...),
                    child: const Center(child: Text("Placeholder Peta")),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),

      // Bottom Button tetap menjadi "Back"
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Selesai Cek",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailItem(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard(String statusText, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, color: color, size: 24),
          const SizedBox(width: 12),
          Text(
            "Status: $statusText",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
