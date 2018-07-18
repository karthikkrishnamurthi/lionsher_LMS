class ReportTemplatesController < ApplicationController
  before_filter :login_required
  before_filter :is_expired?
  # GET /report_templates
  # GET /report_templates.json
  def index
    @report_templates = ReportTemplate.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @report_templates }
    end
  end

  # GET /report_templates/1
  # GET /report_templates/1.json
  def show
    @report_template = ReportTemplate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @report_template }
    end
  end

  # GET /report_templates/new
  # GET /report_templates/new.json
  def new
    @report_template = ReportTemplate.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @report_template }
    end
  end

  # GET /report_templates/1/edit
  def edit
    @report_template = ReportTemplate.find(params[:id])
  end

  # POST /report_templates
  # POST /report_templates.json
  def create
    @report_template = ReportTemplate.new(params[:report_template])

    respond_to do |format|
      if @report_template.save
        format.html { redirect_to("/report_templates/show_templates/#{current_user.id}") }
        format.json { render json: @report_template, status: :created, location: @report_template }
      else
        format.html { render action: "new" }
        format.json { render json: @report_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /report_templates/1
  # PUT /report_templates/1.json
  def update
    @report_template = ReportTemplate.find(params[:id])

    respond_to do |format|
      if @report_template.update_attributes(params[:report_template])
        format.html { redirect_to report_templates_url, notice: 'Report template was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @report_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /report_templates/1
  # DELETE /report_templates/1.json
  def destroy
    @report_template = ReportTemplate.find(params[:id])
    @report_template.destroy

    respond_to do |format|
      format.html { redirect_to report_templates_url }
      format.json { head :no_content }
    end
  end

  def show_templates
    @templates = ReportTemplate.all
  end

  # When a template is deleted then all the dependent rows in the associated tables
  # are deleted using "dependent => destroy" in the associations defined in report_template model.
  def delete_template
    @report_template = ReportTemplate.find(params[:id])
    @report_template.destroy
    redirect_to("/report_templates/show_templates/#{current_user.id}")
  end
end
