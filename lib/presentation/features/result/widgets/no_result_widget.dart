import 'package:cekreklamemobile/core/constants/app_constants.dart';
import 'package:cekreklamemobile/presentation/features/result/bloc/check_result_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';

class NoResultsWidget extends StatelessWidget {
  final String capturedImagePath;
  final double latitude;
  final double longitude;

  const NoResultsWidget({
    super.key,
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
        // 1. AREA KONTEN (Bisa di-scroll)
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 10, left: 16, right: 16),
                  child: Text(
                    "Hasil Tangkapan Foto",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  height: 180,
                  width: double.infinity,
                  margin: const EdgeInsets.only(
                    top: 8,
                    bottom: 24,
                    left: 16,
                    right: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageToDisplay != null
                        ? Image.file(imageToDisplay, fit: BoxFit.cover)
                        : const Center(child: Text("Gambar tidak ditemukan")),
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.block, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 20),
                      const Text(
                        "Tidak Ada Reklame Ditemukan",
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
                          "Tidak ada papan reklame terdaftar di area ini. Jika Anda menemukan reklame di sini, silakan lapor.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. AREA TOMBOL (Menempel di Bawah)
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                offset: const Offset(0, -4),
                blurRadius: 10,
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<CheckResultCubit>().submitReport(
                    imagePath: capturedImagePath,
                    latitude: latitude,
                    longitude: longitude,
                  );
                },
                icon: const Icon(Icons.campaign, color: Colors.white),
                label: const Text(
                  AppConstants.btnLapor,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF175CFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
