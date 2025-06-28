class PatientsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_receptionist, only: [ :new, :create, :edit, :update, :destroy, :restore ]
  before_action :set_patient, only: [ :show, :edit, :update, :destroy ]
  before_action :set_deleted_patient, only: [ :restore ]

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

  # DELETE /patients/1 (soft delete)
  def destroy
    patient_id = @patient.id
    patient_name = @patient.name
    
    if @patient.soft_delete
      Rails.logger.info "Patient soft deleted successfully: #{patient_id} by user: #{current_user.id}"
      
      # Store patient info in session for undo functionality
      session[:last_deleted_patient] = {
        id: patient_id,
        name: patient_name,
        deleted_at: Time.current.iso8601
      }
      
      Rails.logger.info "Session after storing deleted patient: #{session[:last_deleted_patient]}"
      
      respond_to do |format|
        format.html { 
          redirect_to receptionist_dashboard_path, 
          notice: "Patient '#{patient_name}' was successfully deleted."
        }
        format.json { 
          render json: { 
            success: true, 
            message: "Patient deleted successfully",
            undo_url: restore_patient_path(patient_id),
            patient_name: patient_name
          } 
        }
      end
    else
      Rails.logger.error "Patient deletion failed: #{@patient.errors.full_messages.join(', ')}"
      redirect_to receptionist_dashboard_path, alert: "Failed to delete patient. Please try again."
    end
  rescue => e
    Rails.logger.error "Unexpected error deleting patient: #{e.message}"
    redirect_to receptionist_dashboard_path, alert: "An unexpected error occurred while deleting the patient."
  end

  # PATCH /patients/1/restore (undo delete)
  def restore
    if @patient.restore
      Rails.logger.info "Patient restored successfully: #{@patient.id} by user: #{current_user.id}"
      redirect_to receptionist_dashboard_path, notice: "Patient '#{@patient.name}' was successfully restored."
    else
      Rails.logger.error "Patient restoration failed: #{@patient.errors.full_messages.join(', ')}"
      redirect_to receptionist_dashboard_path, alert: "Failed to restore patient. Please try again."
    end
  rescue => e
    Rails.logger.error "Unexpected error restoring patient: #{e.message}"
    redirect_to receptionist_dashboard_path, alert: "An unexpected error occurred while restoring the patient."
  end

  # PATCH /patients/restore_last (restore last deleted patient)
  def restore_last
    Rails.logger.info "Session contents: #{session.to_h}"
    Rails.logger.info "Last deleted patient from session: #{session[:last_deleted_patient]}"
    
    last_deleted = session[:last_deleted_patient]
    
    if last_deleted && last_deleted[:id]
      Rails.logger.info "Attempting to restore patient ID: #{last_deleted[:id]}"
      @patient = Patient.unscoped.find(last_deleted[:id])
      
      if @patient.restore
        Rails.logger.info "Last deleted patient restored successfully: #{@patient.id} by user: #{current_user.id}"
        session.delete(:last_deleted_patient)
        redirect_to receptionist_dashboard_path, notice: "Patient '#{@patient.name}' was successfully restored."
      else
        Rails.logger.error "Last deleted patient restoration failed: #{@patient.errors.full_messages.join(', ')}"
        redirect_to receptionist_dashboard_path, alert: "Failed to restore patient. Please try again."
      end
    else
      Rails.logger.warn "No last deleted patient found in session, trying fallback"
      
      # Fallback: look for recently deleted patients (within last 5 minutes)
      recent_deleted = Patient.unscoped.where('deleted_at > ?', 5.minutes.ago).order(deleted_at: :desc).first
      
      if recent_deleted
        Rails.logger.info "Found recently deleted patient: #{recent_deleted.id}"
        if recent_deleted.restore
          Rails.logger.info "Recently deleted patient restored successfully: #{recent_deleted.id} by user: #{current_user.id}"
          redirect_to receptionist_dashboard_path, notice: "Patient '#{recent_deleted.name}' was successfully restored."
        else
          Rails.logger.error "Recently deleted patient restoration failed: #{recent_deleted.errors.full_messages.join(', ')}"
          redirect_to receptionist_dashboard_path, alert: "Failed to restore patient. Please try again."
        end
      else
        Rails.logger.warn "No recently deleted patients found"
        redirect_to receptionist_dashboard_path, alert: "No patient to restore."
      end
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn "Last deleted patient not found in database"
    session.delete(:last_deleted_patient)
    redirect_to receptionist_dashboard_path, alert: "Patient not found or already restored."
  rescue => e
    Rails.logger.error "Unexpected error restoring last deleted patient: #{e.message}"
    redirect_to receptionist_dashboard_path, alert: "An unexpected error occurred while restoring the patient."
  end

  private

    # Set patient before actions
    def set_patient
      @patient = Patient.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      # This will be handled by rescue_from
      raise
    end

    # Set deleted patient for restore action
    def set_deleted_patient
      @patient = Patient.unscoped.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to receptionist_dashboard_path, alert: "Patient not found or already restored."
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
