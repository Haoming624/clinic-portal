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

    # Group patients by status
    @patients_by_status = Patient.group(:status).count

    render :analytics
  end

  private

  def filtered_patients
    patients = Patient.all

    if params[:query].present?
      patients = patients.where("name ILIKE ?", "%#{params[:query]}%")
    end

    if params[:dob_from].present?
      from_year = params[:dob_from].to_i
      patients = patients.where("dob >= ?", Date.new(from_year).beginning_of_year)
    end

    if params[:dob_to].present?
      to_year = params[:dob_to].to_i
      patients = patients.where("dob <= ?", Date.new(to_year).end_of_year)
    end

    if params[:status].present? && params[:status] != ""
      patients = patients.where(status: params[:status])
    end

    # patients.order(:id)
    patients.order(:id).page(params[:page]).per(10)
  end
end
