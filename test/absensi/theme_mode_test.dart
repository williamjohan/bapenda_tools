import 'package:bapendacore/core/storage/app_preference.dart';
import 'package:bapendacore/core/theme/theme_mode_cubit.dart';
import 'package:bapendacore/presentation/features/home/widgets/home_bapenda_core_drawer.dart';
import 'package:bapendacore/presentation/shared/widgets/adaptive_theme_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('ThemeModeCubit default sistem & tersimpan', () async {
    SharedPreferences.setMockInitialValues({});
    final raw = await SharedPreferences.getInstance();
    final cubit = ThemeModeCubit(AppPreferences(raw));

    expect(cubit.state, ThemeMode.system);
    await cubit.setMode(ThemeMode.dark);
    expect(raw.getString('theme_mode'), 'dark');
    expect(ThemeModeCubit(AppPreferences(raw)).state, ThemeMode.dark);
  });

  testWidgets('drawer: pilih "Gelap" mengubah tema halaman', (tester) async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'light'});
    final cubit = ThemeModeCubit(
      AppPreferences(await SharedPreferences.getInstance()),
    );
    final scaffoldKey = GlobalKey<ScaffoldState>();

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          home: AdaptiveThemeScope(
            child: Scaffold(
              key: scaffoldKey,
              drawer: const HomeBapendaCoreDrawer(
                userName: 'Pegawai',
                userRole: 'Staf',
              ),
              body: const SizedBox(),
            ),
          ),
        ),
      ),
    );
    scaffoldKey.currentState!.openDrawer();
    await tester.pumpAndSettle();

    expect(find.text('Sistem'), findsOneWidget);
    await tester.tap(find.text('Gelap'));
    await tester.pumpAndSettle();

    expect(cubit.state, ThemeMode.dark);
    final context = tester.element(find.byType(Drawer));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(tester.takeException(), isNull);
  });
}
