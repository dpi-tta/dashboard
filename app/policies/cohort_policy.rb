class CohortPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(id: user.cohorts.pluck(:id))
      end
    end
  end

  def show?
    user.admin? || user.cohorts.include?(record)
  end

  def index?
    true
  end

  def edit?
    user.admin? || user.cohort_instructor?(record)
  end

  def update?
    user.admin? || user.cohort_instructor?(record)
  end

  def create?
    user.admin? || user.cohort_instructor?(record)
  end

  def destroy?
    user.admin?
  end

  def new?
    user.admin? || user.cohort_instructor?(record)
  end

  def canvas_highest_position_submission_count?
    user.admin? || user.cohort_instructor?(record) || user.cohort_teaching_assistant?(record)
  end

  def canvas_point_total_most_recent?
    user.admin? || user.cohort_instructor?(record) || user.cohort_teaching_assistant?(record)
  end

  def piazza_post_views?
    user.admin? || user.cohort_instructor?(record) || user.cohort_teaching_assistant?(record)
  end

  def piazza_posts?
    user.admin? || user.cohort_instructor?(record) || user.cohort_teaching_assistant?(record)
  end

  def cohort_enrollments?
    true
  end

  def cohort_canvas_gradebook_snapshots?
    user.admin? || user.cohort_instructor?(record) || user.cohort_teaching_assistant?(record)
  end

  def cohort_piazza_activity_reports?
    user.admin? || user.cohort_instructor?(record)
  end

  def cohort_impressions?
    user.admin? ||
      user.cohort_instructor?(record) ||
      user.cohort_teaching_assistant?(record) ||
      user.cohort_staff?(record)
  end

  def discord?
    user.admin? || user.cohort_instructor?(record) || user.cohort_teaching_assistant?(record) || user.cohort_staff?(record)
  end

  def cohort_feedback_reports?
    user.admin? || user.cohort_instructor?(record) || user.cohort_teaching_assistant?(record)
  end
end
