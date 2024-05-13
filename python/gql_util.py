import json
from graphql import build_schema, validate, graphql_sync


def fetch_and_validate(db_connection, schema_file_path="schema.graphql"):

    try:
        # ...fetch conversations from the database
        cursor = db_connection.cursor()
        cursor.execute("SELECT id, start_time, end_time, messages FROM conversations")
        conversations = cursor.fetchall()

        # ... convert to GraphQL schema format
        graphql_conversations = []
        for conv in conversations:
            graphql_conversations.append(
                {
                    "id": conv[0],
                    "startTime": conv[1].isoformat(),  # reformat datetime for GraphQL
                    "endTime": conv[2].isoformat(),
                    "messages": json.loads(conv[3]),  # load the JSON messages
                }
            )

        # ...load & build schema
        with open(schema_file_path, "r") as file:  # PylintW1514:unspecified-encoding
            schema_str = file.read()
        schema = build_schema(schema_str)

        # init a simple query to fetch conversations
        query_str = """
        {
            conversations {
                id
                startTime
                endTime
                messages {
                    user
                    content
                    timestamp
                }
            }
        }
        """

        # ...validate and execute the query
        validation_errors = validate(
            schema, query_str
        )  # check TypeError in arg. assignment with stricter Pylint
        if validation_errors:
            raise Exception(
                f"Validation errors: {validation_errors}"
            )  # exception is vague/too general
        else:
            result = graphql_sync(
                schema, query_str, root_value={"conversations": graphql_conversations}
            )
            print("GraphQL Data:", json.dumps(result.data, indent=2))

    except (
        Exception
    ) as e:  # exception is too general i.e PylintW0719:broad-exception-raised
        print(f"Error: {e}")
