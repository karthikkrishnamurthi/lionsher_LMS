class QuestionStatusesController < ApplicationController
  # GET /question_statuses
  # GET /question_statuses.json
  def index
    @question_statuses = QuestionStatus.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @question_statuses }
    end
  end

  # GET /question_statuses/1
  # GET /question_statuses/1.json
  def show
    @question_status = QuestionStatus.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @question_status }
    end
  end

  # GET /question_statuses/new
  # GET /question_statuses/new.json
  def new
    @question_status = QuestionStatus.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @question_status }
    end
  end

  # GET /question_statuses/1/edit
  def edit
    @question_status = QuestionStatus.find(params[:id])
  end

  # POST /question_statuses
  # POST /question_statuses.json
  def create
    @question_status = QuestionStatus.new(params[:question_status])

    respond_to do |format|
      if @question_status.save
        format.html { redirect_to @question_status, notice: 'Question status was successfully created.' }
        format.json { render json: @question_status, status: :created, location: @question_status }
      else
        format.html { render action: "new" }
        format.json { render json: @question_status.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /question_statuses/1
  # PUT /question_statuses/1.json
  def update
    @question_status = QuestionStatus.find(params[:id])

    respond_to do |format|
      if @question_status.update_attributes(params[:question_status])
        format.html { redirect_to @question_status, notice: 'Question status was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @question_status.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /question_statuses/1
  # DELETE /question_statuses/1.json
  def destroy
    @question_status = QuestionStatus.find(params[:id])
    @question_status.destroy

    respond_to do |format|
      format.html { redirect_to question_statuses_url }
      format.json { head :no_content }
    end
  end

  # This code will be executed only once
  def create_question_statuses
    question_status = QuestionStatus.find_by_status_value("active")
    if question_status.nil? or question_status.blank?
      question_status = QuestionStatus.new
      question_status.status_value = "active"
      question_status.save
      question_status = QuestionStatus.new
      question_status.status_value = "inactive"
      question_status.save
      question_status = QuestionStatus.new
      question_status.status_value = "archieved"
      question_status.save
    end
  end

end