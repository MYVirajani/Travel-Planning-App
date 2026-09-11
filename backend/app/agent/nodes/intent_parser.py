from app.agent.state import TripState
from app.services.gemini_client import get_gemini_model, parse_json_response

INTENT_PROMPT = """You are a travel planning assistant. Extract structured trip details from the user's message.

Respond ONLY with a JSON object, no preamble, no markdown fences. Use this exact schema:
{{
  "destination": string or null,
  "start_date": string or null,
  "end_date": string or null,
  "budget": string or null,
  "interests": array of strings (empty array if none mentioned)
}}

User message: "{message}"
"""

def parse_intent_node(state: TripState) -> TripState:
    """
    First real node in the pipeline: converts free-text user input
    into structured fields the rest of the graph can act on.
    """
    model = get_gemini_model(temperature=0.1)  
    prompt = INTENT_PROMPT.format(message=state["user_message"])
    response = model.invoke(prompt)
    parsed = parse_json_response(response.content)

    state["destination"] = parsed.get("destination")
    state["start_date"] = parsed.get("start_date")
    state["end_date"] = parsed.get("end_date")
    state["budget"] = parsed.get("budget")
    state["interests"] = parsed.get("interests", [])
    return state