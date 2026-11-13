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
      appBar: AppBar(
        title: const Text("Atenção"),
        leading: SizedBox.shrink(),
        excludeHeaderSemantics: true,
        centerTitle: true,
      ),
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
              key: qrKey,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    QrImageView(
                      data: masterPassword ?? 'Sem senha',
                      version: QrVersions.auto,

                      size: 200,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'NÃO COMPARTILHE ESTE QR CODE!',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
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
            const SizedBox(height: 34),
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

      final shareParams = ShareParams(
        text: 'QR Code contendo sua senha mestra.',
        subject: 'Senha mestra Keezy',

        files: [XFile(file.path)],
      );

      await SharePlus.instance.share(shareParams);
    } catch (e, s) {
      log('Erro ao exportar QR: $e', stackTrace: s);
      // ShowMessager.show(, 'Erro ao exportar QR Code');
    }
  }
}
