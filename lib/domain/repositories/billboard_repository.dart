import '../entities/billboard_entity.dart';

abstract class BillboardRepository {
  Future<List<BillboardEntity>> checkBillboardByPhoto({
    required String imagePath,
    required double latitude,
    required double longitude,
  });

  Future<List<BillboardEntity>> checkReklameWithCoordinate({
    required String imagePath,
    required double latitude,
    required double longitude,
    void Function(double progress)? onProgress,
  });

  Future<bool> reportBillboard({
    required String imagePath,
    required double latitude,
    required double longitude,
    required int type,
  });
}
