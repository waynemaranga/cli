-- Configurations for the TUI/CLI app
-- 1. Start
-- 2. Prompt
-- 3. Response
-- 4. etc
-- 5. exit

Text_config = {
    start_message = {
        color = "green",
        text = "Chat with Elizabot:"
    },
    user_message = {
        color = "blue",
        prefix = "You: "
    },
    bot_message = {
        color = "red",
        prefix = "Bot: "
    },
    end_message = {
        color = "yellow",
        text = "Exiting chat. Goodbye!"
    }
}
