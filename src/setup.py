import os
from datetime import datetime

from langchain_community.llms.ollama import Ollama

"""
This is meant to be run interactively as part of an ipython instance.
To use, run `%run setup.py` in an ipython interpreter and query the LLM using `ask({your_question})`
"""

llm = Ollama(model="kuzco")
qa_sep = "-----------------------------\n"
query_sep = "=============================\n\n"


def ask(query: str) -> None:
    today = datetime.now().date()

    response = llm.invoke(query)
    with open(os.path.join(".", "transcripts", f"{today}.txt"), "at") as f:
        f.write(f"[{datetime.now()}]\n" + query + "\n")
        f.write(qa_sep)
        f.write(response + "\n")
        f.write(query_sep)
    print(response)
