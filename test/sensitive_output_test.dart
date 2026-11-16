import 'package:flutter_test/flutter_test.dart';
import 'package:keezy/src/modules/auth/model/auth_user_model.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';

void main() {
  test('representações de objetos não revelam credenciais nem notas', () {
    final register = RegisterModel(
      id: 'id-publico',
      name: 'nome-privado',
      username: 'usuario-privado',
      password: 'senha-do-registro',
      url: 'url-privada',
      note: 'nota-privada',
    );
    final user = AuthUserModel(
      name: 'Ana',
      password: 'senha-mestra',
    );

    expect(register.toString(), 'RegisterModel(id: id-publico)');
    expect(register.toString(), isNot(contains('senha-do-registro')));
    expect(register.toString(), isNot(contains('nota-privada')));
    expect(user.toString(), isNot(contains('senha-mestra')));
  });
}
