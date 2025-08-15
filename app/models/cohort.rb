# == Schema Information
#
# Table name: cohorts
#
#  id                   :uuid             not null, primary key
#  canvas_shortname     :string
#  month                :integer          not null
#  name                 :string
#  number               :integer          not null
#  piazza_course_number :string
#  started_on           :date
#  year                 :integer          not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  discord_server_id    :string
#
class Cohort < ApplicationRecord
  include Adminable

  has_paper_trail skip: [ :created_at, :updated_at ]

  has_many :enrollments, dependent: :destroy
  has_many :piazza_activity_reports, dependent: :destroy
  has_many :canvas_gradebook_snapshots, dependent: :destroy
  has_many :canvas_assignments, dependent: :destroy
  has_many :included_canvas_assignments, -> { included }, class_name: "CanvasAssignment"
  has_many :impressions, through: :enrollments, source: :impressions
  has_many :users, through: :enrollments, source: :user
  has_many :attendances
  has_many :recurring_messages, dependent: :destroy
  has_many :feedback_reports, through: :enrollments

  validates :year, presence: true
  validates :month, presence: true
  validates :number,
    presence: true,
    uniqueness: { scope: [ "month", "year" ] }
  validates :started_on, presence: true

  scope :default_order, -> { order(:year, :month, :number) }

  def to_s
    "[#{code}] #{name}"
  end

  def code
    "#{year}-#{month}.#{number}"
  end
end
