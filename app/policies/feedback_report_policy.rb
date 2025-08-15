class FeedbackReportPolicy < ApplicationPolicy
  def create?
    user.present? && (user.admin? || user.instructor? || user.teaching_assistant?)
  end

  def show?
    user.present? && (user.admin? || user.instructor? || user.teaching_assistant?)
  end

  def index?
    user.present? && (user.admin? || user.instructor? || user.teaching_assistant?)
  end

  def batch_create?
    user.present? && (user.admin? || user.instructor? || user.teaching_assistant?)
  end

  def send_report?
    user.present? && (user.admin? || user.instructor? || user.teaching_assistant?)
  end

  def destroy?
    user.present? && (user.admin? || user.instructor? || user.teaching_assistant?) && !record.sent?
  end

  def edit?
    user.present? && (user.admin? || user.instructor? || user.teaching_assistant?) && !record.sent?
  end

  def update?
    edit?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.instructor? || user.teaching_assistant?
        scope.joins(canvas_gradebook_snapshot: { cohort: :enrollments })
             .where(enrollments: { user_id: user.id })
      else
        scope.none
      end
    end
  end
end
