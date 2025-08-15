class DiscordService
  def initialize(cohort = nil)
    @bot = DISCORD_BOT
    @cohort = cohort
  end

  def fetch_channels(discord_server_id)
    return [] if discord_server_id.blank?

    server = @bot.servers[discord_server_id.to_i]
    return [] unless server

    server.channels
          .select { |ch| ch.type == 0 }
          .map { |ch| { id: ch.id.to_s, name: format_name(ch.name) } }
  rescue => e
    Rails.logger.error("[DiscordService#fetch_channels] Error: #{e.message}")
    []
  end

  def fetch_channel(server_id, channel_id)
    channel = @bot.channel(channel_id.to_i)
    return nil unless channel && channel.type == 0

    {
      id: channel.id.to_s,
      name: format_name(channel.name),
      topic: channel.topic
    }
  rescue => e
    Rails.logger.error("[DiscordService#fetch_channel] Error: #{e.message}")
    nil
  end

  def fetch_recent_messages(channel_id, limit = 10)
    channel = @bot.channel(channel_id.to_i)
    return [] unless channel && channel.type == 0

    channel.history(limit).map do |msg|
      {
        id: msg.id.to_s,
        author_id: msg.author.id.to_s,
        author_username: msg.author.username,
        content: msg.content,
        timestamp: msg.timestamp
      }
    end
  rescue => e
    Rails.logger.error("[DiscordService#fetch_recent_messages] Error: #{e.message}")
    []
  end

  def send_dm(discord_id, message)
    return if discord_id.blank? || message.blank? || @cohort.blank?

    user = @bot.user(discord_id.to_i)
    return unless user

    dm_channel = user.dm

    dm_channel.send_message(message)
  rescue => e
    Rails.logger.error("[DiscordService#send_dm] Error: #{e.message}")
    raise e
  end

  # TODO: Find a way to optimize this to reduce O(N)^2 before implementing
  # def fetch_server_recent_messages(discord_server_id, per_channel_limit = 5)
  #   return [] if discord_server_id.blank?

  #   server = DISCORD_BOT.server(discord_server_id.to_i)
  #   return [] unless server

  #   all_messages = []

  #   server.channels.select { |ch| ch.type == 0 }.each do |ch|
  #     begin
  #       recent_msgs = ch.history(per_channel_limit).map do |msg|
  #         {
  #           channel_id: ch.id.to_s,
  #           channel_name: format_name(ch.name),
  #           id: msg.id.to_s,
  #           author_id: msg.author.id.to_s,
  #           author_username: msg.author.username,
  #           content: msg.content,
  #           timestamp: msg.timestamp
  #         }
  #       end
  #       all_messages.concat(recent_msgs)
  #     rescue => e
  #       Rails.logger.error("[DiscordService#fetch_server_recent_messages] Error in channel #{ch.id}: #{e.message}")
  #     end
  #   end

  #   all_messages.sort_by { |m| m[:timestamp] }.reverse
  # end

  def top_contributors(channel_id, limit = 50)
    recent_msgs = fetch_recent_messages(channel_id, limit)
    group_and_sort_contributors(recent_msgs)
  end

  # TODO: Find a way to optimize this to reduce O(N)^2 before implementing
  # def top_server_contributors(discord_server_id, per_channel_limit = 20) # We can reduce this number so it can be faster
  #   all_msgs = fetch_server_recent_messages(discord_server_id, per_channel_limit)
  #   group_and_sort_contributors(all_msgs)
  # end

  def send_message(channel_id, content)
    return if channel_id.blank? || content.blank?

    channel = @bot.channel(channel_id.to_i)
    channel&.send_message(content)
  rescue => e
    Rails.logger.error("[DiscordService#send_message] Error: #{e.message}")
    raise e
  end

  private

  def format_name(name)
    name.downcase.gsub("-", " ").titleize
  end

  def group_and_sort_contributors(messages)
    groups = messages.group_by { |m| m[:author_id] }
    groups.map do |author_id, msgs|
      {
        author_id: author_id,
        author_username: msgs.first[:author_username],
        message_count: msgs.size
      }
    end.sort_by { |c| -c[:message_count] }
  end
end
