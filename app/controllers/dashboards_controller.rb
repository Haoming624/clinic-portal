class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def receptionist
    # Only receptionist can access this
    redirect_to root_path, alert: "Access denied." unless current_user.role == "receptionist"

    @patients = filtered_patients
  end

  def doctor
    # Only doctor can access this
    redirect_to root_path, alert: "Access denied." unless current_user.role == "doctor"

    @patients = filtered_patients
  end

  def analytics
    # Fetch patients grouped by registration date, count per day
    @registrations_by_date = Patient.group("DATE(created_at)").order("DATE(created_at)").count

    render :analytics
  end

  private

  def filtered_patients
    patients = Patient.all

    if params[:query].present?
      patients = patients.where("name ILIKE ?", "%#{params[:query]}%")
    end

    if params[:dob_from].present?
      patients = patients.where("dob >= ?", params[:dob_from])
    end

    if params[:dob_to].present?
      patients = patients.where("dob <= ?", params[:dob_to])
    end

    if params[:status].present? && params[:status] != ""
      patients = patients.where(status: params[:status])
    end

    patients.order(:id)
  end
end
