# Checklist de Robótica

Projeto da disciplina Programação para Web III: uma API FastAPI (`backend/`) e um app Flutter (`frontend/`) para um checklist de atividades de robótica educacional.

## A API (backend)

Detalhes completos em [`backend/README.md`](backend/README.md).

```
cd backend
poetry install
poetry run alembic upgrade head
poetry run uvicorn app.main:app --reload
```
Abra http://127.0.0.1:8000/docs

## Como rodar o app (frontend)

Suba a API antes (ela precisa estar na porta 8000). Em outro terminal:
```
cd frontend
flutter pub get
flutter run -d chrome
```
Entre com uma conta criada pelo `POST /usuarios/` do /docs.

### Testes
```
cd frontend
flutter test
```

### Estrutura do app (em camadas, como a API)
- `lib/screens/` — telas: login, cadastro e inicial
- `lib/services/` — regras: o login e o token da sessão
- `lib/repositories/` — o único que fala HTTP com a API
- `lib/models/` — o formato dos dados (Usuario)
- `lib/main.dart` — monta as camadas

## Regras de negócio
Em [`docs/regras-de-negocio.md`](docs/regras-de-negocio.md) — RN01 a RN05.