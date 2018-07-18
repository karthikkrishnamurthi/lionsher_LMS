class QuestionAttributesController < ApplicationController
  # GET /question_attributes
  # GET /question_attributes.xml
  def index
    @question_attributes = QuestionAttribute.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @question_attributes }
    end
  end

  # GET /question_attributes/1
  # GET /question_attributes/1.xml
  def show
    @question_attribute = QuestionAttribute.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @question_attribute }
    end
  end

  # GET /question_attributes/new
  # GET /question_attributes/new.xml
  def new
    @question_attribute = QuestionAttribute.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @question_attribute }
    end
  end

  # GET /question_attributes/1/edit
  def edit
    @question_attribute = QuestionAttribute.find(params[:id])
  end

  # POST /question_attributes
  # POST /question_attributes.xml
  def create
    @question_attribute = QuestionAttribute.new(params[:question_attribute])

    respond_to do |format|
      if @question_attribute.save
        flash[:notice] = 'QuestionAttribute was successfully created.'
        format.html { redirect_to(@question_attribute) }
        format.xml  { render :xml => @question_attribute, :status => :created, :location => @question_attribute }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @question_attribute.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /question_attributes/1
  # PUT /question_attributes/1.xml
  def update
    @question_attribute = QuestionAttribute.find(params[:id])

    respond_to do |format|
      if @question_attribute.update_attributes(params[:question_attribute])
        flash[:notice] = 'QuestionAttribute was successfully updated.'
        format.html { redirect_to(@question_attribute) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @question_attribute.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /question_attributes/1
  # DELETE /question_attributes/1.xml
  def destroy
    @question_attribute = QuestionAttribute.find(params[:id])
    @question_attribute.destroy

    respond_to do |format|
      format.html { redirect_to(question_attributes_url) }
      format.xml  { head :ok }
    end
  end
end
