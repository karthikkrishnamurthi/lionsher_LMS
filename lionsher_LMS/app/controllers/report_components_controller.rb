class ReportComponentsController < ApplicationController
  # GET /report_components
  # GET /report_components.json
  def index
    @report_components = ReportComponent.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @report_components }
    end
  end

  # GET /report_components/1
  # GET /report_components/1.json
  def show
    @report_component = ReportComponent.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @report_component }
    end
  end

  # GET /report_components/new
  # GET /report_components/new.json
  def new
    @report_component = ReportComponent.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @report_component }
    end
  end

  # GET /report_components/1/edit
  def edit
    @report_component = ReportComponent.find(params[:id])
  end

  # POST /report_components
  # POST /report_components.json
  def create
    @report_component = ReportComponent.new(params[:report_component])

    respond_to do |format|
      if @report_component.save
        format.html { redirect_to @report_component, notice: 'Report component was successfully created.' }
        format.json { render json: @report_component, status: :created, location: @report_component }
      else
        format.html { render action: "new" }
        format.json { render json: @report_component.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /report_components/1
  # PUT /report_components/1.json
  def update
    @report_component = ReportComponent.find(params[:id])

    respond_to do |format|
      if @report_component.update_attributes(params[:report_component])
        format.html { redirect_to @report_component, notice: 'Report component was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @report_component.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /report_components/1
  # DELETE /report_components/1.json
  def destroy
    @report_component = ReportComponent.find(params[:id])
    @report_component.destroy

    respond_to do |format|
      format.html { redirect_to report_components_url }
      format.json { head :no_content }
    end
  end

  def create_report_components
    @template = ReportTemplate.find(params[:id])
    @report_components = @template.report_components
  end

  def save_report_components
    report_component = ReportComponent.new
    report_component.component_name = params[:report_component]
    report_component.report_template_id = params[:id]
    report_component.save
    redirect_to("/report_components/create_report_components/#{params[:id]}")
  end
end
