import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:installed_apps/app_info.dart';
import 'package:keezy/src/core/components/auth_dialog_service.dart';
import 'package:keezy/src/core/components/button_copiar.dart';
import 'package:keezy/src/core/components/show_messeger.dart';
import 'package:keezy/src/core/installed_apps/installed_app_model.dart';
import 'package:keezy/src/core/installed_apps/installed_apps_page.dart';
import 'package:keezy/src/core/utils/password_field_with_generator.dart';
import 'package:keezy/src/core/utils/utils.dart';
import 'package:keezy/src/modules/export_registers_csv/controllers/export_register_csv_controller.dart';
import 'package:keezy/src/modules/register/controller/register_controller.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class RegisterFormPage extends StatefulWidget {
  const RegisterFormPage({super.key});

  @override
  _RegisterFormPageState createState() => _RegisterFormPageState();
}

class _RegisterFormPageState extends State<RegisterFormPage> {
  final _formularioKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _siteController = TextEditingController();

  bool edit = false;
  bool carregando = false;
  bool buscandoApps = false;
  bool _isFavorite = false;

  RegisterModel? register;
  InstalledAppModel? selectedApp;

  ExportRegisterCsvController? _exportController;

  @override
  void initState() {
    super.initState();
    // pegar extra após o frame para garantir que GoRouterState esteja disponível
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra;
      if (extra != null && extra is RegisterModel) {
        register = extra;
        loadEdits(register!);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ler controller uma vez por ciclo do widget
    _exportController ??= Provider.of<ExportRegisterCsvController>(
      context,
      listen: false,
    );
  }

  void loadEdits(RegisterModel register) {
    // Atualiza campos de edição; está encapsulado em setState mínimo
    setState(() {
      edit = true;
      _titleController.text = register.name ?? '';
      _loginController.text = register.username ?? '';
      _passwordController.text = register.password ?? '';
      _descriptionController.text = register.note ?? '';
      _siteController.text = register.url ?? '';
      _isFavorite = register.isFavorite ?? false;
      selectedApp = register.selectedApp;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    _descriptionController.dispose();
    _siteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Recomendo deixar resizeToAvoidBottomInset true para melhor comportamento com teclado
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Fechar',
          onPressed: _clearInputs,
        ),
        title: Text(edit ? 'Editar Registro' : 'Adicionar Registro'),
        elevation: 0,
        actions: [
          _favoriteButton(),
          IconButton(
            onPressed: () => _confirmarExportacao(context),
            tooltip: 'Compartilhar Registro',
            icon: const Icon(Icons.share_outlined),
          ),
          if (edit)
            IconButton(
              onPressed: _excluirRegistro,
              tooltip: 'Excluir Registro',
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
        ],
      ),
      body: SafeArea(
        child: carregando
            ? const Center(child: CircularProgressIndicator())
            : _buildForm(context),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    // SingleChildScrollView + Column (mainAxisSize: min) é muito mais barato que IntrinsicHeight
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          selectedApp == null ? selecionarApp() : appSelecionado(),
          const SizedBox(height: 24),
          const Text("Nome, app ou site"),
          const SizedBox(height: 8),
          _buildTextFormField(_titleController, "Nome do app ou site"),
          const SizedBox(height: 24),
          const Text("Usuário e senha"),
          const SizedBox(height: 8),
          _buildLoginField(),
          const SizedBox(height: 12),
          PasswordFieldWithGenerator(
            controller: _passwordController,
            labelText: "Senha do Cofre",
            maxLength: 16,
          ),
          const SizedBox(height: 24),
          const Text("Observação"),
          const SizedBox(height: 8),
          _buildTextFormField(
            _descriptionController,
            "Observação",
            maxLines: 4,
          ),
          const SizedBox(height: 20),
          _buttonSalvar(context),
        ],
      ),
    );
  }

