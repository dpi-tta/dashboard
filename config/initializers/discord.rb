require "discordrb"

bot_token = Rails.application.credentials.dig(:discord, :bot_token)

if bot_token.present?
  DISCORD_BOT = Discordrb::Bot.new(token: bot_token)
  DISCORD_BOT.run(true)
  Rails.logger.info("Discord bot is now running asynchronously.")
else
  Rails.logger.warn("Discord bot token missing; bot not started.")
end
