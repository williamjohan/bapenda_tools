// lib/domain/entities/billboard_status.dart
import 'package:flutter/material.dart';

enum BillboardDisplayStatus { active, expired, unknown }

class StatusHelper {
  final String text;
  final Color color;

  StatusHelper({required this.text, required this.color});

  static StatusHelper fromEntity(bool isActive, bool isExpired) {
    if (isExpired) {
      return StatusHelper(text: "Expired", color: Colors.red[700]!);
    }
    if (isActive) {
      return StatusHelper(text: "Active", color: Colors.blue[700]!);
    }
    // Default jika isActive=false dan belum Expired
    return StatusHelper(
      text: "Inactive",
      color: Colors.orange[700]!, // Orange untuk Non-Aktif/Pending
    );
  }
}
