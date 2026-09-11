from langgraph.graph import StateGraph, END
from app.agent.state import TripState
from app.services.gemini_client import get_gemini_model

def echo_node(state: TripState) -> TripState:
    """
    Placeholder first node: just sends the user message to Gemini
    and stores the reply. Confirms the graph + model wiring works.
    Will be replaced by a proper intent-parsing node in Step 4.
    """
    model = get_gemini_model()
    response = model.invoke(state["user_message"])
    state["itinerary"] = response.content
    return state

def build_graph():
    graph = StateGraph(TripState)
    graph.add_node("echo", echo_node)
    graph.set_entry_point("echo")
    graph.add_edge("echo", END)
    return graph.compile()

trip_agent = build_graph()