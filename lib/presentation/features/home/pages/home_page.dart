import 'package:cekreklamemobile/di.dart';
import 'package:cekreklamemobile/presentation/features/home/cubit/home_action.dart';
import 'package:cekreklamemobile/presentation/features/home/cubit/home_cubit.dart';
import 'package:cekreklamemobile/presentation/features/home/cubit/home_state.dart';
import 'package:cekreklamemobile/presentation/features/home/cubit/nearby_cubit.dart';
import 'package:cekreklamemobile/presentation/features/home/cubit/nearby_state.dart';
import 'package:cekreklamemobile/presentation/features/home/widgets/capture_card_widget.dart';
import 'package:cekreklamemobile/presentation/features/home/widgets/cek_reklame_terdekat_widget.dart';
import 'package:cekreklamemobile/presentation/features/home/widgets/greeting_card_widget.dart';
import 'package:cekreklamemobile/presentation/features/home/widgets/home_footer_widget.dart';
import 'package:cekreklamemobile/presentation/features/update/update_dialog.dart';
import 'package:cekreklamemobile/presentation/shared/widgets/custom_modal_widget.dart';
import 'package:cekreklamemobile/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// =================================================================
// 1. HOME PAGE (WRAPPER)
// Tugas: Hanya mendaftarkan Provider/Cubit
// =================================================================
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // HomeCubit: Logic Header, Menu, Navigasi
        BlocProvider(create: (context) => locator<HomeCubit>()..onPageOpened()),
        // NearbyCubit: Khusus Widget Peta
        BlocProvider(
          create: (context) => locator<NearbyCubit>()..initLocation(),
        ),
      ],
      // Panggil Child Widget yang terpisah (View)
      child: const HomeView(),
    );
  }
}

// =================================================================
// 2. HOME VIEW (CONTENT & LIFECYCLE)
// Tugas: Menangani Tampilan UI dan Lifecycle (Resume/Pause)
// =================================================================
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ✅ SEKARANG AMAN: Karena HomeView adalah ANAK dari MultiBlocProvider
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final nearbyCubit = context.read<NearbyCubit>();

      // Refresh lokasi hanya jika statusnya error/denied/disabled
      if (nearbyCubit.state.status != NearbyStatus.active) {
        nearbyCubit.initLocation();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Gunakan BlocConsumer HANYA untuk HomeCubit
    return BlocConsumer<HomeCubit, HomeState>(
      listenWhen: (prev, curr) =>
          prev.action != curr.action && curr.action != null,
      listener: (context, state) {
        final action = state.action;

        if (action is HomeShowUpdateDialog) {
          showUpdateDialog(context, action.updateInfo);
        } else if (action is HomeShowGpsDisabled) {
          showGpsDisabledModal(context);
        } else if (action is HomeShowPermissionDenied) {
          showPermissionDeniedModal(context); // Soft Deny
        } else if (action is HomeShowPermissionPermanentlyDenied) {
          showPermissionPermanentlyDeniedModal(context); // Hard Deny
        } else if (action is HomeNavigateToCamera) {
          context.pushNamed(AppRoutes.camera);
        }

        context.read<HomeCubit>().clearAction();
      },
      builder: (context, state) {
        final updateInfo = state.updateInfo;
        final isChecking = state.isCheckingUpdate;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6FA),
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 0,
                  top: 10,
                  bottom: 10,
                ),
                child: Row(
                  children: [
                    Image.asset('assets/images/logosby.png', height: 50),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Cek Reklame",
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
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
                    ),

                    // MENU TITIK TIGA
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      offset: const Offset(-20, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: Colors.black45,
                      ),
                      onSelected: (value) {
                        if (value == 'update' && updateInfo != null) {
                          context.read<HomeCubit>().onManualCheckUpdate();
                        } else if (value == 'report') {
                          showReportIssueModal(context);
                        }
                      },
                      itemBuilder: (context) => [
                        // ITEM 1: UPDATE
                        PopupMenuItem(
                          value: 'update',
                          enabled: updateInfo != null,
                          child: Row(
                            children: [
                              Icon(
                                Icons.system_update_alt_rounded,
                                size: 20,
                                color: updateInfo != null
                                    ? Colors.blue
                                    : Colors.grey[400],
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Cek Pembaruan",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: updateInfo != null
                                          ? Colors.black
                                          : Colors.grey[400],
                                    ),
                                  ),
                                  Text(
                                    isChecking
                                        ? "Memeriksa..."
                                        : (updateInfo != null
                                              ? "Versi baru tersedia"
                                              : "Sudah versi terbaru"),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: updateInfo != null
                                          ? Colors.orange
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // ITEM 2: LAPOR
                        const PopupMenuItem(
                          value: 'report',
                          child: Row(
                            children: [
                              Icon(
                                Icons.bug_report_outlined,
                                size: 20,
                                color: Colors.redAccent,
                              ),
                              SizedBox(width: 12),
                              Text(
                                "Lapor Kendala",
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
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
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: const [
                  GreetingCard(),
                  SizedBox(height: 12),
                  CaptureBillboardButton(),
                  SizedBox(height: 12),
                  NearbyBillboardCard(), // Widget ini aman ambil NearbyCubit
                  SizedBox(height: 12),
                  HomeFooter(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
