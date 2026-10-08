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
Os testes cobrem as telas de login e cadastro, o guarda de rotas, o menu lateral, o Sair e o aviso do `SessaoService`.

### Estrutura do app (em camadas, como a API)
- `lib/screens/` — telas: login, cadastro, inicial, atividades e perfil
- `lib/widgets/` — peças reaproveitadas: o guarda de rotas (`rota_protegida.dart`) e o menu lateral (`app_drawer.dart`)
- `lib/services/` — regras: o login e a sessão (`SessaoService`)
- `lib/repositories/` — o único que fala HTTP com a API
- `lib/models/` — o formato dos dados (Usuario)
- `lib/routes.dart` — o nome de cada tela
- `lib/main.dart` — monta as camadas, o Provider e a tabela de rotas

### Navegação (rotas nomeadas)
Cada tela tem um nome em `lib/routes.dart` (`/login`, `/cadastro`, `/inicio`, `/atividades`, `/perfil`) e a tabela `routes:` do `main.dart` liga o nome à tela. A navegação é feita por `pushNamed`, `pushReplacementNamed` e `pushNamedAndRemoveUntil`.

As telas inicial, atividades e perfil passam pelo guarda `RotaProtegida`: abertas sem sessão, mostram o login. Toda tela protegida tem o menu lateral, com o nome e o e-mail de quem entrou, e o Sair, que apaga a sessão e limpa a pilha de telas. A tela de atividades é um lugar reservado por enquanto.

### Sessão (Provider)
O `SessaoService` é um `ChangeNotifier` que fica no topo do app (`ChangeNotifierProvider` no `main.dart`) e chama `notifyListeners()` ao entrar e ao sair. Nenhuma tela recebe a sessão pelo construtor: usa `context.read` para chamar e `context.watch` para mostrar.

O token fica só na memória: recarregar a página (F5) sai do app e cai no login. Guardá-lo no aparelho é o próximo passo.

## Regras de negócio
Em [`docs/regras-de-negocio.md`](docs/regras-de-negocio.md) — RN01 a RN05.