class RulesController < ApplicationController
  # GET /rules
  # GET /rules.json
  def index
    @rules = Rule.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @rules }
    end
  end

  # GET /rules/1
  # GET /rules/1.json
  def show
    @rule = Rule.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @rule }
    end
  end

  # GET /rules/new
  # GET /rules/new.json
  def new
    @rule = Rule.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @rule }
    end
  end

  # GET /rules/1/edit
  def edit
    @rule = Rule.find(params[:id])
  end

  # POST /rules
  # POST /rules.json
  def create
    @rule = Rule.new(params[:rule])

    respond_to do |format|
      if @rule.save
        format.html { redirect_to @rule, notice: 'Rule was successfully created.' }
        format.json { render json: @rule, status: :created, location: @rule }
      else
        format.html { render action: "new" }
        format.json { render json: @rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /rules/1
  # PUT /rules/1.json
  def update
    @rule = Rule.find(params[:id])

    respond_to do |format|
      if @rule.update_attributes(params[:rule])
        format.html { redirect_to @rule, notice: 'Rule was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rules/1
  # DELETE /rules/1.json
  def destroy
    @rule = Rule.find(params[:id])
    @rule.destroy

    respond_to do |format|
      format.html { redirect_to rules_url }
      format.json { head :no_content }
    end
  end

  def create_rule
    @section = Section.find(params[:id])
    @assessment = Assessment.find(params[:assessment])
    @assessment_rules = @assessment.assessment_rules.find_all_by_section_id(params[:id])
    @tags = Tag.all
    @selected_tag = params[:tag].to_i
    @tagvalues = Tagvalue.find_all_by_tag_id(params[:tag])
    @question_banks = QuestionBank.where(:tenant_id => current_user.tenant_id).order("name").all
    @question_types = QuestionType.all
    @difficulties = Difficulty.all
    @structure_component = StructureComponent.find(@section.structure_component_id)
  end

  def edit_rule
    @assessment_rule = AssessmentRule.find(params[:id])
    @section = Section.find_by_id(@assessment_rule.section_id)
    @assessment = Assessment.find(params[:assessment])
    @tags = Tag.all
    @selected_tag = params[:tag].to_i
    @tagvalues = Tagvalue.find_all_by_tag_id(params[:tag])
  end

  def post_rule
    assessment_rule = AssessmentRule.new
    assessment_rule.assessment_id = params[:assessment]
    assessment_rule.tenant_id = current_user.tenant_id
    assessment_rule.section_id = params[:id]
    assessment_rule.questions_required = params[:no_of_questions].to_i
    assessment_rule.positive_mark = params[:positive_mark].to_f
    assessment_rule.negative_mark = params[:negative_mark].to_f
    assessment_rule.question_bank_id = params[:question_bank]
    assessment_rule.question_type_id = params[:question_type]
    assessment_rule.difficulty_id = params[:difficulty]
    assessment_rule.save    
    params[:tagvalue].each_pair do |tag_id, tagvalue_id|
      unless tagvalue_id.nil? or tagvalue_id.blank?
        rule = Rule.new
        rule.tag_id = tag_id.to_i
        rule.tagvalue_id = tagvalue_id.to_i
        rule.assessment_rule_id = assessment_rule.id
        rule.tenant_id = current_user.tenant_id
        rule.save
      end  
    end
    tagvalue_ids = assessment_rule.rules.pluck(:tagvalue_id)
    question_attributes = get_question_attributes_for_tagvalues(assessment_rule,tagvalue_ids)
    assessment_rule.update_attribute(:questions_picked,question_attributes.length)
    assessment_rule.section.structure_component.update_attribute(:is_saved,"true")
    redirect_to("/rules/create_rule/#{params[:id]}?assessment=#{params[:assessment]}")
  end

  def view_questions_for_assessment_rule
    @assessment_rule = AssessmentRule.find(params[:id])
    tagvalue_ids = @assessment_rule.rules.pluck(:tagvalue_id)
    @question_attributes = get_question_attributes_for_tagvalues(@assessment_rule,tagvalue_ids)
  end

  def delete_assessment_rule
    assessment_rule = AssessmentRule.find(params[:id])
    section_id = assessment_rule.section_id
    assessment_rule.destroy
    redirect_to("/rules/create_rule/#{section_id}?assessment=#{params[:assessment]}")
  end

  def edit_assessment_rule
    @assessment_rule = AssessmentRule.find(params[:id])
    section_id = @assessment_rule.section_id
    redirect_to("/rules/edit_rule/#{params[:id]}?assessment=#{params[:assessment]}")
  end

  def update_rule
    @assessment_rule = AssessmentRule.find(params[:id])
    @assessment_rule.update_attribute(:questions_required,params[:no_of_questions].to_i)
    @assessment_rule.update_attribute(:positive_mark,params[:positive_mark].to_f)
    @assessment_rule.update_attribute(:negative_mark,params[:negative_mark].to_f)
    redirect_to("/rules/create_rule/#{@assessment_rule.section_id}?assessment=#{params[:assessment]}")
  end

end