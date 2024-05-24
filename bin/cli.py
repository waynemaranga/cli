import click  # https://click.palletsprojects.com/en/8.1.x/
from openai import OpenAI
from pathlib import Path  # https://realpython.com/python-pathlib/
from collections import Counter
from os import getenv
from dotenv import load_dotenv
import datetime

load_dotenv()

cwd: Path = Path.cwd()  # current working dir
HOME_DIR: Path = Path.home()  # user's home dir; OS-agnostic
cmd = Path(__file__).parent  # current module's location; cmd != cwd
OPENAI_API_KEY = getenv("OPENAI_API_KEY")
counter_cwd = Counter(i for i in cwd.iterdir())
counter_cmd = Counter(j.suffix for j in cmd.iterdir())


client = OpenAI(api_key=OPENAI_API_KEY)


def respond(prompt: str, model="gpt-3.5-turbo") -> str:
    """"""
    if type(prompt) != str:
        prompt = prompt.to_string()

    completion = client.chat.completions.create(
        model=model,
        max_tokens=1024,
        temperature=0.2,
        messages=[{"role": "system", "content": "You are a chatbot."},
                  {"role": "user", "content": prompt}],  # fmt: skip
    )

    return completion.choices[0].message.content


@click.command()
@click.option("--model", default="gpt-3.5-turbo", help="MODEL")
@click.option("--input", prompt="You", help="Ask Elizabot a question")
def chat(model, input):
    # return respond(prompt=input, model=model)
    # return respond(prompt=input)
    click.echo(respond(model=model, prompt=input))


if __name__ == "__main__":
    # counter_home = Counter(j for j in HOME_DIR.iterdir())
    # print(counter_cwd)
    # print(counter_cmd)
    # print(respond("How old was Genghis Khan when he was born?"))
    chat()
