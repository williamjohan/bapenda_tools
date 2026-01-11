import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomeFooter extends StatelessWidget {
  const HomeFooter({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan SafeArea bottom: false di Scaffold utama,
    // tapi true di sini jika ingin footer naik sedikit dari bezel bawah
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.only(
          top: 20,
          bottom: 20,
        ), // Horizontal sudah diatur parent
        child: Column(
          children: [
            // BAGIAN LOGO & ALAMAT
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Opacity(
                  opacity: 0.9,
                  child: Image.asset(
                    'assets/images/logosby.png',
                    width: 45,
                    height: 65,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Pemerintah Kota Surabaya",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              FontWeight.bold, // Sedikit ditebalkan biar tegas
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Jl. Jimerto No.25-27, Ketabang,\nKec. Genteng, Kota SBY, Jawa Timur 60272",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "(031) 5312144",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Divider(height: 1, color: Colors.grey.shade300),
            const SizedBox(height: 8),

            // BAGIAN VERSI & COPYRIGHT
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    String version = snapshot.data?.version ?? "-";
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "v$version Beta",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
                Text(
                  "© ${DateTime.now().year} Bapenda Surabaya",
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
