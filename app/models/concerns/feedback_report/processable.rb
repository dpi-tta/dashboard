module FeedbackReport::Processable
  extend ActiveSupport::Concern

  class_methods do
    def batch_create(cohort, canvas_gradebook_snapshot, start_date, end_date, assignments_ids)
      Rails.logger.info("Starting batch feedback report generation for cohort: #{cohort.id}, period: #{start_date} to #{end_date}")

      success_count = 0
      error_count = 0
      error_messages = []

      process_student_enrollments(cohort) do |enrollment|
        begin
          generate_and_save_feedback_report(
            enrollment,
            canvas_gradebook_snapshot,
            start_date,
            end_date,
            assignments_ids
          )
          success_count += 1
        rescue => e
          error_count += 1
          detailed_error_message = "Error generating report for #{enrollment.user.name} (Enrollment ID: #{enrollment.id}): #{e.message}"
          error_messages << detailed_error_message
          Rails.logger.error "#{detailed_error_message}\nBacktrace: #{e.backtrace.join("\n")}"
        end
      end

      concise_summary_message = "Generated #{success_count} feedback reports for cohort: #{cohort.id}."
      if error_count > 0
        concise_summary_message += " Encountered #{error_count} errors. Please check server logs for details."
      end

      if error_count > 0
        full_summary_for_log = "Generated #{success_count} feedback reports for cohort: #{cohort.id}. Encountered #{error_count} errors:\n#{error_messages.join("\n")}"
        Rails.logger.info(full_summary_for_log)
      else
        Rails.logger.info(concise_summary_message)
      end

      [true, {
        success_count: success_count,
        error_count: error_count,
        error_messages: error_messages,
        message: concise_summary_message,
      }]
    rescue => e
      error_log_message = "Major error during batch feedback report generation for cohort: #{cohort.id}: #{e.message}"
      Rails.logger.error "#{error_log_message}\nBacktrace: #{e.backtrace.join("\n")}"
      [false, {
        error: "A major error occurred during batch processing: #{e.message}. Please check server logs.",
        backtrace: e.backtrace.first,
      }]
    end

    private

    def generate_and_save_feedback_report(enrollment, canvas_gradebook_snapshot, start_date, end_date, assignment_ids)
      selected_assignments = fetch_selected_assignments(canvas_gradebook_snapshot, assignment_ids)
      user_submissions = fetch_user_submissions(enrollment, canvas_gradebook_snapshot, assignment_ids)
      missing_assignments = identify_missing_assignments(selected_assignments, user_submissions)
      impressions = fetch_student_impressions(enrollment, start_date, end_date)
      attendances = fetch_attendances(enrollment, start_date, end_date)
      message_content = format_feedback_message(enrollment, missing_assignments, impressions, attendances, start_date, end_date)
      create_report_record(enrollment, message_content, canvas_gradebook_snapshot, start_date, end_date)
    end

    def fetch_selected_assignments(canvas_gradebook_snapshot, assignment_ids)
      canvas_gradebook_snapshot.canvas_assignments
        .where(id: assignment_ids)
        .index_by(&:id)
    end

    def fetch_user_submissions(enrollment, canvas_gradebook_snapshot, assignment_ids)
      canvas_gradebook_snapshot.canvas_submissions
        .where(enrollment: enrollment)
        .where(canvas_assignment_id: assignment_ids)
        .index_by(&:canvas_assignment_id)
    end

    def identify_missing_assignments(selected_assignments, user_submissions)
      selected_assignments.values.reject do |assignment|
        user_submissions.key?(assignment.id)
      end
    end

    def fetch_student_impressions(enrollment, start_date, end_date)
      enrollment.impressions
        .where(created_at: start_date.beginning_of_day..end_date.end_of_day)
        .where(staff_only: false)
        .order(created_at: :desc)
    end

    def fetch_attendances(enrollment, start_date, end_date)
      enrollment.attendances
        .where(occurred_at: start_date.beginning_of_day..end_date.end_of_day)
        .order(occurred_at: :desc)
    end

    def format_feedback_message(enrollment, missing_assignments, impressions, attendances, start_date, end_date)
      <<~MESSAGE
        Hello #{enrollment.user.name},

        **Feedback Report**
        Period: #{start_date.strftime("%B %d, %Y")} - #{end_date.strftime("%B %d, %Y")}

        **Missing Assignments:**
        #{missing_assignments.empty? ? "No missing assignments! 🎉" : missing_assignments.map { |a| "- #{a.name}" }.join("\n")}

        **Impressions:**
        #{impressions.empty? ? "No impressions recorded for this period." : impressions.map { |i| "- #{i.emoji} #{i.content}" }.join("\n")}

        **Attendance:**
        #{attendances.empty? ? "No attendance records for this period." : attendances.map { |a| "- #{a.title} (#{a.category.titleize})" }.join("\n")}
      MESSAGE
    end

    def create_report_record(enrollment, message_content, canvas_gradebook_snapshot, start_date, end_date)
      create!(
        enrollment: enrollment,
        canvas_gradebook_snapshot: canvas_gradebook_snapshot,
        start_date: start_date,
        end_date: end_date,
        message: message_content,
      )
    end

    def process_student_enrollments(cohort)
      student_enrollments = cohort.enrollments.student
      student_enrollments.each do |enrollment|
        yield enrollment
      end
    end
  end
end
