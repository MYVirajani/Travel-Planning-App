from app.agent.state import TripState

def classify_request_node(state: TripState) -> TripState:
    """
    Decides whether this turn is a refinement of an existing itinerary
    or a brand-new trip request. Simple rule for now: if the client
    sent a previous_itinerary, treat this as a refinement. Good enough
    since the Flutter client only sends it when continuing a plan;
    can be upgraded to an LLM classification later if needed.
    """
    state["is_refinement"] = bool(state.get("previous_itinerary"))
    return state