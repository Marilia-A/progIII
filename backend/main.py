from fastapi import FastAPI


# A instancia da aplicacao. O titulo aparece na pagina /docs.

app = FastAPI(title="API do Meu Projeto", version="0.1.0")



# O decorador diz: "esta funcao atende GET na raiz".

@app.get("/")

def raiz():

    # Devolvemos um dicionario. O FastAPI transforma em JSON sozinho.

    return {"mensagem": "A API do meu projeto esta no ar!"}


@app.get("/produtos")

def listar_produtos():

    return [{"id": 1, "nome": "Teclado"}]

@app.get("/agendamentos")

def listar_agendamentos():

    return [

        {"id": 1, "cliente": "Ana", "servico": "corte", "status": "agendado"},

        {"id": 2, "cliente": "Bruno", "servico": "barba", "status": "concluido"},

    ]
