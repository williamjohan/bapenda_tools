// lib/data/repositories/mock_billboard_repository_impl.dart

import '../../domain/entities/billboard_entity.dart';
import '../../domain/repositories/billboard_repository.dart';
import '../models/billboard_model.dart';

// Data Mockup untuk simulasi API
final mockModels = [
  const BillboardModel(
    id: 'B001',
    name: 'Videotron Jl. Raya Darmo',
    type: 'Videotron',
    address: 'Jl. Darmo No. 12',
    latitude: -7.2801,
    longitude: 112.7380,
    distance: 0.5,
    ownerName: 'PT Media Jaya',
    status: 1,
    photoUrl: 'https://example.com/darmo.jpg',
  ),
  const BillboardModel(
    id: 'B002',
    name: 'Billboard Dekat Tunjungan Plaza',
    type: 'Billboard',
    address: 'Jl. Basuki Rachmat',
    latitude: -7.2650,
    longitude: 112.7388,
    distance: 1.2,
    ownerName: 'Pemerintah Kota',
    status: 0,
    photoUrl: 'https://example.com/tp.jpg',
  ),
  // Tambahkan data mockup lain jika perlu
];

class MockBillboardRepositoryImpl implements BillboardRepository {
  // Implementasi untuk mendapatkan daftar terdekat
  @override
  Future<List<BillboardEntity>> getNearbyBillboards({
    required double latitude,
    required double longitude,
  }) async {
    // Simulasikan delay API
    await Future.delayed(const Duration(milliseconds: 800));

    // Mapping Model Mockup ke Entity
    return mockModels.map((model) => model.toEntity()).toList();
  }

  // Implementasi untuk Check by Photo
  @override
  Future<List<BillboardEntity>> checkBillboardByPhoto({
    required String imagePath,
    required double latitude,
    required double longitude,
  }) async {
    // Simulasikan delay dan hasil (mengembalikan data yang sama untuk tujuan mockup)
    await Future.delayed(const Duration(seconds: 1));
    return mockModels.map((model) => model.toEntity()).toList();
  }
}
