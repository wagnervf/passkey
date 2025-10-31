import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

class InstalledAppsPage extends StatefulWidget {
  final ScrollController? scrollController;
  const InstalledAppsPage({super.key, this.scrollController});

  @override
  State<InstalledAppsPage> createState() => _InstalledAppsPageState();
}

class _InstalledAppsPageState extends State<InstalledAppsPage> {
  List<AppInfo> _apps = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchInstalledApps();
  }

  Future<void> _fetchInstalledApps() async {
    setState(() {
      _isLoading = true;
    });
    // Aguarda 1 segundo para simular o carregamento
    //await Future.delayed(const Duration(seconds: 1));
    final apps = await InstalledApps.getInstalledApps(withIcon: true);
    setState(() {
      _apps = apps;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: LinearProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    if (_apps.isEmpty) {
      return const Center(child: Text('Nenhum aplicativo instalado'));
    }

    return ListView.builder(

      controller: widget.scrollController,
      itemCount: _apps.length,
      itemBuilder: (context, index) {
        final app = _apps[index];

        return ListTile(
          dense: true,
          leading: app.icon != null
              ? Image.memory(app.icon!, width: 40, height: 40)
              : const Icon(Icons.apps),
          title: Text(app.name),
          subtitle: Text(app.packageName),
          onTap: () {
            Navigator.pop(context, app);
          },
        );
      },
    );
  }
}
