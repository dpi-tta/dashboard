# == Schema Information
#
# Table name: feedback_reports
#
#  id                           :uuid             not null, primary key
#  end_date                     :date             not null
#  error_message                :string
#  message                      :text             not null
#  sent                         :boolean          default(FALSE)
#  start_date                   :date             not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  canvas_gradebook_snapshot_id :uuid             not null
#  enrollment_id                :uuid             not null
#
# Indexes
#
#  index_feedback_reports_on_canvas_gradebook_snapshot_id  (canvas_gradebook_snapshot_id)
#  index_feedback_reports_on_enrollment_id                 (enrollment_id)
#  index_feedback_reports_on_unique_constraint             (enrollment_id,canvas_gradebook_snapshot_id,start_date,end_date) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (canvas_gradebook_snapshot_id => canvas_gradebook_snapshots.id)
#  fk_rails_...  (enrollment_id => enrollments.id)
#
class FeedbackReport < ApplicationRecord
  include Processable, Deliverable

  belongs_to :enrollment
  belongs_to :canvas_gradebook_snapshot

  validates :start_date, :end_date, :message, presence: true
  validates :enrollment_id, uniqueness: {
    scope: [ :canvas_gradebook_snapshot_id, :start_date, :end_date ],
    message: "already has a report for this period"
  }

  def mark_as_sent!
    update!(sent: true, error_message: nil)
  end

  def mark_as_failed!(error)
    update!(sent: false, error_message: error.message)
  end
end
