# == Schema Information
#
# Table name: attendances
#
#  id              :uuid             not null, primary key
#  attendees_count :integer          default(0), not null
#  category        :string           not null
#  occurred_at     :datetime         not null
#  title           :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  cohort_id       :uuid
#  roll_taker_id   :uuid             not null
#
# Indexes
#
#  index_attendances_on_cohort_id      (cohort_id)
#  index_attendances_on_roll_taker_id  (roll_taker_id)
#
# Foreign Keys
#
#  fk_rails_...  (cohort_id => cohorts.id)
#  fk_rails_...  (roll_taker_id => users.id)
#
class Attendance < ApplicationRecord
  include Csvable, Ransackable

  validates :category, presence: true

  belongs_to :cohort
  belongs_to :roll_taker, class_name: "User"

  has_many :attendees, dependent: :destroy
  has_many :enrollments, through: :attendees

  accepts_nested_attributes_for :attendees, allow_destroy: true

  enum :category, {
    riverside: "riverside",
    durable_skills_session: "durable skills session",
    office_hours: "office hours",
    technical_lecture: "technical lecture",
    mock_interview: "mock interview",
    community_alumni_event: "community or alumni event",
    other: "other"
  }

  scope :default_order, -> { order(occurred_at: :desc) }

  def role_counts
    attendees
      .joins(:enrollment)
      .group("enrollments.role")
      .count
  end
end
