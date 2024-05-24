from os import getenv
from dotenv import load_dotenv
import psycopg2
import redis
from redis import StrictRedis

load_dotenv()

POSTGRES_USERNAME = getenv("POSTGRES_")
POSTGRES_PASSWORD = getenv("POSTGRES_")
POSTGRES_HOST = getenv("POSTGRES_")
POSTGRES_PORT = getenv("POSTGRES_")
POSTGRES_DATABASE = getenv("POSTGRES_")
REDIS_HOST = getenv("REDIS_HOST")
REDIS_PORT = getenv("REDIS_PORT")
REDIS_PASSWORD = getenv("REDIS_PASSWORD")

# connection = psycopg2.connect(database=POSTGRES_DATABASE) # ... messy


class Chat:
    def __init__(self, chat_id: str) -> None:
        self.chat_id: str = chat_id
        self.redis_client: StrictRedis = redis.StrictRedis(
            host=REDIS_HOST,
            port=REDIS_PORT,
            password=REDIS_PASSWORD,
            decode_responses=True,
        )

    def __str__(self) -> str:
        return f"Chat ID: {self.chat_id}"

    def save_chat(self, message: str) -> None:
        #! can be named better, save != store i.e in-memory
        self.redis_client.rpush(self.chat_id, message)

    def get_conversation(self) -> list:
        return self.redis_client.lrange(name=self.chat_id, start=0, end=-1)

    def finalize_conversation(self) -> None:
        """Placeholder fn. for somethin mighty"""
        conversation: list = self.get_conversation()
        final_conversation: str = "\n".join(
            conversation
        )  # maybe XML transformation, like complicated joins
        self.store_in_postgres(final_conversation)
        self.redis_client.delete(self.chat_id)

    def store_in_postgres(self, final_conversation: str) -> None:
        try:
            connection = psycopg2.connect(
                dbname=POSTGRES_DATABASE,
                user=POSTGRES_USERNAME,
                password=POSTGRES_PASSWORD,
                host=POSTGRES_HOST,
                port=POSTGRES_PORT,
            )
            _cursorrr = connection.cursor()
            _cursorrr.execute(
                "INSERT INTO chats (chat_id, conversation) VALUES (%s, %s)",
                (self.chat_id, final_conversation),
            )
            connection.commit()
            _cursorrr.close()
            connection.close()
        except (Exception, psycopg2.Error) as error:
            print("Error while connecting to PostgreSQL", error)

    def count_bill(self) -> None:
        conversation = self.get_conversation()
        joined_conversation = "\n".join(conversation)
        tokens = joined_conversation.split()
        token_count = len(tokens)
        cost_per_1000_tokens = 0.02
        cost = (token_count / 1000) * cost_per_1000_tokens
        print(f"Total tokens used: {token_count}")
        print(f"Total cost in USD: ${cost:.4f}")
        return cost


if __name__ == "__main__":
    test_chat = Chat(chat_id="test_chat_id")
    test_chat.save_chat(message="Hello")
    test_chat.save_chat(message="How are you?")
    print(test_chat.get_conversation())
    test_chat.finalize_conversation()
    test_chat.count_bill()
