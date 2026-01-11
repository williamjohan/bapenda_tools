// lib/data/repositories/mock_billboard_repository_impl.dart

import 'package:cekreklamemobile/data/datasources/billboard_remote_datasource.dart';

import '../../domain/entities/billboard_entity.dart';
import '../../domain/repositories/billboard_repository.dart';

// Data Mockup untuk simulasi API
// final mockModels = [
//   const BillboardModel(
//     id: 'B001',
//     name: 'Videotron Jl. Raya Darmo',
//     type: 'Videotron',
//     address: 'Jl. Darmo No. 12',
//     latitude: -7.2801,
//     longitude: 112.7380,
//     distance: 0.5,
//     ownerName: 'PT Media Jaya',
//     status: 1,
//     photoUrl: 'https://example.com/darmo.jpg',
//   ),
//   const BillboardModel(
//     id: 'B002',
//     name: 'Billboard Dekat Tunjungan Plaza',
//     type: 'Billboard',
//     address: 'Jl. Basuki Rachmat',
//     latitude: -7.2650,
//     longitude: 112.7388,
//     distance: 1.2,
//     ownerName: 'Pemerintah Kota',
//     status: 0,
//     photoUrl: 'https://example.com/tp.jpg',
//   ),
//   // Tambahkan data mockup lain jika perlu
// ];

class BillboardRepositoryImpl implements BillboardRepository {
  final BillboardRemoteDataSource remoteDataSource;
  BillboardRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<BillboardEntity>> checkBillboardByPhoto({
    required String imagePath,
    required double latitude,
    required double longitude,
  }) async {
    // Simulasikan delay dan hasil (mengembalikan data yang sama untuk tujuan mockup)

    final billboardModels = await remoteDataSource.checkReklame(
      imagePath: imagePath,
    );

    await Future.delayed(const Duration(seconds: 1));
    // return mockModels.map((model) => model.toEntity()).toList();.
    return billboardModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<BillboardEntity>> checkReklameWithCoordinate({
    required String imagePath,
    required double latitude,
    required double longitude,
    void Function(double progress)? onProgress,
  }) async {
    final billboardModels = await remoteDataSource.checkReklameWithCoordinate(
      imagePath: imagePath,
      latitude: latitude,
      longitude: longitude,
      onProgress: onProgress,
    );
    return billboardModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<bool> reportBillboard({
    required String imagePath,
    required double latitude,
    required double longitude,
    required int type,
  }) async {
    return await remoteDataSource.postReport(
      imagePath: imagePath,
      latitude: latitude,
      longitude: longitude,
      type: type,
    );
  }
}
