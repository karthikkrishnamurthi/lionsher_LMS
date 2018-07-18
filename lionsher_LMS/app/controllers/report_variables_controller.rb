class ReportVariablesController < ApplicationController
  # GET /report_variables
  # GET /report_variables.json
  def index
    @report_variables = ReportVariable.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @report_variables }
    end
  end

  # GET /report_variables/1
  # GET /report_variables/1.json
  def show
    @report_variable = ReportVariable.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @report_variable }
    end
  end

  # GET /report_variables/new
  # GET /report_variables/new.json
  def new
    @report_variable = ReportVariable.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @report_variable }
    end
  end

  # GET /report_variables/1/edit
  def edit
    @report_variable = ReportVariable.find(params[:id])
  end

  # POST /report_variables
  # POST /report_variables.json
  def create
    @report_variable = ReportVariable.new(params[:report_variable])
    method_name = params[:report_variable][:name].split(" ").join("_").downcase
    @report_variable.method_name = method_name

    respond_to do |format|
      if @report_variable.save
        format.html { redirect_to report_variables_url, notice: 'Report variable was successfully created.' }
        format.json { render json: @report_variable, status: :created, location: @report_variable }
      else
        format.html { render action: "new" }
        format.json { render json: @report_variable.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /report_variables/1
  # PUT /report_variables/1.json
  def update
    @report_variable = ReportVariable.find(params[:id])

    respond_to do |format|
      if @report_variable.update_attributes(params[:report_variable])
        format.html { redirect_to report_variables_url, notice: 'Report variable was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @report_variable.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /report_variables/1
  # DELETE /report_variables/1.json
  def destroy
    @report_variable = ReportVariable.find(params[:id])
    @report_variable.destroy

    respond_to do |format|
      format.html { redirect_to report_variables_url }
      format.json { head :no_content }
    end
  end

  def fill_default_report_variables
    r = ReportVariable.find_by_name("score")
    if r.nil? or r.blank?
      report_variable = ReportVariable.new
      report_variable.name = "student name"
      report_variable.method_name = "student_name"
      report_variable.save
      report_variable = ReportVariable.new
      report_variable.name = "group name"
      report_variable.method_name = "group_name"
      report_variable.save
      report_variable = ReportVariable.new
      report_variable.name = "test name"
      report_variable.method_name = "test_name"
      report_variable.save
      report_variable = ReportVariable.new
      report_variable.name = "date"
      report_variable.method_name = "date"
      report_variable.save
      report_variable = ReportVariable.new
      report_variable.name = "profile"
      report_variable.method_name = "profile"
      report_variable.save
      report_variable = ReportVariable.new
      report_variable.name = "score"
      report_variable.method_name = "score"
      report_variable.save
      report_variable = ReportVariable.new
      report_variable.name = "rank"
      report_variable.method_name = "rank"
      report_variable.save
      report_variable = ReportVariable.new
      report_variable.name = "result"
      report_variable.method_name = "result"
      report_variable.save
      report_variable = ReportVariable.new
      report_variable.name = "percentage"
      report_variable.method_name = "percentage"
      report_variable.save
      report_variable = ReportVariable.new
      report_variable.name = "percentile"
      report_variable.method_name = "percentile"
      report_variable.save
      report_variable = ReportVariable.new
      report_variable.name = "correct answer count"
      report_variable.method_name = "correct_answer_count"
      report_variable.save
      report_variable = ReportVariable.new
      report_variable.name = "incorrect answer count"
      report_variable.method_name = "incorrect_answer_count"
      report_variable.save
      report_variable = ReportVariable.new
      report_variable.name = "time spent"
      report_variable.method_name = "time_spent"
      report_variable.save
      report_variable = ReportVariable.new
      report_variable.name = "question wise report"
      report_variable.method_name = "question_wise_report"
      report_variable.save
      report_variable = ReportVariable.new
      report_variable.name = "frequency analysis graph"
      report_variable.method_name = "frequency_analysis_graph"
      report_variable.save
      report_variable = ReportVariable.new
      report_variable.name = "score by topic"
      report_variable.method_name = "score_by_topic"
      report_variable.save
      report_variable = ReportVariable.new
      report_variable.name = "test summary graph"
      report_variable.method_name = "test_summary_graph"
      report_variable.save
    end
  end

  def add_more_report_variables_for_admin_report
    r = ReportVariable.find_by_name("progress report")
    if r.nil? or r.blank?
      report_variable = ReportVariable.new
      report_variable.name = "progress report"
      report_variable.method_name = "progress_report"
      report_variable.save
      report_variable = ReportVariable.new
      report_variable.name = "progress report graph"
      report_variable.method_name = "progress_report_graph"
      report_variable.save
      report_variable = ReportVariable.new
      report_variable.name = "question analysis report"
      report_variable.method_name = "question_analysis_report"
      report_variable.save     
    end
  end
end
