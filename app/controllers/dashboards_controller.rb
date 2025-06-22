class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def receptionist
    redirect_to root_path, alert: "Access denied." unless current_user.receptionist?
    @query = params[:query]
    @dob_filter = params[:dob_filter]

    @patients = Patient.all

    # Apply search
    @patients = @patients.where("name ILIKE ?", "%#{@query}%") if @query.present?

    # Apply filter (optional)
    if @dob_filter.present?
      year = @dob_filter.to_i
      @patients = @patients.where("EXTRACT(YEAR FROM dob) = ?", year)
    end

    @patients = @patients.order(:id)
  end

  def doctor
    redirect_to root_path, alert: "Access denied." unless current_user.doctor?
  end
end