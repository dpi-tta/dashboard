module ApplicationHelper
  def rating_class(rating)
    case rating
    when :excellent
      "success"
    when :proficient
      "info"
    when :emerging
      "primary"
    else
      "primary"
    end
  end

  def badge_class_for_role(role)
    case role
    when :student
      "bg-dpi-primary"
    when :instructor, :staff, :teaching_assistant
      "bg-dpi-secondary text-black"
    else
      "bg-secondary"
    end
  end
end
