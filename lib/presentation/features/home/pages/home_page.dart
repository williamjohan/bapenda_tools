import 'package:cekreklamemobile/presentation/features/home/widgets/capture_card_widget.dart';
import 'package:cekreklamemobile/presentation/features/home/widgets/greeting_card_widget.dart';
import 'package:cekreklamemobile/presentation/features/home/widgets/cek_reklame_card_widget.dart';
import 'package:cekreklamemobile/presentation/features/home/widgets/report_card_widget.dart';
import 'package:cekreklamemobile/presentation/shared/widgets/bottom_navigation_widget.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Image.asset('assets/images/logosby.png', height: 55),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Cek Reklame",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "Kota Surabaya",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GreetingCard(),
            const SizedBox(height: 20),
            const CaptureBillboardButton(),
            const SizedBox(height: 20),
            const MyReportsCard(),
            const SizedBox(height: 20),
            const NearbyBillboardCard(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNav(),
    );
  }
}
