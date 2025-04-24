import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';

class InstalledAppsPage extends StatefulWidget {
  final ScrollController? scrollController;
  const InstalledAppsPage({super.key, this.scrollController});

  @override
  State<InstalledAppsPage> createState() => _InstalledAppsPageState();
}

class _InstalledAppsPageState extends State<InstalledAppsPage> {
  List<AppInfo> _apps = [];

  @override
  void initState() {
    super.initState();
    _fetchInstalledApps();
  }

  Future<void> _fetchInstalledApps() async {
    final apps = await InstalledApps.getInstalledApps(true, true);
    setState(() {
      _apps = apps;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.scrollController,
      itemCount: _apps.length,
      itemBuilder: (context, index) {
        final app = _apps[index];
        return ListTile(
          leading: app.icon != null
              ? Image.memory(app.icon!, width: 40, height: 40)
              : const Icon(Icons.apps),
          title: Text(app.name),
          subtitle: Text(app.packageName ?? 'Pacote desconhecido'),
          onTap: () {
            Navigator.pop(context, app); // ✅ Retorna app selecionado
          },
        );
      },
    );
  }
}
