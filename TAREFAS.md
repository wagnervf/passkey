# Pendências do Keezy

## P0 — dados e recuperação

- [ ] **Validar a migração em um aparelho com cofre existente.** Fazer backup, atualizar o app sobre a versão antiga, testar senha e biometria, conferir os registros e reiniciar. Verificar também falhas durante a gravação da nova credencial.
- [ ] **Criar recuperação de acesso sem revelar a senha antiga.** Oferecer código de recuperação mostrado uma vez, vinculado à chave do cofre, e permitir definir nova senha. Avaliar redefinição com biometria no mesmo aparelho. Em outro aparelho, exigir também backup criptografado; sem credencial ou backup, oferecer somente reinicialização com aviso de perda dos dados. Testar rotação do código, migração e falhas intermediárias.
- [ ] **Validar o backup Keezy entre aparelhos reais.** Criar backup em um aparelho, restaurar em outro e conferir perfil, registros e reabertura do cofre após reinício.
- [ ] **Rever a exposição da senha mestra no onboarding.** A senha ainda aparece em texto e QR Code, e o PNG compartilhado permanece no diretório temporário. Reduzir cópias involuntárias e limpar o arquivo temporário. Referência: `lib/src/modules/welcome/master_password_warning_screen.dart`.
- [ ] **Validar o ciclo de vida da sessão em aparelho.** Conferir bloqueio por inatividade e segundo plano, retorno após biometria e proteção das rotas; reproduzir também o popup de sugestão de senha sem cobertura preta.

## P1 — publicação e privacidade

- [ ] **Revisar cópia de senhas para a área de transferência.** Marcar conteúdo sensível no Android, explicar o risco e definir limpeza sem apagar conteúdo copiado depois pelo usuário. Referências: `lib/src/core/utils/utils.dart`, `lib/src/core/components/button_copiar.dart`, `lib/src/core/utils/password_field_with_generator.dart`.
- [ ] **Rever permissões e privacidade para a Google Play.** Justificar ou restringir `QUERY_ALL_PACKAGES` e preparar política de privacidade e formulário de Segurança dos dados coerentes com o app.
- [ ] **Configurar assinatura de produção.** O build `release` ainda usa a chave `debug`; configurar chave de envio e validar o AAB final sem versionar credenciais. Referência: `android/app/build.gradle.kts`.
- [ ] **Preparar o iOS caso seja publicado.** Adicionar descrição de uso do Face ID em `ios/Runner/Info.plist` e testar biometria em iPhone.
- [ ] **Revisar telas sensíveis no alternador de aplicativos e capturas de tela.** Validar a proteção do cofre em segundo plano sem prejudicar a acessibilidade.

## P2 — confiabilidade e manutenção

- [ ] **Corrigir a navegação restante da autenticação.** `AuthValidadePage` ainda navega e mostra erros tanto no listener quanto no builder; revisar também fluxos antigos de `auth_page.dart` e usos de contexto após operações assíncronas.
- [ ] **Completar testes de fluxo em aparelho.** Exercitar exclusão de conta, migração de cofre antigo, restauração entre instalações e recuperação após interrupção real do processo. Os testes automatizados de CSV, cofre e autenticação já existem.
- [ ] **Resolver avisos funcionais da análise estática.** Priorizar código morto, resultados ignorados, anotações inválidas e usos de contexto após `await`; tratar a migração da API Material separadamente.
- [ ] **Revisar dependências antes da publicação.** O `pubspec.lock` já está versionado; confirmar compatibilidade e atualizar apenas o necessário.
