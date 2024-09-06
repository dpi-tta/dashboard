module Impression::Emojiable
  extend ActiveSupport::Concern

  included do
    validates :emoji, emoji: true
  end

  def emoji_name
    Impression::EMOJIS[emoji.to_sym] || Emoji.find_by_unicode(emoji).name
  end

  POSITIVE_EMOJIS = {
    🧥: {category: "Consistency", description: "Attendance and Punctuality"},
    💼: {category: "Consistency", description: "Workplace Appearance"},
    🙌: {category: "Committed", description: "Follow-through"},
    💯: {category: "Committed", description: "Quality of Work"},
    🚀: {category: "Confidence", description: "Taking Initiative"},
    🤝: {category: "Collaboration", description: "Teamwork"},
    🛜: {category: "Collaboration", description: "Networking"},
    💪: {category: "Character", description: "Resilience"},
    🪞: {category: "Character", description: "Self-awareness"},
    🤗: {category: "Character", description: "Positive Attitude"},
    📣: {category: "Communication", description: "Communication Skills"},
    🫡: {category: "Communication", description: "Positive Response to Supervision"}
  }.freeze

  NEGATIVE_EMOJIS = {
    ⏰: {category: "Consistency", description: "Poor Time Management"},
    🧢: {category: "Consistency", description: "Unprofessional Workplace Appearance"},
    🤷: {category: "Committed", description: "Lack of Follow-through"},
    🫤: {category: "Committed", description: "Low Quality of Work"},
    🦥: {category: "Confidence", description: "Lack of Initiative"},
    🥊: {category: "Collaboration", description: "Conflict/Lack of Collaboration"},
    🙈: {category: "Collaboration", description: "Lack of Networking"},
    😬: {category: "Character", description: "Lack of Resilience"},
    😯: {category: "Character", description: "Lacking Self-awareness"},
    👿: {category: "Character", description: "Negative Attitude"},
    🙊: {category: "Communication", description: "Poor Communication Skills"},
    💢: {category: "Communication", description: "Negative Response to Supervision"}
  }.freeze

  EMOJIS = POSITIVE_EMOJIS.merge(NEGATIVE_EMOJIS).freeze
end
