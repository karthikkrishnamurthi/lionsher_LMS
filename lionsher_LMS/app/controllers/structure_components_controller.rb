class StructureComponentsController < ApplicationController
  # GET /structure_components
  # GET /structure_components.json
  def index
    @structure_components = StructureComponent.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @structure_components }
    end
  end

  # GET /structure_components/1
  # GET /structure_components/1.json
  def show
    @structure_component = StructureComponent.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @structure_component }
    end
  end

  # GET /structure_components/new
  # GET /structure_components/new.json
  def new
    @structure_component = StructureComponent.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @structure_component }
    end
  end

  # GET /structure_components/1/edit
  def edit
    @structure_component = StructureComponent.find(params[:id])
  end

  # POST /structure_components
  # POST /structure_components.json
  def create
    @structure_component = StructureComponent.new(params[:structure_component])

    respond_to do |format|
      if @structure_component.save
        format.html { redirect_to @structure_component, notice: 'Structure component was successfully created.' }
        format.json { render json: @structure_component, status: :created, location: @structure_component }
      else
        format.html { render action: "new" }
        format.json { render json: @structure_component.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /structure_components/1
  # PUT /structure_components/1.json
  def update
    @structure_component = StructureComponent.find(params[:id])

    respond_to do |format|
      if @structure_component.update_attributes(params[:structure_component])
        format.html { redirect_to @structure_component, notice: 'Structure component was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @structure_component.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /structure_components/1
  # DELETE /structure_components/1.json
  def destroy
    @structure_component = StructureComponent.find(params[:id])
    @structure_component.destroy

    respond_to do |format|
      format.html { redirect_to structure_components_url }
      format.json { head :no_content }
    end
  end

  # called from assessments/save_assessment method if user
  # selects "from previous_question_banks" option while creating new assessment
  def create_assessment
    @assessment = Assessment.find(params[:id])
  end

  # structure_components/create_assessment form submits to this method
  # to save assessment's description and other related details
  def save_assessment
    @assessment = Assessment.find(params[:id])
    @assessment.description = params[:assessment_description]
    @assessment.user_id = current_user.id
    @assessment.tenant_id = current_user.tenant_id
    @assessment.time_bound = "time_bound"
    @assessment.test_pattern_id = 1
    @assessment.save
    redirect_to("/structure_components/create_structure/#{@assessment.id}")
  end

  # called from sructure_components/save_assessment method 
  # the corresponding view displays the existing components (if any) for the assessment.
  # a component is highlighted if it is filled
  def create_structure
    @assessment = Assessment.find(params[:id])
    @assessment_components = AssessmentComponent.all
    @existing_structure = @assessment.structure_components.find(:all, :order => "id")
  end

  # structure_components/create_structure form submits to this method when user
  # select some component from a dropdown list of various components 
  def post_component
    @assessment = Assessment.find(params[:id])
    @structure_component = StructureComponent.new
    @structure_component.assessment_id = @assessment.id
    @structure_component.assessment_component_id = params[:assessment_component]
    @structure_component.tenant_id = @assessment.tenant_id
    @structure_component.save
    redirect_to("/structure_components/create_structure/#{@assessment.id}")
  end

  # called from instructions/create_instruction page when user deletes component.
  # When a component is deleted then all the dependent rows in the associated tables
  # are deleted using "dependent => destroy" in the associations defined in structure_component model.
  def delete_component
    @structure_component = StructureComponent.find(params[:id])
    @structure_component.destroy
    @existing_structure = StructureComponent.find_all_by_assessment_id(@structure_component.assessment_id, :order => "id")
    redirect_to("/structure_components/create_structure/#{@structure_component.assessment_id}")
  end

  # called from structure_components/create_structure when user clicks on a component.
  # this method redirects to the "create_" method of the controller corresponding to the 
  # component that is clicked by the user on the structure_components/create_structure page.
  # e.g. (i) instructions/create_instruction if user clicks on instruction component
  #     (ii) profiles/create_profile if user clicks on profile component
  #    (iii) sections/create_section if user clicks on section component
  #     (iv) report/create_report if user clicks on report component
  def component_details
    @structure_component = StructureComponent.find(params[:id])
    component_name = @structure_component.assessment_component.name
    redirect_to("/#{component_name}s/create_#{component_name}/#{@structure_component.id}")
  end

end