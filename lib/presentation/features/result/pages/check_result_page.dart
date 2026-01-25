import 'package:cekreklamemobile/di.dart';
import 'package:cekreklamemobile/presentation/features/result/cubit/check_result_cubit.dart';
import 'package:cekreklamemobile/presentation/features/result/widgets/check_result_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CheckResultScreen extends StatelessWidget {
  final String imagePath;
  final double latitude;
  final double longitude;

  const CheckResultScreen({
    super.key,
    required this.imagePath,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CheckResultCubit>(
      create: (context) {
        final cubit = locator<CheckResultCubit>();

        cubit.testingfetchResult(
          imagePath: imagePath,
          latitude: latitude,
          longitude: longitude,
        );
        return cubit;
      },
      child: CheckResultView(
        imagePath: imagePath,
        latitude: latitude,
        longitude: longitude,
      ),
    );
  }
}
