// lib/presentation/features/result/widgets/results_list_view.dart
import 'dart:io';

import 'package:cekreklamemobile/domain/entities/billboard_entity.dart';
import 'package:cekreklamemobile/presentation/features/result/bloc/check_result_cubit.dart';
import 'package:cekreklamemobile/core/constants/app_constants.dart'; // Import Constants
import 'package:cekreklamemobile/presentation/shared/widgets/custom_modal_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import flutter_bloc
import 'result_card_widget.dart';

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
        // -----------------------------------------------------------
        // 1. BAGIAN ATAS (Scrollable Content: Foto & List Result)
        // -----------------------------------------------------------
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // A. Label Foto
              const Padding(
                padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                child: Text(
                  "Hasil Tangkapan Foto",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),

              // B. Preview Foto
              Container(
                height: 180,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
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

              // C. Label Hasil
              const Padding(
                padding: EdgeInsets.only(
                  top: 10,
                  left: 16,
                  right: 16,
                  bottom: 8,
                ),
                child: Text(
                  "Ditemukan Reklame Terdaftar",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),

              // D. List Data (Expanded di dalam Expanded)
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(
                    bottom: 16,
                  ), // Padding bawah agar list terakhir tidak mepet divider
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
          ),
        ),

        // -----------------------------------------------------------
        // 2. BAGIAN BAWAH (Sticky / Fixed Footer)
        // -----------------------------------------------------------
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.05,
                ), // Sedikit lebih soft valuenya
                offset: const Offset(0, -4),
                blurRadius: 10,
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Agar tidak memakan tempat berlebih
              children: [
                // (Opsional) Teks penjelas kecil di atas tombol
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "Data tidak sesuai atau reklame ilegal?",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                // Tombol Lapor
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Action Lapor Ilegal
                      showAppModal(
                        context: context,
                        showCloseButton: false,
                        isDismissible: false,
                        content: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 16),

                            const Text(
                              "Konfirmasi Pelaporan",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),

                            const Text(
                              AppConstants.questionReportIlegal,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        primaryButton: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  foregroundColor: Colors.grey.shade700,
                                ),
                                child: const Text(
                                  "Batal",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();

                                  context.read<CheckResultCubit>().submitReport(
                                    imagePath: capturedImagePath,
                                    latitude: latitude,
                                    longitude: longitude,
                                    type: ReportType.ilegal.value,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  "Ya, Laporkan",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.campaign_outlined,
                      color: Colors.white,
                    ),
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}
