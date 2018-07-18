class CalculatedDataLearnerAssessmentsController < ApplicationController
  # GET /calculated_data_learner_assessments
  # GET /calculated_data_learner_assessments.json
  def index
    @calculated_data_learner_assessments = CalculatedDataLearnerAssessment.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @calculated_data_learner_assessments }
    end
  end

  # GET /calculated_data_learner_assessments/1
  # GET /calculated_data_learner_assessments/1.json
  def show
    @calculated_data_learner_assessment = CalculatedDataLearnerAssessment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @calculated_data_learner_assessment }
    end
  end

  # GET /calculated_data_learner_assessments/new
  # GET /calculated_data_learner_assessments/new.json
  def new
    @calculated_data_learner_assessment = CalculatedDataLearnerAssessment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @calculated_data_learner_assessment }
    end
  end

  # GET /calculated_data_learner_assessments/1/edit
  def edit
    @calculated_data_learner_assessment = CalculatedDataLearnerAssessment.find(params[:id])
  end

  # POST /calculated_data_learner_assessments
  # POST /calculated_data_learner_assessments.json
  def create
    @calculated_data_learner_assessment = CalculatedDataLearnerAssessment.new(params[:calculated_data_learner_assessment])

    respond_to do |format|
      if @calculated_data_learner_assessment.save
        format.html { redirect_to @calculated_data_learner_assessment, notice: 'Calculated data learner assessment was successfully created.' }
        format.json { render json: @calculated_data_learner_assessment, status: :created, location: @calculated_data_learner_assessment }
      else
        format.html { render action: "new" }
        format.json { render json: @calculated_data_learner_assessment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /calculated_data_learner_assessments/1
  # PUT /calculated_data_learner_assessments/1.json
  def update
    @calculated_data_learner_assessment = CalculatedDataLearnerAssessment.find(params[:id])

    respond_to do |format|
      if @calculated_data_learner_assessment.update_attributes(params[:calculated_data_learner_assessment])
        format.html { redirect_to @calculated_data_learner_assessment, notice: 'Calculated data learner assessment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @calculated_data_learner_assessment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /calculated_data_learner_assessments/1
  # DELETE /calculated_data_learner_assessments/1.json
  def destroy
    @calculated_data_learner_assessment = CalculatedDataLearnerAssessment.find(params[:id])
    @calculated_data_learner_assessment.destroy

    respond_to do |format|
      format.html { redirect_to calculated_data_learner_assessments_url }
      format.json { head :no_content }
    end
  end
end
