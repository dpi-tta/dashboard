class Cohort::FeedbackReportsController < ApplicationController
  before_action :set_cohort
  before_action :set_feedback_report, only: [:show, :send_report, :destroy, :edit, :update]
  before_action :set_enrollment, except: [:batch_create, :index, :show, :new, :create, :send_report, :destroy, :edit, :update]
  before_action { authorize(@feedback_report || FeedbackReport) }

  def index
    @feedback_reports = policy_scope(@cohort.feedback_reports)
      .order(created_at: :desc)
      .includes(enrollment: :user)
  end

  def show
    @feedback_report = @cohort.feedback_reports.find(params[:id])
  end

  def batch_create
    canvas_gradebook_snapshot = @cohort.canvas_gradebook_snapshots.find(params[:canvas_gradebook_snapshot_id])
    start_date = Date.parse(params[:start_date])
    end_date = Date.parse(params[:end_date])
    assignments = params[:assignments]

    success, result = canvas_gradebook_snapshot.create_feedback_reports(
      start_date,
      end_date,
      assignments
    )

    if success
      redirect_to cohort_feedback_reports_path(@cohort), notice: result[:message]
    else
      redirect_to cohort_feedback_reports_path(@cohort), alert: "Error generating reports: #{result[:error]}\n#{result[:backtrace]}"
    end
  end

  def edit
    if @feedback_report.sent?
      redirect_to cohort_feedback_report_path(@cohort, @feedback_report), alert: "This report has been sent and cannot be edited."
      nil
    end
  end

  def send_report
    success, message = @feedback_report.send_report

    if success
      redirect_to cohort_feedback_reports_path(@cohort), notice: message
    else
      redirect_to cohort_feedback_reports_path(@cohort), alert: "Failed to send feedback report: #{message}"
    end
  end

  def update
    if @feedback_report.sent?
      redirect_to cohort_feedback_report_path(@cohort, @feedback_report), alert: "This report has been sent and cannot be updated."
      return
    end

    if @feedback_report.update(feedback_report_params)
      redirect_to cohort_feedback_report_path(@cohort, @feedback_report), notice: "Feedback report was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @feedback_report.sent?
      redirect_to cohort_feedback_reports_path(@cohort), alert: "This report has been sent and cannot be deleted."
      return
    end

    @feedback_report.destroy

    respond_to do |format|
      format.html { redirect_to cohort_feedback_reports_path(@cohort), notice: "Feedback report was successfully deleted." }
      format.json { head :no_content }
    end
  rescue => e
    respond_to do |format|
      format.html { redirect_to cohort_feedback_report_path(@cohort, @feedback_report), alert: "Failed to delete feedback report: #{e.message}" }
      format.json { render json: { error: e.message }, status: :unprocessable_entity }
    end
  end

  private

  def set_cohort
    @cohort = Cohort.find(params[:cohort_id])
  end

  def set_enrollment
    @enrollment = @cohort.enrollments.find(params[:enrollment_id])
  end

  def set_feedback_report
    @feedback_report = @cohort.feedback_reports.find(params[:id])
  end

  def feedback_report_params
    params.require(:feedback_report).permit(:message)
  end
end
