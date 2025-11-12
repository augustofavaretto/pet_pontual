# Pet Pontual

Aplicativo Flutter para organização da rotina dos pets. O usuário cadastra seus animais, registra eventos (banhos, vacinas, consultas, etc.), anexa observações e acompanha lembretes de próximos compromissos. O app nasceu para facilitar o dia a dia de tutores que precisam registrar serviços prescritos pelos profissionais e manter o histórico sempre à mão.

## Principais recursos

- Cadastro completo de pets com foto, tipo, raça e data de nascimento.
- Linha do tempo de eventos por pet (banho, tosa, vacina, consulta, alimentação e mais).
- Catálogo de serviços por tipo de evento para seleção rápida.
- Persistência local com SQLite (via `sqflite`/`sqflite_common_ffi`) e dados de exemplo opcionais.
- Arquitetura MVVM com Provider e injeção de dependência, facilitando testes e manutenção.

## Requisitos

- Flutter 3.35+ e Dart 3.9+ configurados no `PATH`.
- Emulador Android/iOS ou dispositivo físico desbloqueado para desenvolvimento.
- (Opcional) Xcode e CocoaPods para builds iOS.

## Como configurar e executar

```bash
# 1. Instale as dependências
flutter pub get

# 2. Rode o app em um emulador/dispositivo
flutter run
```

> Dica: o `PetController` carrega uma base de demonstração na primeira execução. Defina `loadSampleData: false` ao instanciá-lo (por exemplo em testes) para iniciar com um banco limpo.

### Testes e análise estática

```bash
# Executa testes de unidade e widget
flutter test

# Analisa o código (lint/dart analyzer)
flutter analyze
```

## Arquitetura e organização

- `lib/controllers/`: `PetController` funciona como ViewModel e expõe o estado para a UI.
- `lib/data/`: camadas de persistência (`PetRepository`, `SqlitePetRepository`).
- `lib/models/`: modelos imutáveis (`Pet`, `PetEvent`) e regras de transformação.
- `lib/screens/`: telas (Home, formulário de pet, formulário de evento, detalhes).
- `lib/navigation/`: rotas centralizadas (`AppRouter`).
- `assets/`: imagens e recursos estáticos.
- `test/`: testes de unidade/widget usando repositórios fakes e Provider para DI.

O `MultiProvider` definido em `lib/main.dart` injeta o `PetController` na árvore de widgets. As telas consomem o estado via `context.watch`/`context.read`, mantendo a UI desacoplada da persistência. Para substituir o backend (por exemplo, usar API/Firestore), basta fornecer outra implementação de `PetRepository`.

## Personalização

- Adicione novas seções ao catálogo de serviços em `lib/screens/add_pet_event_page.dart`.
- Ajuste cores e fontes em `lib/theme/app_colors.dart`.
- Inclua assets personalizados configurando o `pubspec.yaml`.

---

Qualquer dúvida ou sugestão, fique à vontade para abrir uma issue ou contribuir com um pull request. Boas contribuições! :)
