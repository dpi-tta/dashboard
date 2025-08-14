class AttendancesController < ApplicationController
  before_action :set_attendance, only: %i[ show edit update destroy ]
  before_action :set_cohort
  before_action { authorize(@attendance || Attendance) }

  # GET /attendances or /attendances.json
  def index
    @breadcrumbs = [
      { content: "Cohorts", href: cohorts_path },
      { content: @cohort.to_s, href: cohort_path(@cohort) },
      { content: "Attendance", href: cohort_attendances_path(@cohort) }
    ]

    @q = policy_scope(@cohort.attendances).ransack(params[:q])
    @attendances = @q.result.default_order

    respond_to do |format|
      format.html { @attendances = @attendances.page(params[:page]).per(params.fetch(:per_page, 10)) }
      format.csv { send_data(Attendance.to_csv(@attendances), filename: csv_filename, type: "text/csv") }
    end
  end

  # GET /attendances/1 or /attendances/1.json
  def show
    @breadcrumbs = [
      { content: "Cohorts", href: cohorts_path },
      { content: @cohort.to_s, href: cohort_path(@cohort) },
      { content: "Attendance", href: cohort_attendances_path(@cohort) },
      { content: @attendance.title }
    ]

    @cohort = @attendance.cohort
    @enrollments = @cohort.enrollments.includes(:user)

    @role_counts = @attendance.role_counts
  end

  # GET /attendances/new
  def new
    @breadcrumbs = [
      { content: "Cohorts", href: cohorts_path },
      { content: @cohort.to_s, href: cohort_path(@cohort) },
      { content: "Attendance", href: cohort_attendances_path(@cohort) },
      { content: "New" }
    ]

    @attendance = policy_scope(@cohort.attendances).new
    @cohort.enrollments.each do |enrollment|
      @attendance.attendees.build(enrollment: enrollment)
    end
  end

  # GET /attendances/1/edit
  def edit
    @breadcrumbs = [
      { content: "Cohorts", href: cohorts_path },
      { content: @cohort.to_s, href: cohort_path(@cohort) },
      { content: "Attendance", href: cohort_attendances_path(@cohort) },
      { content: "Edit" }
    ]

    @attendance.attendees.each do |attendee|
      attendee._destroy ||= "0"
    end
  end

  # POST /attendances or /attendances.json
  def create
    @attendance = @cohort.attendances.new(attendance_params.merge(roll_taker: current_user))

    respond_to do |format|
      if @attendance.save
        format.html { redirect_to cohort_attendance_url(@cohort, @attendance), notice: "Attendance was successfully created." }
        format.json { render :show, status: :created, location: @attendance }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @attendance.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /attendances/1 or /attendances/1.json
  def update
    respond_to do |format|
      if @attendance.update(attendance_params)
        format.html { redirect_to cohort_attendance_url(@cohort, @attendance), notice: "Attendance was successfully updated." }
        format.json { render :show, status: :ok, location: @attendance }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @attendance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /attendances/1 or /attendances/1.json
  def destroy
    @attendance.destroy

    respond_to do |format|
      format.html { redirect_to cohort_attendances_path(@cohort), notice: "Attendance was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_attendance
    @attendance = policy_scope(Attendance).find(params[:id])
  end

  def set_cohort
    # only need enrollments/user on new/edit
    @cohort = Cohort.includes(enrollments: :user).find(params[:cohort_id])
  end

  def attendance_params
    params.require(:attendance).permit(:title, :category, :occurred_at, :cohort_id, attendees_attributes: [ :id, :enrollment_id, :_destroy ])
  end

  def csv_filename
    base_name = "#{Time.zone.today}-attendance-records"

    if params[:q].blank?
      return "#{base_name}.csv"
    end

    formatted_query_params = params[:q].values.compact_blank.join("-")
    "#{base_name}-#{formatted_query_params}.csv"
  end
end
