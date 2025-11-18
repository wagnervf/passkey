// import 'package:flutter/material.dart';
// import 'package:keezy/src/core/components/show_messeger.dart';
// import 'package:keezy/src/modules/auth/controllers/auth_controller.dart';
// import 'package:provider/provider.dart';

// class ExportKeyMaster extends StatelessWidget {
//   ExportKeyMaster({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Provider.of<AuthController>(context, listen: false);

//     return Column(
//       children: [
//         ListTile(
//           leading: Icon(Icons.lock),
//           title: Text("Exportar senha mestra"),
//           subtitle: Text("Necessário autenticar biometria"),
//           trailing: Icon(Icons.arrow_forward_ios),
//           onTap: () async {
//             final auth = await context
//                 .read<AuthController>()
//                 .loginWithBiometrics(); 

//             if (!auth) {
//               ShowMessager.show(
//                 context,
//                 "Autenticação necessária para continuar.",
//               );
//               return;
//             }

//             // Usuário autenticado → abre tela de exportação
//             //context.push(RoutesPaths.masterPasswordWarning);
//           },
//         ),
//       ],
//     );
//   }
// }

