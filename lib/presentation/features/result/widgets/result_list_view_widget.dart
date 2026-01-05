// lib/presentation/features/result/widgets/results_list_view.dart
import 'dart:io';

import 'package:cekreklamemobile/domain/entities/billboard_entity.dart';
import 'package:flutter/material.dart';
import 'result_card_widget.dart'; // Asumsi kita akan menggunakan widget Card yang terpisah

const String staticTestAssetPath = 'assets/images/guardian_reklame.jpg';

class ResultsListViewWidget extends StatelessWidget {
  final List<BillboardEntity> data;
  final String capturedImagePath;
  final double latitude;
  final double longitude;

  const ResultsListViewWidget({
    super.key,
    required this.data,
    required this.capturedImagePath,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final imageToDisplay = File(capturedImagePath).existsSync()
        ? File(capturedImagePath)
        : null;

    return Column(
      children: [
        // Search Bar (Mockup)
        // Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: TextField(
        //     decoration: InputDecoration(
        //       hintText: "Search by name or address",
        //       prefixIcon: const Icon(Icons.search),
        //       border: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(12),
        //         borderSide: BorderSide.none,
        //       ),
        //       filled: true,
        //       fillColor: Colors.white,
        //     ),
        //   ),
        // ),

        // -------------------------------
        // 📸 TAMPILAN FOTO YANG DI-CAPTURE
        // -------------------------------
        const Padding(
          padding: EdgeInsets.only(top: 10, left: 16, right: 16),
          child: Text(
            "Hasil Tangkapan Foto", // 💡 TEKS BARU
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),

        Container(
          height: 180, // Ukuran sedang
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageToDisplay != null
                ? Image.file(imageToDisplay, fit: BoxFit.cover)
                : const Center(
                    child: Text(
                      "Gambar capture tidak ditemukan",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
          ),
        ),

        const Padding(
          padding: EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 8),
          child: Text(
            "Ditemukan Reklame Terdaftar",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
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
              return ResultCardWidget(
                billboard: item,
                capturedImagePath: capturedImagePath,
                latitude: latitude,
                longitude: longitude,
              );
            },
          ),
        ),
      ],
    );
  }
}
