class AssessmentRulesController < ApplicationController
  # GET /assessment_rules
  # GET /assessment_rules.json
  def index
    @assessment_rules = AssessmentRule.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @assessment_rules }
    end
  end

  # GET /assessment_rules/1
  # GET /assessment_rules/1.json
  def show
    @assessment_rule = AssessmentRule.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @assessment_rule }
    end
  end

  # GET /assessment_rules/new
  # GET /assessment_rules/new.json
  def new
    @assessment_rule = AssessmentRule.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @assessment_rule }
    end
  end

  # GET /assessment_rules/1/edit
  def edit
    @assessment_rule = AssessmentRule.find(params[:id])
  end

  # POST /assessment_rules
  # POST /assessment_rules.json
  def create
    @assessment_rule = AssessmentRule.new(params[:assessment_rule])

    respond_to do |format|
      if @assessment_rule.save
        format.html { redirect_to @assessment_rule, notice: 'Assessment rule was successfully created.' }
        format.json { render json: @assessment_rule, status: :created, location: @assessment_rule }
      else
        format.html { render action: "new" }
        format.json { render json: @assessment_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /assessment_rules/1
  # PUT /assessment_rules/1.json
  def update
    @assessment_rule = AssessmentRule.find(params[:id])

    respond_to do |format|
      if @assessment_rule.update_attributes(params[:assessment_rule])
        format.html { redirect_to @assessment_rule, notice: 'Assessment rule was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @assessment_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assessment_rules/1
  # DELETE /assessment_rules/1.json
  def destroy
    @assessment_rule = AssessmentRule.find(params[:id])
    @assessment_rule.destroy

    respond_to do |format|
      format.html { redirect_to assessment_rules_url }
      format.json { head :no_content }
    end
  end
end
