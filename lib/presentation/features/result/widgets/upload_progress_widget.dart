// lib/presentation/features/result/widgets/upload_progress_widget.dart
import 'package:flutter/material.dart';

class UploadProgressWidget extends StatelessWidget {
  final double progress;

  const UploadProgressWidget({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    // Logika tampilan sederhana
    final bool isUploading = progress > 0;
    final String percentage = (progress * 100).toStringAsFixed(0);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Indikator Lingkaran
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              // Jika 0 = Indeterminate (Muter terus)
              // Jika > 0 = Determinate (Mengisi sesuai value)
              value: isUploading ? progress : null,
              backgroundColor: Colors.grey[200],
              strokeWidth: 6,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          const SizedBox(height: 24),

          // 2. Teks Status Utama
          Text(
            isUploading
                ? "Mengirim Data: $percentage%"
                : "Menghubungkan ke Server...",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),

          // 3. Subteks (Penjelasan)
          const SizedBox(height: 8),
          Text(
            isUploading
                ? "Mohon tunggu, jangan tutup aplikasi."
                : "Sedang melakukan verifikasi keamanan (SSL)...",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
