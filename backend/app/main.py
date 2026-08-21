from fastapi import FastAPI
from .atividade import controller as atividade_controller

app = FastAPI(title="API Checklist de Robotica", version="0.1.0")
app.include_router(atividade_controller.router)