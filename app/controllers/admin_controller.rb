class AdminController < ActionController::Base
  before_action :authenticate_user!

  # TODO: authenticate_admin!
  # May want to wait until we refactor how we set admin via rolify
end
