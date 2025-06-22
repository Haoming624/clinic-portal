class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def receptionist
    redirect_to root_path, alert: "Access denied." unless current_user.receptionist?

    @query = params[:query]
    @dob_from = params[:dob_from]
    @dob_to = params[:dob_to]
    @status = params[:status]

    @patients = Patient.all

    # Search by name (case-insensitive)
    @patients = @patients.where("name ILIKE ?", "%#{@query}%") if @query.present?

    # Filter by dob range
    if @dob_from.present?
      @patients = @patients.where("dob >= ?", @dob_from)
    end
    if @dob_to.present?
      @patients = @patients.where("dob <= ?", @dob_to)
    end

    # Filter by status if valid
    if @status.present? && Patient.statuses.key?(@status)
      @patients = @patients.where(status: @status)
    end

    @patients = @patients.order(:id)
  end

  def doctor
    redirect_to root_path, alert: "Access denied." unless current_user.doctor?
  end
end