// lib/di.dart
import 'package:cekreklamemobile/data/repositories/billboard_repository_impl.dart';
import 'package:get_it/get_it.dart';
import 'domain/repositories/billboard_repository.dart';
import 'domain/usecases/check_billboard_usecase.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // --- Domain Layer ---
  locator.registerLazySingleton<BillboardRepository>(
    () => MockBillboardRepositoryImpl(), // Memakai Mock Implementasi
  );

  // --- Use Case Layer ---
  locator.registerLazySingleton<CheckBillboardUseCase>(
    () => CheckBillboardUseCase(locator()), // Injeksi BillboardRepository
  );

  // ... (Tambahkan Use Case, Bloc/Cubit lain di sini nanti)
}
