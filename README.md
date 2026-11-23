# Checklist de Robótica

Projeto da disciplina Programação para Web III: uma API FastAPI (`backend/`) e um app Flutter (`frontend/`) para um checklist de atividades de robótica educacional.

## No ar
- O app: https://SEU-APP.onrender.com
- A API: https://progiii.onrender.com/docs

A API dorme depois de 15 minutos sem uso: o primeiro acesso leva cerca de 1 minuto.

### Como está no ar (Render)
São três serviços, criados nesta ordem, porque cada um precisa do endereço do anterior:

| A peça | No Render | Root Directory | As variáveis |
|---|---|---|---|
| O banco | Postgres (Free) | — | nenhuma |
| A API | Web Service, Language: Docker | `backend` | `DATABASE_URL` (o endereço interno do banco, com o começo trocado para `postgresql+psycopg://`), `SECRET_KEY` (Generate) e `ENDERECO_DO_APP` (o endereço do app, sem barra no fim) |
| O app | Static Site | `frontend` | `API_URL` (o endereço da API, sem barra no fim) |

- **A API** é construída pelo `backend/Dockerfile`: Python 3.13, os pacotes do Poetry sem os de teste e, ao ligar, `alembic upgrade head` (cria ou atualiza as tabelas) e o uvicorn na porta que o Render indica (`PORT`). O `backend/.dockerignore` deixa de fora da imagem o `.env`, os bancos locais e os testes.
- **O app** é construído com o Build Command `git clone https://github.com/flutter/flutter.git -b stable --depth 1 sdk && sdk/bin/flutter build web --dart-define=API_URL=$API_URL` e o Publish Directory `build/web`. O endereço da API vem do `--dart-define`: o `String.fromEnvironment('API_URL')` do `usuario_repository.dart`; sem ele, o app usa `http://127.0.0.1:8000`, como sempre.
- **O CORS**: a API aceita as portas do localhost e o endereço que estiver em `ENDERECO_DO_APP`. Na sua máquina essa variável não existe, e nada muda.
- **Nenhum segredo no Git nem na imagem**: a `SECRET_KEY` e a senha do banco ficam só na tela Environment de cada serviço.

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

### Estrutura do app (em camadas, como a API)
- `lib/screens/` — telas: login, cadastro, inicial, atividades (a lista), atividade (o detalhe), formulário (criar e editar) e perfil
- `lib/widgets/` — peças reaproveitadas: o guarda de rotas (`rota_protegida.dart`), o menu lateral (`app_drawer.dart`) e o aviso de toda ação (`aviso.dart`)
- `lib/services/` — regras: o login, o cadastro e a sessão (`SessaoService`) e as atividades (`AtividadeService`)
- `lib/repositories/` — o acesso aos dados: `usuario_repository.dart` e `atividade_repository.dart` (os únicos que falam HTTP com a API) e `token_repository.dart` (o único que guarda o token no aparelho)
- `lib/models/` — o formato dos dados (Usuario e Atividade)
- `lib/routes.dart` — o nome de cada tela
- `lib/main.dart` — monta as camadas, restaura a sessão, os Providers e a tabela de rotas

### Navegação (rotas nomeadas)
Cada tela tem um nome em `lib/routes.dart` (`/login`, `/cadastro`, `/inicio`, `/atividades`, `/atividade`, `/formulario`, `/perfil`) e a tabela `routes:` do `main.dart` liga o nome à tela. A navegação é feita por `pushNamed`, `pushReplacementNamed` e `pushNamedAndRemoveUntil`.

As telas inicial, atividades, atividade, formulário e perfil passam pelo guarda `RotaProtegida`: abertas sem sessão, mostram o login. Toda tela principal tem o menu lateral, com o nome e o e-mail de quem entrou, e o Sair, que apaga a sessão e limpa a pilha de telas.

### Sessão (Provider)
O `SessaoService` é um `ChangeNotifier` que fica no topo do app e chama `notifyListeners()` ao entrar e ao sair. O `main.dart` usa um `MultiProvider`: o `ChangeNotifierProvider` da sessão e o `Provider` do `AtividadeService`. Nenhuma tela recebe a sessão pelo construtor: usa `context.read` para chamar e `context.watch` para mostrar.

### Cadastro e sessão guardada
O cadastro chama `POST /usuarios/` pelas mesmas camadas do login e já entra com a conta nova. Quando a API recusa (e-mail repetido, campo inválido), a frase aparece na tela.

O token fica no aparelho (`shared_preferences`, que no navegador é o `localStorage`), num repositório próprio, o `TokenRepository`. O `main` o restaura antes de abrir o app: se a API ainda o aceita, o F5 não derruba a sessão. Se a API recusar o token (401), ele é apagado; se a API estiver fora do ar, ele continua guardado. O Sair apaga o token.

### Listagem e detalhe das atividades
A tela de atividades chama `GET /atividades/` pelas camadas do app (tela, `AtividadeService`, `AtividadeRepository`), com o token no cabeçalho, e mostra só as atividades de quem está logado. O pedido nasce uma vez, no `initState`, e um `FutureBuilder` com `ListView.builder` mostra um de quatro estados: carregando, erro (com Tentar de novo), lista vazia e a lista.

Tocar numa atividade abre o detalhe pela rota `/atividade`, com o id nos `arguments`: o detalhe busca a atividade na API (`GET /atividades/{id}`), para mostrar o dado de agora, com os mesmos estados da lista. Sem o id (depois de um F5), a tela mostra a lista.

