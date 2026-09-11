from langchain_google_genai import ChatGoogleGenerativeAI
from app.config import settings

def get_gemini_model(temperature: float = 0.4):
    """
    Returns a configured Gemini chat model instance.
    Centralizing this means every LangGraph node uses the same setup.
    """
    return ChatGoogleGenerativeAI(
        model="gemini-1.5-flash",
        google_api_key=settings.GOOGLE_API_KEY,
        temperature=temperature,
    )