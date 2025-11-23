import 'dart:typed_data';
import 'package:cekreklamemobile/domain/value_objects/billboard_status.dart';
import 'package:cekreklamemobile/domain/entities/billboard_entity.dart';
import 'package:cekreklamemobile/presentation/features/result/widgets/image_preview_page.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/image_utils.dart';

class ResultCardWidget extends StatelessWidget {
  final BillboardEntity billboard;

  const ResultCardWidget({super.key, required this.billboard});

  @override
  Widget build(BuildContext context) {
    final status = StatusHelper.fromEntity(
      billboard.isActive,
      billboard.isExpired,
    );
    final Uint8List? imageBytes = decodeBase64DataUrl(billboard.imageUrl);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        // onTap: () {
        //   // Navigasi ke Detail Page dengan membawa Entity
        //   context.pushNamed(AppRoutes.detail, extra: billboard);
        // },
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
                    //       "Approx. ${billboard.distanceKm.toStringAsFixed(2)}km away",
                    //       style: TextStyle(color: Colors.grey[600]),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
              // const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
