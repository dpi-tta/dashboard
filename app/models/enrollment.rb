# == Schema Information
#
# Table name: enrollments
#
#  id                             :uuid             not null, primary key
#  career_attendance              :integer          default(0)
#  career_calendar_management     :integer          default(0)
#  career_customer_service        :integer          default(0)
#  career_networking              :integer          default(0)
#  career_problem_solving         :integer          default(0)
#  career_punctuality             :integer          default(0)
#  career_quality_of_work         :integer          default(0)
#  career_response_to_supervision :integer          default(0)
#  career_summary                 :text
#  career_taking_initiative       :integer          default(0)
#  career_task_management         :integer          default(0)
#  career_teamwork                :integer          default(0)
#  career_total                   :integer          default(0)
#  career_workplace_appearance    :integer          default(0)
#  career_workplace_culture       :integer          default(0)
#  communication_nonverbal        :integer          default(0)
#  communication_summary          :text
#  communication_total            :integer          default(0)
#  communication_verbal           :integer          default(0)
#  communication_written          :integer          default(0)
#  emotional_intelligence         :text
#  id_from_canvas                 :string
#  role                           :string
#  skills_development             :text
#  staff_areas_for_growth         :text
#  staff_strengths                :text
#  technical_good_questions       :integer          default(0)
#  technical_progress             :integer          default(0)
#  technical_rating               :string
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  cohort_id                      :uuid             not null
#  user_id                        :uuid             not null
#
# Indexes
#
#  index_enrollments_on_cohort_id              (cohort_id)
#  index_enrollments_on_id_from_canvas         (id_from_canvas)
#  index_enrollments_on_user_id                (user_id)
#  index_enrollments_on_user_id_and_cohort_id  (user_id,cohort_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (cohort_id => cohorts.id)
#  fk_rails_...  (user_id => users.id)
#
class Enrollment < ApplicationRecord
  include Adminable, Endorsable, Ransackable

  has_paper_trail skip: [ :created_at, :updated_at ]

  belongs_to :user
  accepts_nested_attributes_for :user, update_only: true
  belongs_to :cohort
  has_many :piazza_activity_breakdowns, dependent: :destroy
  has_many :canvas_submissions, dependent: :destroy
  has_many :impressions, foreign_key: "subject_id", dependent: :destroy
  has_many :attendees, dependent: :destroy
  has_many :attendances, through: :attendees
  has_many :feedback_reports, dependent: :destroy

  scope :default_order, -> { joins(:user).order(User.arel_table[:first_name].asc) }
  scope :student, -> { where(role: "student") }
  scope :not_student, -> { where.not(role: "student") }
  scope :filter_by_name, ->(name) {
    joins(:user)
      .where("CONCAT(users.first_name, ' ', users.last_name) ILIKE ?", "%#{name}%")
      .order("enrollments.created_at DESC")
      .includes(:user)
  }
  scope :with_user_info, -> {
    joins(:user)
      .select("enrollments.id, enrollments.cohort_id, users.id AS user_id, users.first_name, users.last_name")
  }
  scope :recent_gradebook_snapshot, ->(cohort) {
    joins(canvas_submissions: :canvas_gradebook_snapshot)
      .where(canvas_gradebook_snapshots: { cohort_id: cohort.id })
      .where('canvas_gradebook_snapshots.created_at = (
      SELECT MAX(created_at)
      FROM canvas_gradebook_snapshots
      WHERE canvas_gradebook_snapshots.cohort_id = ?
    )', cohort.id)
  }
  scope :with_recent_canvas_points, ->(cohort) {
    with_user_info
      .recent_gradebook_snapshot(cohort)
      .select("enrollments.id, users.id AS user_id, users.first_name, users.last_name, SUM(canvas_submissions.points) AS total_points")
      .group("enrollments.id, users.id, users.first_name, users.last_name")
      .order("total_points DESC")
  }
  scope :search_by_name, ->(name) {
    includes(:user)
      .where("CONCAT(users.first_name, ' ', users.last_name) ILIKE ?", "%#{name}%")
      .references(:user)
  }

  def total_points
    canvas_submissions.sum(:points)
  end

  delegate :education,
    :github_username,
    :devto_username,
    :discord_id,
    :discord_username,
    :salesforce_id,
    :languages,
    :most_recent_role,
    :personal_website,
    :quote,
    :strengths,
    :first_name,
    :last_name,
    :email,
    :to_s,
    :full_name,
    :name,
    to: :user

  enum :role, {
    instructor: "instructor",
    staff: "staff",
    student: "student",
    teaching_assistant: "teaching assistant"
  }, default: :student

  def completed_assignments
    results = []

    cohort.canvas_assignments.each do |canvas_assignment|
      my_submission = canvas_assignment.canvas_submissions.find_by(enrollment: self)

      if my_submission && my_submission.points == canvas_assignment.points_possible
        results << canvas_assignment
      end
    end

    results
  end

  def most_advanced_completed_project_for(skill)
    completed_assignments.max { |a, b| a.send(skill).to_i <=> b.send(skill).to_i }
  end

  def to_s
    "#{cohort} - #{user} (#{role})"
  end

  def attendance_by_category
    attendances.group(:category).count
  end
end
