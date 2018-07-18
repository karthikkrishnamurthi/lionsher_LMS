class QuestionBanksController < ApplicationController
  before_filter :login_required
  before_filter :is_expired?

  def index
    @question_banks = current_user.question_banks.find(:all, :order => "id DESC")
  end

  def show
    if params.include? 'wrong_entries' then
      @wrong_entries = params[:wrong_entries].to_i
    end
    if params.include? 'assessment_id' then
      @obj_assessment = Assessment.find_by_id(params[:assessment_id])
    end
    @question_bank = QuestionBank.find(params[:id])
    @questions = Question.find(:all, :conditions => ["question_bank_id = ?",(params[:id])], :include => :answers, :order => "id")
  end

  def new
    @obj_assessment = Assessment.find_by_id(params[:id])
    @obj_question_bank = QuestionBank.find_by_id(params[:question_bank_id])
    @question_bank = QuestionBank.new
  end

  def edit
    @question_bank = QuestionBank.find(params[:id])
  end

  def update
    @question_bank = QuestionBank.find(params[:id])
    @question_bank.update_attributes(params[:question_bank])
    redirect_to(@question_bank)
  end

  def destroy
    question_bank = QuestionBank.find(params[:id], :include => :questions)
    question_bank.questions.each do| question |
      if question.question_type == "MTF" or question.question_type == "mtf" then
        sub_questions = Question.find(:all, :conditions => ["mtf_id = ?",question.id], :include => :answers)
        sub_questions.each do |sub_q|
          sub_q.answers.each do | ans |
            ans.destroy
          end
          sub_q.destroy
        end
      else
        question.answers.each do | ans |
          ans.destroy
        end
      end
      question.destroy
    end
#    assessment_question_banks = AssessmentsQuestionBank.find_all_by_question_bank_id(question_bank.id)
#    assessment_question_banks.each{|assessment_qb|
#      delete_assessment_dependencies(assessment_qb.assessment)
#    }
    question_bank.destroy

    respond_to do |format|
      format.html { redirect_to(question_banks_url) }
    end
  end

  # v2 related methods starts here
  def create_new_question_bank

end

  def save_question_bank
    create_question_bank(params[:qb],current_user.tenant_id,current_user.id)
    redirect_to("/question_banks/question_bank_list/#{current_user.id}")
  end

  def question_bank_list
    all_question_banks = QuestionBank.where("user_id = ?",current_user.id).includes([:questions,:topics,:subtopics,:errors]).order("id desc")
    @question_banks = all_question_banks.paginate(:page => params[:page])
  end

  def show_all_questions
    @question_bank = QuestionBank.find(params[:id])
    @question_attributes = QuestionAttribute.where(:question_bank_id => params[:id]).includes([{:question => :answers},{:question => :image},{:question => :directions},{:question => :passages},{:question => :tagvalues},:topic,:subtopic,:error,:difficulty]).order("id asc")
  end

  def show_all_active_questions
    @question_bank = QuestionBank.find(params[:id])
    @questions = @question_bank.question_attributes.find(:all, :conditions => "question_status_id = 1", :include => [{:question => :answers},:topic,:subtopic,:error,:difficulty])
  end

  def show_all_inactive_questions
    @question_bank = QuestionBank.find(params[:id])
    @questions = @question_bank.question_attributes.find(:all, :conditions => "question_status_id = 2", :include => [{:question => :answers},:topic,:subtopic,:error,:difficulty])
  end

  def show_all_error_questions
    @question_bank = QuestionBank.find(params[:id])
    @questions = @question_bank.question_attributes.find(:all, :conditions => "error_id IS NOT NULL", :include => [{:question => :answers},:topic,:subtopic,:error,:difficulty])
  end

  def topic_list
    @question_bank = QuestionBank.find(params[:id])
    @topics = Topic.where(:question_bank_id => params[:id]).find(:all, :include => [:questions,:subtopics,:errors])
  end

  def create_new_topic
    @question_bank = QuestionBank.find(params[:id])
  end

  def subtopic_list
    @question_bank = QuestionBank.find(params[:id])
    @topic = Topic.find(params[:topic])
    @subtopics = Subtopic.where(:topic_id => params[:topic]).find(:all, :include => [:questions,:errors])
  end

  def create_new_subtopic
    @question_bank = QuestionBank.find(params[:id])
    @topic = Topic.find(params[:topic])
  end

  def question_list
    @question_bank = QuestionBank.find(params[:id])
    @subtopic = Subtopic.find(params[:subtopic].to_i, :include => [:topics,:questions,:topics,:question_types,:question_statuses])
    @topic = @subtopic.topics[0]
    @questions = @subtopic.question_attributes
  end

  def questions_upload_summary
    @question_bank = QuestionBank.find(params[:id])
    @topics = @question_bank.topics.find(:all, :include => [:questions,:errors,{:subtopics => :questions},{:subtopics => :errors}]).uniq
  end

  def upload_questions
    @question_bank = QuestionBank.find(params[:id])
  end

  def send_all_these_questions_to_another_question_bank
    @question_bank = QuestionBank.find(params[:id])
    @question_bank.questions.each do |question|
      send_question_to_another_question_bank(question.id,params[:new_question_bank_id],current_user.tenant_id)
    end
    redirect_to("/question_banks/question_bank_list/#{current_user.tenant_id}")
  end

  def delete_related_data_for_question_bank
    question_bank = QuestionBank.find(params[:id])
    unless question_bank.type_of_question_bank.nil? or question_bank.type_of_question_bank.blank?
      unless question_bank.type_of_question_bank.downcase == "default"
        delete_questions_and_related_data(question_bank)
        question_bank.destroy
      else
        delete_questions_and_related_data(question_bank)
      end
    else
      delete_questions_and_related_data(question_bank)
    end
    if params.include? "page"
      redirect_to("/question_banks/question_bank_list/#{current_user.id}?page=#{params[:page]}")
    else
      redirect_to("/question_banks/question_bank_list/#{current_user.id}")
    end
  end

  def delete_questions_and_related_data(question_bank)
    question_bank.questions.each do |q|
      q.answers.each do |a|
        a.destroy
      end
      q.destroy
    end
    question_bank.question_attributes.each do |qa|
      unless qa.topic.nil? or qa.topic.blank?
        qa.topic.destroy
      end
      unless qa.subtopic.nil? or qa.subtopic.blank?
        qa.subtopic.destroy
      end
      unless qa.direction.nil? or qa.direction.blank?
        qa.direction.destroy
      end
      unless qa.passage.nil? or qa.passage.blank?
        qa.passage.destroy
      end
      qa.destroy
    end
  end

  def delete_qb
    question_bank = QuestionBank.find(params[:id])
    question_bank.destroy
    if params.include? "page"
      redirect_to("/question_banks/question_bank_list/#{current_user.id}?page=#{params[:page]}")
    else
      redirect_to("/question_banks/question_bank_list/#{current_user.id}")
    end
  end
  # v2 related methods ends here

end
