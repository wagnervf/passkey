import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:keezy/src/core/router/routes.dart';

class ModeSelectionScreenTwo extends StatelessWidget {
  const ModeSelectionScreenTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar cofre local'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RoutesPaths.initial),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.phonelink_lock,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Seus registros ficam neste dispositivo',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'O Keezy não sincroniza com contas Google ou com a nuvem. '
                'Você pode exportar seus registros em CSV nas configurações.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () =>
                    context.go(RoutesPaths.createMasterPassword),
                icon: const Icon(Icons.lock_outline),
                label: const Text('Criar senha mestra'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
