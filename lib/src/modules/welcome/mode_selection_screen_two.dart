// mode_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:keezy/src/core/router/routes.dart';

class ModeSelectionScreenTwo extends StatelessWidget {
  const ModeSelectionScreenTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Como você quer usar o Cofre?'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.go(RoutesPaths.initial);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Theme.of(context).colorScheme.primary , width: 1.5),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(4.0),
                  leading: Icon(Icons.lock, size: 30, color: Colors.blueGrey),
                  title: Text(
                    'Usar Localmente',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Sem conta, sem nuvem, apenas você.',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      Text(
                        'Todos os seus dados ficarão apenas no seu dispositivo.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  onTap: () {
                    context.go(
                        '/create-master-password'); 
                  },
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Theme.of(context).colorScheme.surfaceTint , width: 1.5),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(4.0),
                  leading: Icon(Icons.cloud, size: 40, color: Colors.lightBlue),
                  title: Text(
                    'Criar Conta',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Google Login',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      Text(
                        'Sincronize seus dados com segurança na nuvem usando sua conta Google.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  onTap: () {
                    // For Google Login, you'd typically handle the authentication
                    // then navigate to the MasterPasswordCreationScreen or directly to security settings
                    // For now, let's assume it proceeds to master password creation for UI flow
                    context.go('/create-master-password');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