  // botão de favorito controlado pelo estado local
  Widget _favoriteButton() {
    return IconButton(
      tooltip: _isFavorite
          ? 'Remover dos favoritos'
          : 'Adicionar aos favoritos',
      onPressed: _updateFavorito,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        transitionBuilder: (child, anim) =>
            ScaleTransition(scale: anim, child: child),
        child: Icon(
          _isFavorite ? Icons.star : Icons.star_border,
          key: ValueKey(_isFavorite),
          color: _isFavorite ? Colors.amber : null,
        ),
      ),
    );
  }

  Future<void> _updateFavorito() async {
    if (register == null) return;

    final novoValor = !(_isFavorite); // toggla corretamente

    final updated = register!.copyWith(isFavorite: novoValor);

    final success = await context
        .read<RegisterController>()
        .saveAndUpdateRegisterController(updated);

    if (success) {
      setState(() {
        _isFavorite = novoValor;
        register = updated;
      });

      ShowMessager.show(
        context,
        novoValor ? 'Adicionado aos favoritos!' : 'Removido dos favoritos!',
      );
    } else {
      ShowMessager.show(context, 'Erro ao atualizar favorito.');
    }
  }

  Padding _buttonSalvar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Utils.isDarkMode(context)
                ? Theme.of(context).colorScheme.surface
                : Theme.of(context).colorScheme.primary,
          ),
          onPressed: carregando ? null : () => acaoSalvarRegistro(context),
          child: carregando
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              :  Text(
                  "Salvar",
                  style:Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Colors.white,
                  )
                ),
        ),
      ),
    );
  }
 

  Future<void> _confirmarExportacao(BuildContext context) async {
    final controller = _exportController;
    if (controller == null || register == null) return;

    final confirmou = await AuthDialogService.confirmarAcao(
      context: context,
      titulo: 'Compartilhar Registro',
      mensagem: '''⚠ ATENÇÃO!\n\nAo exportar, suas senhas ficarão visíveis em um arquivo externo.\nRecomendamos guardar esse arquivo com extremo cuidado.
        ''',
      textoConfirmar: 'Compartilhar',
    );

    if (confirmou) {
      await controller.exportSingleRegister(register!);
    }
  }

  Column selecionarApp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Selecionar um App do celular"),
        const SizedBox(height: 8),
        SizedBox(
          width: double.maxFinite,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
            icon: const Icon(Icons.apps),
            onPressed: buscandoApps ? null : _onBuscarAppPressed,
            label: const Text("Buscar app"),
          ),
        ),
      ],
    );
  }

  Future<void> _onBuscarAppPressed() async {
    setState(() => buscandoApps = true);
    await _showAppDialog(context);
    if (!mounted) return;
    setState(() => buscandoApps = false);
  }

  ColoredBox appSelecionado() {
    final app = selectedApp!;
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        leading: app.iconBytes != null
            ? Image.memory(app.iconBytes!, width: 40, height: 40)
            : const Icon(Icons.apps),
        title: Text(app.name),
        subtitle: const Text("App selecionado"),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => setState(() => selectedApp = null),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textInputAction: maxLines == 1
          ? TextInputAction.next
          : TextInputAction.newline,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildLoginField() {
    return TextFormField(
      controller: _loginController,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: "Usuário/Login",
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: ButtonCopiar(
          controller: _loginController,
          context: context,
          message: 'Usuário copiado para a área de transferência',
        ),
      ),
    );
  }

  Future<void> _showAppDialog(BuildContext context) async {
    final AppInfo? selected = await showDialog<AppInfo>(
      context: context,

      builder: (context) {
        return AlertDialog(
          titleTextStyle: Theme.of(context).textTheme.titleMedium,
          title: Text('Selecione um App'),
          contentPadding: EdgeInsets.all(4),
          elevation: 5,

          content: SizedBox(
            width: double.maxFinite,
            child: const InstalledAppsPage(),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
          ],
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        selectedApp = InstalledAppModel(
          name: selected.name,
          iconBytes: selected.icon,
          iconPath: "",
          id: 4,
        );
        _titleController.text = selected.name;
      });
    }
  }

  Future<bool> acaoSalvarRegistro(BuildContext context) async {
    setState(() => carregando = true);
    final controller = context.read<RegisterController>();

    // Mantém estado de favorito se for edição; senão usa valor atual _isFavorite
    final currentFavorite = edit
        ? (register?.isFavorite ?? false)
        : _isFavorite;

    final formQuery = RegisterModel(
      id: edit ? register!.id : const Uuid().v4(),
      name: _titleController.text.trim(),
      username: _loginController.text.trim(),
      password: _passwordController.text.trim(),
      note: _descriptionController.text.trim(),
      url: _siteController.text.trim(),
      selectedApp: selectedApp,
      isFavorite: currentFavorite,
    );

    final success = await controller.saveAndUpdateRegisterController(formQuery);

    if (!mounted) return false;
    setState(() => carregando = false);

    if (success) {
      ShowMessager.show(
        context,
        edit ? 'Registro Atualizado!' : 'Registro Salvo!',
      );
      Navigator.of(context).pop(true);
    } else {
      ShowMessager.show(context, 'Erro ao salvar Registro, tente novamente.');
    }

    return success;
  }

  Future<void> _excluirRegistro() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir este registro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true || register == null) return;

    final result = await context
        .read<RegisterController>()
        .deleteRegisterController(register!);

    if (!mounted) return;

    if (result) {
      ShowMessager.show(context, 'Registro removido');
      // pop duas vezes: fechar dialog e voltar para lista
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } else {
      ShowMessager.show(context, 'Erro ao excluir registro');
    }
  }

  void _clearInputs() {
    _titleController.clear();
    _loginController.clear();
    _passwordController.clear();
    _descriptionController.clear();
    _siteController.clear();
    Navigator.of(context).pop();
  }
}
