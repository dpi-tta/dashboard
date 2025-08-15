module FeedbackReport::Deliverable
  extend ActiveSupport::Concern

  def send_report
    Rails.logger.info("[FeedbackReportDelivery] Attempting to send report #{id} for #{enrollment.user.name}")

    if enrollment.user.discord_id.blank?
      error_message = "User #{enrollment.user.name} does not have a Discord ID set. Report #{id} cannot be sent."
      Rails.logger.warn("[FeedbackReportDelivery] #{error_message}")
      mark_as_failed!(StandardError.new(error_message))
      return [false, error_message]
    end

    begin
      deliver_via_discord
      success_message = "Feedback report was successfully sent to #{enrollment.user.name}."
      Rails.logger.info("[FeedbackReportDelivery] #{success_message}")
      [true, success_message]
    rescue => e
      error_message = "Failed to send feedback report for #{enrollment.user.name}: #{e.message}"
      [false, error_message]
    end
  end

  private

  def deliver_via_discord
    current_cohort = enrollment&.cohort
    unless current_cohort
      raise "Cannot determine cohort for FeedbackReport #{id}. Report cannot be sent."
    end

    discord_service = DiscordService.new(current_cohort)
    discord_service.send_dm(enrollment.user.discord_id, message)
    mark_as_sent!
  rescue => e
    error_message = "Error in deliver_via_discord for Report ID #{id}, Enrollment ID #{enrollment.id}: #{e.message}"
    Rails.logger.error("#{error_message}\nBacktrace: #{e.backtrace.join("\n")}")
    mark_as_failed!(e)
    raise
  end
end
