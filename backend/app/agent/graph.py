from langgraph.graph import StateGraph, END
from app.agent.state import TripState
from app.agent.nodes.intent_parser import parse_intent_node
from app.agent.nodes.search_tool import search_tool_node

def build_graph():
    graph = StateGraph(TripState)
    graph.add_node("parse_intent", parse_intent_node)
    graph.add_node("search_tool", search_tool_node)

    graph.set_entry_point("parse_intent")
    graph.add_edge("parse_intent", "search_tool")
    graph.add_edge("search_tool", END)
    
    return graph.compile()

trip_agent = build_graph()