import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:keezy/src/core/router/routes.dart';
import 'package:keezy/src/core/utils/utils.dart';
import 'package:keezy/src/modules/auth/model/auth_user_model.dart';

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
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
                "Proteja suas senhas de forma segura e privada",
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
      
              buttonCriarConta(context),
              const SizedBox(height: 20),
              buttonAcessar(context),
      
            ],
          ),
        ),
      ),
    );
  }

  SizedBox buttonCriarConta(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .9,
      height: 50,
      child: ElevatedButton(
        onPressed: () => _criarConta(context),
        style: Utils.styleButtonElevated(),
        child: const Text(
          "Criar Conta",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  SizedBox buttonAcessar(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .9,
      height: 50,
      child: OutlinedButton(
        onPressed: () => Navigator.of(context).pushNamed(RoutesPaths.auth),
        style: Utils.styleButtonElevated(),
        child: const Text(
          "Acessar",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  // void _acessar(BuildContext context) {
  //   GoRouter.of(context).pushReplacement(RoutesPaths.auth);
  // }

  void _criarConta(BuildContext context) {
    GoRouter.of(context)
        .pushReplacement(RoutesPaths.authRegister, extra: AuthUserModel());
  }

}
