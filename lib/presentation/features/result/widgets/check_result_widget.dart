import 'package:cekreklamemobile/core/constants/app_colors.dart';
import 'package:cekreklamemobile/presentation/features/result/bloc/check_result_cubit.dart';
import 'package:cekreklamemobile/presentation/features/result/bloc/check_result_state.dart';
import 'package:cekreklamemobile/presentation/features/result/widgets/error_state_widget.dart';
import 'package:cekreklamemobile/presentation/features/result/widgets/no_result_widget.dart';
import 'package:cekreklamemobile/presentation/features/result/widgets/result_list_view_widget.dart';
import 'package:cekreklamemobile/presentation/features/result/widgets/upload_progress_widget.dart';
import 'package:cekreklamemobile/presentation/shared/widgets/custom_modal_widget.dart';
import 'package:cekreklamemobile/presentation/shared/widgets/processing_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CheckResultView extends StatelessWidget {
  final String imagePath;
  final double latitude;
  final double longitude;

  const CheckResultView({
    super.key,
    required this.imagePath,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckResultCubit, CheckResultState>(
      listener: (context, state) {
        if (state is CheckResultReportSuccess) {
          showAppModal(
            context: context,
            content: Column(
              children: [
                Image.asset(
                  'assets/images/sendicon.png',
                  width: double.infinity,
                  height: 150,
                ),
                SizedBox(height: 10),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
              ],
            ),
            showCloseButton: false,
            isDismissible: false,
            primaryButton: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                context.pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          );
        } else if (state is CheckResultReportError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            "Hasil Pengecekan",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            // LAYER 1: KONTEN UTAMA
            BlocBuilder<CheckResultCubit, CheckResultState>(
              buildWhen: (previous, current) =>
                  current is CheckResultLoading ||
                  current is CheckResultLoaded ||
                  current is CheckResultError,
              builder: (context, state) {
                if (state is CheckResultLoading) {
                  return UploadProgressWidget(progress: state.progress);
                }
                if (state is CheckResultError) {
                  return ErrorStateWidget(message: state.message);
                }
                if (state is CheckResultLoaded) {
                  if (state.results.isEmpty) {
                    return NoResultsWidget(
                      capturedImagePath: imagePath,
                      latitude: latitude,
                      longitude: longitude,
                    );
                  }
                  return ResultsListViewWidget(
                    data: state.results,
                    capturedImagePath: imagePath,
                    latitude: latitude,
                    longitude: longitude,
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // LAYER 2: OVERLAY LOADING
            BlocBuilder<CheckResultCubit, CheckResultState>(
              builder: (context, state) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  child: _buildOverlayContent(state),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayContent(CheckResultState state) {
    // 1. Tampilan saat sedang mengirim laporan
    if (state is CheckResultReporting) {
      return Container(
        key: const ValueKey('reporting_overlay'),
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withValues(alpha: 0.5),
        child: const Center(
          child: ProcessingLoadingWidget(message: "Mengirim Laporan..."),
        ),
      );
    }

    // 2. Tampilan saat sudah berhasil (menghilangkan loading, tapi tetap memberi overlay redup)
    if (state is CheckResultReportSuccess) {
      return Container(
        key: const ValueKey('success_overlay'),
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withValues(alpha: 0.3),
      );
    }

    // 3. Jika tidak dalam state lapor/sukses, kembalikan widget kosong dengan key unik
    return const SizedBox.shrink(key: ValueKey('empty_overlay'));
  }
}
