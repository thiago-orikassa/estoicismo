# Aethor

Aplicativo mobile com backend e curadoria de conteúdo estoico.

## Estrutura do repositório
- `app/`: aplicativo Flutter (iOS/Android/Web/Desktop)
- `backend/`: API e scheduler (Node.js)
- `content/`: catálogo e seeds de conteúdo
- `docs/`: documentação de produto e execução
- `qa/`: validações e guias de qualidade

## Requisitos
- Flutter (stable)
- Node.js 20+
- Xcode (iOS) e/ou Android Studio (Android)

## Setup rápido

### App (Flutter)
```bash
cd app
flutter pub get
flutter run
```

### Backend (Node)
```bash
cd backend
npm install
npm start
```

### Testes
```bash
# Backend
cd backend
npm test

# Flutter
cd app
flutter test

# QA conteúdo
node qa/validate_seed.mjs
```

## CI
O pipeline principal está em `.github/workflows/qa.yml` e roda em PRs e pushes na `main`.
