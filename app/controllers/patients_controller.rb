class PatientsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_receptionist, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :set_patient, only: [ :show, :edit, :update, :destroy ]

  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing

  # Only receptionists allowed for modifying actions
  def check_receptionist
    redirect_to root_path, alert: "Access denied." unless current_user.role == "receptionist"
  end

  # GET /patients
  def index
    @patients = Patient.all
  rescue => e
    Rails.logger.error "Error fetching patients: #{e.message}"
    redirect_to root_path, alert: "Unable to load patients. Please try again."
  end

  # GET /patients/1
  def show
  end

  # GET /patients/new
  def new
    @patient = Patient.new
  end

  # GET /patients/1/edit
  def edit
  end

  # POST /patients
  def create
    @patient = Patient.new(patient_params)
    @patient.updated_by_user = current_user

    if @patient.save
      Rails.logger.info "Patient created successfully: #{@patient.id} by user: #{current_user.id}"
      redirect_to receptionist_dashboard_path, notice: "Patient was successfully created."
    else
      Rails.logger.warn "Patient creation failed: #{@patient.errors.full_messages.join(', ')}"
      render :new, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Unexpected error creating patient: #{e.message}"
    @patient = Patient.new
    flash.now[:alert] = "An unexpected error occurred. Please try again."
    render :new, status: :unprocessable_entity
  end

  # PATCH/PUT /patients/1
  def update
    @patient.updated_by_user = current_user
    if @patient.update(patient_params)
      Rails.logger.info "Patient updated successfully: #{@patient.id} by user: #{current_user.id}"
      redirect_to edit_patient_path(@patient), notice: "Patient was successfully updated."
    else
      Rails.logger.warn "Patient update failed: #{@patient.errors.full_messages.join(', ')}"
      render :edit, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Unexpected error updating patient: #{e.message}"
    flash.now[:alert] = "An unexpected error occurred. Please try again."
    render :edit, status: :unprocessable_entity
  end

  # DELETE /patients/1
  def destroy
    patient_id = @patient.id
    patient_name = @patient.name
    
    if @patient.destroy
      Rails.logger.info "Patient deleted successfully: #{patient_id} by user: #{current_user.id}"
      redirect_to receptionist_dashboard_path, notice: "Patient '#{patient_name}' was successfully deleted."
    else
      Rails.logger.error "Patient deletion failed: #{@patient.errors.full_messages.join(', ')}"
      redirect_to receptionist_dashboard_path, alert: "Failed to delete patient. Please try again."
    end
  rescue => e
    Rails.logger.error "Unexpected error deleting patient: #{e.message}"
    redirect_to receptionist_dashboard_path, alert: "An unexpected error occurred while deleting the patient."
  end

  private

    # Set patient before actions
    def set_patient
      @patient = Patient.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      # This will be handled by rescue_from
      raise
    end

    # Whitelist parameters
    def patient_params
      params.require(:patient).permit(:name, :dob, :notes, :status, :updated_by_user_id)
    rescue ActionController::ParameterMissing => e
      Rails.logger.warn "Missing required parameters: #{e.message}"
      raise
    end

    # Handle record not found errors
    def handle_record_not_found(exception)
      Rails.logger.warn "Patient not found: #{params[:id]}"
      redirect_to receptionist_dashboard_path, alert: "Patient not found."
    end

    # Handle missing parameters
    def handle_parameter_missing(exception)
      Rails.logger.warn "Missing parameters: #{exception.message}"
      redirect_to receptionist_dashboard_path, alert: "Invalid request. Please check your input."
    end
end
