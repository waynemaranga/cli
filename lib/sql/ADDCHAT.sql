CREATE TABLE IF NOT EXISTS conversations (
    id SERIAL PRIMARY KEY,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    messages JSONB NOT NULL
);