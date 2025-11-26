import 'package:cekreklamemobile/presentation/shared/widgets/custom_modal_widget.dart';
import 'package:flutter/material.dart';

class MyReportsCard extends StatelessWidget {
  const MyReportsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        showAppModal(
          context: context,
          content: Column(
            children: [
              Image.asset(
                'assets/images/feat_comingsoon.png',
                width: double.infinity,
                height: 150,
              ),
              SizedBox(height: 10),
              Text(
                'Mohon Maaf, fitur ini masih dalam tahap pengembangan dan akan segera hadir dalam waktu dekat.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          primaryButton: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF175CFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'OK',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          showCloseButton: false,
          isDismissible: true,
        );
      },
      splashColor: Colors.white.withValues(alpha: 0.2),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.document_scanner_outlined,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                "My Reports\nLihat laporan Anda",
                style: TextStyle(fontSize: 14, height: 1.3),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.black45,
            ),
          ],
        ),
      ),
    );
  }
}
