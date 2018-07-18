class InstructionsController < ApplicationController
  # GET /instructions
  # GET /instructions.json
  def index
    @instructions = Instruction.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @instructions }
    end
  end

  # GET /instructions/1
  # GET /instructions/1.json
  def show
    @instruction = Instruction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @instruction }
    end
  end

  # GET /instructions/new
  # GET /instructions/new.json
  def new
    @instruction = Instruction.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @instruction }
    end
  end

  # GET /instructions/1/edit
  def edit
    @instruction = Instruction.find(params[:id])
  end

  # POST /instructions
  # POST /instructions.json
  def create
    @instruction = Instruction.new(params[:instruction])

    respond_to do |format|
      if @instruction.save
        format.html { redirect_to @instruction, notice: 'Instruction was successfully created.' }
        format.json { render json: @instruction, status: :created, location: @instruction }
      else
        format.html { render action: "new" }
        format.json { render json: @instruction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /instructions/1
  # PUT /instructions/1.json
  def update
    @instruction = Instruction.find(params[:id])

    respond_to do |format|
      if @instruction.update_attributes(params[:instruction])
        format.html { redirect_to @instruction, notice: 'Instruction was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @instruction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /instructions/1
  # DELETE /instructions/1.json
  def destroy
    @instruction = Instruction.find(params[:id])
    @instruction.destroy

    respond_to do |format|
      format.html { redirect_to instructions_url }
      format.json { head :no_content }
    end
  end

  # when user clicks on "instruction" href in structure_components/create_structure view,
  # then this method is called from structure_components/component_details method using this line:
  # redirect_to("/#{component_name}s/create_#{component_name}/#{@structure_component.id}")
  def create_instruction
    @structure_component = StructureComponent.find(params[:id])
  end

  # instructions/create_instruction form submits to this method to save instruction
  def save_instruction
    @structure_component = StructureComponent.find(params[:id])
    @instruction = Instruction.find_by_structure_component_id(params[:id])
    unless @instruction.nil?
      @instruction.update_attribute(:instruction_text,params[:instructions])
    else
      @instruction = Instruction.new
      @instruction.instruction_text = params[:instructions]
      @instruction.tenant_id = @structure_component.tenant_id
      @instruction.structure_component_id = @structure_component.id
      @instruction.save
      @structure_component.update_attribute(:is_saved, "true")
    end
    redirect_to("/structure_components/create_structure/#{@structure_component.assessment_id}")
  end
end
