class PatientsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_receptionist, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_patient, only: [:show, :edit, :update, :destroy]

  def check_receptionist
    redirect_to root_path, alert: "Access denied." unless current_user.role == "receptionist"
  end

  # GET /patients
  def index
    @patients = Patient.all
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

    if @patient.save
      redirect_to receptionist_dashboard_path, notice: "Patient was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /patients/1
  def update
    if @patient.update(patient_params)
      # flash[:notice] = "Patient was successfully updated."
      # render :edit, status: :ok
      redirect_to edit_patient_path(@patient), notice: "Patient was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /patients/1
  def destroy
    # @patient = Patient.find(params[:id])
    # if @patient.destroy
    #   redirect_to receptionist_dashboard_path, notice: "Patient was successfully deleted."
    # else
    #   redirect_to receptionist_dashboard_path, alert: "Failed to delete patient."
    # end
    @patient = Patient.find(params[:id])
    @patient.destroy
    redirect_to receptionist_dashboard_path, notice: 'Patient was successfully deleted.'
  end

  private

    # Set patient before actions
    def set_patient
      @patient = Patient.find(params[:id])
    end

    # Whitelist parameters
    def patient_params
      params.require(:patient).permit(:name, :dob, :notes)
    end
end