from app.agent.state import TripState
from app.services.search_client import search_web

def search_tool_node(state: TripState) -> TripState:
    """
    Uses the structured intent from parse_intent_node to run targeted
    searches: attractions/things-to-do always, plus hotels if a budget
    was given. Results are stored for the itinerary synthesis node.
    """
    destination = state.get("destination")
    if not destination:
        state["search_results"] = []
        return state

    interests = state.get("interests") or []
    interest_str = ", ".join(interests) if interests else "top attractions"

    queries = [f"best things to do in {destination}: {interest_str}"]

    if state.get("budget"):
        queries.append(f"hotels in {destination} under {state['budget']}")

    all_results = []
    for query in queries:
        all_results.extend(search_web(query, max_results=4))

    state["search_results"] = all_results
    return state