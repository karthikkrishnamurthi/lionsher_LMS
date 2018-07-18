class QuestionsController < ApplicationController
  before_filter :login_required
  before_filter :is_expired?

  def index
    @questions = Question.all
  end

  def new
    @question = Question.new
  end

  def edit
    @obj_assessment = Assessment.find_by_id(params[:assessment_id])
    @question = Question.find(params[:id], :include => :answers)
    # @answers = Answer.find_all_by_question_id(@question.id, :order => 'id')
  end

  def create
    @question = Question.new(params[:question_text])
    @question.save
    flash[:notice] = 'Question was successfully created.'
    redirect_to('/questions')
  end

  def update
    question = Question.find(params[:id])
    question.update_attributes(params[:question])
    question.update_attribute("question_text",params[:question_text])
    question.update_attribute("explanation",params[:explanation_text])

    unless params[:ans].nil? or params[:ans].blank?
      params[:ans].each_pair {|key,value|
        answer = Answer.find(key)
        answer.update_attribute(:answer_image, value)
      }
    end
    
    question_attribute = get_question_attribute(question.id)
    if question_attribute.nil? or question_attribute.blank?
      assessment = Assessment.find(params[:assessment_id])
      question_type_id = get_question_type(question.question_type).id
      difficulty_id = get_difficulty("not defined")
      question_attribute = create_question_attribute(question.id,question_type_id,params[:question_bank_id],"","",difficulty_id,"","","",1,assessment.tenant_id)
    end
    if params.include? "answer" and !(params[:answer].nil? or params[:answer].blank?)
      update_answers_from_param(params[:answer],params[:correct_answer],question_attribute)
    end
    for i in 1..(5 - question.answers.length)
      create_new_answer_from_params(params[:new_answer][i.to_s],params[:new_correct_answer].to_i,question,i,params[:question_bank_id])
    end
    unless question_attribute.direction.nil?
      question_attribute.direction.update_attribute("direction_text",params[:direction_text])
    else
      direction_obj = create_direction(params[:direction_text],question_attribute.question_bank_id,question_attribute.tenant_id)
      question_attribute.update_attribute("direction_id",direction_obj.id)
    end
    unless question_attribute.passage.nil?
      question_attribute.passage.update_attribute("passage_text",params[:passage_text])
    else
      passage_obj = create_passage(params[:passage_text],question_attribute.question_bank_id,question_attribute.tenant_id)
      question_attribute.update_attribute("passage_id",passage_obj.id)
    end    

    unless params[:mark].nil? or params[:mark].blank?
      assessment = Assessment.find(params[:assessment_id].to_i)
      edit_assessment_question_mapping(assessment,question,params[:mark],params[:negative_mark])      
    end
    if params.include? 'control_from_edit_questions_page' then
      redirect_to('/question_banks/'+params[:question_bank_id]+'?assessment_id='+params[:assessment_id]+'&control_from_edit_questions_page=')
    else
      redirect_to('/question_banks/'+params[:question_bank_id]+'?assessment_id='+params[:assessment_id])
    end
  end

  def destroy
    question = Question.find(params[:id])
    question_attribute = QuestionAttribute.find_by_question_id(question.id)
    question.answers.each do | ans |
      ans.destroy
    end    
    question.destroy
    unless question_attribute.nil?
      question_attribute.destroy
    end
    obj_question_bank = QuestionBank.find(params[:question_bank_id])
    obj_question_bank.update_attribute('no_of_questions', obj_question_bank.no_of_questions - 1)
    obj_assessment = Assessment.find(params[:assessment_id])
    obj_assessment.update_attribute('no_of_questions', obj_assessment.no_of_questions - 1)
    assessment_question_bank = AssessmentsQuestionBank.find_by_assessment_id_and_question_bank_id(obj_assessment.id,obj_question_bank.id)
    assessment_question_bank.update_attribute('question_limit', assessment_question_bank.question_limit - 1)
    redirect_to('/question_banks/'+question.question_bank_id.to_s+'?assessment_id='+params[:assessment_id])
  end

  def show
    @assessment = Assessment.find_by_id(params[:id])
  end

  def show_question_attributes
    @question = Question.find(params[:id])
    @question_attributes = QuestionAttribute.find_all_by_question_id(params[:id])
  end

  def edit_question
    @question = Question.find(params[:id])
    @question_number = params[:number]
    @question_bank = QuestionBank.find(params[:qb])
    @topics = @question_bank.topics.uniq
    @subtopics = @question_bank.subtopics.uniq
    @question_banks = QuestionBank.find(:all, :order => "name")
    @difficulties = Difficulty.find(:all, :conditions => "difficulty_value != 'all'")
    @tagvalues = @question.tagvalues
    @tags = Tag.all
    @date = DateTime.now
  end

  def update_question
    question = Question.find(params[:id])
    if params[:qb] != params[:new_question_bank_id]
      send_question_to_another_question_bank(params[:id],params[:new_question_bank_id])
    else
      question_attribute = get_question_attribute(question.id)
      if params.include? "answer" and !(params[:answer].nil? or params[:answer].blank?)
        update_answers_from_param(params[:answer],params[:correct_answer],question_attribute)
      end
      for i in 1..(5 - question.answers.length)
        if params.include?"new_correct_answer"
          if question.question_type == "MAQ"
            create_new_answer_from_params(params[:new_answer][i.to_s],params[:new_correct_answer][i.to_s].to_i,question,i,params[:qb])
          else
            create_new_answer_from_params(params[:new_answer][i.to_s],params[:new_correct_answer].to_i,question,i,params[:qb])
          end
        end
      end
      question.update_attribute("question_text",params[:question_text])
      question.update_attribute("explanation",params[:explanation_text])
      question_attribute.update_attribute("topic_id",params[:topic].to_i)
      question_attribute.update_attribute("subtopic_id",params[:subtopic].to_i)
      question_attribute.update_attribute("difficulty_id",params[:difficulty].to_i)
      unless question_attribute.direction.nil?
        question_attribute.direction.update_attribute("direction_text",params[:direction_text])
      else
        direction_obj = create_direction(params[:direction_text],question_attribute.question_bank_id,question_attribute.tenant_id)
        question_attribute.update_attribute("direction_id",direction_obj.id)
      end
      unless question_attribute.passage.nil?
        question_attribute.passage.update_attribute("passage_text",params[:passage_text])
      else
        passage_obj = create_passage(params[:passage_text],question_attribute.question_bank_id,question_attribute.tenant_id)
        question_attribute.update_attribute("passage_id",passage_obj.id)
      end
    end
    if params.include? "tagvalue"
      params[:tagvalue].each_pair do |tag_id, tagvalue_id|
        if question.question_tags.nil? or question.question_tags.blank?
          question_tag = QuestionTag.new
          question_tag.question_id = question.id
          question_tag.tagvalue_id = tagvalue_id
          question_tag.save
        else
          question_tag = QuestionTag.find_by_question_id_and_tagvalue_id(question.id,tagvalue_id)
          question_tag.update_attribute(:tagvalue_id,tagvalue_id)
        end
      end
    end
    unless (DateTime.valid_date?(params[:year].to_i,params[:month].to_i,params[:date].to_i)).nil?
      expiry_date = Date.new(params[:year].to_i,params[:month].to_i,params[:date].to_i)
      question.update_attribute("expiry_date",expiry_date)
      redirect_to("/question_banks/#{params[:page]}/#{params[:qb]}?from=#{params[:from]}")
    else
      flash[:notice] = "Please select a valid date"
      redirect_to("/questions/edit_question/#{params[:id]}?qb=#{params[:qb]}&number=#{params[:number]}&from=#{params[:from]}&page=#{params[:page]}")
    end
  end

  def update_answers_from_param(answers,correct_answer,question_attribute)
    answers.each_pair { |key,value|
      answer = Answer.find(key.to_i)
      answer.update_attribute("answer_text",value)
      if question_attribute.question_type.value == "MCQ"
        if key == correct_answer
          answer.update_attribute("answer_status","correct")
          question_attribute.update_attribute("error_id",nil)
        else
          answer.update_attribute("answer_status","wrong")
        end
      else
        if key == correct_answer[key]
          answer.update_attribute("answer_status","correct")
          question_attribute.update_attribute("error_id",nil)
        else
          answer.update_attribute("answer_status","wrong")
        end
      end
    }
  end

  def create_new_answer_from_params(answer,correct_answer,question,i,question_bank_id)
    unless answer.nil? or answer.blank?
      if correct_answer == i
        create_answer(answer,question.id,current_user.tenant_id,question_bank_id,"correct")
      else
        create_answer(answer,question.id,current_user.tenant_id,question_bank_id,"wrong")
      end
    end
  end

end