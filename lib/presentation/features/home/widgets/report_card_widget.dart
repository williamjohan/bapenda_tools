import 'package:flutter/material.dart';

class MyReportsCard extends StatelessWidget {
  const MyReportsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black45),
        ],
      ),
    );
  }
}
