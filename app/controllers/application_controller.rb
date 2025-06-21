class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def after_sign_in_path_for(resource)
    if resource.receptionist?
      receptionist_dashboard_path
    elsif resource.doctor?
      doctor_dashboard_path
    else
      root_path # login page
    end
  end
end