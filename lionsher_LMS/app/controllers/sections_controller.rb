class SectionsController < ApplicationController
  # GET /sections
  # GET /sections.json
  def index
    @sections = Section.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sections }
    end
  end

  # GET /sections/1
  # GET /sections/1.json
  def show
    @section = Section.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @section }
    end
  end

  # GET /sections/new
  # GET /sections/new.json
  def new
    @section = Section.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @section }
    end
  end

  # GET /sections/1/edit
  def edit
    @section = Section.find(params[:id])
  end

  # POST /sections
  # POST /sections.json
  def create
    @section = Section.new(params[:section])

    respond_to do |format|
      if @section.save
        format.html { redirect_to @section, notice: 'Section was successfully created.' }
        format.json { render json: @section, status: :created, location: @section }
      else
        format.html { render action: "new" }
        format.json { render json: @section.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sections/1
  # PUT /sections/1.json
  def update
    @section = Section.find(params[:id])

    respond_to do |format|
      if @section.update_attributes(params[:section])
        format.html { redirect_to @section, notice: 'Section was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @section.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sections/1
  # DELETE /sections/1.json
  def destroy
    @section = Section.find(params[:id])
    @section.destroy

    respond_to do |format|
      format.html { redirect_to sections_url }
      format.json { head :no_content }
    end
  end
  
  def create_section
    @structure_component = StructureComponent.find(params[:id])
    @tenant = Tenant.find(@structure_component.tenant_id)
  end

  def save_section
    logger.info"PARAMS >>>>>>>>>>>>..#{params.inspect}"
    @structure_component = StructureComponent.find(params[:id])
    @section = Section.find_by_structure_component_id(params[:id])
    unless @section.nil?
      @section.update_attribute(:name,params[:section_name])
      @section.update_attribute(:duration_hour,params[:section_duration_hour])
      @section.update_attribute(:duration_min,params[:section_duration_min])
      @section.update_attribute(:time_bound,params[:section_time_bound])
    else
      @section = Section.new
      @section.name = params[:section_name]
      @section.structure_component_id = @structure_component.id
      @section.tenant_id = @structure_component.tenant_id
      @section.assessment_id = @structure_component.assessment_id
      @section.duration_hour = params[:section_duration_hour]
      @section.duration_min = params[:section_duration_min]
      @section.time_bound = params[:section_time_bound]
      @section.save
    end
    redirect_to("/rules/create_rule/#{@section.id}?assessment=#{@structure_component.assessment_id}")
  end
end