### Criar, editar e excluir pelo app
O app cria, edita e exclui atividades pelas camadas (tela, `AtividadeService`, `AtividadeRepository`), com o token no cabeçalho: `POST /atividades/`, `PATCH /atividades/{id}` e `DELETE /atividades/{id}`. Um formulário só (`FormularioScreen`) serve para criar (aberto pelo + da lista, vazio) e para editar (aberto pelo Editar do detalhe, já preenchido), com título, descrição, categoria (dropdown) e data prevista (seletor de data). O campo `concluida` não vai no formulário por causa da RN02.

A validação acontece nas duas pontas: o `validator` de cada campo antes de enviar (título obrigatório, categoria escolhida, descrição até 500 caracteres), e a API, que confere tudo de novo e recusa com 422 (campo inválido) ou 409 (RN01, título repetido; RN03, atividade concluída não pode ser excluída). A frase da API aparece em vermelho, e a tela fica aberta. Excluir pede confirmação num diálogo (`showDialog`). Depois de cada operação, a tela fecha com `true`, e a lista pede as atividades de novo.

### Busca e avisos
A lista tem um campo de busca pelo título. O Enter manda a busca pelas camadas (tela, `AtividadeService`, `AtividadeRepository`) e o endereço ganha o `?titulo=`: quem filtra é a API, no banco (`ilike`, sem ligar para maiúsculas). Busca vazia (ou o x no fim do campo) volta a lista inteira, e a lista vazia diz o que foi procurado.

Toda ação que muda dados mostra um aviso (`SnackBar`, em `lib/widgets/aviso.dart`): verde em "Atividade salva" e "Atividade excluída", vermelho em "Não deu para salvar" e "Não deu para excluir", além da frase da API na tela.

## Checklist das seis funcionalidades mínimas
- [x] **Autenticação** — login e cadastro (`login_screen.dart`, `cadastro_screen.dart`; API `/usuarios/`, `/usuarios/login`), senha com bcrypt e token JWT; sem sessão, as telas protegidas mostram o login. *Prova:* sair, tentar abrir a lista e entrar de novo.
- [x] **CRUD** — o + da lista cria, o detalhe edita e exclui (`formulario_screen.dart`, `atividade_screen.dart`; API `POST`, `GET`, `PATCH` e `DELETE /atividades/`). *Prova:* criar, editar e excluir uma atividade.
- [x] **Relacionamento com o usuário** — o `dono_id` vem do token, e cada um vê só as suas (RN05). *Prova:* entrar com outra conta: a lista é outra.
- [x] **Validação nas duas pontas** — o `validator` no formulário (título obrigatório, categoria escolhida) e a API, que recusa com 422 (campo inválido) e 409 (RN01 título repetido, RN03 atividade concluída). *Prova:* salvar com o título vazio, e salvar um título que já existe.
- [x] **Busca/filtro** — o campo de busca da lista, pelo `?titulo=` da API. *Prova:* uma busca que acha e uma que não acha.
- [x] **Feedback visual** — a faixa verde ou vermelha de toda ação. *Prova:* salvar, uma recusa, excluir.

## Testes
Não precisa da API no ar nem do navegador.

Na pasta `backend/`:
```
poetry install
poetry run pytest
```
São 10 testes de endpoint (pytest + `TestClient`), num banco SQLite só do teste (`teste.db`, criado e apagado a cada teste): criar (201), sem token (401), um usuário não vê a atividade do outro, editar, excluir, 404, título repetido (409), `concluida` pelo PATCH (409), a busca e a senha errada (401).

Na pasta `frontend/`:
```
flutter test
```
São 53 testes de widget e de unidade, com uma API e um aparelho de mentira: login, cadastro, guarda de rotas, menu, sessão guardada, os quatro estados da lista, o detalhe, o formulário (criar, editar, validação e 409), o excluir, a busca, os avisos, e os arquivos `test/formulario_test.dart` (as frases do `validator`) e `test/lista_test.dart` (a lista com a resposta da API).

## Versões

Cada tag marca o merge na `main` que fechou uma etapa da disciplina.

| Tag | Conteúdo |
|---|---|
| `v0.1` | Encontros 1 e 2: ficha do projeto, Poetry, FastAPI e o primeiro endpoint |
| `v0.2` | Encontros 3 a 5: CRUD com schemas, PostgreSQL atrás do repository e regras de negócio no service |
| `v0.3` | Encontro 6: cadastro com bcrypt, login com JWT e rotas protegidas |
| `v1.0` | Checkpoint 1 (encontro 7): API completa, com dono das atividades, busca e filtro, migrações Alembic e validação em português |
| `v1.1` | Encontro 8: o app Flutter nasce, com o login de verdade em camadas e o CORS |
| `v1.2` | Encontro 9: rotas nomeadas, guarda de rotas, sessão no Provider, menu lateral e perfil |
| `v1.3` | Encontro 10: cadastro pelo app e sessão guardada no aparelho |
| `v1.4` | Encontro 11: listagem e detalhe com dados reais |
| `v1.5` | Encontro 12: criar, editar e excluir pelo app |
| `v2.0` | Checkpoint 2 e encontro 14: busca no app, avisos, checklist das seis funcionalidades e testes automatizados |
| `v2.1` | Encontro 15: Dockerfile, CORS e endereço da API configuráveis para a nuvem |

## Regras de negócio
Em [`docs/regras-de-negocio.md`](docs/regras-de-negocio.md) — RN01 a RN05.