# App Scaffold (Sprint 1-2)

Este diretório contém a base Flutter do app mobile com:
- navegação principal
- Home (citação + prática + check-in)
- Histórico (30 dias)
- Favoritos
- Ajustes

## Estrutura criada
- lib/features/* com camadas presentation/domain/data por feature
- `lib/main.dart` com shell de navegação
- `lib/app_state.dart` para orquestração simples de estado e chamadas de API
- integração com backend local em `127.0.0.1:8787` (iOS) e `10.0.2.2:8787` (Android emulator)

## Próximos passos
- Instalar Flutter no ambiente e rodar:
```bash
cd /Users/thiagoorikassa/Documents/Estoicismo/app
flutter pub get
flutter run
```
- Conectar settings reais (autor preferido, horário de notificação, temas).
- Evoluir gerenciamento de estado para Riverpod conforme roadmap.
