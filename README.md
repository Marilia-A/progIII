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
Os testes cobrem as telas de login e cadastro, o cadastro com as recusas da API (409 e 422), o guarda de rotas, o menu lateral, o Sair, o aviso do `SessaoService`, o token guardado no aparelho (guardar, restaurar, apagar o token recusado e apagar no Sair), os quatro estados da lista de atividades (carregando, erro com Tentar de novo, vazia e a lista), o detalhe que busca pelo id (incluindo o 404 e o F5 sem id), o `AtividadeRepository` e o `AtividadeService`. Usam uma API de mentira e um aparelho de mentira, sem precisar do uvicorn.

### Estrutura do app (em camadas, como a API)
- `lib/screens/` — telas: login, cadastro, inicial, atividades (a lista), atividade (o detalhe) e perfil
- `lib/widgets/` — peças reaproveitadas: o guarda de rotas (`rota_protegida.dart`) e o menu lateral (`app_drawer.dart`)
- `lib/services/` — regras: o login, o cadastro e a sessão (`SessaoService`) e as atividades (`AtividadeService`)
- `lib/repositories/` — o acesso aos dados: `usuario_repository.dart` e `atividade_repository.dart` (os únicos que falam HTTP com a API) e `token_repository.dart` (o único que guarda o token no aparelho)
- `lib/models/` — o formato dos dados (Usuario e Atividade)
- `lib/routes.dart` — o nome de cada tela
- `lib/main.dart` — monta as camadas, restaura a sessão, os Providers e a tabela de rotas

### Navegação (rotas nomeadas)
Cada tela tem um nome em `lib/routes.dart` (`/login`, `/cadastro`, `/inicio`, `/atividades`, `/atividade`, `/perfil`) e a tabela `routes:` do `main.dart` liga o nome à tela. A navegação é feita por `pushNamed`, `pushReplacementNamed` e `pushNamedAndRemoveUntil`.

As telas inicial, atividades, atividade e perfil passam pelo guarda `RotaProtegida`: abertas sem sessão, mostram o login. Toda tela principal tem o menu lateral, com o nome e o e-mail de quem entrou, e o Sair, que apaga a sessão e limpa a pilha de telas.

### Sessão (Provider)
O `SessaoService` é um `ChangeNotifier` que fica no topo do app e chama `notifyListeners()` ao entrar e ao sair. O `main.dart` usa um `MultiProvider`: o `ChangeNotifierProvider` da sessão e o `Provider` do `AtividadeService`. Nenhuma tela recebe a sessão pelo construtor: usa `context.read` para chamar e `context.watch` para mostrar.

### Cadastro e sessão guardada
O cadastro chama `POST /usuarios/` pelas mesmas camadas do login e já entra com a conta nova. Quando a API recusa (e-mail repetido, campo inválido), a frase aparece na tela.

O token fica no aparelho (`shared_preferences`, que no navegador é o `localStorage`), num repositório próprio, o `TokenRepository`. O `main` o restaura antes de abrir o app: se a API ainda o aceita, o F5 não derruba a sessão. Se a API recusar o token (401), ele é apagado; se a API estiver fora do ar, ele continua guardado. O Sair apaga o token.

### Listagem e detalhe das atividades
A tela de atividades chama `GET /atividades/` pelas camadas do app (tela, `AtividadeService`, `AtividadeRepository`), com o token no cabeçalho, e mostra só as atividades de quem está logado. O pedido nasce uma vez, no `initState`, e um `FutureBuilder` com `ListView.builder` mostra um de quatro estados: carregando, erro (com Tentar de novo), lista vazia e a lista.

Tocar numa atividade abre o detalhe pela rota `/atividade`, com o id nos `arguments`: o detalhe busca a atividade na API (`GET /atividades/{id}`), para mostrar o dado de agora, com os mesmos estados da lista. Sem o id (depois de um F5), a tela mostra a lista.

## Regras de negócio
Em [`docs/regras-de-negocio.md`](docs/regras-de-negocio.md) — RN01 a RN05.