// lib/presentation/features/result/widgets/upload_progress_widget.dart
import 'package:flutter/material.dart';

class UploadProgressWidget extends StatelessWidget {
  final double progress;

  const UploadProgressWidget({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    // 1. LOGIC STATE:
    // Cek apakah sudah 100% (1.0). Jika ya, berarti masuk fase "Processing Server"
    final bool isProcessing = progress >= 1.0;
    // Cek apakah sedang upload (antara 0.1 sampai 0.99)
    final bool isUploading = progress > 0 && progress < 1.0;

    final String percentage = (progress * 100).toStringAsFixed(0);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 2. Indikator Lingkaran
          SizedBox(
            width: 70, // Sedikit diperbesar biar lega
            height: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Layer 1: Circular Progress
                CircularProgressIndicator(
                  // TRICK UX:
                  // Jika isProcessing (100%), kita set NULL agar dia MUTER LAGI (Indeterminate).
                  // Ini memberi sinyal psikologis "Sabar, sistem masih bekerja".
                  // Jika isUploading, isi sesuai progress.
                  value: isUploading ? progress : null,

                  backgroundColor: Colors.grey[200],
                  strokeWidth: 6,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    // Ubah warna jadi Hijau jika sudah processing (opsional, biar beda rasa)
                    isProcessing ? Colors.green : Colors.blue,
                  ),
                ),

                // Layer 2: Icon/Text ditengah lingkaran (Opsional - Pemanis)
                if (isProcessing)
                  const Icon(Icons.cloud_sync, color: Colors.green, size: 32),
                if (isUploading)
                  Text(
                    "$percentage%",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. Teks Status Utama
          Text(
            isProcessing
                ? "Memproses Data..."
                : (isUploading
                      ? "Mengirim Data..."
                      : "Menghubungkan ke Server..."),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),

          // 4. Subteks (Penjelasan)
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              isProcessing
                  ? "Sedang mencocokkan gambar di server. Mohon tunggu sebentar..."
                  : "Jangan tutup aplikasi saat proses berjalan.",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
