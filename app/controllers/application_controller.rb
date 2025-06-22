class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  before_action :authenticate_user!
  skip_before_action :authenticate_user!, if: :devise_controller?


  def after_sign_in_path_for(resource)
    if resource.receptionist?
      receptionist_dashboard_path
    elsif resource.doctor?
      doctor_dashboard_path
    else
      root_path # login page
    end
  end

  private

  def record_not_found
    redirect_to after_sign_in_path_for(current_user), alert: "Record not found or has been deleted."
  end
end
