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
Crie uma conta pela tela de cadastro do app (ou pelo `POST /usuarios/` do /docs) e entre com ela.

### Testes
```
cd frontend
flutter test
```
Os testes cobrem as telas de login e cadastro, o cadastro com as recusas da API (409 e 422), o guarda de rotas, o menu lateral, o Sair, o aviso do `SessaoService` e o token guardado no aparelho (guardar, restaurar, apagar o token recusado e apagar no Sair). Usam uma API de mentira e um aparelho de mentira, sem precisar do uvicorn.

### Estrutura do app (em camadas, como a API)
- `lib/screens/` — telas: login, cadastro, inicial, atividades e perfil
- `lib/widgets/` — peças reaproveitadas: o guarda de rotas (`rota_protegida.dart`) e o menu lateral (`app_drawer.dart`)
- `lib/services/` — regras: o login, o cadastro e a sessão (`SessaoService`)
- `lib/repositories/` — o acesso aos dados: `usuario_repository.dart` (o único que fala HTTP com a API) e `token_repository.dart` (o único que guarda o token no aparelho)
- `lib/models/` — o formato dos dados (Usuario)
- `lib/routes.dart` — o nome de cada tela
- `lib/main.dart` — monta as camadas, restaura a sessão, o Provider e a tabela de rotas

### Navegação (rotas nomeadas)
Cada tela tem um nome em `lib/routes.dart` (`/login`, `/cadastro`, `/inicio`, `/atividades`, `/perfil`) e a tabela `routes:` do `main.dart` liga o nome à tela. A navegação é feita por `pushNamed`, `pushReplacementNamed` e `pushNamedAndRemoveUntil`.

As telas inicial, atividades e perfil passam pelo guarda `RotaProtegida`: abertas sem sessão, mostram o login. Toda tela protegida tem o menu lateral, com o nome e o e-mail de quem entrou, e o Sair, que apaga a sessão e limpa a pilha de telas. A tela de atividades é um lugar reservado por enquanto.

### Sessão (Provider)
O `SessaoService` é um `ChangeNotifier` que fica no topo do app (`ChangeNotifierProvider` no `main.dart`) e chama `notifyListeners()` ao entrar e ao sair. Nenhuma tela recebe a sessão pelo construtor: usa `context.read` para chamar e `context.watch` para mostrar.

### Cadastro e sessão guardada
O cadastro chama `POST /usuarios/` pelas mesmas camadas do login e já entra com a conta nova. Quando a API recusa (e-mail repetido, campo inválido), a frase aparece na tela.

O token fica no aparelho (`shared_preferences`, que no navegador é o `localStorage`), num repositório próprio, o `TokenRepository`. O `main` o restaura antes de abrir o app: se a API ainda o aceita, o F5 não derruba a sessão. Se a API recusar o token (401), ele é apagado; se a API estiver fora do ar, ele continua guardado. O Sair apaga o token.

## Regras de negócio
Em [`docs/regras-de-negocio.md`](docs/regras-de-negocio.md) — RN01 a RN05.