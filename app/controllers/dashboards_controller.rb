class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def receptionist
    redirect_to root_path, alert: "Access denied." unless current_user.receptionist?
  end

  def doctor
    redirect_to root_path, alert: "Access denied." unless current_user.doctor?
  end
end