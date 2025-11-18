// ignore_for_file: use_build_context_synchronously
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:keezy/src/core/router/routes.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class MasterPasswordWarningScreen extends StatelessWidget {
  final String masterPassword;
  MasterPasswordWarningScreen({super.key, required this.masterPassword});

  // GlobalKey para acessar o widget do QR
  final GlobalKey qrKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Atenção")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.warning, size: 80, color: Colors.amber),
            const SizedBox(height: 20),

            Text(
              "Se você esquecer sua senha mestra,\n"
              "NÃO HÁ COMO RECUPERAR.\n\n"
              "Anote em um lugar seguro ou salve o QR Code abaixo!",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 24),

            RepaintBoundary(
  key: qrKey, // ESTA KEY É A MESMA QUE VOCÊ VAI USAR NO EXPORT
  child: QrImageView(
    data: masterPassword ?? 'Sem senha',
    version: QrVersions.auto,
    size: 200,
  ),
),
            const SizedBox(height: 12),
            SelectableText(
              masterPassword,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const Spacer(),

            OutlinedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text("Exportar QR Code"),
              onPressed: () => exportQrCode(),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: const Text("Entendi e quero continuar"),
              onPressed: () {
                context.push(RoutesPaths.biometricSetup);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> exportQrCode() async {
  try {
    await Future.delayed(const Duration(milliseconds: 300));

    RenderRepaintBoundary boundary =
        qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ImageByteFormat.png);

    if (byteData == null) return;

    final pngBytes = byteData.buffer.asUint8List();
    
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/senha_qrcode.png');
    await file.writeAsBytes(pngBytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'QR Code contendo sua senha mestra.',
      subject: 'Senha mestra Keezy',
    );
  } catch (e, s) {
    log('Erro ao exportar QR: $e', stackTrace: s);
   // ShowMessager.show(, 'Erro ao exportar QR Code');
  }
}


  // Future<void> exportQrCode() async {
  //   try {
  //     RenderRepaintBoundary boundary =
  //         qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

  //     final image = await boundary.toImage(pixelRatio: 3.0);
  //     final byteData = await image.toByteData(format: ImageByteFormat.png);
  //     final pngBytes = byteData!.buffer.asUint8List();

  //     // Salva como arquivo temporário
  //     final tempDir = await getTemporaryDirectory();
  //     final file = File('${tempDir.path}/qr_senha.png');
  //     await file.writeAsBytes(pngBytes);

  //     final shareParams = ShareParams(
  //       text: 'Aqui está o backup dos seus registros.',
  //       subject: 'Senha Mestra',

  //       files: [XFile(file.path)],
  //     );

  //     final result = await SharePlus.instance.share(shareParams);

  //     // Se o usuário cancelar, exclui o arquivo imediatamente
  //     if (result.status != ShareResultStatus.success) {
  //       Future.delayed(const Duration(seconds: 3), () async {
  //         if (await file.exists()) await file.delete();
  //         log('🗑️ Arquivo removido — o usuário cancelou o compartilhamento.');
  //       });
  //       return null;
  //     }

  //     log('✅ Senha Mestra compartilhado com sucesso!');
  //     return; // retorna o arquivo só se foi realmente compartilhad
  //   } catch (e) {
  //     debugPrint('Erro ao exportar QR: $e');
  //   }
  // }
}
