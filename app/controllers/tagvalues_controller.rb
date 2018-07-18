class TagvaluesController < ApplicationController
  # GET /tagvalues
  # GET /tagvalues.xml
  def index
    @tagvalues = Tagvalue.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tagvalues }
    end
  end

  # GET /tagvalues/1
  # GET /tagvalues/1.xml
  def show
    @tagvalue = Tagvalue.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tagvalue }
    end
  end

  # GET /tagvalues/new
  # GET /tagvalues/new.xml
  def new
    @tagvalue = Tagvalue.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tagvalue }
    end
  end

  # GET /tagvalues/1/edit
  def edit
    @tagvalue = Tagvalue.find(params[:id])
  end

  # POST /tagvalues
  # POST /tagvalues.xml
  def create
    @tagvalue = Tagvalue.new(params[:tagvalue])

    respond_to do |format|
      if @tagvalue.save
        flash[:notice] = 'Tagvalue was successfully created.'
        format.html { redirect_to(@tagvalue) }
        format.xml  { render :xml => @tagvalue, :status => :created, :location => @tagvalue }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tagvalue.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tagvalues/1
  # PUT /tagvalues/1.xml
  def update
    @tagvalue = Tagvalue.find(params[:id])

    respond_to do |format|
      if @tagvalue.update_attributes(params[:tagvalue])
        flash[:notice] = 'Tagvalue was successfully updated.'
        format.html { redirect_to(@tagvalue) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tagvalue.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tagvalues/1
  # DELETE /tagvalues/1.xml
  def destroy
    @tagvalue = Tagvalue.find(params[:id])
    @tagvalue.destroy

    respond_to do |format|
      format.html { redirect_to(tagvalues_url) }
      format.xml  { head :ok }
    end
  end
end
