class QuestionTypesController < ApplicationController
  # GET /question_types
  # GET /question_types.json
  def index
    @question_types = QuestionType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @question_types }
    end
  end

  # GET /question_types/1
  # GET /question_types/1.json
  def show
    @question_type = QuestionType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @question_type }
    end
  end

  # GET /question_types/new
  # GET /question_types/new.json
  def new
    @question_type = QuestionType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @question_type }
    end
  end

  # GET /question_types/1/edit
  def edit
    @question_type = QuestionType.find(params[:id])
  end

  # POST /question_types
  # POST /question_types.json
  def create
    @question_type = QuestionType.new(params[:question_type])

    respond_to do |format|
      if @question_type.save
        format.html { redirect_to @question_type, notice: 'Question type was successfully created.' }
        format.json { render json: @question_type, status: :created, location: @question_type }
      else
        format.html { render action: "new" }
        format.json { render json: @question_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /question_types/1
  # PUT /question_types/1.json
  def update
    @question_type = QuestionType.find(params[:id])

    respond_to do |format|
      if @question_type.update_attributes(params[:question_type])
        format.html { redirect_to @question_type, notice: 'Question type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @question_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /question_types/1
  # DELETE /question_types/1.json
  def destroy
    @question_type = QuestionType.find(params[:id])
    @question_type.destroy

    respond_to do |format|
      format.html { redirect_to question_types_url }
      format.json { head :no_content }
    end
  end

  # This code will be executed only once
  def create_all_question_types
    question_type = QuestionType.find_by_value("MCQ")
    if question_type.nil? or question_type.blank?
      question_type = QuestionType.new
      question_type.value = "MCQ"
      question_type.save
      question_type = QuestionType.new
      question_type.value = "MAQ"
      question_type.save
      question_type = QuestionType.new
      question_type.value = "FIB"
      question_type.save
      question_type = QuestionType.new
      question_type.value = "SA"
      question_type.save
      question_type = QuestionType.new
      question_type.value = "PTQ"
      question_type.save
    end
  end

end