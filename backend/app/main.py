from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.routes.agent import router as agent_router

app = FastAPI(title="Travel Planning Agent API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
def startup_event():
    settings.validate()

@app.get("/health")
def health_check():
    return {"status": "ok"}

app.include_router(agent_router)