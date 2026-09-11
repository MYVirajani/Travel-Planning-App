from langgraph.graph import StateGraph, END
from app.agent.state import TripState
from app.agent.nodes.intent_parser import parse_intent_node

def build_graph():
    graph = StateGraph(TripState)
    graph.add_node("parse_intent", parse_intent_node)
    graph.set_entry_point("parse_intent")
    graph.add_edge("parse_intent", END)
    return graph.compile()

trip_agent = build_graph()