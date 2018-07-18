class LearnerQuestionsController < ApplicationController
  # GET /learner_questions
  # GET /learner_questions.xml
  def index
    @learner_questions = LearnerQuestion.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @learner_questions }
    end
  end

  # GET /learner_questions/1
  # GET /learner_questions/1.xml
  def show
    @learner_question = LearnerQuestion.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @learner_question }
    end
  end

  # GET /learner_questions/new
  # GET /learner_questions/new.xml
  def new
    @learner_question = LearnerQuestion.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @learner_question }
    end
  end

  # GET /learner_questions/1/edit
  def edit
    @learner_question = LearnerQuestion.find(params[:id])
  end

  # POST /learner_questions
  # POST /learner_questions.xml
  def create
    @learner_question = LearnerQuestion.new(params[:learner_question])

    respond_to do |format|
      if @learner_question.save
        flash[:notice] = 'LearnerQuestion was successfully created.'
        format.html { redirect_to(@learner_question) }
        format.xml  { render :xml => @learner_question, :status => :created, :location => @learner_question }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @learner_question.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /learner_questions/1
  # PUT /learner_questions/1.xml
  def update
    @learner_question = LearnerQuestion.find(params[:id])

    respond_to do |format|
      if @learner_question.update_attributes(params[:learner_question])
        flash[:notice] = 'LearnerQuestion was successfully updated.'
        format.html { redirect_to(@learner_question) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @learner_question.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /learner_questions/1
  # DELETE /learner_questions/1.xml
  def destroy
    @learner_question = LearnerQuestion.find(params[:id])
    @learner_question.destroy

    respond_to do |format|
      format.html { redirect_to(learner_questions_url) }
      format.xml  { head :ok }
    end
  end
end
