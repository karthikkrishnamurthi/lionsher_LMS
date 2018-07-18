class WidgetsController < ApplicationController
  # GET /widgets
  # GET /widgets.json
  def index    
    @widgets = Widget.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @widgets }
    end
  end

  # GET /widgets/1
  # GET /widgets/1.json
  def show
    logger.info"PARAMS in show #{params.inspect}"
    @widget = Widget.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @widget }
    end
  end

  # GET /widgets/new
  # GET /widgets/new.json
  def new
    logger.info"PARAMS in new #{params.inspect}"
    @widget = Widget.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @widget }
    end
  end

  # GET /widgets/1/edit
  def edit
    @widget = Widget.find(params[:id])
  end

  # POST /widgets
  # POST /widgets.json
  def create
    logger.info"PARAMS in create #{params.inspect}"
    @widget = Widget.new(params[:widget])

    respond_to do |format|
      if @widget.save
        logger.info"saved properly #{@widget.inspect}"
        format.html { redirect_to widgets_url, notice: 'Widget was successfully created.' }
        format.json { render json: @widget, status: :created, location: @widget }
      else
        format.html { render action: "new" }
        format.json { render json: @widget.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /widgets/1
  # PUT /widgets/1.json
  def update
    @widget = Widget.find(params[:id])

    respond_to do |format|
      if @widget.update_attributes(params[:widget])
        format.html { redirect_to widgets_url, notice: 'Widget was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @widget.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /widgets/1
  # DELETE /widgets/1.json
  def destroy
    @widget = Widget.find(params[:id])
    @widget.destroy

    respond_to do |format|
      format.html { redirect_to widgets_url }
      format.json { head :no_content }
    end
  end

  def fill_default_widgets
    w = Widget.find_by_name("2 tiles")
    if w.nil? or w.blank?
      widget = Widget.new
      widget.name = "2 tiles"
      widget.div_name = "two_tiles" # In styling div id can't start with integer
      widget.save
      widget = Widget.new
      widget.name = "3 tiles"
      widget.div_name = "three_tiles" # In styling div id can't start with integer
      widget.save
      widget = Widget.new
      widget.name = "4 tiles"
      widget.div_name = "four_tiles" # In styling div id can't start with integer
      widget.save
      widget = Widget.new
      widget.name = "list"
      widget.div_name = "list"
      widget.save
      widget = Widget.new
      widget.name = "text"
      widget.div_name = "text"
      widget.save
      widget = Widget.new
      widget.name = "sheet"
      widget.div_name = "sheet"
      widget.save
      widget = Widget.new
      widget.name = "graph"
      widget.div_name = "graph"
      widget.save
      widget = Widget.new
      widget.name = "table"
      widget.div_name = "table"
      widget.save
    end
  end
end
