import 'package:cekreklamemobile/presentation/features/result/bloc/check_result_cubit.dart';
import 'package:cekreklamemobile/presentation/features/result/bloc/check_result_state.dart';
import 'package:cekreklamemobile/presentation/features/result/widgets/error_state_widget.dart';
import 'package:cekreklamemobile/presentation/features/result/widgets/no_result_widget.dart';
import 'package:cekreklamemobile/presentation/features/result/widgets/result_list_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CheckResultView extends StatelessWidget {
  final String imagePath;

  const CheckResultView({
    super.key,
    required this.imagePath,
    // Add other fields if needed by the view
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: BlocBuilder<CheckResultCubit, CheckResultState>(
        builder: (context, state) {
          // Di sini, context sudah pasti memiliki Cubit yang dipicu
          if (state is CheckResultLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CheckResultError) {
            return ErrorStateWidget(message: state.message);
          }
          if (state is CheckResultLoaded) {
            if (state.results.isEmpty) {
              return NoResultsWidget(
                capturedImagePath: imagePath,
              ); // Gunakan widget yang sudah ada
            } else {
              return ResultsListViewWidget(
                data: state.results,
                capturedImagePath: imagePath,
              ); // Gunakan widget yang sudah ada
            }
          }
          return const Center(child: Text("Initializing..."));
        },
      ),
    );
  }
}
