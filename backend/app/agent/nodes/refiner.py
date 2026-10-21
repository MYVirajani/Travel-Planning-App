import json
from app.agent.state import TripState
from app.services.gemini_client import get_gemini_model, parse_json_response

REFINE_PROMPT = """You are a travel planner revising an existing itinerary based on user feedback.

Existing itinerary (JSON):
{previous_itinerary}

User's requested change:
"{user_message}"

Respond ONLY with a JSON object, no preamble, no markdown fences. Use this exact schema:
{{
  "days": [
    {{
      "day_number": 1,
      "title": "short descriptive title for the day",
      "activities": [
        {{
          "time_of_day": "Morning" | "Afternoon" | "Evening",
          "place_name": "specific real place name",
          "description": "1-2 sentence description"
        }}
      ]
    }}
  ]
}}

Rules:
- Apply only the requested change; keep every other day exactly as it was
- Keep the same number of days and the same overall structure
- If the request targets a specific day (e.g. "day 2"), only that day's activities should differ from the original
- Return the FULL itinerary (all days), not just the changed day
"""

def refine_itinerary_node(state: TripState) -> TripState:
    """
    Revises the previous structured itinerary based on the user's
    follow-up message, without re-running search or intent parsing.
    """
    model = get_gemini_model(temperature=0.5)
    prompt = REFINE_PROMPT.format(
        previous_itinerary=json.dumps(state.get("previous_itinerary", [])),
        user_message=state["user_message"],
    )
    response = model.invoke(prompt)
    parsed = parse_json_response(response.content)
    state["itinerary"] = parsed.get("days", [])
    return state