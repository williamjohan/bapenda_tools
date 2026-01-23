import 'dart:typed_data';
import 'package:cekreklamemobile/core/constants/app_constants.dart';
import 'package:cekreklamemobile/core/utils/image_utils.dart';
import 'package:cekreklamemobile/domain/value_objects/billboard_status.dart';
import 'package:cekreklamemobile/domain/entities/billboard_entity.dart';
import 'package:cekreklamemobile/presentation/features/result/cubit/check_result_cubit.dart';
import 'package:cekreklamemobile/presentation/features/result/widgets/image_preview_page.dart';
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
      child: InkWell(
        onTap: () {
          // Navigasi ke Detail Page dengan membawa Entity
          // context.pushNamed(AppRoutes.detail, extra: billboard);
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // 1. Thumbnail
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child:
                    imageBytes !=
                        null // ✅ Cek apakah bytes gambar tersedia
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              opaque: false,
                              barrierColor: Colors.black.withValues(alpha: 0.8),
                              pageBuilder: (_, __, ___) => ImagePreviewPage(
                                imageBytes: imageBytes,
                                tag: "img-${billboard.id}",
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: "img-${billboard.id}",
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(imageBytes, fit: BoxFit.cover),
                          ),
                        ),
                      )
                    : const Icon(
                        // Placeholder jika Base64 kosong atau gagal
                        Icons.broken_image,
                        size: 30,
                        color: Colors.grey,
                      ),
              ),
              const SizedBox(width: 16),

              // 2. Info Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ID: ${billboard.id}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "Jenis: ${billboard.type}",
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        // Ikon Status
                        Icon(
                          Icons.shield_outlined, // Ikon lisensi/verifikasi
                          size: 14,
                          color: status.color, // Warna dinamis dari Helper
                        ),
                        const SizedBox(width: 4),

                        // Teks Status
                        Text(
                          "Status: ${status.text.toUpperCase()}",
                          style: TextStyle(
                            color: status.color, // Warna dinamis dari Helper
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "Isi Reklame: ${billboard.name}",
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),
                    Text(
                      billboard.address,
                      style: const TextStyle(color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Row(
                    //   children: [
                    //     const Icon(
                    //       Icons.location_on,
                    //       size: 14,
                    //       color: Colors.blue,
                    //     ),
                    //     const SizedBox(width: 4),
                    //     Text(
                    //       "Approx. ${billboard.distance.toStringAsFixed(2)}km away",
                    //       style: TextStyle(color: Colors.grey[600]),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
              // const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),

              //buat icon untuk lapor
              if (billboard.isExpired)
                IconButton(
                  onPressed: billboard.isReported
                      ? null
                      : () {
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
                                  AppConstants.questionReportExpired,
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
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      side: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      foregroundColor: Colors.grey.shade700,
                                    ),
                                    child: const Text(
                                      "Batal",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();

                                      context
                                          .read<CheckResultCubit>()
                                          .submitReport(
                                            imagePath: capturedImagePath,
                                            latitude: latitude,
                                            longitude: longitude,
                                            type: ReportType.expired.value,
                                            reklameId: billboard.id,
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
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                  icon: Icon(
                    Icons.report_problem_outlined,
                    size: 24,
                    color: billboard.isReported ? Colors.grey : Colors.red[400],
                  ),
                  tooltip: billboard.isReported
                      ? "Sudah dilaporkan"
                      : "Laporkan Reklame",
                ),
            ],
          ),
        ),
      ),
    );
  }
}
