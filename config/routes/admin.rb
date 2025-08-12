authenticate :user, ->(user) { ApplicationPolicy.new(user, nil).admin_panel_accessible? } do
  mount RailsAdmin::Engine, at: "admin", as: "rails_admin"
end

authenticate :user, ->(user) { ApplicationPolicy.new(user, nil).mission_control_panel_accessible? } do
  mount MissionControl::Jobs::Engine, at: "/jobs"
end

authenticate :user, ->(user) { ApplicationPolicy.new(user, nil).blazer_panel_accessible? } do
  mount Blazer::Engine, at: "blazer"
end
