import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keezy/src/core/storage/i_token_storage.dart';
import 'package:keezy/src/modules/auth/controllers/auth_controller.dart';
import 'package:keezy/src/modules/auth/controllers/auth_state.dart';
import 'package:keezy/src/modules/auth/model/auth_user_model.dart';
import 'package:keezy/src/modules/auth/repositories/auth_repository.dart';
import 'package:keezy/src/modules/profile/profile_page.dart';
import 'package:provider/provider.dart';

class _Tokens implements TokenStorageInterface {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _AuthController extends AuthController {
  _AuthController()
    : super(tokenStorage: _Tokens(), authRepository: AuthRepository()) {
    updateName('Ana');
  }

  void updateName(String name) =>
      emit(AuthSuccessState(AuthUserModel(name: name)));
}

void main() {
  testWidgets('Perfil estabiliza e atualiza com fonte ampliada', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 360);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final auth = _AuthController();

    await tester.pumpWidget(
      Provider<AuthController>.value(
        value: auth,
        child: MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
            child: const ProfilePage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ana'), findsOneWidget);
    await tester.ensureVisible(find.text('Sair'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    auth.updateName('Beatriz');
    await tester.pumpAndSettle();
    expect(find.text('Beatriz'), findsOneWidget);
    expect(find.text('Ana'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await auth.close();
  });
}
