// security_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SecuritySettingsScreen extends StatefulWidget {
  @override
  _SecuritySettingsScreenState createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _autoLockTimeout = true;
  double _timeoutMinutes = 5.0; // Default timeout
  bool _secureModeDeleteData = false;
  int _maxAttempts = 5; // Default max attempts

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações de Segurança'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Ajuste as opções de segurança do seu cofre:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 30),
            SwitchListTile(
              title: Text('Bloquear após inatividade (Timeout automático)'),
              subtitle: Text('O cofre será bloqueado após um período de inatividade.'),
              value: _autoLockTimeout,
              onChanged: (bool value) {
                setState(() {
                  _autoLockTimeout = value;
                });
              },
            ),
            if (_autoLockTimeout)
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tempo de inatividade: ${_timeoutMinutes.toInt()} minutos'),
                    Slider(
                      value: _timeoutMinutes,
                      min: 1,
                      max: 60,
                      divisions: 11, // 1, 5, 10, 15, ..., 60
                      label: _timeoutMinutes.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _timeoutMinutes = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            Divider(height: 30),
            SwitchListTile(
              title: Text('Modo Seguro: Apagar dados após muitas tentativas erradas'),
              subtitle: Text('Proteja seus dados contra tentativas de acesso não autorizadas.'),
              value: _secureModeDeleteData,
              onChanged: (bool value) {
                setState(() {
                  _secureModeDeleteData = value;
                });
              },
            ),
            if (_secureModeDeleteData)
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Número máximo de tentativas: $_maxAttempts'),
                    Slider(
                      value: _maxAttempts.toDouble(),
                      min: 3,
                      max: 10,
                      divisions: 7,
                      label: _maxAttempts.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _maxAttempts = value.toInt();
                        });
                      },
                    ),
                  ],
                ),
              ),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement saving settings here
                  context.go('/biometric-setup'); // Navigate to biometric setup
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Salvar e Continuar',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}