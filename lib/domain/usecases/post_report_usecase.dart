import '../repositories/billboard_repository.dart';

class PostReportUsecase {
  final BillboardRepository repository;

  PostReportUsecase(this.repository);

  Future<bool> call({
    required String imagePath,
    required double latitude,
    required double longitude,
    required int type,
  }) async {
    return await repository.reportBillboard(
      imagePath: imagePath,
      latitude: latitude,
      longitude: longitude,
      type: type,
    );
  }
}
