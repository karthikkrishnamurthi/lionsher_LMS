class QuestionTagsController < ApplicationController
  # GET /question_tags
  # GET /question_tags.json
  def index
    @question_tags = QuestionTag.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @question_tags }
    end
  end

  # GET /question_tags/1
  # GET /question_tags/1.json
  def show
    @question_tag = QuestionTag.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @question_tag }
    end
  end

  # GET /question_tags/new
  # GET /question_tags/new.json
  def new
    @question_tag = QuestionTag.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @question_tag }
    end
  end

  # GET /question_tags/1/edit
  def edit
    @question_tag = QuestionTag.find(params[:id])
  end

  # POST /question_tags
  # POST /question_tags.json
  def create
    @question_tag = QuestionTag.new(params[:question_tag])

    respond_to do |format|
      if @question_tag.save
        format.html { redirect_to @question_tag, notice: 'Question tag was successfully created.' }
        format.json { render json: @question_tag, status: :created, location: @question_tag }
      else
        format.html { render action: "new" }
        format.json { render json: @question_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /question_tags/1
  # PUT /question_tags/1.json
  def update
    @question_tag = QuestionTag.find(params[:id])

    respond_to do |format|
      if @question_tag.update_attributes(params[:question_tag])
        format.html { redirect_to @question_tag, notice: 'Question tag was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @question_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /question_tags/1
  # DELETE /question_tags/1.json
  def destroy
    @question_tag = QuestionTag.find(params[:id])
    @question_tag.destroy

    respond_to do |format|
      format.html { redirect_to question_tags_url }
      format.json { head :no_content }
    end
  end
end
