class AssessmentComponentsController < ApplicationController
  # GET /assessment_components
  # GET /assessment_components.json
  def index
    @assessment_components = AssessmentComponent.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @assessment_components }
    end
  end

  # GET /assessment_components/1
  # GET /assessment_components/1.json
  def show
    @assessment_component = AssessmentComponent.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @assessment_component }
    end
  end

  # GET /assessment_components/new
  # GET /assessment_components/new.json
  def new
    @assessment_component = AssessmentComponent.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @assessment_component }
    end
  end

  # GET /assessment_components/1/edit
  def edit
    @assessment_component = AssessmentComponent.find(params[:id])
  end

  # POST /assessment_components
  # POST /assessment_components.json
  def create
    @assessment_component = AssessmentComponent.new(params[:assessment_component])

    respond_to do |format|
      if @assessment_component.save
        format.html { redirect_to @assessment_component, notice: 'Assessment component was successfully created.' }
        format.json { render json: @assessment_component, status: :created, location: @assessment_component }
      else
        format.html { render action: "new" }
        format.json { render json: @assessment_component.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /assessment_components/1
  # PUT /assessment_components/1.json
  def update
    @assessment_component = AssessmentComponent.find(params[:id])

    respond_to do |format|
      if @assessment_component.update_attributes(params[:assessment_component])
        format.html { redirect_to @assessment_component, notice: 'Assessment component was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @assessment_component.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assessment_components/1
  # DELETE /assessment_components/1.json
  def destroy
    @assessment_component = AssessmentComponent.find(params[:id])
    @assessment_component.destroy

    respond_to do |format|
      format.html { redirect_to assessment_components_url }
      format.json { head :no_content }
    end
  end
end
