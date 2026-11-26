import 'dart:async';

import 'package:flutter/material.dart';

/// Shows the newly created password only while the user explicitly reveals it.
class MasterPasswordWarningScreen extends StatefulWidget {
  const MasterPasswordWarningScreen({super.key, required this.masterPassword});

  final String masterPassword;

  @override
  State<MasterPasswordWarningScreen> createState() =>
      _MasterPasswordWarningScreenState();
}

class _MasterPasswordWarningScreenState
    extends State<MasterPasswordWarningScreen> with WidgetsBindingObserver {
  static const _revealDuration = Duration(seconds: 15);
  Timer? _hideTimer;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _hide();
  }

  void _reveal() {
    _hideTimer?.cancel();
    setState(() => _visible = true);
    _hideTimer = Timer(_revealDuration, _hide);
  }

  void _hide() {
    _hideTimer?.cancel();
    if (mounted && _visible) setState(() => _visible = false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Guarde sua senha mestra'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.key_rounded, size: 72, color: colors.primary),
                const SizedBox(height: 24),
                Text(
                  'Você precisará desta senha para abrir seu cofre. '
                  'Guarde-a em um local seguro.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                Container(
                  key: const ValueKey('master-password-panel'),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _visible ? widget.masterPassword : 'Senha oculta',
                        key: const ValueKey('master-password-display'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _visible ? _hide : _reveal,
                        icon: Icon(
                          _visible ? Icons.visibility_off : Icons.visibility,
                        ),
                        label: Text(
                          _visible
                              ? 'Ocultar agora'
                              : 'Mostrar por 15 segundos',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Depois de adicionar registros, crie um backup Keezy '
                  'criptografado em Configurações. Ele permite restaurar '
                  'seus dados com uma nova senha mestra.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () {
                    _hide();
                    Navigator.of(context).pop(true);
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Entendi e quero continuar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
