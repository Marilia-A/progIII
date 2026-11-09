"""Cada teste faz pedidos de verdade à API, sem uvicorn e sem o seu banco."""

ATIVIDADE = {"titulo": "Montar o circuito do LED", "categoria": "hardware"}


# Cria a conta, faz o login e devolve o cabeçalho com o token.
def entrar(cliente, email):
    cliente.post("/usuarios/", json={"nome": "Teste", "email": email, "senha": "segredo123"})
    dados = {"username": email, "password": "segredo123"}
    resposta = cliente.post("/usuarios/login", data=dados)
    return {"Authorization": "Bearer " + resposta.json()["access_token"]}


def test_criar_uma_atividade_devolve_201_com_o_titulo(cliente):
    ana = entrar(cliente, "ana@ifg.edu.br")
    resposta = cliente.post("/atividades/", json=ATIVIDADE, headers=ana)
    assert resposta.status_code == 201
    assert resposta.json()["titulo"] == "Montar o circuito do LED"


def test_sem_token_a_api_recusa(cliente):
    resposta = cliente.get("/atividades/")
    assert resposta.status_code == 401


def test_o_bruno_nao_ve_a_atividade_da_ana(cliente):
    ana = entrar(cliente, "ana@ifg.edu.br")
    bruno = entrar(cliente, "bruno@ifg.edu.br")
    cliente.post("/atividades/", json=ATIVIDADE, headers=ana)
    lista_da_ana = cliente.get("/atividades/", headers=ana).json()
    lista_do_bruno = cliente.get("/atividades/", headers=bruno).json()
    assert len(lista_da_ana) == 1
    assert lista_do_bruno == []


def test_editar_muda_o_titulo(cliente):
    ana = entrar(cliente, "ana@ifg.edu.br")
    atividade = cliente.post("/atividades/", json=ATIVIDADE, headers=ana).json()
    mudanca = {"titulo": "Programar o pisca-pisca"}
    resposta = cliente.patch(f"/atividades/{atividade['id']}", json=mudanca, headers=ana)
    assert resposta.status_code == 200
    assert resposta.json()["titulo"] == "Programar o pisca-pisca"


def test_excluir_tira_a_atividade_da_lista(cliente):
    ana = entrar(cliente, "ana@ifg.edu.br")
    atividade = cliente.post("/atividades/", json=ATIVIDADE, headers=ana).json()
    resposta = cliente.delete(f"/atividades/{atividade['id']}", headers=ana)
    assert resposta.status_code == 204
    assert cliente.get("/atividades/", headers=ana).json() == []


def test_atividade_que_nao_existe_devolve_404(cliente):
    ana = entrar(cliente, "ana@ifg.edu.br")
    resposta = cliente.get("/atividades/999", headers=ana)
    assert resposta.status_code == 404


def test_o_mesmo_titulo_duas_vezes_devolve_409(cliente):
    ana = entrar(cliente, "ana@ifg.edu.br")
    cliente.post("/atividades/", json=ATIVIDADE, headers=ana)
    resposta = cliente.post("/atividades/", json=ATIVIDADE, headers=ana)
    assert resposta.status_code == 409


def test_editar_concluida_pelo_patch_devolve_409(cliente):
    ana = entrar(cliente, "ana@ifg.edu.br")
    atividade = cliente.post("/atividades/", json=ATIVIDADE, headers=ana).json()
    resposta = cliente.patch(f"/atividades/{atividade['id']}", json={"concluida": True}, headers=ana)
    assert resposta.status_code == 409


def test_a_busca_devolve_so_o_que_combina(cliente):
    ana = entrar(cliente, "ana@ifg.edu.br")
    cliente.post("/atividades/", json=ATIVIDADE, headers=ana)
    cliente.post("/atividades/", json={"titulo": "Programar o pisca-pisca", "categoria": "programacao"}, headers=ana)
    resposta = cliente.get("/atividades/", params={"titulo": "led"}, headers=ana)
    assert len(resposta.json()) == 1
    assert resposta.json()[0]["titulo"] == "Montar o circuito do LED"


def test_senha_errada_devolve_401(cliente):
    entrar(cliente, "ana@ifg.edu.br")
    dados = {"username": "ana@ifg.edu.br", "password": "senha-errada"}
    resposta = cliente.post("/usuarios/login", data=dados)
    assert resposta.status_code == 401