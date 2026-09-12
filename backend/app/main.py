from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.agent.graph import trip_agent


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

@app.post("/test-agent")
def test_agent(payload: dict):
    result = trip_agent.invoke({"user_message": payload["message"]})
    return {
        "destination": result.get("destination"),
        "start_date": result.get("start_date"),
        "end_date": result.get("end_date"),
        "budget": result.get("budget"),
        "interests": result.get("interests"),
        "itinerary": result.get("itinerary"),
    }