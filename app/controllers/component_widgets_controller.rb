class ComponentWidgetsController < ApplicationController
  # GET /component_widgets
  # GET /component_widgets.json
  def index
    @component_widgets = ComponentWidget.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @component_widgets }
    end
  end

  # GET /component_widgets/1
  # GET /component_widgets/1.json
  def show
    @component_widget = ComponentWidget.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @component_widget }
    end
  end

  # GET /component_widgets/new
  # GET /component_widgets/new.json
  def new
    @component_widget = ComponentWidget.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @component_widget }
    end
  end

  # GET /component_widgets/1/edit
  def edit
    @component_widget = ComponentWidget.find(params[:id])
  end

  # POST /component_widgets
  # POST /component_widgets.json
  def create
    @component_widget = ComponentWidget.new(params[:component_widget])

    respond_to do |format|
      if @component_widget.save
        format.html { redirect_to @component_widget, notice: 'Component widget was successfully created.' }
        format.json { render json: @component_widget, status: :created, location: @component_widget }
      else
        format.html { render action: "new" }
        format.json { render json: @component_widget.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /component_widgets/1
  # PUT /component_widgets/1.json
  def update
    @component_widget = ComponentWidget.find(params[:id])

    respond_to do |format|
      if @component_widget.update_attributes(params[:component_widget])
        format.html { redirect_to @component_widget, notice: 'Component widget was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @component_widget.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /component_widgets/1
  # DELETE /component_widgets/1.json
  def destroy
    @component_widget = ComponentWidget.find(params[:id])
    @component_widget.destroy

    respond_to do |format|
      format.html { redirect_to component_widgets_url }
      format.json { head :no_content }
    end
  end

  def create_component_widgets
    logger.info"PARAMS in create_component_widgets #{params.inspect}"
    @report_component = ReportComponent.find(params[:id])
    @component_widgets = @report_component.component_widgets
    @widgets = Widget.all
  end

  def save_component_widget
    component_widget = ComponentWidget.new
    component_widget.report_component_id = params[:id]
    component_widget.widget_id = params[:widget]
    component_widget.save
    redirect_to("/component_widgets/create_component_widgets/#{params[:id]}")
  end
end
