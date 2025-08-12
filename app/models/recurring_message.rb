# == Schema Information
#
# Table name: recurring_messages
#
#  id              :uuid             not null, primary key
#  days_of_week    :text             default([]), is an Array
#  frequency       :string           default("weekly"), not null
#  message_content :text
#  scheduled_time  :time
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  channel_id      :string
#  cohort_id       :uuid
#  job_id          :string
#
# Indexes
#
#  index_recurring_messages_on_cohort_id  (cohort_id)
#
# Foreign Keys
#
#  fk_rails_...  (cohort_id => cohorts.id)
#
class RecurringMessage < ApplicationRecord
  DAYS = %w[monday tuesday wednesday thursday friday saturday sunday].freeze
  FREQUENCIES = %w[weekly biweekly monthly].freeze

  belongs_to :cohort

  validates :message_content, presence: true
  validates :scheduled_time, presence: true
  validates :frequency, inclusion: { in: FREQUENCIES }
  validates :days_of_week, presence: true, inclusion: { in: DAYS, message: "%{value} is not a valid day" }, length: { minimum: 1 }

  before_destroy :cancel_previous_job

  def deliver_message
    DiscordService.new.send_message(channel_id, message_content)

    next_occurrence = calculate_next_occurrence
    if next_occurrence
      DiscordMessageJob.set(wait_until: next_occurrence).perform_later(id)
    end
  end

  def schedule_discord_message
    cancel_previous_job
    next_occurrence = calculate_next_occurrence
    return unless next_occurrence

    job = DiscordMessageJob
          .set(wait_until: next_occurrence)
          .perform_later(id)
    update_column(:job_id, job.provider_job_id) if job.respond_to?(:provider_job_id)
  end

  private

  def cancel_previous_job
    return if job_id.blank?

    SolidQueue::Job.find_by(id: job_id)&.discard
  end

  def calculate_next_occurrence
    now = Time.current
    target_seconds = scheduled_time.seconds_since_midnight

    weekdays = days_of_week.map { |day| Date::DAYNAMES.index(day.capitalize) }.compact

    period = case frequency
    when "weekly"
               1.week
    when "biweekly"
               2.weeks
    else
               nil
    end

    candidates = weekdays.map do |weekday|
      days_ahead = (weekday - now.wday) % 7
      candidate = now.beginning_of_day + days_ahead.days + target_seconds.seconds

      if frequency == "monthly"
        candidate = candidate < now ? candidate.next_month : candidate
      else
        candidate = candidate <= now ? candidate + period : candidate
      end

      candidate
    end

    candidates.min
  end
end
