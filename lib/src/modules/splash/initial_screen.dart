import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:passkey/src/core/router/routes.dart';
import 'package:passkey/src/modules/auth/model/auth_user_model.dart';

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagem Ilustrativa
            SizedBox(
              height: 250,
              child: SvgPicture.asset(
                'assets/images/mobile_encryption.svg', // Caminho da imagem SVG
                height: 250,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 60),

            Text(
              "Gerencie suas senhas com segurança",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge,
            ),

            const SizedBox(height: 10),
            Text(
              "Armazenamento criptografado e acesso fácil quando precisar",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 80),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _acessar(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Acessar",
                    style: TextStyle(
                     fontWeight: FontWeight.bold,
                     fontSize: 18
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                TextButton(
                  child: Text(
                    "Criar Conta",
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  onPressed: () => _registrar(context),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

   void _acessar(BuildContext context) {
      GoRouter.of(context).pushReplacement(RoutesPaths.auth);
  }

  void _registrar(BuildContext context) {
      GoRouter.of(context).pushReplacement(RoutesPaths.authRegister, extra: AuthUserModel());
  }
}
