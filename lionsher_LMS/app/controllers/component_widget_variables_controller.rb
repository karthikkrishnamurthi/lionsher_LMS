class ComponentWidgetVariablesController < ApplicationController
  # GET /component_widget_variables
  # GET /component_widget_variables.json
  def index
    @component_widget_variables = ComponentWidgetVariable.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @component_widget_variables }
    end
  end

  # GET /component_widget_variables/1
  # GET /component_widget_variables/1.json
  def show
    @component_widget_variable = ComponentWidgetVariable.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @component_widget_variable }
    end
  end

  # GET /component_widget_variables/new
  # GET /component_widget_variables/new.json
  def new
    @component_widget_variable = ComponentWidgetVariable.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @component_widget_variable }
    end
  end

  # GET /component_widget_variables/1/edit
  def edit
    @component_widget_variable = ComponentWidgetVariable.find(params[:id])
  end

  # POST /component_widget_variables
  # POST /component_widget_variables.json
  def create
    @component_widget_variable = ComponentWidgetVariable.new(params[:component_widget_variable])

    respond_to do |format|
      if @component_widget_variable.save
        format.html { redirect_to @component_widget_variable, notice: 'Component widget variable was successfully created.' }
        format.json { render json: @component_widget_variable, status: :created, location: @component_widget_variable }
      else
        format.html { render action: "new" }
        format.json { render json: @component_widget_variable.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /component_widget_variables/1
  # PUT /component_widget_variables/1.json
  def update
    @component_widget_variable = ComponentWidgetVariable.find(params[:id])

    respond_to do |format|
      if @component_widget_variable.update_attributes(params[:component_widget_variable])
        format.html { redirect_to @component_widget_variable, notice: 'Component widget variable was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @component_widget_variable.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /component_widget_variables/1
  # DELETE /component_widget_variables/1.json
  def destroy
    @component_widget_variable = ComponentWidgetVariable.find(params[:id])
    @component_widget_variable.destroy

    respond_to do |format|
      format.html { redirect_to component_widget_variables_url }
      format.json { head :no_content }
    end
  end

  def create_component_widget_variables
    logger.info"PARAMS in create_component_widget_variables #{params.inspect}"
    @component_widget = ComponentWidget.find(params[:id])
    @existing_report_variables = @component_widget.report_variables
    @report_variables = ReportVariable.all
  end

  def save_component_widget_variables
    logger.info"PARAMS in save_component_widget_variables #{params.inspect}"
    @component_widget = ComponentWidget.find(params[:id])
    component_widget_variable = ComponentWidgetVariable.new
    if @component_widget.widget.name == "text"
      component_widget_variable.report_text = params[:report_variable]
    else
      component_widget_variable.report_variable_id = params[:report_variable]
    end    
    component_widget_variable.component_widget_id = params[:id]
    component_widget_variable.save
    redirect_to("/component_widget_variables/create_component_widget_variables/#{params[:id]}?template=#{params[:template]}")
  end
end
