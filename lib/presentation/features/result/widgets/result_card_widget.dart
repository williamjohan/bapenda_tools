import 'dart:typed_data';
import 'package:cekreklamemobile/core/constants/app_constants.dart';
import 'package:cekreklamemobile/core/utils/image_utils.dart';
import 'package:cekreklamemobile/domain/value_objects/billboard_status.dart';
import 'package:cekreklamemobile/domain/entities/billboard_entity.dart';
import 'package:cekreklamemobile/presentation/features/result/cubit/check_result_cubit.dart';
import 'package:cekreklamemobile/presentation/features/result/widgets/blink_status_indicator_widget.dart';
import 'package:cekreklamemobile/presentation/shared/pages/image_preview_page.dart';
import 'package:cekreklamemobile/presentation/shared/widgets/custom_modal_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResultCardWidget extends StatelessWidget {
  final BillboardEntity billboard;
  final String capturedImagePath;
  final double latitude;
  final double longitude;

  const ResultCardWidget({
    super.key,
    required this.billboard,
    required this.capturedImagePath,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final status = StatusHelper.fromEntity(
      billboard.isActive,
      billboard.isExpired,
    );
    final Uint8List? imageBytes = ImageUtils.decodeBase64DataUrl(
      billboard.imageUrl,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // -------------------------------------------------------
              // 1. STRIP WARNA KIRI (Visual Status Cepat)
              // -------------------------------------------------------
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 6,
                child: Container(color: status.color),
              ),

              // -------------------------------------------------------
              // 2. KONTEN UTAMA
              // -------------------------------------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  22,
                  16,
                  16,
                  16,
                ), // Kiri 22 karena ada strip
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // A. THUMBNAIL
                    _buildThumbnail(context, imageBytes),

                    const SizedBox(width: 16),

                    // B. TEXT INFO
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Spacer untuk menghindari tabrakan dengan badge jarak di kanan atas
                          Padding(
                            padding: const EdgeInsets.only(right: 60.0),
                            child: Text(
                              "ID: ${billboard.id}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Jenis Reklame
                          Text(
                            billboard.type,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // --- INDIKATOR STATUS (KELAP KELIP) ---
                          Row(
                            children: [
                              BlinkingStatusIndicator(color: status.color),
                              const SizedBox(width: 8),
                              Text(
                                status.text.toUpperCase(),
                                style: TextStyle(
                                  color: status.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Nama & Alamat
                          Text(
                            billboard.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            billboard.address,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // -------------------------------------------------------
              // 3. BADGE JARAK (Pojok Kanan Atas)
              // -------------------------------------------------------
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.directions_walk_rounded, // Icon Orang Jalan
                        size: 14,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${billboard.distance.toStringAsFixed(0)} m", // Jarak (misal: 120 m)
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // -------------------------------------------------------
              // 4. TOMBOL LAPOR (Pojok Kanan Bawah - Lebih Rapi)
              // -------------------------------------------------------
              if (billboard.isExpired)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: billboard.isReported
                          ? null
                          : () => _handleReport(context),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: billboard.isReported
                              ? Colors.grey[200]
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.campaign_outlined,
                              size: 18,
                              color: billboard.isReported
                                  ? Colors.grey
                                  : Colors.red,
                            ),
                            if (!billboard.isReported) ...[
                              const SizedBox(width: 4),
                              const Text(
                                "Lapor",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget untuk Thumbnail biar code utama bersih
  Widget _buildThumbnail(BuildContext context, Uint8List? imageBytes) {
    return Container(
      width: 80,
      height: 110, // Sedikit lebih tinggi biar proporsional
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
      ),
      child: imageBytes != null
          ? GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    opaque: false,
                    barrierColor: Colors.black,
                    pageBuilder: (_, __, ___) => ImagePreviewPage(
                      imageProvider: MemoryImage(imageBytes),
                      tag: "img-${billboard.id}",
                    ),
                  ),
                );
              },
              child: Hero(
                tag: "img-${billboard.id}",
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(imageBytes, fit: BoxFit.cover),
                ),
              ),
            )
          : const Icon(Icons.broken_image, size: 30, color: Colors.grey),
    );
  }

  void _handleReport(BuildContext context) {
    showConfirmationModal(
      context,
      title: "Konfirmasi Pelaporan",
      message: AppConstants.questionReportExpired,
      confirmText: "Ya, Laporkan",
      cancelText: "Batal",
      isDestructive: true,
      onConfirm: () {
        context.read<CheckResultCubit>().submitReport(
          imagePath: capturedImagePath,
          latitude: latitude,
          longitude: longitude,
          type: ReportType.expired.value,
          reklameId: billboard.id,
        );
      },
    );
  }
}
