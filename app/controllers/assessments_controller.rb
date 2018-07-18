# Author : Karthik,Surupa,Aarthi
# Total assigned learners = [currently assigned learners(includes admin if self assigned) + deleted(or anything else)]  i.e,learners assigned for this test/course at any point of time
# Active learners = Total assigned learners - deleted learners
# COMPLETED - Completed test/course within time
# INCOMPLETE - Currently in incomplete status/when the test finished, learner was not logged in
# TIMEUP - Within given time not able to complete(when the test finished, learner was logged in)
# UNATTEMPTED - Learner never attempted the test/course
# Scoring : Pass/Fail
# If pass_score = 0 then pass/fail is not applicable
# learner - Admin as learner or learners
require 'mime/types'
require 'roo'
require 'benchmark'

class AssessmentsController < ApplicationController
  before_filter :login_required
  before_filter :is_expired?
 
  # http://www.catiim.in/CATPracticeTest/IIMDemo.html
  def cat_review
    @current_learner = Learner.find(params[:id])
    @assessment = Assessment.find(@current_learner.assessment_id)
    @test_details = @current_learner.test_details
    @cat_review = Array.new
    @marked = 0
    @incomplete = 0
    for i in 0..@test_details.count-1 do
      if @test_details[i].marked_status == "marked"
        @cat_review[i] = ["#{@test_details[i]}","Yes","Yes",""]
        @marked = 1
      elsif @test_details[i].attempted_status == "answered"
        @cat_review[i] = ["#{@test_details[i]}","","","Yes"]
      else
        @cat_review[i] = ["#{@test_details[i]}","","Yes",""]
        @incomplete = 1
      end
    end
  end

  def cat_goto_question
    test_detail = TestDetail.find(params[:id])
    @current_learner = test_detail.learner
    @current_learner.update_attribute(:lesson_location,params[:lesson_location])
    redirect_to("/assessments/multi_page_test/#{@current_learner.id}")
  end

  def get_score_for_question(test_detail,question_object,answer_status,current_test)
    unless current_test.using_rules
      assessment_question_obj = AssessmentQuestion.find_by_assessment_id_and_question_id(current_test.id,question_object.id)
      unless assessment_question_obj.nil? or assessment_question_obj.blank?
        correct_mark = assessment_question_obj.mark
        negative_mark = assessment_question_obj.negative_mark
      else
        correct_mark = current_test.correct_ans_points
        negative_mark = current_test.wrong_ans_points
      end
    else
      correct_mark = test_detail.question_positive_mark
      negative_mark = test_detail.question_negative_mark
    end   
    if answer_status == "correct"
      return correct_mark
    else
      return negative_mark
    end
  end

  def single_page_test
    @current_learner = Learner.find(params[:id])
    # creates assessment object: type of assessment(duration, time_bound, open schedule etc.)
    @assessment = Assessment.find(@current_learner.assessment_id)
    # creates question_list that contains ids of questions for the current learner
    # map(&:to_i) converts each and every element of array to integer
    @test_details = @current_learner.test_details#.group("question_id").order("id")
    time = Time.now
    learner_values = Hash.new
    # enters into this if block if test taker is learner
    # if lesson status of the current learner is "not attempted" then updates the test_start_time
    # with current system time and lesson location as "incomplete"
    case(@current_learner.lesson_status)
    when "not attempted" then
      learner_values['test_start_time'] = time
      learner_values['recent_timestamp'] = time
      learner_values['lesson_status'] = "incomplete"
      learner_values['no_of_times_attempted'] = current_learner.no_of_times_attempted + 1
      learner_values['no_of_times_attempted'] = current_learner.no_of_times_attempted + 1
      @current_learner.update_attributes(learner_values)
      if (@current_learner.no_of_times_attempted == 1)
        @assessment.assessment_status_based_updation(@assessment,@current_learner)
      end
    when "completed","time up"
      case @assessment.reattempt
      when "on"
        learner_values['test_start_time'] = time
        learner_values['recent_timestamp'] = time
        learner_values['lesson_status'] = "incomplete"
        learner_values['no_of_times_attempted'] = current_learner.no_of_times_attempted + 1
        @current_learner.update_attributes(learner_values)
      when "off"
        redirect_to("/mycourses")
      end
    else
      assessment_conditions_based_page_redirect(@current_learner,@assessment)
    end
  end

  def ajax_save_answer_mcq_single_page_test
    test_detail = TestDetail.find(params[:id]) 
    @current_learner = test_detail.learner
    test_detail.answer_id = params[:answer_id]
    test_detail.attempted_status = "answered"
    test_detail.answer_status = test_detail.answer.answer_status
    score = get_score_for_question(test_detail,test_detail.question,test_detail.answer_status,@current_learner.assessment)
    test_detail.score = score    
    test_detail.timestamp = Time.now
    test_detail.save!
    duration = test_detail.duration_spent + (test_detail.timestamp - @current_learner.recent_timestamp)            
    test_detail.update_attribute(:duration_spent,duration)
    @current_learner.update_attribute(:recent_timestamp,test_detail.timestamp)
    @current_learner.update_attribute(:lesson_location,params[:lesson_location])
  end

  def ajax_save_answer_maq_single_page_test
    test_detail = TestDetail.find(params[:id])
    @current_learner = test_detail.learner
    answer_list = Array.new
    answer_status = Array.new
    answer_object = Answer.find(params[:answer_id].to_i)
    unless test_detail.learner_answer_text.nil?
      answer_list = test_detail.learner_answer_text.split(',')
      answer_status = test_detail.answer_status.split(',')
      if answer_list.include? params[:answer_id]
        position = answer_list.index(params[:answer_id])
        score = get_score_for_maq_question(test_detail.question,answer_object.answer_status,@current_learner.assessment)
        maq_score = test_detail.score - score
        test_detail.score = maq_score
        answer_list.delete(params[:answer_id])
        answer_status.delete_at(position)
      else
        answer_list.push(params[:answer_id])
        answer_status.push(answer_object.answer_status)
        score = get_score_for_maq_question(test_detail.question,answer_object.answer_status,@current_learner.assessment)
        maq_score = test_detail.score + score
        test_detail.score = maq_score
      end
    else
      answer_list.push(params[:answer_id])
      answer_status.push(answer_object.answer_status)
      score = get_score_for_maq_question(test_detail.question,answer_object.answer_status,@current_learner.assessment)
      maq_score = test_detail.score + score
      test_detail.score = maq_score
    end
    test_detail.answer_status = answer_status.join(',')
    test_detail.learner_answer_text = answer_list.join(',')
    unless test_detail.learner_answer_text.length == 0
      test_detail.attempted_status = "answered"
    else 
      test_detail.attempted_status = "unanswered"
      test_detail.learner_answer_text = nil
      test_detail.answer_status = nil
    end
    test_detail.timestamp = Time.now
    test_detail.save!
    duration = test_detail.duration_spent + (test_detail.timestamp - @current_learner.recent_timestamp)            
    test_detail.update_attribute(:duration_spent,duration)
    @current_learner.update_attribute(:recent_timestamp,test_detail.timestamp) 
    @current_learner.update_attribute(:lesson_location,params[:lesson_location])
  end

  def ajax_mark_question_single_page_test
    test_detail = TestDetail.find(params[:id])
    test_detail.marked_status = "marked"
    test_detail.save!
    @current_learner = test_detail.learner
  end

  def ajax_unmark_question_single_page_test
    test_detail = TestDetail.find(params[:id])
    test_detail.marked_status = "unmarked"
    test_detail.save!
    @current_learner = test_detail.learner
  end

  def ajax_reset_answer_single_page_test
    test_detail = TestDetail.find(params[:id])
    reset_test_detail_table_columns(test_detail)
    @current_learner = test_detail.learner
  end

  def multi_page_test
    @current_learner = get_current_learner_object(params[:id])
    @assessment = get_assessment_object(@current_learner.assessment_id)  
    if @assessment.show_all_per_page
      redirect_to("/assessments/single_page_test/#{params[:id]}")
    else
      case(params[:from])
      when "marked" 
        @test_details = TestDetail.where(:learner_id => @current_learner.id,:marked_status => "marked")
      when "skipped"
        @test_details = TestDetail.where(:learner_id => @current_learner.id,:attempted_status => "unanswered")
      else
        @test_details = @current_learner.test_details
      end
      if @test_details.nil? or @test_details.blank?
        @test_details = @current_learner.test_details
      end
    end
  end

  def ajax_save_answer_mcq_multi_page_test
    test_detail = TestDetail.find(params[:id]) 
    @current_learner = test_detail.learner
    @assessment = @current_learner.assessment
    if @assessment.using_rules
      @structure_component = StructureComponent.find(params[:structure_component])
    end
    test_detail.answer_id = params[:answer_id]
    test_detail.attempted_status = "answered"
    test_detail.answer_status = test_detail.answer.answer_status
    score = get_score_for_question(test_detail,test_detail.question,test_detail.answer_status,@current_learner.assessment)
    test_detail.score = score
    test_detail.timestamp = Time.now
    test_detail.save!
    duration = test_detail.duration_spent + (test_detail.timestamp - @current_learner.recent_timestamp)            
    test_detail.update_attribute(:duration_spent,duration)
    @current_learner.update_attribute(:recent_timestamp,test_detail.timestamp)
    @current_learner.update_attribute(:lesson_location,params[:lesson_location])
  end

  # save pending answers for multipage/single page test for all the question types
  # when the internet connection is back to active state
  def ajax_save_pending_answers_multi_page_test
    i = 0
    params[:test_detail_ids].split(',').each do |test_detail_id|
      test_detail = TestDetail.find(test_detail_id)
      @current_learner = test_detail.learner
      case test_detail.question_type
      when "MCQ"
        answer_id = params[:answer_ids].split('|')[i]
        logger.info"ANSWER ID #{answer_id.inspect}"
        test_detail.update_attribute(:answer_id,answer_id)
        test_detail.update_attribute(:attempted_status,"answered")
        answer = Answer.find(answer_id)
        test_detail.update_attribute(:answer_status,answer.answer_status)
        score = get_score_for_question(test_detail,test_detail.question,test_detail.answer.answer_status,@current_learner.assessment)
        test_detail.update_attribute(:score,score)
      when "MAQ"
        answer_list = Array.new
        answer_status = Array.new
        answer_id = params[:answer_ids].split('|')[i]
        answer_object = Answer.find(answer_id)
        unless test_detail.learner_answer_text.nil?
         answer_list = test_detail.learner_answer_text.split(',')
         answer_status = test_detail.answer_status.split(',')
          if answer_list.include? answer_id
            position = answer_list.index(answer_id)
            score = get_score_for_maq_question(test_detail.question,answer_object.answer_status,@current_learner.assessment)
            maq_score = test_detail.score - score
            test_detail.update_attribute(:score,maq_score)
            answer_list = answer_list.delete(answer_id)
            answer_status = answer_status.delete_at(position)
            test_detail.update_attribute(:learner_answer_text,answer_list)
            test_detail.update_attribute(:answer_status,answer_status)
          else
            answer_list = answer_list.push(answer_id)
            answer_status = answer_status.push(answer_object.answer_status)
            test_detail.update_attribute(:learner_answer_text,answer_list.join(','))
            test_detail.update_attribute(:answer_status,answer_status.join(','))
            score = get_score_for_maq_question(test_detail.question,answer_object.answer_status,@current_learner.assessment)
            maq_score = test_detail.score + score
            test_detail.update_attribute(:score,maq_score)
          end
       else
          answer_list = answer_id
          answer_status = answer_object.answer_status
          test_detail.update_attribute(:learner_answer_text,answer_list)
          test_detail.update_attribute(:answer_status,answer_status)
          score = get_score_for_maq_question(test_detail.question,answer_object.answer_status,@current_learner.assessment)
          maq_score = test_detail.score + score
          test_detail.update_attribute(:score,maq_score)
       end
        unless test_detail.learner_answer_text.length == 0
         test_detail.update_attribute(:attempted_status,"answered")
        else
         test_detail.update_attribute(:attempted_status,"unanswered")
         test_detail.update_attribute(:learner_answer_text,nil)
         test_detail.update_attribute(:answer_status,nil)
        end
      when "FIB","SA"
        fib_answer = params[:answer_ids].split('|')[i]
        answers = test_detail.question.answers.where(:answer_text => fib_answer)
        answer_id = answers[0].id
        test_detail.update_attribute(:answer_id,answer_id)
        test_detail.update_attribute(:learner_answer_text,fib_answer)
        test_detail.update_attribute(:attempted_status,"answered")
        answer = Answer.find(answer_id)
        test_detail.update_attribute(:answer_status,answer.answer_status)
        score = get_score_for_question(test_detail,test_detail.question,test_detail.answer.answer_status,@current_learner.assessment)
        test_detail.update_attribute(:score,score)
      end
      time_remaining = params[:timestamps].split('|')[i]
      test_duration = Time.parse("#{@current_learner.assessment.duration_hour}:#{@current_learner.assessment.duration_min}:0")
      test_time_remaining = Time.parse(time_remaining)
      time_taken = test_duration - test_time_remaining
      timestamp = @current_learner.test_start_time + time_taken
      test_detail.update_attribute(:timestamp,timestamp)
      duration = test_detail.duration_spent + (test_detail.timestamp - @current_learner.recent_timestamp)
      test_detail.update_attribute(:duration_spent,duration)
      @current_learner.update_attribute(:recent_timestamp,test_detail.timestamp)
      i = i + 1
    end
  end

  def ajax_save_answer_fib_multi_page_test
    test_detail = TestDetail.find(params[:id]) 
    @current_learner = test_detail.learner
    unless params[:fib_answer_text].nil? or params[:fib_answer_text].blank?
      test_detail.learner_answer_text = params[:fib_answer_text]
      test_detail.attempted_status = "answered"
      answer = test_detail.question.answers.where(:answer_text => params[:fib_answer_text])
      unless answer.nil? or answer.blank?
        test_detail.answer_id = answer[0].id
        test_detail.answer_status = test_detail.answer.answer_status        
      else
        test_detail.answer_id = nil
        test_detail.answer_status = "wrong"
      end
      score = get_score_for_question(test_detail,test_detail.question,test_detail.answer_status,@current_learner.assessment)
      test_detail.score = score   
      test_detail.timestamp = Time.now
      test_detail.save!
      duration = test_detail.duration_spent + (test_detail.timestamp - @current_learner.recent_timestamp)            
      test_detail.update_attribute(:duration_spent,duration)
      @current_learner.update_attribute(:recent_timestamp,test_detail.timestamp)
      @current_learner.update_attribute(:lesson_location,params[:lesson_location])
    else
      test_detail.learner_answer_text = nil
      test_detail.attempted_status = "unanswered"
      test_detail.answer_status = nil
      test_detail.save!
    end
  end

  # def ajax_update_lesson_location_on_next
  #   test_detail = TestDetail.find(params[:id]) 
  #   @current_learner = test_detail.learner
  #   @current_learner.update_attribute(:lesson_location,params[:lesson_location])
  # end

  # def ajax_update_lesson_location_on_previous
  #   test_detail = TestDetail.find(params[:id]) 
  #   @current_learner = test_detail.learner
  #   @current_learner.update_attribute(:lesson_location,params[:lesson_location].to_i - 1)
  # end

  # def goto_question_on_side_panel_click
  #   test_detail = TestDetail.find(params[:id]) 
  #   @current_learner = test_detail.learner
  #   @current_learner.update_attribute(:lesson_location,params[:lesson_location])
  # end

  def ajax_save_answer_maq_multi_page_test
    test_detail = TestDetail.find(params[:id])
    @current_learner = test_detail.learner
    @assessment = @current_learner.assessment
    answer_list = Array.new
    answer_status = Array.new
    answer_object = Answer.find(params[:answer_id].to_i)
    unless test_detail.learner_answer_text.nil?
      answer_list = test_detail.learner_answer_text.split(',')
      answer_status = test_detail.answer_status.split(',')
      if answer_list.include? params[:answer_id]
        position = answer_list.index(params[:answer_id])
        score = get_score_for_maq_question(test_detail.question,answer_object.answer_status,@current_learner.assessment)
        maq_score = test_detail.score - score
        test_detail.score = maq_score
        answer_list.delete(params[:answer_id])
        answer_status.delete_at(position)
      else
        answer_list.push(params[:answer_id])
        answer_status.push(answer_object.answer_status)
        score = get_score_for_maq_question(test_detail.question,answer_object.answer_status,@current_learner.assessment)
        maq_score = test_detail.score + score
        test_detail.score = maq_score
      end
    else
      answer_list.push(params[:answer_id])
      answer_status.push(answer_object.answer_status)
      score = get_score_for_maq_question(test_detail.question,answer_object.answer_status,@current_learner.assessment)
      maq_score = test_detail.score + score
      test_detail.score = maq_score
    end
    test_detail.answer_status = answer_status.join(',')
    test_detail.learner_answer_text = answer_list.join(',')
    unless test_detail.learner_answer_text.length == 0
      test_detail.attempted_status = "answered"      
    else 
      test_detail.attempted_status = "unanswered"
      test_detail.learner_answer_text = nil
      test_detail.answer_status = nil
    end    
    test_detail.timestamp = Time.now
    test_detail.save!  
    duration = test_detail.duration_spent + (test_detail.timestamp - @current_learner.recent_timestamp)            
    test_detail.update_attribute(:duration_spent,duration)
    @current_learner.update_attribute(:recent_timestamp,test_detail.timestamp)
    @current_learner.update_attribute(:lesson_location,params[:lesson_location])
  end

  def get_score_for_maq_question(question_object,answer_status,current_test)
    correct_length = question_object.answers.where(:answer_status => "correct").count
    wrong_length = question_object.answers.where(:answer_status => "wrong").count
    assessment_question_obj = AssessmentQuestion.find_by_assessment_id_and_question_id(current_test.id,question_object.id)
    unless assessment_question_obj.nil? or assessment_question_obj.blank?
      correct_mark = assessment_question_obj.mark
      negative_mark = assessment_question_obj.negative_mark
    else
      correct_mark = current_test.correct_ans_points
      negative_mark = current_test.wrong_ans_points
    end
    unless correct_mark.to_f == 0.0
      correct_points = (correct_mark.to_f/correct_length).round(3)
    else
      correct_points = 0
    end
    unless negative_mark.to_f == 0.0
      wrong_points = (negative_mark.to_f/wrong_length).round(3)
    else
      wrong_points = 0
    end
    if answer_status == "correct"
      return correct_points
    else
      return wrong_points
    end
  end

  def ajax_mark_question_multi_page_test
    test_detail = TestDetail.find(params[:id])
    test_detail.marked_status = "marked"
    test_detail.save!
    @current_learner = test_detail.learner
    @assessment = @current_learner.assessment
    if @assessment.using_rules
      @structure_component = StructureComponent.find(params[:structure_component])
    end
  end

  def ajax_unmark_question_multi_page_test
    test_detail = TestDetail.find(params[:id])
    test_detail.marked_status = "unmarked"
    test_detail.save!
    @current_learner = test_detail.learner
    @current_learner.update_attribute(:lesson_location,params[:lesson_location])
    @assessment = @current_learner.assessment
    if @assessment.using_rules
      @structure_component = StructureComponent.find(params[:structure_component])
    end
  end

  def ajax_reset_answer_multi_page_test
    test_detail = TestDetail.find(params[:id])
    @current_learner = test_detail.learner
    @assessment = @current_learner.assessment
    if @assessment.using_rules
      @structure_component = StructureComponent.find(params[:structure_component])
    end
    reset_test_detail_table_columns(test_detail)
    @current_learner.update_attribute(:lesson_location,params[:lesson_location])
  end

  def reset_test_detail_table_columns(test_detail)
    test_detail.attempted_status = "unanswered"
    test_detail.answer_id = nil
    test_detail.answer_status = nil 
    test_detail.learner_answer_text = nil
    test_detail.score = 0
    test_detail.save!
  end

  # clearing pending answers for multipage/single page test for all the question types(onclick of reset)
  # when the internet connection is back to active state
  def ajax_reset_pending_answers_multi_page_test
    logger.info"PARAMS >>>>>>>>>>>>>>>>>>>>.#{params.inspect}"
    i = 0
    params[:reset_test_detail_ids].split(',').each do |test_detail_id|
      test_detail = TestDetail.find(test_detail_id)
      @current_learner = test_detail.learner
      test_detail.update_attribute(:answer_id,"")
      test_detail.update_attribute(:learner_answer_text,"")
      test_detail.update_attribute(:attempted_status,"unanswered")
      test_detail.update_attribute(:answer_status,"")
      test_detail.update_attribute(:score,0)
      i = i + 1
    end
  end

  #a method to send test_added mail again explicitly by taking assessment_id
  def send_test_added_mail_again
    count = 0
    all_learners = Learner.find_all_by_assessment_id_and_admin_id(params[:id],current_user.id, :conditions => "type_of_test_taker = 'learner'")
    all_learners.each { |learner|
      #      user = User.find(learner.user_id)
      result = testadd_assessment_learner_notification_send_grid(learner.user,params[:id])
      if result == "success" then
        count = count + 1
      end
    }
    flash[:mails_sent_again] = "#{count} mails sent "
    redirect_to('/courses')
  end

  #send activation mail again explicitly for that tenant
  def send_activation_mail_again
    count = 0
    all_learners = User.find_all_by_user_id(current_user.id, :conditions => "typeofuser = 'learner' AND crypted_password is NULL")
    all_learners.each { |learner|
      result = signup_assessment_learner_notification_send_grid(learner,params[:id])
      if result == "success" then
        count = count + 1
      end
    }
    flash[:mails_sent_again] = "#{count} mails sent "
    redirect_to('/courses')
  end

  # control comes here from courses/index when we click on "Edit Assessment Details"
  # @assessment is the current assessment object
  def edit_questions
    @assessment = Assessment.find(params[:id])
  end

  # control comes here from courses/index when we click on "Edit Assessment Details" and
  # then clicks on "Assessment Details"
  def edit_assessment_details
    @assessment = Assessment.find(params[:id])
    @time = Time.now.getutc
    convert_utc_time_to_system_time(@time,@assessment.tenant)
    if @show_time.strftime("%p")=="AM"
      @hour = @show_time.hour
    elsif (@show_time.strftime("%p")=="PM" and @show_time.hour == 12) or (@show_time.strftime("%p")=="AM" and @show_time.hour == 0)
      @hour = 12
    else
      @hour = @show_time.hour - 12
    end

    if @zone.include? "+"
      show_start_assessment_time = @assessment.start_time + @total_offset
    else
      show_start_assessment_time = @assessment.start_time - @total_offset
    end

    selected_start_day = show_start_assessment_time.strftime('%d')
    selected_start_month = show_start_assessment_time.month
    selected_start_year = show_start_assessment_time.strftime('%Y')

    @selected_start_hour = show_start_assessment_time.strftime('%I').to_i
    @selected_start_min = show_start_assessment_time.strftime('%M').to_i
    @selected_start_am_pm = show_start_assessment_time.strftime('%p')

    @calander_start_date = selected_start_year + "-" + selected_start_month.to_s + "-" + selected_start_day.to_s

    if @assessment.schedule_type == "fixed" then

      if @zone.include? "+"
        show_end_assessment_time = @assessment.end_time + @total_offset
      else
        show_end_assessment_time = @assessment.end_time - @total_offset
      end

      selected_end_day = show_end_assessment_time.strftime('%d')
      selected_end_month = show_end_assessment_time.month
      selected_end_year = show_end_assessment_time.strftime('%Y')

      @selected_end_hour = show_end_assessment_time.strftime('%I').to_i
      @selected_end_min = show_end_assessment_time.strftime('%M').to_i
      @selected_end_am_pm = show_end_assessment_time.strftime('%p')

      @calander_end_date = selected_end_year + "-" +selected_end_month.to_s + "-" + selected_end_day
    end
  end

  # control comes here from add_questions_to_assessment(single topic - manual),
  # add_more_topics_to_assessment(multi topic - when clicks on "Done adding topics" link),
  # question_banks/show(single topic - from excel file)
  def assessment_details
    @assessment = Assessment.find(params[:id])
    if !(@assessment.test_pattern.nil? or @assessment.test_pattern.blank?) and @assessment.test_pattern_id != 1
      store_test_pattern_details(@assessment)
      redirect_to("/assessments/schedule_assessment/#{@assessment.id.to_s}")
    else
      @assessment.update_attribute(:test_pattern_id,1)
    end
  end

  # control comes here from assessment_details
  def save_assessment_details
    @assessment = Assessment.find(params[:id])
    @assessment.update_attributes(params[:assessment])
    redirect_to("/assessments/pre_test_information/#{@assessment.id.to_s}")
  end

  def pre_test_information

  end

  # control comes here from save_assessment_details
  def scoring
    @assessment = Assessment.find(params[:id])
  end

  # control comes here from scoring
  def save_scoring
    @assessment = Assessment.find(params[:id])
    admin_in_learner = Learner.new
    if !(params[:assessment][:pass_score].nil? or params[:assessment][:pass_score].blank?)
      admin_in_learner.score_min = params[:assessment][:pass_score]
    else
      admin_in_learner.score_min = "0"
    end
    admin_in_learner.assessment_id = @assessment.id
    admin_in_learner.user_id = current_user.id
    admin_in_learner.admin_id = current_user.id
    admin_in_learner.tenant_id = @assessment.tenant_id
    admin_in_learner.lesson_location = "0"
    if params.include? "question_bank"
      #The below logic is for multi topic
      qb_mapped_to_limit = Hash.new
      qb_mapped_to_limit = map_qb_to_limit()
      no_of_questions = 0
      qb_mapped_to_limit.each_pair { |qb,limit|
        selected_question_bank_id = AssessmentsQuestionBank.find_by_assessment_id_and_question_bank_id(@assessment.id,qb.to_i)
        question_bank = QuestionBank.find(qb.to_i)
        if params[:show_questions] == "limited" then
          selected_question_bank_id.update_attribute(:question_limit, limit.to_i)
          @assessment.update_attribute(:is_show_all,false)
        else
          selected_question_bank_id.update_attribute(:question_limit, question_bank.no_of_questions)
          @assessment.update_attribute(:is_show_all,true)
        end
        no_of_questions += limit.to_i
        if params[:order] == "random"
          @assessment.update_attribute(:is_linear, false)
        else
          @assessment.update_attribute(:is_linear, true)
        end
      }
      #The below logic is for single topic
    else
      selected_question_bank_id = AssessmentsQuestionBank.find_by_assessment_id(@assessment.id)
      if params[:show_questions] == "limited"
        no_of_questions = params[:assessment][:no_of_questions]
        limit = params[:assessment][:no_of_questions]
        @assessment.update_attribute(:is_show_all,false)
      else
        no_of_questions = @assessment.no_of_questions
        limit = @assessment.no_of_questions.to_s
        @assessment.update_attribute(:is_show_all,true)
      end
      selected_question_bank_id.update_attribute(:question_limit, limit.to_i)
      if params[:order] == "random"
        @assessment.update_attribute(:is_linear, false)
      else
        @assessment.update_attribute(:is_linear, true)
      end
    end
    @assessment.update_attributes(params[:assessment])
    if params[:show_per_page] == "one"
      @assessment.update_attribute(:show_all_per_page, false)
    else
      @assessment.update_attribute(:show_all_per_page, true)
    end
    (params[:assessment].include? "send_score_by_mail")?@assessment.update_attribute(:send_score_by_mail,"on"):@assessment.update_attribute(:send_score_by_mail,"off")
    (params[:assessment].include? "show_status")?@assessment.update_attribute(:show_status,"on"):@assessment.update_attribute(:show_status,"off")
    (params[:assessment].include? "skip_question")?@assessment.update_attribute(:skip_question,true):@assessment.update_attribute(:skip_question,false)
    (params[:assessment].include? "show_question_explanation")?@assessment.update_attribute(:show_question_explanation,true):@assessment.update_attribute(:show_question_explanation,false)
    @assessment.update_attribute(:no_of_questions,no_of_questions)
    qb_list,question_list = create_question_list(@assessment)
    admin_in_learner.entry = qb_list
    # fill suspend data with space initially
    answer_list = Array.new(question_list.split(',').length)
    answer_list.collect! {|x| x = '' }
    admin_in_learner.suspend_data = answer_list.join('|')
    # fill question status details column with space initially
    question_status_list = Array.new(question_list.split(',').length)
    question_status_list.collect! {|x| x = '' }
    admin_in_learner.question_status_details = question_status_list.join(',')
    admin_in_learner.score_max = @assessment.no_of_questions * @assessment.correct_ans_points
    admin_in_learner.group_id = current_user.group_id
    admin_in_learner.save    
    @assessment.update_attribute(:current_learner_id, admin_in_learner.id)
    @i = 1
    create_mapping_for_all_questions_in_assessment(@assessment,@assessment.correct_ans_points,@assessment.wrong_ans_points)
    create_test_details_for_user(admin_in_learner.id,current_user.id,current_user.tenant_id,question_list,@assessment)
    redirect_to("/assessments/schedule_assessment/#{@assessment.id.to_s}")
  end

  def create_mapping_for_all_questions_in_assessment(assessment,positive_mark,negative_mark)
    question_banks = assessment.question_banks
    question_banks.length.times do |i|
      question_banks[i].questions.each {|question|
        create_assessment_question_mapping(assessment,question,positive_mark,negative_mark)
      }
    end
  end

  # control comes here save_scoring
  def schedule_assessment
    @assessment = Assessment.find(params[:id])
    time = Time.now.getutc
    convert_utc_time_to_system_time(time,@assessment.tenant)
    if @show_time.strftime("%p")=="AM"
      @hour = @show_time.hour
    elsif (@show_time.strftime("%p")=="PM" and @show_time.hour == 12) or (@show_time.strftime("%p")=="AM" and @show_time.hour == 0)
      @hour = 12
    else
      @hour = @show_time.hour - 12
    end
  end

  def save_schedule_details(assessment)
    (params[:assessment].include? "reattempt")?assessment.update_attribute(:reattempt,"on"):assessment.update_attribute(:reattempt,"off")
    if params[:assessment][:schedule_type] == "open"
      open_schedule_calendar = params[:open][:start_schedule].split("-")
      start_date_time = time_conversions(open_schedule_calendar[2],open_schedule_calendar[1],open_schedule_calendar[0],params[:open][:hour],params[:open][:min],params[:open][:am_pm])
      end_date_time = start_date_time
    else
      fixed_start_schedule_calendar = params[:fixed_start][:start_schedule].split("-")
      start_date_time = time_conversions(fixed_start_schedule_calendar[2],fixed_start_schedule_calendar[1],fixed_start_schedule_calendar[0],params[:fixed_start][:hour],params[:fixed_start][:min],params[:fixed_start][:am_pm])
      fixed_end_schedule_calendar = params[:fixed_end][:start_schedule].split("-")
      end_date_time = time_conversions(fixed_end_schedule_calendar[2],fixed_end_schedule_calendar[1],fixed_end_schedule_calendar[0],params[:fixed_end][:hour],params[:fixed_end][:min],params[:fixed_end][:am_pm])
    end
    total_offset = calculate_total_offset(assessment.tenant)
    if assessment.tenant.zone.include? "+"
      start_time = start_date_time - total_offset
      end_time = end_date_time - total_offset
    else
      start_time = start_date_time + total_offset
      end_time = end_date_time + total_offset
    end
    assessment.update_attribute(:start_time,start_time)
    assessment.update_attribute(:end_time,end_time)
  end

  # control comes here schedule_assessment
  def create
    @assessment = Assessment.find(params[:id])
    @assessment.update_attributes(params[:assessment])
    save_schedule_details(@assessment)
    redirect_to("/courses/preview/#{current_user.id}?assessment_id=#{@assessment.id}")
  end

  def time_conversions(assessment_date,assessment_month,assessment_year,assessment_hour,assessment_min,assessment_am_pm)
    case
    when (assessment_am_pm == "am" and assessment_hour.to_i == 12) then
      date_time = Time.utc(assessment_year,assessment_month,assessment_date,00,assessment_min)
    when (assessment_am_pm == "pm" and assessment_hour.to_i < 12) then
      hour = assessment_hour.to_i + 12
      date_time = Time.utc(assessment_year,assessment_month,assessment_date,hour,assessment_min)
    else
      date_time = Time.utc(assessment_year,assessment_month,assessment_date,assessment_hour,assessment_min)
    end
    return date_time
  end

  # this function is called from save_scoring if assessment_type is multiple
  def map_qb_to_limit
    # Maps question banks to corresponding limits
    # Author : Karthik
    qb = Hash.new
    params[:question_bank].each_pair { |key, value|
      qb_key = key.slice("qb")
      if qb_key == "qb" && !value.empty? then
        qb[key] = value
      end
    }

    limit = Hash.new
    params[:question_bank].each_pair { |key, value|
      limit_key = key.slice("limit")
      if limit_key == "limit" && !value.empty? then
        limit[key] = value
      end
    }

    sorted_qb = Hash.new
    sorted_qb = qb.sort

    sorted_limit = Hash.new
    sorted_limit = limit.sort

    mapped_hash = Hash.new
    count = sorted_qb.length
    i=0
    while i < count
      mapped_hash[sorted_qb[i][1]] = sorted_limit[i][1]
      i=i+1
    end
    return mapped_hash
  end

  # control comes here if we click on "Delete Assessment" link either in assessment_details or edit page
  def destroy
    assessment = Assessment.find(params[:id])
    delete_assessment_dependencies(assessment)
    redirect_to("/courses")
  end

  # control comes here when admin clicks on preview and learner clicks on take test
  # assessment object: contains the details for the current assessment.
  # current_learner object: object that stores details of the current user taking the test (preview/actual test)
  # current learner params differentiates the current user as an admin/learner
  def start_test
    @current_learner = Learner.find_by_id(params[:id].to_i)
    @assessment = Assessment.find(@current_learner.assessment_id)
    logger.info "TYPE OF LEARNER #{@current_learner.type_of_test_taker.inspect}"
    unless @current_learner.type_of_test_taker == "admin" then
      logger.info "IF NOT ADMIN #{@current_learner.type_of_test_taker.inspect}"
      if valid_test_taking()
        if @current_learner.type_of_test_taker == "learner" and @current_learner.lesson_status == "not attempted" and current_user.tenant.pricing_plan.plan_group == "assessment_only_plan" then
          update_remaining_learner_credit()
        end
      else
        flash[:contact_your_admin] = "Credits for your organization seems to have expired. Contact you admin for futhur details."
        redirect_to("/mycourses")
      end
    end
    logger.info ">>>>>>>>>>>>>>>>>>>FOR ALL LEARNERS #{@current_learner.type_of_test_taker.inspect}"
    update_learner_and_redirect(@assessment,@current_learner)
  end

  # called from start_test to update launch_data, suspend_data, lesson_location, lesson_status,
  # type_of_test_taker, test_start_time, session_time if test taker is learner and redirect to assessment.
  # if test taker is admin then only redirect to assessment
  def update_learner_and_redirect(assessment,current_learner)
    logger.info ">>>>>>>>>>>>>>>>>>>>update_learner_and_redirect #{current_learner.type_of_test_taker.inspect}"
    time = Time.now
    learner_values = Hash.new
    case (current_learner.type_of_test_taker)
      # if test taker is learner and he has not attempted the test and either the assessment has demographics
      # or instructions are not empty then redirect to learner_information page to take demographics details.
    when "admin"
      # when admin clicks on preview the control comes here. It updates the no_of_times_attempted column
      # of learners table to keep track how many times admin has taken preview.
      learner_values['test_start_time'] = time
      learner_values['recent_timestamp'] = time
      learner_values['lesson_status'] = "incomplete"
      learner_values['no_of_times_attempted'] = current_learner.no_of_times_attempted + 1
      #      current_learner.update_attribute(:no_of_times_attempted, current_learner.no_of_times_attempted + 1)
      if current_learner.lesson_status == "not attempted"
        learner_values = update_timestamps("start",current_learner,assessment.id,learner_values)
      end
      current_learner.update_attributes(learner_values)
      unless assessment.using_rules == true
        redirect_to("/assessments/multi_page_test/#{current_learner.id}")
      else
        component_id = StructureComponent.find_by_assessment_id(assessment.id).id
        redirect_to("/assessments/get_structure_component/#{current_learner.id}?component=#{component_id}")
      end
    when "learner"
      case
      when (assessment.test_pattern.id != 1 and assessment.test_pattern.instructions and current_learner.lesson_status == "not attempted")
        redirect_to("/assessments/instructions/#{params[:id]}")
      when ((!assessment.demographics_id.nil? or !(assessment.instruction_for_test.nil? or assessment.instruction_for_test.blank?)) and current_learner.lesson_status == "not attempted")
        if current_learner.demographic_1.nil? and current_learner.demographic_2.nil? and current_learner.demographic_3.nil? and current_learner.demographic_4.nil? then
          redirect_to("/assessments/learner_information/#{params[:id]}")
        else
          learner_values['test_start_time'] = time
          learner_values['recent_timestamp'] = time
          learner_values['lesson_status'] = "incomplete"
          learner_values['no_of_times_attempted'] = current_learner.no_of_times_attempted + 1
          current_learner.update_attributes(learner_values)
          assessment.assessment_status_based_updation(assessment,current_learner)
          # if test taker is learner and he is continuing the test, either the assessment has demographics
          # or instructions are not empty then redirect to assessment page to continue the test.
          unless assessment.using_rules == true
            redirect_to("/assessments/multi_page_test/#{current_learner.id}")
          else
            component_id = StructureComponent.find_by_assessment_id(assessment.id).id
            redirect_to("/assessments/get_structure_component/#{current_learner.id}?component=#{component_id}")
          end
        end
      else
        case (current_learner.lesson_status)
        when "not attempted" then
          learner_values['test_start_time'] = time
          learner_values['recent_timestamp'] = time
          learner_values['lesson_status'] = "incomplete"
          learner_values['no_of_times_attempted'] = current_learner.no_of_times_attempted + 1
          #          current_learner.update_attribute(:no_of_times_attempted, current_learner.no_of_times_attempted + 1)
          learner_values = update_timestamps("start",current_learner,assessment.id,learner_values)
          current_learner.update_attributes(learner_values)
          assessment.assessment_status_based_updation(assessment,current_learner)
          unless assessment.using_rules == true
            redirect_to("/assessments/multi_page_test/#{current_learner.id}")
          else
            component_id = StructureComponent.find_by_assessment_id(assessment.id).id
            redirect_to("/assessments/get_structure_component/#{current_learner.id}?component=#{component_id}")
          end
        when "completed","time up"
          case (assessment.reattempt)
          when "off"
            redirect_to("/mycourses")
          when "on"
            learner_values['no_of_times_attempted'] = current_learner.no_of_times_attempted + 1
            learner_values['lesson_location'] = "0"
            learner_values['suspend_data'] = ""
            learner_values['lesson_status'] = "completed"
            learner_values['test_start_time'] = time
            learner_values['recent_timestamp'] = time
            learner_values['session_time'] = ""
            current_learner.update_attributes(learner_values)
            unless assessment.using_rules == true
              redirect_to("/assessments/multi_page_test/#{current_learner.id}")
            else
              component_id = StructureComponent.find_by_assessment_id(assessment.id).id
              redirect_to("/assessments/get_structure_component/#{current_learner.id}?component=#{component_id}")
            end
          end
        when "incomplete"
          # If assessment has demographics or instructions are not empty, and learner is in incomplete state
          # then it redirects to assessment page to continue the test.
          unless assessment.using_rules == true
            redirect_to("/assessments/multi_page_test/#{current_learner.id}")
          else
            component_id = StructureComponent.find_by_assessment_id(assessment.id).id
            redirect_to("/assessments/get_structure_component/#{current_learner.id}?component=#{component_id}")
          end
        end
      end
    end    
  end

  def get_structure_component
    logger.info "get_structure_component PARAMS //////////////// #{params.inspect}"
    @learner = Learner.find(params[:id])
    @structure_component = StructureComponent.find(params[:component])
    @is_last_component,@next_component_id = get_next_component(params[:component],@structure_component.assessment_id)
    component_name = @structure_component.assessment_component.name
    if component_name == "section"
      redirect_to("/assessments/section_wise_test/#{@learner.id}?structure_component=#{@structure_component.id}&next_component=#{@next_component_id}&last=#{@is_last_component}&from_get_structure_component=")
    elsif component_name == "report"
      @assessment = @learner.assessment  
      save_test_details("normal",@learner,@assessment,current_user)
      unless @assessment.reports.nil? or @assessment.reports.blank?
        @reports = @assessment.reports.where(:for_whom => "admin")
        @report = @assessment.reports.where(:for_whom => "learner")[0]
        render("#{component_name}")
      else
        if @learner.type_of_test_taker == "learner"
          redirect_to("/mycourses")
        else
          redirect_to("/courses")
        end
      end
      # flash[:test_submitted_successful] = "Your test '#{@learner.assessment.name}' has been submitted."
      # redirect_to("/reports/learner_test_status/#{@learner.id.to_s}")
    else
      render("#{component_name}")
    end
  end

  def get_next_component(structure_component_id,assessment_id)
    structure_component_ids = StructureComponent.where(:assessment_id => assessment_id).pluck(:id)
    current_component_location = structure_component_ids.index(structure_component_id.to_i)
    next_component_id = structure_component_ids.at(current_component_location.to_i + 1)
    if structure_component_ids.last == structure_component_id.to_i
      return [true,next_component_id]
    else
      return [false,next_component_id]
    end
  end

  def section_wise_test
    logger.info "section_wise_test PARAMS >>>>>>>>>>>>>>>>>>>>> #{params.inspect}"
    @current_learner = get_current_learner_object(params[:id])
    @assessment = get_assessment_object(@current_learner.assessment_id)
    @is_last_component = params[:last]
    logger.info"@is_last_component #{@is_last_component.inspect}"
    @structure_component = StructureComponent.find(params[:structure_component])
    logger.info"@structure_component >>>>>>>>>>>>>>#{@structure_component.inspect}"
    @test_details = @current_learner.test_details.find_all_by_section_id(@structure_component.section.id)
    logger.info"TEST DETAILS #{@test_details.inspect}"
    @section = Section.find_by_structure_component_id(@structure_component.id)
    # if section time is given in assessment creation process then
    # update section_start_time column in test_details(belonging to one section) with current time
    # end_time will be calculated using this section_start_time
    unless @section.duration_hour == 0 and @section.duration_min == 0
      time = Time.now
       for i in 0..@test_details.length-1
         @test_details[i].update_attribute(:section_start_time,time)
       end
    end
  end

  # this method is called from assessment to redirect to other page based on few parameters, like
  # lesson status, time bound or not, schedule type is fixed or open, etc
  def assessment_conditions_based_page_redirect(current_learner,assessment)
    time = Time.now.getutc
    start_time = current_learner.test_start_time
    end_time = start_time + ((assessment.duration_hour * 3600)+(assessment.duration_min * 60))
    case(current_learner.type_of_test_taker)
    when "learner"
      if assessment.schedule_type == "fixed" and end_time >= assessment.end_time
        end_time = assessment.end_time
      end
    end
    if time >= end_time
      url = timeup(current_learner,assessment)
      redirect_to(url)
    end
  end

  def update_timestamps(lesson_location,current_learner,assessment_id,learner_values)
    assessment = get_assessment_object(assessment_id)
    if current_learner.timestamps.nil?
      timestamp = Array.new
    else
      timestamp = (current_learner.timestamps).split("|")
    end
    convert_utc_time_to_system_time(Time.now.getutc,assessment.tenant)
    timestamp.push(lesson_location + "=" + @show_time.strftime('%H:%M:%S'))
    new_timestamp = timestamp.join("|")
    learner_values['timestamps'] = new_timestamp
    return learner_values
  end

  def review_assessment
    logger.info"IN REVIEW ASSESSMENT >>>>>#{params.inspect}"
    @current_learner = get_current_learner_object(params[:id])
    unless params[:fib_answer_text].nil? or params[:fib_answer_text].blank?
      test_detail = TestDetail.find(params[:fib_test_detail_id])
      test_detail.learner_answer_text = params[:fib_answer_text]
      test_detail.attempted_status = "answered"
      answer = test_detail.question.answers.where(:answer_text => params[:fib_answer_text])
      unless answer.nil? or answer.blank?
        test_detail.answer_id = answer[0].id
        test_detail.answer_status = test_detail.answer.answer_status        
      else
        test_detail.answer_id = nil
        test_detail.answer_status = "wrong"
      end
      score = get_score_for_question(test_detail,test_detail.question,test_detail.answer_status,@current_learner.assessment)
      test_detail.score = score   
      test_detail.timestamp = Time.now
      test_detail.save!
      duration = test_detail.duration_spent + (test_detail.timestamp - @current_learner.recent_timestamp)            
      test_detail.update_attribute(:duration_spent,duration)
      @current_learner.update_attribute(:recent_timestamp,test_detail.timestamp)  
    end
    @assessment = get_assessment_object(@current_learner.assessment_id)
    @answered = TestDetail.where(:learner_id => @current_learner.id,:attempted_status => "answered").length
    @skipped = TestDetail.where(:learner_id => @current_learner.id,:attempted_status => "unanswered").length
    @marked = TestDetail.where(:learner_id => @current_learner.id,:marked_status => "marked").length
  end

  def timeup(current_learner,assessment)
    learner_values = Hash.new
    learner_values = update_timestamps("timeup",current_learner,assessment.id,learner_values)
    current_learner.update_attributes(learner_values)
    # if the assessment is part of a package then assign the next assement to the learner from that package
    unless current_learner.package_id.nil? or current_learner.package_id.blank?
      next_assessment_course,assessment_course = new_pick_next_assessment_course_in_package(current_learner.package,assessment,"assessment")
      # if the next_assment is empty from the method then it means he has been assigned to all the assmts in that package and no more assmnts are left.
      unless next_assessment_course == ""
        if assessment_course == "assessment"
          #        store_learner_details(next_assessment,current_user.user_id,current_user,"learner")
          admin_user = assessment.user
          assign_next_assessment_to_learner(next_assessment_course,admin_user,current_user,current_learner.package_id)
        elsif assessment_course == "course"
          admin_user = assessment.user
          assign_next_course_to_learner(next_assessment_course,admin_user,current_user,current_learner.package_id)
        end
      end
    end 

    unless current_learner.test_details.nil? or current_learner.test_details.blank?
      question_wise_report_url = "/reports/learner_test_status/#{current_learner.id}?assessment_id=#{assessment.id}"
    else
      question_wise_report_url = "/mycourses"
    end

    case(current_learner.type_of_test_taker)
    when "admin"
      case(assessment.test_pattern.pattern_name)
      when "AIEEE"
        url = "/assessments/feedback/#{current_learner.id}?timeup"
      else
        reset_admin_preview_columns(current_learner)
        url = "/courses"
      end
    when "learner"
      case(assessment.test_pattern.pattern_name)
      when "AIEEE"
        url = "/assessments/feedback/#{current_learner.id}?timeup"
      else
        case(assessment.show_status)
        when "on"
          save_test_details("time up",current_learner,assessment,current_user)
          url = question_wise_report_url
        else
          save_test_details("time up",current_learner,assessment,current_user)
          url = "/mycourses"
        end
      end      
    end
    return url
  end

  # control comes here from assessments/submit
  # TODO: Question scores storing has been done for only MCQ, FIB and SA. So this has to be done for MAQ and MTF too
  def save_test_details(scenario,current_learner,current_test,user)
    learner_column_values = Hash.new
    learner_column_values = current_test.calculate_and_save_score(current_learner,current_test,learner_column_values)
    case(scenario)
    when "normal" then
      learner_column_values['lesson_status'] = "completed"
    when "time up" then
      learner_column_values['lesson_status'] = "time up"
    end

    current_learner.update_attributes(learner_column_values)
    
    if current_test.send_score_by_mail == "on" then
      result = send_score_to_learner_send_grid(user,current_test,user.tenant,user.tenant.user,current_learner)
    end
  end

  #sets the attributes from_replacements, subject_replacements and body_replacements for the send_score_to_learner mail
  #basically every attribute is a hash structured as seen below and these are sent to the 'send_mail' method in UserMailer model for further processing(check UserMailer model)
  def send_score_to_learner_send_grid(user,assessment,tenant,admin,learner)
    begin
      url =  user.crypted_password.nil? ? "https://#{tenant.custom_url}.#{SITE_URL}/activate/#{user.activation_code}" : "https://#{tenant.custom_url}.#{SITE_URL}"
      if learner.credit == "fail" then
        learner_credit = "failed"
      elsif learner.credit == "pass"
        learner_credit = "passed"
      end

      from_replacements = Hash["[tenant_name]" => tenant.organization,
        "[sender_name]" => admin.login,
        "[sender_email]" => admin.email
      ]

      subject_replacements = Hash["[tenant_name]" => tenant.organization,
        "[url]" => url,
        "[sender_name]" => admin.login,
        "[sender_email]" => admin.email,
        "[learner_name]" => user.login,
        "[learner_email]" => user.email,

        "[assessment_name]" => assessment.name,
        "[assessment_description]" => assessment.description,

        "[assessment_start_schedule]" => assessment.start_time,
        "[assessment_end_schedule]" => assessment.end_time,
        "[assessment_duration_hour]" => assessment.duration_hour,
        "[assessment_duration_min]" => assessment.duration_min,

        "[learner_lesson_status]" => learner.lesson_status,
        "[learner_lesson_raw_score]" => learner.score_raw,
        "[learner_lesson_max_score]" => learner.score_max,
        "[learner_lesson_credit]" => learner_credit
      ]
      body_replacements = Hash["[tenant_name]" => tenant.organization,
        "[url]" => url,
        "[sender_name]" => admin.login,
        "[sender_email]" => admin.email,
        "[learner_name]" => user.login,
        "[learner_email]" => user.email,

        "[assessment_name]" => assessment.name,
        "[assessment_description]" => assessment.description,

        "[assessment_start_schedule]" => assessment.start_time,
        "[assessment_end_schedule]" => assessment.end_time,
        "[assessment_duration_hour]" => assessment.duration_hour,
        "[assessment_duration_min]" => assessment.duration_min,

        "[learner_lesson_status]" => learner.lesson_status,
        "[learner_lesson_raw_score]" => learner.score_raw,
        "[learner_lesson_max_score]" => learner.score_max,
        "[learner_lesson_credit]" => learner_credit
      ]
      UserMailer.delay.send_mail(user,'send_score_to_learner',tenant.id,from_replacements,subject_replacements,body_replacements)
      #return 'success' once sent without any errors
      return "success"
      #catch if any errors or exceptions and return that exception
    rescue Net::SMTPFatalError => exception
      return exception
    rescue Net::SMTPSyntaxError => exception
      return exception
    end
  end

  #control comes here when user clicks on manage_learners link
  def manage_learners
    @assessment = Assessment.find(params[:id])
    #    remove_bounced_from_learners(@assessment)
  end

  def find_remaining_learners_from_already_assigned
    checked_learners = Array.new
    j=0
    params.each_pair { |key, value|
      if key.include? "email:"
        checked_learners[j] = value.to_i
        j = j + 1
      end
    }
    return checked_learners
  end
 
  #control comes here when user clicks on 'show' link of any group in manage_leanrers page
  #calculates required objects for learners_in_group page. calculates totalleaners for that particular group in the system and total learners who are assigned to that assessment in that group
  def learners_in_group
    @assessment = Assessment.find(params[:id])
    @group = Group.find(params[:group_id])
    @assigned_learners = @assessment.learners.find(:all, :conditions => ["type_of_test_taker = 'learner' AND active='yes' AND group_id= ?",params[:group_id]])
    @total_learners = @group.users.find(:all, :include=> "user", :conditions=> ["user_id = ? AND deactivated_at IS NULL",current_user.id])
  end

  #control comes here when admin selects groups in manage_learnes page of assessments and clicks done.
  def manage_groups
    unless params[:group].nil?
      assessment = Assessment.find(params[:id])
      groups_to_be_assigned = params[:group]
      groups_assign(groups_to_be_assigned,assessment)
      flash[:wait_feedback] = "The learners are being assigned. The process will take some time. Please check later for the updated learner count."
    end
    redirect_to("/courses")
  end

  #this method takes array of group_ids for which learners have to be assigned. It calculates learners_for_course_adding and learners_valid_for_signup and pushes into delayed_jobs table.
  def groups_assign(groups_to_be_assigned,assessment)
    groups_delayed = Array.new
    groups_to_be_assigned.each { |g|
      groups_delayed << g[0].to_i
    }
    assessment_id = assessment.id
    current_user_id = current_user.id
    
    #call calculate_delayed_group_learners method using delayedjob
    assessment_obj = AssessmentsController.new
    assessment_obj.delay.calculate_delayed_group_learners(groups_delayed,current_user_id,assessment_id)
  end

  #this method is called from groups_assign using delayed_job therefore this gets executed in background
  #this assigns the groups to the package
  def calculate_delayed_group_learners(groups_to_be_assigned,current_user_id,assessment_course_id)
    current_user = User.find(current_user_id)

    groups_to_be_assigned.each { |g|
      learners_for_course_adding = current_user.user.find(:all,:conditions => ["group_id = ? AND crypted_password IS NOT NULL AND deactivated_at IS NULL",g])
      learners_valid_for_signup = current_user.user.find(:all,:conditions => ["group_id = ? AND crypted_password IS NULL AND deactivated_at IS NULL",g])
      save_and_send_mails(learners_for_course_adding,learners_valid_for_signup,current_user,assessment_course_id)
    }
  end

  #control comes here when user checks few learnres in learners_in_group page and clicks submit.
  #This method first checks if any learners have to be unassigned.
  # If there are any learners to be unassigned then update the learner.active = 'no' which will retain the learner record in the table but just he inactive for that course as his active attribute in learnes table is 'no'.
  def manage
    @assessment = Assessment.find(params[:id])

    no_of_learners_to_be_deleted = 0
    remaining_learners_from_already_assigned = Array.new
    remaining_learners_from_already_assigned = find_remaining_learners_from_already_assigned()
    @learners = Learner.find_all_by_assessment_id_and_active(params[:id],"yes", :conditions => ["type_of_test_taker != 'admin' AND group_id = ?",params[:group_id]])
    existing_learners_ids = Array.new
    for learner in @learners
      existing_learners_ids << learner.user_id
    end
    learners_to_be_deleted = existing_learners_ids - remaining_learners_from_already_assigned
    for learner_id in learners_to_be_deleted
      no_of_learners_to_be_deleted += 1
      learner_make_inactive = Learner.find_by_user_id_and_assessment_id(learner_id,@assessment.id, :conditions => ["type_of_test_taker != 'admin' AND group_id = ?",params[:group_id]])
      learner_make_inactive.update_attribute(:active,"no")
      decrease_assessment_columns_while_deleting(@assessment,learner_make_inactive)
    end
    learners_for_course_adding_ids = Array.new
    learners_for_course_adding_ids = learners_for_course_added_mails()
    learners_for_course_adding = Array.new
    learners_for_course_adding_ids.each {|user_id|
      learners_for_course_adding << User.find(user_id)
    }
    learners_for_signup = Hash.new
    learners_for_signup = map_login_to_email()
    learners_valid_for_signup = Hash.new
    learners_valid_for_signup = validate_email(learners_for_signup)
    no_of_learners_assigned = 0
    no_of_learners_assigned += save_and_send_mails(learners_for_course_adding,learners_valid_for_signup,current_user,@assessment.id)
    if no_of_learners_to_be_deleted == 1 then
      flash[:number_of_deleted_learner] = "#{no_of_learners_to_be_deleted} learner removed from assessment #{@assessment.name}"
    elsif no_of_learners_to_be_deleted > 0 then
      flash[:number_of_deleted_learner] = "#{no_of_learners_to_be_deleted} learners removed from assessment #{@assessment.name}"
    end
    if flash[:learner_limit_exceeds].nil? or flash[:learner_limit_exceeds].blank?
      if (@already_assigned.nil? or @already_assigned.blank?) and (@admin.nil? or @admin.blank?) and (@other_org.nil? or @other_org.blank?) and (@incorrect_mail_count == 0) then
        if no_of_learners_assigned == 1 then
          flash[:number_of_mails] = "#{no_of_learners_assigned} learner assigned to assessment #{@assessment.name}"
        elsif no_of_learners_assigned > 1 then
          flash[:number_of_mails] = "#{no_of_learners_assigned} learners assigned to assessment #{@assessment.name}"
        end
        redirect_to("/courses")
      else
        redirect_to("/assessments/manage_learners/#{@assessment.id}")
      end
    else
      redirect_to("/courses")
    end
  end


  def learners_for_course_added_mails
    checked_learners = Array.new
    j=0
    params.each_pair { |key, value|
      if key.include? "email-"
        checked_learners[j] = value
        j = j + 1
      end
    }
    return checked_learners
  end

  def map_login_to_email
    # Maps given user name to corresponding email ids
    # Author : Karthik
    login = Hash.new
    params[:user].each_pair { |key, value|
      login_key = key.slice("login")
      if login_key == "login" && !value.empty? then
        login[key] = value
      end
    }

    email = Hash.new
    params[:user].each_pair { |key, value|
      email_key = key.slice("email")
      if email_key == "email" && !value.empty? then
        email[key] = value
      end
    }

    sorted_login = Hash.new
    sorted_login = login.sort

    sorted_email = Hash.new
    sorted_email = email.sort

    mapped_hash = Hash.new
    count = sorted_login.length

    i=0
    while i < count
      mapped_hash[sorted_email[i][1]] = sorted_login[i][1]
      i=i+1
    end
    return mapped_hash
  end

  def validate_email(learners_for_signup)
    email_pattern = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/
    valid_learners = Hash.new
    @incorrect_mail_count = 0
    learners_for_signup.each { |email,login|
      if email_pattern.match(email) then
        valid_learners[email] = login
      else
        @incorrect_mail_count += 1
        flash[:incorrect_mail_message] = "#{email} is incorrect"
      end
    }
    return valid_learners
  end

  #saves all details and sends mail. checks if learner is already assigned for that assessment by that user. If so then do nothing else store_learner_details
  #return the number of learners assigned for this package
  def save_and_send_mails(learners_for_course_adding,learners_valid_for_signup,current_user,assessment_id)
    @final_signup_learners = Array.new     #Creates a global hash to store filtered learners for sending signup mail.
    final_course_added_learners = Array.new
    @total_final_course_added_learners = Array.new
    @already_assigned = Array.new
    @admin = Array.new
    @other_org = Array.new
    @assessment = Assessment.find(assessment_id)
    unless learners_valid_for_signup.nil? or learners_valid_for_signup.blank? then
      learners_valid_for_signup.each { |learner|
        if valid_assign(@assessment.id,current_user)
          @user = User.find_by_email(learner.email)
          #          final_signup_learners << learner.email
          case
          when (@user.user_id == current_user.id or @user.id == current_user.id) then     # whether the learner is for current admin or not or whether admin is assigning himself as learner
            @learner = Learner.find_by_assessment_id_and_user_id_and_type_of_test_taker(assessment_id,@user.id,"learner")
            if @learner.nil? then   # whether the learner is already present or not
              if valid_assign(@assessment.id,current_user)
                if @assessment.assessment_rules.nil? or @assessment.assessment_rules.blank?
                  store_learner_details(@assessment,current_user,@user,"","learner")
                else
                  store_learner_details_using_rules(@assessment,current_user,@user,"","learner")
                end
                fill_signup_course_added_array(@user)
              end
            elsif !@learner.nil? and @learner.active == "no" then        # if learner is existing in learners table with active status "no" then just change the status to "yes"No need to add new record for him again
              @learner.update_attribute(:active,"yes")
              fill_signup_course_added_array(@learner.user)
              increase_assessment_columns_while_assigning(@assessment,@learner)
            end
          end
        end
      }
    end
    
    #dont write final_course_added_learners= total_final_course_added_learners = learners_for_course_adding. This doesnt work.. they make use of same address and mem space.
    # so x=y=3, here if u make any changes on x they reflect on y also.
    final_course_added_learners = learners_for_course_adding
    #    total_final_course_added_learners.replace(final_course_added_learners)
    final_course_added_learners.each { |learner|
      @user = User.find_by_email(learner.email)

      @learner = Learner.find_by_assessment_id_and_user_id_and_type_of_test_taker(assessment_id,@user.id,"learner")
      if @learner.nil? then   # whether the learner is already present or not
        if valid_assign(@assessment.id,current_user)
          if @assessment.assessment_rules.nil? or @assessment.assessment_rules.blank?
            store_learner_details(@assessment,current_user,@user,"","learner")
          else
            store_learner_details_using_rules(@assessment,current_user,@user,"","learner")
          end
          fill_signup_course_added_array(@user)
        end
      elsif !@learner.nil? and @learner.active == "no" then        # if learner is existing in learners table with active status "no" then just change the status to "yes"No need to add new record for him again
        @learner.update_attribute(:active,"yes")
        fill_signup_course_added_array(@learner.user)
        increase_assessment_columns_while_assigning(@assessment,@learner)
      end
    }
    
    test_added_count = send_test_added_mails(@total_final_course_added_learners,@assessment,current_user)
    signup_count = send_signup_mails(@final_signup_learners,@assessment,current_user)
    return (signup_count + test_added_count)
  end

  def fill_signup_course_added_array(user)
    if user.crypted_password.nil? then
      @final_signup_learners << user.email
    else
      @total_final_course_added_learners << user
    end
  end

  #stores details in learners table for every learner. We got to pass current_user because there wont be any session during delayed job worker process is running.
  def store_learner_details(assessment,current_user,user,package_id,type_of_test_taker)
    learner = Learner.new
    learner.assessment_id = assessment.id
    learner.score_min = assessment.pass_score
    learner.user_id = user.id
    learner.admin_id = current_user.id
    learner.tenant_id = assessment.tenant_id
    learner.group_id = user.group_id
    learner.lesson_location = "0"
    learner.type_of_test_taker = type_of_test_taker
    qb_list,question_list = create_question_list(assessment)
    # fill suspend data with * initially
    answer_list = Array.new(question_list.split(',').length)
    answer_list.collect! {|x| x = '' }
    learner.suspend_data = answer_list.join('|')
    # fill question status details column with "" initially
    question_status_list = Array.new(question_list.split(',').length)
    question_status_list.collect! {|x| x = '' }
    learner.question_status_details = question_status_list.join(',')
    learner.score_max = assessment.no_of_questions * assessment.correct_ans_points
    learner.total_time = ((assessment.duration_hour * 3600)+(assessment.duration_min * 60))
    learner.entry = qb_list
    learner.question_status_details = ""
    unless package_id.nil? and package_id.blank?
      learner.package_id = package_id
    end
    learner.save
    @i = 1
    create_test_details_for_user(learner.id,user.id,current_user.tenant_id,question_list,assessment)    
    increase_assessment_columns_while_assigning(assessment,learner)
    return learner
  end

  def store_admin_preview_details_using_rules
    assessment = Assessment.find(params[:id])
    admin_as_learner = Learner.new
    admin_as_learner.assessment_id = assessment.id
    admin_as_learner.score_min = assessment.pass_score
    admin_as_learner.user_id = current_user.id
    admin_as_learner.admin_id = current_user.id
    admin_as_learner.tenant_id = assessment.tenant_id
    admin_as_learner.group_id = current_user.group_id
    admin_as_learner.lesson_location = "0"
    admin_as_learner.save
    assessment.update_attribute(:current_learner_id,admin_as_learner.id)
    assessment.update_attribute(:no_of_questions,assessment.assessment_rules.sum(:questions_required))
    if assessment.sections.count > 1
      assessment.update_attribute(:assessment_type,"multiple")
    end
    @section_id = 0
    assessment.assessment_rules.each do |assessment_rule|
      tagvalue_ids = assessment_rule.rules.pluck(:tagvalue_id)
      @question_attributes = get_question_attributes_for_tagvalues(assessment_rule,tagvalue_ids)
      if @section_id != assessment_rule.section_id
        @section_id = assessment_rule.section_id
        @i = 1
      end
      if assessment.is_linear == false then
        create_test_details_for_user_using_rule(admin_as_learner.id,current_user.id,assessment.tenant_id,@question_attributes.limit(assessment_rule.questions_required).order('RAND()'),assessment,assessment_rule)
      else
        create_test_details_for_user_using_rule(admin_as_learner.id,current_user.id,assessment.tenant_id,@question_attributes.limit(assessment_rule.questions_required).order('id'),assessment,assessment_rule)
      end
    end
    positive_score_count = admin_as_learner.test_details.sum(:question_positive_mark)
    admin_as_learner.update_attribute(:score_max, positive_score_count)
    redirect_to("/assessments/schedule_assessment/#{assessment.id.to_s}")
  end

  def store_learner_details_using_rules(assessment,current_user,user,package_id,type_of_test_taker)
    learner = Learner.new
    learner.assessment_id = assessment.id
    learner.score_min = assessment.pass_score
    learner.user_id = user.id
    learner.admin_id = current_user.id
    learner.tenant_id = assessment.tenant_id
    learner.group_id = user.group_id
    learner.lesson_location = "0"
    learner.type_of_test_taker = type_of_test_taker    
    learner.score_max = assessment.no_of_questions * assessment.correct_ans_points
    learner.total_time = ((assessment.duration_hour * 3600)+(assessment.duration_min * 60))
    learner.question_status_details = ""
    unless package_id.nil? and package_id.blank?
      learner.package_id = package_id
    end
    learner.save
    @section_id = 0
    assessment.assessment_rules.each do |assessment_rule|
      tagvalue_ids = assessment_rule.rules.pluck(:tagvalue_id)
      @question_attributes = get_question_attributes_for_tagvalues(assessment_rule,tagvalue_ids)
      if @section_id != assessment_rule.section_id
        @section_id = assessment_rule.section_id
        @i = 1
      end
      if assessment.is_linear == false then
        create_test_details_for_user_using_rule(learner.id,current_user.id,assessment.tenant_id,@question_attributes.limit(assessment_rule.questions_required).order('RAND()'),assessment,assessment_rule)
      else
        create_test_details_for_user_using_rule(learner.id,current_user.id,assessment.tenant_id,@question_attributes.limit(assessment_rule.questions_required).order('id'),assessment,assessment_rule)
      end
    end
    positive_score_count = learner.test_details.sum(:question_positive_mark)
    learner.update_attribute(:score_max, positive_score_count)
    increase_assessment_columns_while_assigning(assessment,learner)
    return learner
  end

  def create_test_details_for_user_using_rule(learner_id,user_id,tenant_id,question_attributes,assessment,assessment_rule)
    question_attributes.each do |qa|
      save_test_details_for_user(learner_id,user_id,tenant_id,qa.question,qa.question.question_type,qa.question_bank_id,assessment_rule.positive_mark,assessment_rule.negative_mark,assessment,@i,assessment_rule.section_id)
    end
  end

  def create_test_details_for_user(learner_id,user_id,tenant_id,question_attributes,assessment)
    question_attributes.each do |qa|
      obj_assessment_question = create_assessment_question_mapping(assessment,qa.question,assessment.correct_ans_points,assessment.wrong_ans_points)
      unless obj_assessment_question.nil? or obj_assessment_question.blank?
        save_test_details_for_user(learner_id,user_id,tenant_id,qa.question,qa.question.question_type,qa.question_bank_id,obj_assessment_question.mark,obj_assessment_question.negative_mark,assessment,@i,"")
      else
        save_test_details_for_user(learner_id,user_id,tenant_id,qa.question,qa.question.question_type,qa.question_bank_id,assessment.correct_ans_points,assessment.wrong_ans_points,assessment,@i,"")
      end
    end
  end

  def save_test_details_for_user(learner_id,user_id,tenant_id,question,question_type,question_bank_id,positive_mark,negative_mark,assessment,serial_number,section_id)
    test_detail = TestDetail.find_by_learner_id_and_question_id(learner_id,question.id)
    if test_detail.nil? or test_detail.blank?
      test_details = TestDetail.new
      test_details.learner_id = learner_id
      test_details.user_id = user_id
      test_details.tenant_id = tenant_id
      test_details.question_id = question.id
      test_details.question_type = question_type
      test_details.question_bank_id = question_bank_id
      test_details.question_positive_mark = positive_mark
      test_details.question_negative_mark = negative_mark
      test_details.serial_number = serial_number
      test_details.section_id = section_id
      test_details.assessment_id = assessment.id
      test_details.save
      @i = @i + 1
    end
  end

  def send_signup_mails(learners_for_signup,assessment,current_user)
    count = 0
    learners_for_signup.each { |email|
      @user = User.find_by_email(email)
      if valid_assign(assessment.id,current_user)
        if !@user.nil? then
          current_learner = Learner.find_by_assessment_id_and_user_id_and_type_of_test_taker(assessment.id,@user.id,'learner')
          result = signup_assessment_learner_notification_send_grid(@user,assessment,current_learner,current_user,@user.tenant)
          if result == "success" then
            count = count + 1
          end
        end
      end
    }
    return count
  end

  #sets the attributes from_replacements, subject_replacements and body_replacements for the signup_assessment_learner_notification mail
  #basically every attribute is a hash structured as seen below and these are sent to the 'send_mail' method in UserMailer model for further processing(check UserMailer model)
  def signup_assessment_learner_notification_send_grid(user,assessment,learner,admin,tenant)
    begin
      url =  user.crypted_password.nil? ? "https://#{tenant.custom_url}.#{SITE_URL}/activate/#{user.activation_code}" : "https://#{tenant.custom_url}.#{SITE_URL}"
      from_replacements = Hash["[tenant_name]" => tenant.organization,
        "[sender_name]" => admin.login,
        "[sender_email]" => admin.email
      ]

      subject_replacements = Hash["[tenant_name]" => tenant.organization,
        "[url]" => url,
        "[sender_name]" => admin.login,
        "[sender_email]" => admin.email,
        "[learner_name]" => user.login,
        "[learner_email]" => user.email,

        "[assessment_name]" => assessment.name,
        "[assessment_description]" => assessment.description,

        "[assessment_start_schedule]" => assessment.start_time,
        "[assessment_end_schedule]" => assessment.end_time,
        "[assessment_duration_hour]" => assessment.duration_hour,
        "[assessment_duration_min]" => assessment.duration_min,

        "[learner_lesson_status]" => learner.lesson_status,
        "[learner_lesson_raw_score]" => learner.score_raw,
        "[learner_lesson_max_score]" => learner.score_max,
        "[learner_lesson_credit]" => learner.credit
      ]
      body_replacements = Hash["[tenant_name]" => tenant.organization,
        "[url]" => url,
        "[sender_name]" => admin.login,
        "[sender_email]" => admin.email,
        "[learner_name]" => user.login,
        "[learner_email]" => user.email,

        "[assessment_name]" => assessment.name,
        "[assessment_description]" => assessment.description,

        "[assessment_start_schedule]" => assessment.start_time,
        "[assessment_end_schedule]" => assessment.end_time,
        "[assessment_duration_hour]" => assessment.duration_hour,
        "[assessment_duration_min]" => assessment.duration_min,

        "[learner_lesson_status]" => learner.lesson_status,
        "[learner_lesson_raw_score]" => learner.score_raw,
        "[learner_lesson_max_score]" => learner.score_max,
        "[learner_lesson_credit]" => learner.credit
      ]
      UserMailer.delay.send_mail(user,'signup_assessment_learner_notification',tenant.id,from_replacements,subject_replacements,body_replacements)
      return "success"
      #catch if any errors or exceptions and return that exception
    rescue Net::SMTPFatalError => exception
      return exception
    rescue Net::SMTPSyntaxError => exception
      return exception
    end
  end

  def send_test_added_mails(learners_for_test_adding,assessment,current_user)
    count = 0
    learners_for_test_adding.each { |learner|
      @user = User.find_by_email(learner.email)
      if valid_assign(assessment.id,current_user)
        if !@user.nil? then
          current_learner = Learner.find_by_assessment_id_and_user_id_and_type_of_test_taker(assessment.id,@user.id,'learner')
          result = testadd_assessment_learner_notification_send_grid(@user,assessment,current_learner,current_user,@user.tenant)
          if result == "success" then
            count = count + 1
          end
        end
      end
    }
    return count
  end

  #sets the attributes from_replacements, subject_replacements and body_replacements for the testadd_assessment_learner_notification mail
  #basically every attribute is a hash structured as seen below and these are sent to the 'send_mail' method in UserMailer model for further processing(check UserMailer model)
  def testadd_assessment_learner_notification_send_grid(user,assessment,learner,admin,tenant)
    begin
      url =  user.crypted_password.nil? ? "https://#{tenant.custom_url}.#{SITE_URL}/activate/#{user.activation_code}" : "https://#{tenant.custom_url}.#{SITE_URL}"
      from_replacements = Hash["[tenant_name]" => tenant.organization,
        "[sender_name]" => admin.login,
        "[sender_email]" => admin.email
      ]

      subject_replacements = Hash["[tenant_name]" => tenant.organization,
        "[url]" => url,
        "[sender_name]" => admin.login,
        "[sender_email]" => admin.email,
        "[learner_name]" => user.login,
        "[learner_email]" => user.email,

        "[assessment_name]" => assessment.name,
        "[assessment_description]" => assessment.description,

        "[assessment_start_schedule]" => assessment.start_time,
        "[assessment_end_schedule]" => assessment.end_time,
        "[assessment_duration_hour]" => assessment.duration_hour,
        "[assessment_duration_min]" => assessment.duration_min,

        "[learner_lesson_status]" => learner.lesson_status,
        "[learner_lesson_raw_score]" => learner.score_raw,
        "[learner_lesson_max_score]" => learner.score_max,
        "[learner_lesson_credit]" => learner.credit
      ]
      body_replacements = Hash["[tenant_name]" => tenant.organization,
        "[url]" => url,
        "[sender_name]" => admin.login,
        "[sender_email]" => admin.email,
        "[learner_name]" => user.login,
        "[learner_email]" => user.email,

        "[assessment_name]" => assessment.name,
        "[assessment_description]" => assessment.description,

        "[assessment_start_schedule]" => assessment.start_time,
        "[assessment_end_schedule]" => assessment.end_time,
        "[assessment_duration_hour]" => assessment.duration_hour,
        "[assessment_duration_min]" => assessment.duration_min,

        "[learner_lesson_status]" => learner.lesson_status,
        "[learner_lesson_raw_score]" => learner.score_raw,
        "[learner_lesson_max_score]" => learner.score_max,
        "[learner_lesson_credit]" => learner.credit
      ]
      UserMailer.delay.send_mail(user,'testadd_assessment_learner_notification',tenant.id,from_replacements,subject_replacements,body_replacements)
      return "success"
      #catch if any errors or exceptions and return that exception
    rescue Net::SMTPFatalError => exception
      return exception
    rescue Net::SMTPSyntaxError => exception
      return exception
    end
  end

  def convert_utc_time_to_system_time(time,tenant)
    @total_offset = calculate_total_offset(tenant)
    if @zone.include? "+"
      @show_time = time + @total_offset
    else
      @show_time = time - @total_offset
    end
  end

  def calculate_total_offset(tenant)
    @zone = tenant.zone
    if @zone.include? "+"
      @offset = @zone.gsub('+','')
    else
      @offset = @zone.gsub('-','')
    end
    offset_hour = @offset.split(':')[0].to_i
    offset_min = @offset.split(':')[1].to_i
    total_offset = (offset_hour * 60 * 60) + (offset_min * 60)
    return total_offset
  end

  # control comes here when the learner clicks on start test for the first time
  def learner_information
    @current_learner = get_current_learner_object(params[:id])
    @assessment = get_assessment_object(@current_learner.assessment_id)    
  end

  def instructions
    @current_learner = get_current_learner_object(params[:id])
    @assessment = get_assessment_object(@current_learner.assessment_id)
  end

  def about_test
    @current_learner = get_current_learner_object(params[:id])
    @assessment = get_assessment_object(@current_learner.assessment_id)
  end

  def test_specific_instructions
    @current_learner = get_current_learner_object(params[:id])
    @assessment = get_assessment_object(@current_learner.assessment_id)
  end

  def cmat_instructions
    @current_learner = get_current_learner_object(params[:id])
    @assessment = get_assessment_object(@current_learner.assessment_id)
  end

  def all_demographics_filled(assessment)
    demographics = assessment.demographics
    if !demographics.demographic_type_1.nil? and !demographics.demographic_type_1.empty?
      if params[:learner][:demographic_1].nil? or params[:learner][:demographic_1].empty? or params[:learner][:demographic_1].blank?
        return false
      end
    end
    if !demographics.demographic_type_2.nil? and !demographics.demographic_type_2.empty?
      if params[:learner][:demographic_2].nil? or params[:learner][:demographic_2].empty? or params[:learner][:demographic_2].blank?
        return false
      end
    end
    if !demographics.demographic_type_3.nil? and !demographics.demographic_type_3.empty? and !demographics.demographic_type_3.blank?
      if params[:learner][:demographic_3].nil? or params[:learner][:demographic_3].empty? or params[:learner][:demographic_3].blank?
        return false
      end
    end
    if !demographics.demographic_type_4.nil? and !demographics.demographic_type_4.empty? and !demographics.demographic_type_4.blank?
      if params[:learner][:demographic_4].nil? or params[:learner][:demographic_4].empty? or params[:learner][:demographic_4].blank?
        return false
      end
    end
    if !demographics.demographic_type_5.nil? and !demographics.demographic_type_5.empty? and !demographics.demographic_type_5.blank?
      if params[:learner][:demographic_5].nil? or params[:learner][:demographic_5].empty? or params[:learner][:demographic_5].blank?
        return false
      end
    end
    if !demographics.demographic_type_6.nil? and !demographics.demographic_type_6.empty? and !demographics.demographic_type_6.blank?
      if params[:learner][:demographic_6].nil? or params[:learner][:demographic_6].empty? or params[:learner][:demographic_6].blank?
        return false
      end
    end
    if !demographics.demographic_type_7.nil? and !demographics.demographic_type_7.empty? and !demographics.demographic_type_7.blank?
      if params[:learner][:demographic_7].nil? or params[:learner][:demographic_7].empty? or params[:learner][:demographic_7].blank?
        return false
      end
    end
    if !demographics.demographic_type_8.nil? and !demographics.demographic_type_8.empty? and !demographics.demographic_type_8.blank?
      if params[:learner][:demographic_8].nil? or params[:learner][:demographic_8].empty? or params[:learner][:demographic_8].blank?
        return false
      end
    end
    if !demographics.demographic_type_9.nil? and !demographics.demographic_type_9.empty? and !demographics.demographic_type_9.blank?
      if params[:learner][:demographic_9].nil? or params[:learner][:demographic_9].empty? or params[:learner][:demographic_9].blank?
        return false
      end
    end
    if !demographics.demographic_type_10.nil? and !demographics.demographic_type_10.empty? and !demographics.demographic_type_10.blank?
      if params[:learner][:demographic_10].nil? or params[:learner][:demographic_10].empty? or params[:learner][:demographic_10].blank?
        return false
      end
    end
    if !demographics.demographic_type_11.nil? and !demographics.demographic_type_11.empty? and !demographics.demographic_type_11.blank?
      if params[:learner][:demographic_11].nil? or params[:learner][:demographic_11].empty? or params[:learner][:demographic_11].blank?
        return false
      end
    end
    if !demographics.demographic_type_12.nil? and !demographics.demographic_type_12.empty? and !demographics.demographic_type_12.blank?
      if params[:learner][:demographic_12].nil? or params[:learner][:demographic_12].empty? or params[:learner][:demographic_12].blank?
        return false
      end
    end
    if !demographics.demographic_type_13.nil? and !demographics.demographic_type_13.empty? and !demographics.demographic_type_13.blank?
      if params[:learner][:demographic_13].nil? or params[:learner][:demographic_13].empty? or params[:learner][:demographic_13].blank?
        return false
      end
    end
    if !demographics.demographic_type_14.nil? and !demographics.demographic_type_14.empty? and !demographics.demographic_type_14.blank?
      if params[:learner][:demographic_14].nil? or params[:learner][:demographic_14].empty? or params[:learner][:demographic_14].blank?
        return false
      end
    end
    if !demographics.demographic_type_15.nil? and !demographics.demographic_type_15.empty? and !demographics.demographic_type_15.blank?
      if params[:learner][:demographic_15].nil? or params[:learner][:demographic_15].empty? or params[:learner][:demographic_15].blank?
        return false
      end
    end
    return true
  end

  # Control comes here from assessments/learner_information.
  # Saves demographics details of learner, updating start time of that learner and no_of_times_attempted
  # column and redirects to assessment page to take test
  def save_learner_information
    @current_learner = get_current_learner_object(params[:id])
    @assessment = get_assessment_object(@current_learner.assessment_id)
    if @assessment.demographics_compulsory == true
      if all_demographics_filled(@assessment)
        store_demographics(@assessment,@current_learner)
        redirect_to("/assessments/multi_page_test/#{@current_learner.id}")
      else
        flash[:details_not_filled] = "Fill all the details"
        redirect_to("/assessments/learner_information/#{params[:id]}")
      end
    else
      store_demographics(@assessment,@current_learner)
      redirect_to("/assessments/multi_page_test/#{@current_learner.id}")
    end
  end

  def store_demographics(assessment,current_learner)
    learner_values = Hash.new
    if params.include? "learner"
      current_learner.update_attributes(params[:learner])
    end
    time = Time.now
    if current_learner.lesson_status == "not attempted" then
      learner_values['test_start_time'] = time
      learner_values['lesson_status'] = "incomplete"
      learner_values['recent_timestamp'] = time
      learner_values['no_of_times_attempted'] = current_learner.no_of_times_attempted + 1
      learner_values = update_timestamps("start",current_learner,current_learner.assessment_id,learner_values)
      current_learner.update_attributes(learner_values)
      if (current_learner.no_of_times_attempted == 1)
        assessment.assessment_status_based_updation(assessment,current_learner)
      end
    end    
  end

  # control comes here from add_questions_to_assessment
  def add_next_question
    @assessment = Assessment.find(params[:id])
    @obj_question_bank = QuestionBank.find_by_id(params[:question_bank_id])
    case
    when params[:question_type] == "MCQ"
      if !(params[:mcq_question][:question_text].nil? or params[:mcq_question][:question_text].blank?)
        question_obj = Question.new
        question_obj.question_text = params[:mcq_question][:question_text]
        question_obj.question_type = params[:question_type]
        question_obj.question_bank_id = @obj_question_bank.id
        question_obj.question_image = params[:mcq_question][:question_image]
        question_obj.explanation = params[:mcq_question][:explanation]
        question_obj.tenant_id = @assessment.tenant_id
        question_obj.save
        question_type_id = get_question_type("MCQ").id
        difficulty_id = get_difficulty("not defined")
        question_attribute = create_question_attribute(question_obj.id,question_type_id,@obj_question_bank.id,"","",difficulty_id,"","","",1,@assessment.tenant_id)

        if !(params[:mcq_option_1].nil? or params[:mcq_option_1].blank?)
          flash[:mcq_option_1] = params[:mcq_option_1]
          answer_obj = Answer.new
          answer_obj.question_id = question_obj.id
          answer_obj.question_bank_id = @obj_question_bank.id
          answer_obj.answer_text = params[:mcq_option_1]
          if params.include? "mcq_radio_value"
            if params[:mcq_radio_value] == params[:mcq_option_1] then
              answer_obj.answer_status = "correct"
            else
              answer_obj.answer_status = "wrong"
            end
          end
          answer_obj.save
        end
        if !(params[:mcq_option_2].nil? or params[:mcq_option_2].blank?)
          flash[:mcq_option_2] = params[:mcq_option_2]
          answer_obj = Answer.new
          answer_obj.question_id = question_obj.id
          answer_obj.question_bank_id = @obj_question_bank.id
          answer_obj.answer_text = params[:mcq_option_2]
          if params.include? "mcq_radio_value"
            if params[:mcq_radio_value] == params[:mcq_option_2] then
              answer_obj.answer_status = "correct"
            else
              answer_obj.answer_status = "wrong"
            end
          end
          answer_obj.save
        end
        if !(params[:mcq_option_3].nil? or params[:mcq_option_3].blank?)
          flash[:mcq_option_3] = params[:mcq_option_3]
          answer_obj = Answer.new
          answer_obj.question_id = question_obj.id
          answer_obj.question_bank_id = @obj_question_bank.id
          answer_obj.answer_text = params[:mcq_option_3]
          if params.include? "mcq_radio_value"
            if params[:mcq_radio_value] == params[:mcq_option_3] then
              answer_obj.answer_status = "correct"
            else
              answer_obj.answer_status = "wrong"
            end
          end
          answer_obj.save
        end
        if !(params[:mcq_option_4].nil? or params[:mcq_option_4].blank?)
          flash[:mcq_option_4] = params[:mcq_option_4]
          answer_obj = Answer.new
          answer_obj.question_id = question_obj.id
          answer_obj.question_bank_id = @obj_question_bank.id
          answer_obj.answer_text = params[:mcq_option_4]
          if params.include? "mcq_radio_value"
            if params[:mcq_radio_value] == params[:mcq_option_4] then
              answer_obj.answer_status = "correct"
            else
              answer_obj.answer_status = "wrong"
            end
          end
          answer_obj.save
        end
        if !(params[:mcq_option_5].nil? or params[:mcq_option_5].blank?)
          flash[:mcq_option_5] = params[:mcq_option_5]
          answer_obj = Answer.new
          answer_obj.question_id = question_obj.id
          answer_obj.question_bank_id = @obj_question_bank.id
          answer_obj.answer_text = params[:mcq_option_5]
          if params.include? "mcq_radio_value"
            if params[:mcq_radio_value] == params[:mcq_option_5] then
              answer_obj.answer_status = "correct"
            else
              answer_obj.answer_status = "wrong"
            end
          end
          answer_obj.save
        end
      end
    when params[:question_type] == "MAQ"
      if !(params[:maq_question][:question_text].nil? or params[:maq_question][:question_text].blank?)
        question_obj = Question.new
        question_obj.question_text = params[:maq_question][:question_text]
        question_obj.question_type = params[:question_type]
        question_obj.question_bank_id = @obj_question_bank.id
        question_obj.question_image = params[:maq_question][:question_image]
        question_obj.explanation = params[:maq_question][:explanation]
        question_obj.tenant_id = @assessment.tenant_id
        question_obj.save

        question_type_id = get_question_type("MAQ").id
        difficulty_id = get_difficulty("not defined")
        question_attribute = create_question_attribute(question_obj.id,question_type_id,@obj_question_bank.id,"","",difficulty_id,"","","",1,@assessment.tenant_id)

        if !(params[:maq_option_1].nil? or params[:maq_option_1].blank?)
          flash[:maq_option_1] = params[:maq_option_1]
          answer_obj = Answer.new
          answer_obj.question_id = question_obj.id
          answer_obj.question_bank_id = @obj_question_bank.id
          answer_obj.answer_text = params[:maq_option_1]
          if params.include? "maq_radio_value1" then
            answer_obj.answer_status = "correct"
          else
            answer_obj.answer_status = "wrong"
          end
          answer_obj.save
        end
        if !(params[:maq_option_2].nil? or params[:maq_option_2].blank?)
          flash[:maq_option_2] = params[:maq_option_2]
          answer_obj = Answer.new
          answer_obj.question_id = question_obj.id
          answer_obj.question_bank_id = @obj_question_bank.id
          answer_obj.answer_text = params[:maq_option_2]
          if params.include? "maq_radio_value2" then
            answer_obj.answer_status = "correct"
          else
            answer_obj.answer_status = "wrong"
          end
          answer_obj.save
        end
        if !(params[:maq_option_3].nil? or params[:maq_option_3].blank?)
          flash[:maq_option_3] = params[:maq_option_3]
          answer_obj = Answer.new
          answer_obj.question_id = question_obj.id
          answer_obj.question_bank_id = @obj_question_bank.id
          answer_obj.answer_text = params[:maq_option_3]
          if params.include? "maq_radio_value3" then
            answer_obj.answer_status = "correct"
          else
            answer_obj.answer_status = "wrong"
          end
          answer_obj.save
        end
        if !(params[:maq_option_4].nil? or params[:maq_option_4].blank?)
          flash[:maq_option_4] = params[:maq_option_4]
          answer_obj = Answer.new
          answer_obj.question_id = question_obj.id
          answer_obj.question_bank_id = @obj_question_bank.id
          answer_obj.answer_text = params[:maq_option_4]
          if params.include? "maq_radio_value4" then
            answer_obj.answer_status = "correct"
          else
            answer_obj.answer_status = "wrong"
          end
          answer_obj.save
        end
        if !(params[:maq_option_5].nil? or params[:maq_option_5].blank?)
          flash[:maq_option_5] = params[:maq_option_5]
          answer_obj = Answer.new
          answer_obj.question_id = question_obj.id
          answer_obj.question_bank_id = @obj_question_bank.id
          answer_obj.answer_text = params[:maq_option_5]
          if params.include? "maq_radio_value5" then
            answer_obj.answer_status = "correct"
          else
            answer_obj.answer_status = "wrong"
          end
          answer_obj.save
        end
      end
    when params[:question_type] == "FIB"
      if !(params[:fib_question][:question_text].nil? or params[:fib_question][:question_text].blank?)
        question_obj = Question.new
        question_obj.question_text = params[:fib_question][:question_text]
        question_obj.question_type = params[:question_type]
        question_obj.question_bank_id = @obj_question_bank.id
        question_obj.question_image = params[:fib_question][:question_image]
        question_obj.explanation = params[:fib_question][:explanation]
        question_obj.tenant_id = @assessment.tenant_id
        question_obj.save

        question_type_id = get_question_type("FIB").id
        difficulty_id = get_difficulty("not defined")
        question_attribute = create_question_attribute(question_obj.id,question_type_id,@obj_question_bank.id,"","",difficulty_id,"","","",1,@assessment.tenant_id)

        if !(params[:fib_option].nil? or params[:fib_option].blank?)
          answer_obj = Answer.new
          answer_obj.question_id = question_obj.id
          answer_obj.question_bank_id = @obj_question_bank.id
          answer_obj.answer_text = params[:fib_option]
          answer_obj.answer_status = "correct"
          answer_obj.save
        else
          question_obj.destroy
          question_attribute.destroy
        end
      end
    when params[:question_type] == "SA"
      if !(params[:sa_question][:question_text].nil? or params[:sa_question][:question_text].blank?)
        question_obj = Question.new
        question_obj.question_text = params[:sa_question][:question_text]
        question_obj.question_type = params[:question_type]
        question_obj.question_bank_id = @obj_question_bank.id
        question_obj.question_image = params[:sa_question][:question_image]
        question_obj.explanation = params[:sa_question][:explanation]
        question_obj.save

        question_type_id = get_question_type("SA").id
        difficulty_id = get_difficulty("not defined")
        question_attribute = create_question_attribute(question_obj.id,question_type_id,@obj_question_bank.id,"","",difficulty_id,"","","",1,@assessment.tenant_id)

        if !(params[:sa_option].nil? or params[:sa_option].blank?)
          answer_obj = Answer.new
          answer_obj.question_id = question_obj.id
          answer_obj.question_bank_id = @obj_question_bank.id
          answer_obj.answer_text = params[:sa_option]
          answer_obj.answer_status = "correct"
          answer_obj.save
        else
          question_obj.destroy
          question_attribute.destroy
        end
      end
    end
    case
    when params[:Done] == "Add Next Question"
      if params.include? 'control_from_edit_questions_page' then
        redirect_to('/assessments/add_questions_to_assessment/'+@assessment.id.to_s+'?question_bank_id='+@obj_question_bank.id.to_s+'&selected_question_type='+params[:question_type]+'&control_from_edit_questions_page=')
      else
        redirect_to('/assessments/add_questions_to_assessment/'+@assessment.id.to_s+'?question_bank_id='+@obj_question_bank.id.to_s+'&selected_question_type='+params[:question_type])
      end
    when (params[:Done] == "Done Adding Questions" and @assessment.assessment_type == "single")
      no_of_questions = Question.find_all_by_question_bank_id(@obj_question_bank.id).length
      if !params.include? 'control_from_edit_questions_page' then
        @assessment.update_attribute(:no_of_questions,no_of_questions)
      end
      @obj_question_bank.update_attribute(:no_of_questions,no_of_questions)
      @obj_question_bank.assessments_question_banks.each do |ass_qb|
        ass_qb.update_attribute(:question_limit, no_of_questions)
      end
      redirect_to('/assessments/assessment_details/'+@assessment.id.to_s+'?question_bank_id='+@obj_question_bank.id.to_s)

    when (params[:Done] == "Done Adding Questions" and @assessment.assessment_type == "multiple")
      no_of_questions = @obj_question_bank.questions.length
      @obj_question_bank.update_attribute(:no_of_questions,no_of_questions)
      @obj_question_bank.assessments_question_banks.each do |ass_qb|
        ass_qb.update_attribute(:question_limit, no_of_questions)
      end
      if @assessment.no_of_questions.nil?  then
        if !params.include? 'control_from_edit_questions_page' then
          @assessment.update_attribute(:no_of_questions,no_of_questions)
        end
      else
        no_of_questions += @assessment.no_of_questions
        if !params.include? 'control_from_edit_questions_page' then
          @assessment.update_attribute(:no_of_questions,no_of_questions)
        end
      end
      if params.include? 'control_from_edit_questions_page' then
        redirect_to('/assessments/edit_questions/'+@assessment.id.to_s+'?control_from_edit_questions_page=')
      else
        redirect_to('/assessments/add_more_topics_to_assessment/'+@assessment.id.to_s)
      end
    else
      if params.include? 'control_from_edit_questions_page' then
        redirect_to('/assessments/add_questions_to_assessment/'+@assessment.id.to_s+'?question_bank_id='+@obj_question_bank.id.to_s+'&selected_question_type='+params[:question_type]+'&control_from_edit_questions_page=')
      else
        redirect_to('/assessments/add_questions_to_assessment/'+@assessment.id.to_s+'?question_bank_id='+@obj_question_bank.id.to_s+'&selected_question_type='+params[:question_type])
      end
    end
  end

  # control comes here when we click on create assessment link
  def create_assessment
  end

  #checks if the current tenant is allowed to upload assessment or not depending upon his plan
  def upload_valid()
    if current_user.tenant.pricing_plan.allow_assessments then
      #      if current_user.tenant.pricing_plan.plan_group == "assessment_only_plan" then
      #        max_learners_to_be_assigned = current_user.tenant.max_learner_credit
      #        total_leaners_assigned = current_user.tenant.remaining_learner_credit
      #        if tenant.remaining_learner_credit > 0 then
      #          return true
      #        else
      #          return false
      #        end
      #      else
      #        return true
      #      end
      return true
    else
      return false
    end
  end

  # control comes here from create_assessment.html
  def save_assessment
    @upload_type = params[:upload_type]
    if params[:upload_type] == "excelsheet" and params[:import][:excel] == ""
      redirect_to("/assessments/assessment_creation/#{current_user.id}?pattern=#{params[:pattern]}")
    else
      @assessment = Assessment.new()
      @assessment.name = params[:question_bank][:name]
      @assessment.assessment_type = params[:assessment_type]
      @assessment.tenant_id = current_user.tenant_id
      @assessment.save
      # create_calculated_data_for_assessment(@assessment.id,current_user.tenant_id)
      if params.include? "assessment" and params[:assessment].include? "test_pattern_id"
        @assessment.update_attribute(:test_pattern_id, params[:assessment][:test_pattern_id].to_i)
        @assessment.update_attribute(:correct_ans_points, @assessment.test_pattern.correct_mark)
        @assessment.update_attribute(:wrong_ans_points, @assessment.test_pattern.wrong_mark)
        @assessment.update_attribute(:skip_question, @assessment.test_pattern.skip_question)
        unless @assessment.test_pattern.total_duration == 0
          @assessment.update_attribute(:time_bound, "time_bound")
          duration = @assessment.test_pattern.total_duration.to_i
          if duration >= 60
            hour = duration/60
            min = duration%60
          else
            hour = 0
            min = duration
          end
          @assessment.update_attribute(:duration_hour, hour)
          @assessment.update_attribute(:duration_min, min)
        end
      else
        @assessment.update_attribute(:test_pattern_id, 1)
      end
      if(params[:upload_type] != "previous_questions") then
        @obj_question_bank = QuestionBank.new()
        if params[:assessment_type] == "single"
          @obj_question_bank.name = params[:question_bank][:name]
        else
          @obj_question_bank.name = params[:topic_name]
        end
        @obj_question_bank.user_id = current_user.id
        @obj_question_bank.tenant_id = current_user.tenant_id
        @obj_question_bank.save
        # below method is to create object of AssessmentsQuestionBank table to store question bank id,
        # number of questions from that question bank and assessment id
        assessment_question_bank = create_and_save_assessment_question_bank(@assessment.id,@obj_question_bank.id,@obj_question_bank.no_of_questions)
      else
        if params[:assessment_type] == "single"
          @obj_question_bank = QuestionBank.find_by_id(params[:radio_check])

          @assessment.update_attribute(:no_of_questions, @obj_question_bank.no_of_questions)
          # below method is to create object of AssessmentsQuestionBank table to store question bank id,
          # number of questions from that question bank and assessment id
          assessment_question_bank = create_and_save_assessment_question_bank(@assessment.id,@obj_question_bank.id,@obj_question_bank.no_of_questions)
        else
          selected_prev_qbs = params[:total_prev_qb_checked].split(",")
          if @assessment.no_of_questions.nil? then
            no_of_questions = 0
          else
            no_of_questions = @assessment.no_of_questions
          end
          selected_prev_qbs.each { |qb|
            if !qb.nil? and !qb.blank? then
              ques_bank = QuestionBank.find_by_id(qb.to_i)
              no_of_questions = no_of_questions + ques_bank.no_of_questions
              # below method is to create object of AssessmentsQuestionBank table to store question bank id,
              # number of questions from that question bank and assessment id
              assessment_question_bank = create_and_save_assessment_question_bank(@assessment.id,ques_bank.id,ques_bank.no_of_questions)
            end
          }
          @assessment.update_attribute(:no_of_questions, no_of_questions)
          #          if params.include? "assessment" and params[:assessment].include? "test_pattern_id"
          #            @assessment.update_attribute(:test_pattern_id, params[:assessment][:test_pattern_id].to_i)
          #          end
        end
      end

      @assessment.update_attribute(:user_id, current_user.id)
      # TODO : to be optimized with associations
      if params.include? "import"
        if params[:import][:excel] != "" then
          mime = MIME::Types.type_for(params[:import][:excel].original_filename)[0]
          mime_obj_extention = mime.extensions[0]
          if (!mime_obj_extention.nil? and !mime_obj_extention.blank? and !mime_obj_extention.downcase.eql? "doc") and (mime_obj_extention.include? "docx" ) then
            # If uploaded file is docx then control comes here
            save_docx_file(@obj_question_bank.id,params[:import][:excel].tempfile,params[:import][:excel].original_filename)
            @upload_type = "docx"
          else
            # If uploaded file is excel or excelx then control comes here
            parser_controller_obj = ParserController.new
            parser_controller_obj.parse_excel_file("","",@obj_question_bank.id,params[:import],current_user.tenant_id)
          end
        end
        no_of_questions = @obj_question_bank.questions
        @obj_question_bank.update_attribute(:no_of_questions,no_of_questions.length)
        @obj_question_bank.assessments_question_banks.each do |ass_qb|
          ass_qb.update_attribute(:question_limit, no_of_questions.length)
        end
        if @assessment.no_of_questions.nil? then
          @assessment.update_attribute(:no_of_questions,no_of_questions.length)
        else
          no_of_questions = no_of_questions.length + @assessment.no_of_questions
          @assessment.update_attribute(:no_of_questions,no_of_questions)
        end
      end
      case(@upload_type)
      when "manual" then
        redirect_to("/assessments/add_questions_to_assessment/#{@assessment.id}?question_bank_id=#{@obj_question_bank.id}")
      when "excelsheet"
        redirect_to("/question_banks/#{@obj_question_bank.id}?wrong_entries=#{@wrong_entries.to_s}&assessment_id=#{@assessment.id}&assessment_type=#{params[:assessment_type]}")
      when "docx"
        redirect_to("/assessments/extract_content_from_docx/#{@obj_question_bank.id}?assessment=#{@assessment.id}")
#      when "previous_questions"
#        if params[:assessment_type] == "single"
#          redirect_to("/assessments/assessment_details/#{@assessment.id}")
#        else
#          redirect_to("/assessments/add_more_topics_to_assessment/#{@assessment.id}")
#        end
      when "previous_question_banks"
        # redirecting to component based test
        # creating reports for admin (for report_templates with admin) on creating assessment
        report_templates = ReportTemplate.where(:for_whom => "admin")
        report_templates.each do |report_template|
          @report = Report.new
          @report.assessment_id = @assessment.id
          @report.tenant_id = @assessment.tenant_id
          @report.structure_component_id = 0
          @report.report_template_id = report_template.id
          @report.for_whom = "admin"
          @report.save
        end
        @assessment.update_attribute(:using_rules,true)
        redirect_to("/structure_components/create_assessment/#{@assessment.id}")
      else
        redirect_to("/assessments/add_more_topics_to_assessment/#{@assessment.id}")
      end
    end
  end

  def save_docx_file(question_bank_id,tempfile,original_filename)
    upload_path = "public/question_banks/#{question_bank_id}"
    FileUtils.mkdir_p(upload_path)
    FileUtils.mkdir_p(upload_path+"/original")
    FileUtils.mkdir_p(upload_path+"/resized")
    path = upload_path + "/original/" + original_filename
    FileUtils.cp tempfile.path, path
    Zip::ZipFile.open(path) do |fileq|
      fileq.each do |f|
        f_path=upload_path+"/original/"+f.name
        FileUtils.mkdir_p(File.dirname(f_path))
        fileq.extract(f, f_path) unless File.exist?(f_path)
      end
    end
  end

  def extract_content_from_docx
    docxmlpath = "public/question_banks/#{params[:id]}/original/word/document.xml"
    xml_data = File.read(docxmlpath)
    doc = REXML::Document.new(xml_data)
    @para_elements = doc.elements.to_a("//w:p").count
    @table_elements = doc.elements.to_a("//w:tbl").count
    image_elements = doc.elements.to_a("//w:drawing").count
    inline_image_elements = doc.elements.to_a("//w:object").count
    @total_image_elements = image_elements + inline_image_elements
  end

  def parse_docx_to_extract_text    
    @obj_question_bank = get_question_bank(params[:id])
    @assessment = Assessment.find(params[:assessment])
    @assessments_question_bank = AssessmentsQuestionBank.find_by_assessment_id_and_question_bank_id(@assessment.id,@obj_question_bank.id)
    parser_controller_obj = ParserController.new
    parser_controller_obj.parse(@assessment,params[:id],current_user.tenant_id,current_user,@assessments_question_bank)
    no_of_questions = 0
    if @assessment.assessments_question_banks.length > 1
      @assessment.assessments_question_banks.each do |ass_qb|
        no_of_questions = no_of_questions + ass_qb.question_limit
      end
    end
    if @assessment.no_of_questions.nil? then
      @assessment.update_attribute(:no_of_questions,no_of_questions)
    else
      no_of_questions = no_of_questions + @assessment.no_of_questions
      @assessment.update_attribute(:no_of_questions,no_of_questions)
    end
    redirect_to("/question_banks/#{params[:id]}?assessment_id=#{params[:assessment]}")
  end

  #create roo object based on the mime_type. check http://roo.rubyforge.org/rdoc/index.html
  def create_roo_instance(imported_file_path,mime_obj)
    case
    when (mime_obj.include? 'xlsx') then
      roo = Excelx.new(imported_file_path)
    when (mime_obj.include? 'ods') then
      roo = Openoffice.new(imported_file_path)
    when (mime_obj.include? 'xls') then
      roo = Excel.new(imported_file_path)
    else
      roo = "Upload correct excel format."
    end
    return roo
  end

  # TODO Comment
  def create_and_save_assessment_question_bank(assessment_id,question_bank_id,limit)
    assessment_question_bank = AssessmentsQuestionBank.new
    assessment_question_bank.assessment_id = assessment_id
    assessment_question_bank.question_bank_id = question_bank_id
    assessment_question_bank.question_limit = limit
    assessment_question_bank.save
    return assessment_question_bank
  end

  def proc_csv_qb(id,question_bank_id,mime_obj)
    @import = Import.find(id)
    @question_bank_id = question_bank_id
    @wrong_entries = 0
    @wrong_answer_combination = 0
    unless @roo == "Upload correct excel format." then
      if @roo == "csv format" then
        lines = parse_csv_file(@import.excel.path)
      else
        lines = parse_excel_file_roo(@roo)
      end
      if lines.size > 0
        @import.processed = lines.size
        for i in 0..lines.length-1
          if !lines[i][0].nil?
            question_types = ["MCQ","MAQ","SA","FIB","MTF","PTQ","DTQ"]
            lines[i][0] = lines[i][0].strip.split(' ').join('').upcase
            if question_types.include?(lines[i][0])
              case(lines[i][0])
              when "MTF" then
                mtf_array = Array.new
                no_of_mtf = 0
                k=i+1
                while lines[k][0].nil? and !lines[k][1].nil?
                  no_of_mtf = no_of_mtf +1
                  k = k+1
                  if k > lines.length-1 then
                    break
                  end
                end
                for j in i..i+no_of_mtf
                  mtf_array << lines[j]
                end
                fill_mtf_qb_db(mtf_array,@question_bank_id,@wrong_entries,@wrong_answer_combination)
              when "PTQ" then
                ptq_array = Array.new
                no_of_ptq = 0
                k=i+1
                while lines[k][0].nil? and !lines[k][1].nil?
                  no_of_ptq = no_of_ptq +1
                  k = k+1
                  if k > lines.length-1 then
                    break
                  end
                end
                for l in i..i+no_of_ptq
                  ptq_array << lines[l]
                end
                fill_ptq_qb_db(ptq_array,@question_bank_id,@wrong_entries,@wrong_answer_combination,i,mime_obj)
              else
                fill_qb_db(lines[i],@question_bank_id,i,mime_obj)
              end
            else
              flash[:error] = "Incorrect data."
            end
          end
        end
      else
        flash[:error] = "CSV data processing failed."
      end
    end
  end

  #parse the excel file directly using roo.
  def parse_excel_file_roo(roo_obj)
    roo_obj.default_sheet = roo_obj.sheets.first
    lines = Array.new
    (1..roo_obj.last_row).each do |r|
      lines << roo_obj.row(r)
    end
    return lines
  end

  def parse_csv_file(path_to_csv)
    lines = []
    #if not installed run, sudo gem install fastercsv
    #http://fastercsv.rubyforge.org/
    require 'fastercsv'
    FasterCSV.foreach(path_to_csv) do |row|
      lines << row
    end
    lines
  end

  def fill_mtf_qb_db(csv_row,question_bank_id,wrong_entries,wrong_answer_combination)
    # save question to DB
    @wrong_entries = wrong_entries
    @wrong_answer_combination = wrong_answer_combination
    super_question_hash = Hash.new
    super_question_hash['question_type'] = csv_row[0][0].strip.split(' ').join('').upcase
    super_question_hash['question_text'] = csv_row[0][1]
    super_question_hash['question_bank_id'] = question_bank_id
    if super_question_hash['question_text'].nil? or super_question_hash['question_text'].blank? or super_question_hash['question_text'] == "" then
      @wrong_entries = @wrong_entries + 1
    else
      obj_super_question = Question.new(super_question_hash)
      obj_super_question.save
    end
    sub_question_hash = Hash.new
    sub_answer_hash = Hash.new
    jumbled_question_ids = Array.new
    sub_question_hash['mtf_id'] = obj_super_question.id
    sub_answer_hash['answer_status'] = 'correct'
    for i in 1..csv_row.length-1
      sub_question_hash['question_text'] = csv_row[i][1]
      obj_sub_question = Question.new(sub_question_hash)
      obj_sub_question.save
      sub_answer_hash['answer_text']= csv_row[i][2]
      sub_answer_hash['question_id'] = obj_sub_question.id
      sub_answer_hash['question_bank_id'] = question_bank_id
      jumbled_question_ids << obj_sub_question.id
      obj_sub_answer = Answer.new(sub_answer_hash)
      obj_sub_answer.save
    end
    jumbled_question_ids = jumbled_question_ids.shuffle
    i = 0
    options = Question.find_all_by_mtf_id(obj_super_question.id)
    for option in options
      answer = Answer.find_by_question_id(option.id)
      answer.update_attribute(:status,jumbled_question_ids[i])
      i = i + 1
    end
  end

  def fill_ptq_qb_db(csv_row,question_bank_id,wrong_entries,wrong_answer_combination,i,mime_obj)
    @wrong_entries = wrong_entries
    @wrong_answer_combination = wrong_answer_combination
    super_question_hash = Hash.new
    super_question_hash['question_type'] = csv_row[0][0].strip.split(' ').join('').upcase
    super_question_hash['question_text'] = csv_row[0][1]
    #    super_question_hash['question_bank_id'] = question_bank_id
    if super_question_hash['question_text'].nil? or super_question_hash['question_text'].blank? or super_question_hash['question_text'] == "" then
      @wrong_entries = @wrong_entries + 1
    else
      obj_super_question = Question.new(super_question_hash)
      obj_super_question.save
    end
    for j in 1..csv_row.length-1
      fill_ptq_sub_questions(csv_row[j],question_bank_id,@wrong_entries, @wrong_answer_combination,obj_super_question.id,i,j,mime_obj)
    end
  end

  def fill_ptq_sub_questions(csv_row,question_bank_id,wrong_entries,wrong_answer_combination,super_question_id,i,j,mime_obj)
    # save question to DB
    @wrong_entries = wrong_entries
    @wrong_answer_combination = wrong_answer_combination
    question_hash = Hash.new
    question_hash['question_type'] = csv_row[1].strip.split(' ').join('').upcase
    question_hash['question_text'] = csv_row[2]
    question_hash['explanation'] = csv_row[14]
    if question_hash['question_text'].nil? or question_hash['question_text'].blank? or question_hash['question_text'] == "" then
      @wrong_entries = @wrong_entries + 1
    else
      obj_question = Question.new(question_hash)
      obj_question.question_bank_id = question_bank_id
      obj_question.mtf_id = super_question_id
      obj_question.save

      if question_hash['question_type'].strip.split(' ').join('').upcase != "DTQ"
        # save answers to DB
        answer_hash = Hash.new

        for k in 3..7
          unless csv_row[k].nil? or csv_row[k].blank? then
            if (mime_obj.include? 'xlsx') then
              if @roo.excelx_format(i+j+1,k+1) == "0%" or @roo.excelx_format(i+j+1,k+1) == "0.00%"
                value = @roo.cell(i+j+1,k+1) * 100
                if @roo.excelx_format(i+j+1,k+1) == "0.00%"
                  answer_hash['answer_text'] = value.round(2).to_s + "%"
                else
                  answer_hash['answer_text'] = value.round(0).to_s + "%"
                end
              else
                if @roo.celltype(i+j+1,k+1) == :string
                  answer_hash['answer_text'] = @roo.cell(i+j+1,k+1)
                else
                  answer_hash['answer_text'] = @roo.excelx_value(i+j+1,k+1)
                end
              end
            else
              if @roo.celltype(i+j+1,k+1) == :float
                answer = check_if_integer_or_float(csv_row[k])
              else
                answer = csv_row[k]
              end
              answer_hash['answer_text'] = answer
            end
            answer_hash['question_id'] = obj_question.id
            answer_hash['question_bank_id'] = question_bank_id
            case(question_hash['question_type'].strip.split(' ').join('').upcase)
            when "MCQ" then
              if csv_row[k] == csv_row[8]
                answer_hash['answer_status'] = 'correct'
              else
                answer_hash['answer_status'] = 'wrong'
              end

            when "FIB","SA" then
              answer_hash['answer_status'] = 'correct'

            when "MAQ" then
              multi_ans = csv_row.length - 8
              for j in 1..multi_ans
                if csv_row[k] == csv_row[csv_row.length-j]
                  answer_hash['answer_status'] = 'correct'
                  break
                else
                  answer_hash['answer_status'] = 'wrong'
                end
              end

            when "MTF" then
              # do nothing
            end
            obj_answer = Answer.new(answer_hash)
            obj_answer.save!
          end
        end
      end
    end
  end

  def fill_qb_db(csv_row,question_bank_id,i,mime_obj)
    # save question to DB
    question_hash = Hash.new
    question_hash['question_type'] = csv_row[0]
    question_hash['question_text'] = csv_row[1]
    question_hash['explanation'] = csv_row[14]
    obj_question = Question.new(question_hash)
    obj_question.question_bank_id = question_bank_id
    obj_question.save

    if question_hash['question_type'].strip.split(' ').join('').upcase != "DTQ"
      # save answers to DB
      answer_hash = Hash.new
      for k in 2..6
        unless csv_row[k].nil? or csv_row[k].blank? then
          if mime_obj.include? 'xlsx' then
            if @roo.excelx_format(i+1,k+1) == "0%" or @roo.excelx_format(i+1,k+1) == "0.00%"
              value = @roo.cell(i+1,k+1) * 100
              if @roo.excelx_format(i+1,k+1) == "0.00%"
                answer_hash['answer_text'] = value.round(2).to_s + "%"
              else
                answer_hash['answer_text'] = value.round(0).to_s + "%"
              end
            else
              if @roo.celltype(i+1,k+1) == :string
                answer_hash['answer_text'] = @roo.cell(i+1,k+1)
              else
                answer_hash['answer_text'] = @roo.excelx_value(i+1,k+1)
              end
            end
          else
            if @roo.celltype(i+1,k+1) == :float
              answer = check_if_integer_or_float(csv_row[k])
            else
              answer = csv_row[k]
            end
            answer_hash['answer_text'] = answer
          end
          answer_hash['question_id'] = obj_question.id
          answer_hash['question_bank_id'] = question_bank_id
          case(question_hash['question_type'].strip.split(' ').join('').upcase)
          when "MCQ" then
            if csv_row[k] == csv_row[7]
              answer_hash['answer_status'] = 'correct'
            else
              answer_hash['answer_status'] = 'wrong'
            end
          when "FIB","SA" then
            answer_hash['answer_status'] = 'correct'
          when "MAQ" then
            multi_ans = csv_row.length - 7
            for j in 1..multi_ans
              if csv_row[k] == csv_row[csv_row.length-j]
                answer_hash['answer_status'] = 'correct'
                break
              else
                answer_hash['answer_status'] = 'wrong'
              end
            end
          when "MTF" then
            # do nothing
          end
          obj_answer = Answer.new(answer_hash)
          obj_answer.save!
        end
      end
    end
    reason_for_error = is_question_format_correct(obj_question)
    if !reason_for_error.nil?
      obj_question.update_attribute(:error_in_question,reason_for_error)
    end
    reason_for_error = is_answer_format_correct(obj_question)
    if !reason_for_error.nil?
      obj_question.update_attribute(:error_in_question,reason_for_error)
    end
  end


  # KK wrote this method for validating the question type and returns true/false.
  # Returns false if the question type is not one among (MCQ,MAQ,MTF,FIB,SA,PTQ) else true.
  def is_question_format_correct(obj_question)
    if obj_question.question_text.nil?
      error_string = "Question cannot be blank. "
    end
    if obj_question.question_type == "FIB" and !obj_question.question_text.include? "___"
      error_string = "FIB should contain atleast three consecutive underscores. "
    end
    if obj_question.error_in_question.nil? then
      error_string = error_string
    else
      error_string = obj_question.error_in_question +","+ error_string
    end
    return error_string
  end

  # KK wrote this method for validating the question type and returns true/false.
  # Returns false if the question type is not one among (MCQ,MAQ,MTF,FIB,SA,PTQ) else true.
  def is_answer_format_correct(obj_question)
    error_string = ""
    answers = Answer.find_all_by_question_id(obj_question.id)
    correct_ans_found = 0
    no_options_given = 0
    
    unless answers.nil? or answers.blank?
      answers.each { |ans|
        if ans.answer_status == "correct" then
          correct_ans_found = 1
          break;
        end
      }
    else
      no_options_given = 1
    end

    if obj_question.question_type == "DTQ"
      no_options_given = 0
      correct_ans_found = 1
    end

    if no_options_given == 1 then
      error_string = error_string + "No options given. "
    end
    if correct_ans_found == 0 then
      error_string = error_string + "No correct answer. "
    end
    if obj_question.error_in_question.nil? then
      error_string = error_string
    else
      error_string = obj_question.error_in_question +","+ error_string
    end
    return error_string
  end

  #takes the path to delete. it deletes the folder from
  def delete_csv(path_to_delete)
    file_to_del = path_to_delete.split("/").last
    path_to_del = path_to_delete.gsub("/original/"+file_to_del,"")
    FileUtils.rm_r path_to_del
  end

  #control comes here from edit_assessment_details
  def update_assessment_details
    @assessment = Assessment.find(params[:id])
    @assessment.update_attributes(params[:assessment])
    if params.include? 'assessment_demographics_compulsory'
      @assessment.update_attribute(:demographics_compulsory, true)
    else
      @assessment.update_attribute(:demographics_compulsory, false)
    end
    @assessment.learners.each do |learner|
      learner.update_attribute(:score_min, params[:assessment][:pass_score])
    end
    if !(@assessment.demographics.nil? or @assessment.demographics.blank?)
      demographics = @assessment.demographics
      demographics.update_attributes(params[:demographic])
    else
      if !(params[:demographic].nil? or params[:demographic].blank?)
        demographics = Demographics.new(params[:demographic])
        demographics.assessment_id = @assessment.id
        demographics.save
        @assessment.update_attribute(:demographics_id,demographics.id)
      end
    end
    (params[:assessment].include? "show_status")?@assessment.update_attribute(:show_status,"on"):@assessment.update_attribute(:show_status,"off")
    (params[:assessment].include? "show_question_explanation")?@assessment.update_attribute(:show_question_explanation,true):@assessment.update_attribute(:show_question_explanation,false)
    if @assessment.test_pattern.id == 1
      (params[:assessment].include? "skip_question")?@assessment.update_attribute(:skip_question,true):@assessment.update_attribute(:skip_question,false)
    else
      (@assessment.test_pattern.skip_question)?@assessment.update_attribute(:skip_question,true):@assessment.update_attribute(:skip_question,false)
    end
    if @assessment.show_status == "off"  then
      @assessment.update_attribute(:send_score_by_mail,"off")
      @assessment.update_attribute(:show_question_wise_scoring,"off")
    elsif @assessment.show_status == "on"
      (params[:assessment].include? "send_score_by_mail")?@assessment.update_attribute(:send_score_by_mail,"on"):@assessment.update_attribute(:send_score_by_mail,"off")
      (params[:assessment].include? "show_question_wise_scoring")?@assessment.update_attribute(:show_question_wise_scoring,"on"):@assessment.update_attribute(:show_question_wise_scoring,"off")
    end
    (params[:assessment].include? "allow_improvement")?@assessment.update_attribute(:allow_improvement,true):@assessment.update_attribute(:allow_improvement,false)
    if params[:is_overall] == "on"
      @assessment.update_attribute(:is_overall, true)
      @assessment.update_attribute(:section_less_percentage, 0)
    else
      @assessment.update_attribute(:is_overall, false)
      @assessment.update_attribute(:overall_less_percentage, 0)
    end
    if params[:show_per_page] == "one"
      @assessment.update_attribute(:show_all_per_page, false)
    else
      @assessment.update_attribute(:show_all_per_page, true)
    end
    save_schedule_details(@assessment)
    redirect_to('/courses')
  end

  # control comes here from assessments/save_assessment,assessments/update_assessment,assessments/add_next_question
  def add_questions_to_assessment
    @assessment = Assessment.find(params[:id])
  end

  # control comes here from assessments/add_next_question,question_banks/show
  def add_more_topics_to_assessment
    @assessment = Assessment.find(params[:id])
  end

  # control comes here from assessments/add_more_topics_to_assessment
  def update_assessment
    @upload_type = params[:upload_type]
    @assessment = Assessment.find(params[:id])
    if(params[:upload_type] != "previous_questions") then
      @obj_question_bank = QuestionBank.new()
      @obj_question_bank.name = params[:topic_name]
      @obj_question_bank.user_id = current_user.id
      @obj_question_bank.tenant_id = current_user.tenant_id
      @obj_question_bank.save
      create_and_save_assessment_question_bank(@assessment.id,@obj_question_bank.id,0)
    else
      selected_prev_qbs = params[:total_prev_qb_checked].split(",")
      if @assessment.no_of_questions.nil?
        no_of_questions = 0
      else
        no_of_questions = @assessment.no_of_questions
      end
      selected_prev_qbs.each { |qb|
        if !qb.nil? and !qb.blank? then
          ques_bank = QuestionBank.find_by_id(qb.to_i)
          if !params.include? 'control_from_edit_questions_page' then
            no_of_questions = no_of_questions + ques_bank.no_of_questions
          end
          create_and_save_assessment_question_bank(@assessment.id,ques_bank.id,ques_bank.no_of_questions.to_s)
        end
      }
      if !params.include? 'control_from_edit_questions_page' then
        @assessment.update_attribute(:no_of_questions,no_of_questions)
      end
    end

    if params.include? "import"
      if params[:import][:excel] != "" then
        mime = MIME::Types.type_for(params[:import][:excel].original_filename)[0]
        mime_obj_extention = mime.extensions[0]
        if (!mime_obj_extention.nil? and !mime_obj_extention.blank? and !mime_obj_extention.downcase.eql? "doc") and (mime_obj_extention.include? "docx" ) then
          # If uploaded file is docx then control comes here
          save_docx_file(@obj_question_bank.id,params[:import][:excel].tempfile,params[:import][:excel].original_filename)
          @upload_type = "docx"
        else
          # If uploaded file is excel or excelx then control comes here
          parser_controller_obj = ParserController.new
          parser_controller_obj.parse_excel_file("","",@obj_question_bank.id,params[:import],current_user.tenant_id)
        end

        no_of_questions = @obj_question_bank.questions.length
        @obj_question_bank.update_attribute(:no_of_questions,no_of_questions)
        @obj_question_bank.assessments_question_banks.each do |ass_qb|
          ass_qb.update_attribute(:question_limit, no_of_questions)
        end
        if !params.include? 'control_from_edit_questions_page' then
          if @assessment.no_of_questions.nil? then
            @assessment.update_attribute(:no_of_questions,no_of_questions)
          else
            no_of_questions += @assessment.no_of_questions
            @assessment.update_attribute(:no_of_questions,no_of_questions)
          end
        else
          no_of_questions += @assessment.no_of_questions
          @assessment.update_attribute(:no_of_questions,no_of_questions)
        end
        #      delete_csv(@import.csv.path)
        #      @import.destroy
      end
    end

    # find the mapping in learner table for preview and update the launch_data
    learner = Learner.find_by_assessment_id_and_type_of_test_taker(@assessment.id,"admin")
    unless learner.nil? or learner.blank?
      learner.update_attribute(:question_status_details, "")
    end

    if @assessment.assessment_type == "single" then
      @assessment.update_attribute(:assessment_type, "multiple")
    end
    case(@upload_type)
    when "manual" then
      redirect_to("/assessments/add_questions_to_assessment/#{@assessment.id}?question_bank_id=#{@obj_question_bank.id}")
    when "excelsheet"
      redirect_to("/question_banks/#{@obj_question_bank.id}?wrong_entries=#{@wrong_entries.to_s}&assessment_id=#{@assessment.id}&assessment_type=#{params[:assessment_type]}")
    when "docx"
      redirect_to("/assessments/extract_content_from_docx/#{@obj_question_bank.id}?assessment=#{@assessment.id}")
    when "previous_questions"
      if params[:assessment_type] == "single"
        redirect_to("/assessments/assessment_details/#{@assessment.id}")
      else
        redirect_to("/assessments/add_more_topics_to_assessment/#{@assessment.id}")
      end
    else
      redirect_to("/assessments/add_more_topics_to_assessment/#{@assessment.id}")
    end
  end

  def save_pre_test_information
    demographic = Demographics.new(params[:demographic])
    demographic.save
    assessment = Assessment.find(params[:id])
    assessment.update_attribute(:demographics_id, demographic.id)
    if params.include? 'assessment_demographics_compulsory'
      assessment.update_attribute(:demographics_compulsory,true)
    end
    redirect_to('/assessments/scoring/'+params[:id].to_s)
  end

  # Few tests will be created and assigned to all learners of that tenant. On day 1 of test when time finishes
  # whoever didn't take test, replace the 1st assessment id with second and change the launch_data too. Do the same for
  # rest of the tests.
  def lpu_set_based_assigning
    learners = Learner.find_all_by_admin_id_and_assessment_id(current_user.id,params[:id],:conditions => "lesson_status = 'not attempted' AND type_of_test_taker = 'learner'")
    old_assessment = Assessment.find_by_id(params[:id])
    new_assessment = Assessment.find_by_id(params[:test_id_to_replace_with])
    learners.each{|learner|
      learner.update_attribute(:assessment_id, new_assessment.id)
      qb_list,question_list = create_question_list(new_assessment)
      learner.update_attribute(:entry, qb_list)
      learner.update_attribute(:question_status_details, "")
      new_assessment.update_attribute(:total_learners, new_assessment.total_learners + 1)
      old_assessment.update_attribute(:total_learners, old_assessment.total_learners - 1)
    }
  end

  def create_question_list(assessment)
    ptq_questions = Array.new
    non_ptq_questions = Array.new
    final_questions = Array.new
    final_list = Array.new
    remaining_list = Array.new
    qb_list = Array.new
    passage = 0
    assessments_question_banks_obj = AssessmentsQuestionBank.find_all_by_assessment_id(assessment.id, :order => 'id')
    if assessments_question_banks_obj.count > 1
      assessments_question_banks_obj.each do |qb|
        qb_list,final_list = create_list_of_questions(assessment,qb,final_list,remaining_list,qb_list)
      end  # end of assessments_question_banks_obj.each loop
    else
      qb_list,final_list = create_list_of_questions(assessment,assessments_question_banks_obj[0],final_list,remaining_list,qb_list)
    end
    if qb_list.length > 1 and qb_list.kind_of?(Array)
      qb_list = qb_list.join(",")
    end
    # question_list = get_questions_list(final_list)
    return [qb_list,final_list]
  end

  # Author: Karthik, Surupa
  def create_list_of_questions(assessment,qb,final_list,remaining_list,qb_list)
    individual_list = Array.new
    final_individual_list = Array.new
    qb_list << qb.question_bank_id
    if assessment.is_linear == false then
      question_attributes = QuestionAttribute.where(:question_bank_id => qb.question_bank_id).limit(qb.question_limit).order('RAND()')
    else
      question_attributes = QuestionAttribute.where(:question_bank_id => qb.question_bank_id).limit(qb.question_limit).order('id')
    end
    unless question_attributes.nil? or question_attributes.blank?
      individual_list = question_attributes
      non_ptq = Array.new
      ptq = Array.new
      l = individual_list.length
      while l != 0
        i = 0
        q1 = individual_list[i]
        if q1.passage_id.nil? or q1.passage_id.blank?
          # if question is non-PTQ
          non_ptq << q1
          remaining_list = individual_list - non_ptq
          final_individual_list = final_individual_list + non_ptq
          non_ptq = []
        else
          # if question is PTQ
          ptq_id = q1.passage_id
          ptq << q1
          for j in 1..l-1
            q2 = individual_list[j]
            unless q2.passage_id.nil? or q2.passage_id.blank?
              if q2.passage_id == ptq_id
                ptq << q2
              end
            end
          end
          remaining_list = individual_list - ptq
          final_individual_list = final_individual_list + ptq
          ptq = []
        end
        individual_list = remaining_list
        l = individual_list.length
      end
      final_list = final_list + final_individual_list
      return [qb_list,final_list]
    else
      # If after migrating existing questions,answers to new database, due to some problem the
      # corresponding mapping is not there in question attribute table, then call this. So that
      # error wouldn't occur while assigning learner or blank test wouldn't be assigned to learner.
      put_question_attribute_mapping_for_existing_questions(qb.question_bank_id,assessment.user)
      create_question_list(assessment)
    end # end of unless question_attributes object nil or blank check    
  end

  def test_pattern

  end

  def assessment_creation
    case(params[:pattern])
    when "Create manually" then redirect_to("/assessments/create_assessment/#{params[:id]}")
    else @test_pattern = TestPattern.find_by_pattern_name(params[:pattern])
    end
  end

  # It gets called from assessment_details when it belongs to any test pattern like CAT,CMAT or AIEEE
  def store_test_pattern_details(assessment)
    i = 0
    total_no_of_questions = 0
    assessment.assessments_question_banks.each do |qb|
      qb.update_attribute(:question_limit, assessment.test_pattern.questions_per_section.split(',')[i])
      total_no_of_questions = total_no_of_questions + qb.question_limit
      i = i + 1
    end
    assessment.update_attribute(:no_of_questions, total_no_of_questions)
    admin_in_learner = Learner.new
    admin_in_learner.assessment_id = assessment.id
    admin_in_learner.user_id = current_user.id
    admin_in_learner.admin_id = current_user.id
    admin_in_learner.tenant_id = assessment.tenant_id
    admin_in_learner.lesson_location = "0"
    admin_in_learner.type_of_test_taker = "admin"
    admin_in_learner.save
    assessment.update_attribute(:current_learner_id, admin_in_learner.id)
    if assessment.test_pattern.random_order_questions then
      assessment.update_attribute(:is_linear, false)
    else
      assessment.update_attribute(:is_linear, true)
    end    
    # creates launch data for preview
    qb_list,question_list = create_question_list(assessment)
    # find the mapping in learner table for preview and update the launch_data
    unless admin_in_learner.nil? or admin_in_learner.blank?
      admin_in_learner.update_attribute(:entry, qb_list)
      admin_in_learner.update_attribute(:question_status_details, "")
    end
    @i = 1
    create_mapping_for_all_questions_in_assessment(assessment,assessment.correct_ans_points,assessment.wrong_ans_points)
    create_test_details_for_user(admin_in_learner.id,current_user.id,current_user.tenant_id,question_list,assessment)
  end

  def goto_section
    @current_learner = get_current_learner_object(params[:current_learner])
    @assessment = get_assessment_object(@current_learner.assessment_id)
    #    @current_learner = Learner.find_by_id(params[:current_learner])
    questions_per_section_list = @assessment.test_pattern.questions_per_section.split(",")
    case(params[:id])
    when "1" then lesson_location = (params[:id].to_i - 1).to_s
    else 
      no_of_questions = 0
      (0...params[:id].to_i-1).each do |i|
        no_of_questions += questions_per_section_list[i].to_i
      end
      lesson_location = no_of_questions.to_s
    end
    @current_learner.update_attribute(:lesson_location, lesson_location)
    redirect_to("/assessments/multi_page_test/#{@current_learner.id}")
  end

  #send learners id params[:id].
  def temp_calculate_score
    @current_learner = get_current_learner_object(params[:id])
    @assessment = get_assessment_object(@current_learner.assessment_id)
    if @current_learner.lesson_status == "time up"
      save_test_details("time up",@current_learner,@assessment,@current_learner.user)
    else
      save_test_details("normal",@current_learner,@assessment,@current_learner.user)
    end
    redirect_to "/courses"
  end

  def feedback
    @current_learner = get_current_learner_object(params[:id])
    @assessment = get_assessment_object(@current_learner.assessment_id)
    if params.include? "timeup"
      case(@current_learner.type_of_test_taker)
      when "admin"
        @current_learner.update_attribute(:lesson_status,"time up")
      else
        save_test_details("time up",@current_learner,@assessment,current_user)
      end
    else
      case(@current_learner.type_of_test_taker)
      when "admin"
        @current_learner.update_attribute(:lesson_status,"completed")
      else
        save_test_details("normal",@current_learner,@assessment,current_user)
      end
    end
  end

  def save_feedback_and_redirect
    @current_learner = get_current_learner_object(params[:id])
    @assessment = get_assessment_object(@current_learner.assessment_id)
    if @current_learner.type_of_test_taker == "admin"
      @current_learner.update_attributes(params[:learner])
      reset_admin_preview_columns(@current_learner)
      redirect_to("/courses")
    else
      if @assessment.reattempt == "on"
        @current_learner.update_attribute(:question_status_details,"")
      end
      @current_learner.update_attributes(params[:learner])      
      unless @current_learner.test_details.nil? or @current_learner.test_details.blank?
        question_wise_report_url = "/reports/learner_test_status/#{@current_learner.id.to_s}?assessment_id=#{@assessment.id}"
      else
        question_wise_report_url = "/mycourses"
      end
      case(@assessment.show_status)
      when "on"
        flash[:test_submitted_successful] = "Your test '#{@assessment.name}' has been submitted."
        redirect_to(question_wise_report_url)
      else
        flash[:test_submitted_successful] = "Your test '#{@assessment.name}' has been submitted."
        redirect_to("/mycourses")
      end
    end
  end

  #find the next assessment in the assessment_paackge list. Find out the index of current assessment in the assmt_list, so the next assmt will be the curr_assmt_index + 1.
  #But remember to do a :order +> 'id' as we are on cloud it may not retrieve in sequel. Return the next_assessmen
  def pick_next_assessment_in_package(assessment_package_obj,current_assessment)
    assessment_order_arr = assessment_package_obj.assessment_order.split(',')
    next_assessment = ""

    current_assessment_pos = assessment_order_arr.index(current_assessment.id.to_s)
    if current_assessment_pos < assessment_order_arr.length-1
      next_assessment_id = assessment_order_arr[current_assessment_pos+1]
      next_assessment = Assessment.find(next_assessment_id)
    end
    return next_assessment

    #    package.assessment_order.split(',')
    #     assessment_list = package.assessments.find(:all,:order => 'id')
    #     next_assessment = ""
    #     assessment_list.each { |assessment|
    #      if assessment.id == current_assessment.id
    #        current_assessment_index = assessment_list.index(assessment)
    #        if current_assessment_index != assessment_list.length-1
    #          next_assessment_index = current_assessment_index + 1
    #          next_assessment = assessment_list[next_assessment_index]
    #          break
    #        end
    #      end
    #     }
    #     return next_assessment
  end

  def assign_next_assessment_to_learner(assessment,admin_user,current_user,package_id)
    @learner = Learner.find_by_assessment_id_and_user_id_and_type_of_test_taker(assessment.id,current_user.id,"learner")
    if @learner.nil?
      if assessment.assessment_rules.nil? or assessment.assessment_rules.blank?
        store_learner_details(assessment,admin_user,current_user,package_id,"learner")
      else
        store_learner_details_using_rules(assessment,admin_user,current_user,package_id,"learner")
      end
    end
  end

  def assign_next_course_to_learner(course,admin_user,current_user,package_id)
    @learner = Learner.find_by_course_id_and_user_id_and_type_of_test_taker(course.id,current_user.id,"learner") 
    if @learner.nil?
      course_obj = CoursesController.new
      course_obj.store_learner_details(course,admin_user,current_user,package_id,"learner")
    end 
  end

  def new_pick_next_assessment_course_in_package(package,current_assessment_course,ass_or_course)
    if ass_or_course == "assessment"
      current_assessment_course_id = package.assessment_courses.where('assessment_id = ?',current_assessment_course.id)[0].id
    else
      current_assessment_course_id = package.assessment_courses.where('course_id = ?',current_assessment_course.id)[0].id
    end
    ass_courses_ids = package.assessment_courses.order('id').pluck('id')

    current_assessment_course_id_pos = ass_courses_ids.index(current_assessment_course_id)
    if current_assessment_course_id_pos < ass_courses_ids.length-1
      next_assessment_course_id = ass_courses_ids[current_assessment_course_id_pos+1]
      next_assessment_id = package.assessment_courses.find(next_assessment_course_id).assessment_id
      next_course_id = package.assessment_courses.find(next_assessment_course_id).course_id
      if !next_assessment_id.nil?
        next_assessment = Assessment.find(next_assessment_id)
        return [next_assessment,"assessment"]
      elsif @next_course_id.nil?
        next_course = Course.find(next_course_id)
        return [next_course,"course"]
      end
    end
  end

  def quit_assessment
    @current_learner = get_current_learner_object(params[:id])
    @assessment = get_assessment_object(@current_learner.assessment_id)
    learner_values = Hash.new
    # if the assessment is part of a package then assign the next assement to the learner from that package
    #    unless @assessment.assessment_package_id.nil? or @assessment.assessment_package_id.blank?
    #      next_assessment = pick_next_assessment_in_package(@assessment.assessment_package,@assessment)
    #      # if the next_assment is empty from the method then it means he has been assigned to all the assmts in that package and no more assmnts are left.
    #      unless next_assessment == ""
    #        #        store_learner_details(next_assessment,current_user.user_id,current_user,"learner")
    #        admin_user = @assessment.user
    #        assign_next_assessment_to_learner(next_assessment,admin_user,current_user,"")
    #      end
    #    end
    unless @current_learner.package_id.nil? or @current_learner.package_id.blank?
      next_assessment_course,assessment_course = new_pick_next_assessment_course_in_package(@current_learner.package,@assessment,"assessment")
      # if the next_assment is empty from the method then it means he has been assigned to all the assmts in that package and no more assmnts are left.
      unless next_assessment_course == ""
        if assessment_course == "assessment"
          #        store_learner_details(next_assessment,current_user.user_id,current_user,"learner")
          admin_user = @assessment.user
          assign_next_assessment_to_learner(next_assessment_course,admin_user,current_user,@current_learner.package_id)
        elsif assessment_course == "course"
          admin_user = @assessment.user
          assign_next_course_to_learner(next_assessment_course,admin_user,current_user,@current_learner.package_id)
        end
      end
    end
    learner_values = update_timestamps("submit",@current_learner,@current_learner.assessment_id,learner_values)
    if @current_learner.type_of_test_taker == "admin"
      reset_admin_preview_columns(@current_learner)
      redirect_to("/courses")
    else
      if @assessment.reattempt == "on"
        #        @current_learner.update_attribute(:question_status_details,"")
        learner_values['question_status_details'] = ""
      end
      unless @current_learner.test_details.nil? or @current_learner.test_details.blank?
        question_wise_report_url = "/reports/learner_test_status/"+@current_learner.id.to_s
      else
        question_wise_report_url = "/mycourses"
      end
      case(@assessment.show_status)
      when "on"
        save_test_details("normal",@current_learner,@assessment,current_user)
        @current_learner.update_attributes(learner_values)
        flash[:test_submitted_successful] = "Your test '#{@assessment.name}' has been submitted."
        redirect_to(question_wise_report_url)
      else
        save_test_details("normal",@current_learner,@assessment,current_user)
        @current_learner.update_attributes(learner_values)
        flash[:test_submitted_successful] = "Your test '#{@assessment.name}' has been submitted."
        redirect_to("/mycourses")
      end
    end
  end

  def show_skipped
    current_learner = get_current_learner_object(params[:id])
    test_details = TestDetail.where(:learner_id => current_learner.id,:attempted_status => "unanswered")
    # Updating lesson location to the first skipped question
    current_learner.update_attribute(:lesson_location, test_details[0].serial_number - 1)
    redirect_to("/assessments/multi_page_test/#{current_learner.id}?from=skipped")
  end

  def show_marked
    current_learner = get_current_learner_object(params[:id])
    test_details = TestDetail.where(:learner_id => current_learner.id,:marked_status => "marked")
    # Updating lesson location to the first marked question
    current_learner.update_attribute(:lesson_location, test_details[0].serial_number - 1)
    redirect_to("/assessments/multi_page_test/#{current_learner.id}?from=marked")
  end

  def reset_admin_preview_columns(current_learner)
    admin_columns = Hash.new
    admin_columns['lesson_location'] = "0"
    admin_columns['lesson_status'] = "not attempted"
    admin_columns['suspend_data'] = ""
    admin_columns['question_status_details'] = ""
    admin_columns['timestamps'] = ""
    current_learner.test_details.each do |test_detail|
      reset_test_detail_table_columns(test_detail)
    end
    current_learner.update_attributes(admin_columns)
  end

  def save_evaluator_details
    assessment = Assessment.find(params[:id])
    learner = Learner.find_by_assessment_id_and_user_id_and_type_of_test_taker(assessment.id,params[:evaluator].to_i,"evaluator")
    if learner.nil? or learner.blank?
      learner = Learner.new
      learner.assessment_id = assessment.id
      learner.user_id = params[:evaluator].to_i
      learner.admin_id = current_user.id
      learner.tenant_id = assessment.tenant.id
      #    learner.group_id = @user.group_id
      learner.lesson_location = "0"
      learner.lesson_status = "not attempted"
      learner.type_of_test_taker = "evaluator"
      learner.save
      assessment.descriptive_answers.each{|dtq|
        dtq.update_attribute(:user_id, params[:evaluator].to_i)
      }
    end
    # send evaluation mail to evaluator
    # flash to show how many mails sent
    redirect_to("/courses")
  end

  def assign_evaluators
    @assessment = Assessment.find(params[:id])
    @evaluators = current_user.user.find(:all,:conditions => "typeofuser = 'evaluator'")
  end

  def evaluate_test
    @assessment = Assessment.find(params[:id])
    @current_learner = Learner.find_by_assessment_id_and_user_id_and_type_of_test_taker(@assessment.id,current_user.id,"evaluator")
    @all_descriptive_answers = current_user.descriptive_answers
    @dtq_id = @all_descriptive_answers[@current_learner.lesson_location.to_i].id
    @question = @all_descriptive_answers[@current_learner.lesson_location.to_i].question
    @answer = @all_descriptive_answers[@current_learner.lesson_location.to_i].answer
    @mark = @all_descriptive_answers[@current_learner.lesson_location.to_i].marks
  end

  def save_result
    @dtq = DescriptiveAnswer.find(params[:id])    
    unless params[:mark].nil? or params[:mark].blank?
      @dtq.update_attribute(:marks,params[:mark].to_i)
      position_of_question = @dtq.learner.launch_data.split(',').index(@dtq.question_id.to_s)
      unless @dtq.learner.question_scores.nil? or @dtq.learner.question_scores.blank?
        question_score = @dtq.learner.question_scores.split(',')
      else
        question_score = Array.new
      end
      question_score[position_of_question] = params[:mark].to_i
      @dtq.learner.update_attribute(:question_scores, question_score.join(','))
      evaluator = Learner.find_by_assessment_id_and_user_id_and_type_of_test_taker(@dtq.assessment_id,current_user.id,"evaluator")
      unless evaluator.question_status_details.nil? or evaluator.question_status_details.blank?
        question_status = evaluator.question_status_details.split(',')
      else
        question_status = Array.new()
      end
      question_status[evaluator.lesson_location.to_i] = "A"
      evaluator.update_attribute(:question_status_details, question_status.join(","))
    end
    if params[:next] == "Save & Next"
      evaluator.update_attribute(:lesson_status, "incomplete")
      evaluator.update_attribute(:lesson_location, (evaluator.lesson_location.to_i + 1))
      redirect_to("/assessments/evaluate_test/#{@dtq.assessment_id}")
    else
      current_user.descriptive_answers.each{|dtq|
        dtq.learner.update_attribute(:score_raw, (dtq.learner.score_raw.to_i + dtq.marks))
      }
      evaluator.update_attribute(:lesson_status, "complete")
      redirect_to("/mypapers")
    end    
  end

  def goto_question_for_evaluation
    current_learner = Learner.find_by_id(params[:current_learner])
    lesson_location = (params[:id].to_i - 1)
    current_learner.update_attribute(:lesson_location, lesson_location.to_s)
    unless current_learner.question_status_details.nil? or current_learner.question_status_details.blank?
      question_status = current_learner.question_status_details.split(',')
    else
      question_status = Array.new()
    end
    question_status[current_learner.lesson_location.to_i] = "A"
    current_learner.update_attribute(:question_status_details, question_status.join(","))
    redirect_to("/assessments/evaluate_test/#{current_learner.assessment_id}")
  end
  
  # temporary code to correct scores of learner
  def correct_scores
    assessment = Assessment.find(params[:assessment_id])
    user = User.find(params[:id])
    learners = Learner.find_all_by_assessment_id_and_admin_id(params[:assessment_id],params[:id],:conditions => "type_of_test_taker = 'learner' AND lesson_status != 'not attempted'")
    for learner in learners
      save_test_details(learner.lesson_status,learner,assessment,user)
    end
    redirect_to("/courses")
  end

  def change_inactive_to_active_for_gsk
    inactive_learners = Learner.find_all_by_assessment_id_and_active(params[:id],"no")
    inactive_learners.each { |learner|
      learner.update_attribute(:active, "yes")
    }
  end

  def get_current_learner_object(id)
    @current_learner = Learner.find(id)
    return @current_learner
  end

  def get_assessment_object(id)
    @assessment = Assessment.find(id)
    return @assessment
  end

  # Fill all courses table with tenant_id for all tenants
  # This is a temporary code
  def fill_tenant_id_for_courses
    tenants = Tenant.all(:conditions => "is_expired = 'false'")
    tenants.each do |tenant|
      courses = Course.find_all_by_user_id(tenant.user_id)
      courses.each do |course|
        course.update_attribute(:tenant_id, tenant.id)
      end
    end
    redirect_to('/courses')
  end

  # Fill the test_details table for existing learners for all assessments for all tenants
  # It is a temporary code.
  def fill_test_details_for_existing_learners
    tenants = Tenant.all(:conditions => "is_expired = 'false'")
    tenants.each do |tenant|
      assessments = Assessment.find_all_by_user_id(tenant.user_id)
      assessments.each do |assessment|
        learners = Learner.find_all_by_assessment_id(assessment.id, :conditions => "active = 'yes' AND lesson_status = 'not attempted' AND type_of_test_taker = 'learner'")
        learners.each do |learner|
          if learner.test_details.nil? or learner.test_details.blank?
            create_test_details_for_existing_user(learner.id,learner.user_id,learner.tenant_id,learner.launch_data,learner.suspend_data,learner)
          end
        end # end of learners.each loop
      end # end of assessments.each loop
    end # end of tenants.each loop
    redirect_to('/courses')
  end

  def fill_test_details_for_preview
    tenants = Tenant.all(:conditions => "is_expired = 'false'")
    tenants.each do |tenant|
      assessments = Assessment.find_all_by_user_id(tenant.user_id)
      assessments.each do |assessment|
        learner = Learner.find_by_assessment_id(assessment.id, :conditions => "type_of_test_taker = 'admin'")
        unless learner.nil? or learner.blank?
          if learner.test_details.nil? or learner.test_details.blank?
            create_test_details_for_existing_user(learner.id,learner.user_id,learner.tenant_id,learner.launch_data,learner.suspend_data,learner)
          end
        end
      end # end of assessments.each loop
    end # end of tenants.each loop
    redirect_to('/courses')
  end

  def remove_test_details_for_preview
    tenants = Tenant.all(:conditions => "is_expired = 'false'")
    tenants.each do |tenant|
      assessments = Assessment.find_all_by_user_id(tenant.user_id)
      assessments.each do |assessment|
        learner = Learner.find_by_assessment_id(assessment.id, :conditions => "type_of_test_taker = 'admin'")
        unless learner.nil? or learner.blank?
          unless learner.test_details.nil? or learner.test_details.blank?
            test_details = TestDetail.find_all_by_learner_id(learner.id)
            test_details.each do |test_detail|
              test_detail.destroy
            end
          end
        end
      end # end of assessments.each loop
    end # end of tenants.each loop
    redirect_to('/courses')
  end

  def fill_test_detail_for_particular_tenant
    assessments = Assessment.find_all_by_user_id(params[:id])
    assessments.each do |assessment|
      learner = Learner.find_by_assessment_id(assessment.id)
      unless learner.nil? or learner.blank?
        if learner.test_details.nil? or learner.test_details.blank?
          create_test_details_for_existing_user(learner.id,learner.user_id,learner.tenant_id,learner.launch_data,learner.suspend_data,learner)
        end
      end
    end # end of assessments.each loop
  end

  def fill_test_detail_for_particular_assessment
    assessment = Assessment.find(params[:id])
    learners = Learner.find_all_by_assessment_id(assessment.id)
    learners.each do |learner|
      if learner.test_details.nil? or learner.test_details.blank?
        create_test_details_for_existing_user(learner.id,learner.user_id,learner.tenant_id,learner.launch_data,learner.suspend_data,learner)
      end
    end # end of learners.each loop
    redirect_to('/courses')
  end

  def fill_test_detail_for_particular_learner
    learner = Learner.find(params[:id])
    if learner.test_details.nil? or learner.test_details.blank?
      create_test_details_for_existing_user(learner.id,learner.user_id,learner.tenant_id,learner.launch_data,learner.suspend_data,learner)
    end
    redirect_to('/courses')
  end

  def create_test_details_for_existing_user(learner_id,user_id,tenant_id,question_list,answer_list,learner)
    i = 0
    unless question_list.nil? or question_list.blank?
      question_list.split(',').each do |question_id|
        test_details = TestDetail.new
        test_details.learner_id = learner_id
        test_details.user_id = user_id
        test_details.tenant_id = tenant_id
        test_details.question_id = question_id.to_i
        test_details.serial_number = i + 1
        question = Question.find_by_id(question_id.to_i)
        unless question.nil?
          current_test = learner.assessment
          assessment_question_obj = AssessmentQuestion.find_by_assessment_id_and_question_id(current_test.id,question.id)
          unless assessment_question_obj.nil? or assessment_question_obj.blank?
            correct_mark = assessment_question_obj.mark
            negative_mark = assessment_question_obj.negative_mark
          else
            correct_mark = current_test.correct_ans_points
            negative_mark = current_test.wrong_ans_points
          end
          test_details.question_positive_mark = correct_mark
          test_details.question_negative_mark = negative_mark
          test_details.question_type = question.question_type
          unless answer_list.split('|')[i].nil? or answer_list.split('|')[i].blank? or answer_list.split('|')[i] == '*'
            test_details.attempted_status = "answered"
            if question.question_type == "MCQ"
              test_details.answer_id = answer_list.split('|')[i].to_i
              answer = Answer.find(answer_list.split('|')[i].to_i)
              test_details.answer_status = answer.answer_status
            else
              test_details.learner_answer_text = answer_list.split('|')[i]
            end
          end
          unless learner.question_scores.nil? or learner.question_scores.blank?
            test_details.score = learner.question_scores.split('|')[0].split(',')[i]
          end
          unless learner.session_time.nil? or learner.session_time.blank?
            test_details.duration_spent = learner.session_time.split(',')[i]
          end
          test_details.question_bank_id = question.question_bank_id
          test_details.save
          i = i + 1
        end # end of question nil check
      end # end of question_list.split(',').each loop
    end # end of question_list nil check
  end
  # Temporary code to fill test_details table ends here

  # Temporary script to move v1's question tables data to v2's corresponding columns
  # NOTE: Before running this script, we have run below scripts:
  # /difficulties/create_difficulties/1
  # /errors/create_default_error/1
  # /question_statuses/create_question_statuses/1
  # /question_types/create_all_question_types/1
  def move_v1_questions_answers_to_v2
    tenants = Tenant.all(:conditions => "is_expired = 'false'")
    tenants.each do |tenant|
      unless tenant.user.nil?
        user = User.find(tenant.user_id)
        user.question_banks.each do |qb|
          # PTQ type questions don't have question_bank_id. So it will bring all
          # questions except PTQ type.
          qb.questions.each do |question|
            put_question_and_answer_related_mappings_for_existing(question,qb,user)
          end # end of qb.questions.each loop
        end # end of user.question_banks.each loop
      end
    end # end of tenants.each loop
    redirect_to('/courses')
  end

  def put_question_and_answer_related_mappings_for_existing(question,question_bank,user)
    question_type = question.question_type
    unless (question_type.nil? or question_type.blank? or question_type == "MTF")
      tenant_id = user.tenant_id
      # Fill question_bank_table with corresponding tenant_id
      question_bank.update_attribute(:tenant_id, tenant_id)
      question.update_attribute(:tenant_id, tenant_id)
      error_id = ""
      direction_id = ""
      unless question.question_image_file_size.nil?
        create_image(question.question_image_file_name,question.question_image_content_type,question.question_image_file_size,question.id,"")
      end
      unless question.error_in_question.nil? or question.error_in_question.blank?
        error_obj = create_error(question.error_in_question,tenant_id)
        error_id = error_obj.id
      end
      unless question.direction_text.nil? or question.direction_text.blank?
        direction_obj = create_direction(question.direction_text,question_bank.id,tenant_id)
        direction_id = direction_obj.id
      end
      question_type_obj = get_question_type(question_type)
      # If question type is not MCQ,MAQ,SA,FIB,PTQ or MTF, then question_type_obj will be nil
      unless question_type_obj.nil?
        # If the question doesn't belong to PTQ, then the mtf_id will be null.
        # Else mtf_id column will have id of PTQ type question.
        # If the question type is MTF, then also the mtf_id will be null.
        if question.mtf_id.nil? or question.mtf_id.blank?
          create_question_attribute(question.id,question_type_obj.id,question_bank.id,"","","",direction_id,"",error_id,1,tenant_id)
        else
          ptq_question = get_question(question.mtf_id)
          unless ptq_question.nil? or ptq_question.blank?
            passage_obj = create_passage(ptq_question.question_text,question_bank.id,tenant_id)
            create_question_attribute(question.id,question_type_obj.id,question_bank.id,"","","",direction_id,passage_obj.id,error_id,1,tenant_id)
          end
        end # end of question.mtf_id.nil? check
      end # end of question_type_obj.nil? check
    end # end of question_type nil or blank check
    question.answers.each do |answer|
      answer.update_attribute(:tenant_id, tenant_id)
      unless answer.answer_image_file_size.nil?
        create_image(answer.answer_image_file_name,answer.answer_image_content_type,answer.answer_image_file_size,"",answer.id)
      end
    end # end of question.answers.each loop
  end

  def put_question_attribute_mapping_for_existing_questions(question_bank_id,user)
    question_bank = QuestionBank.find(question_bank_id)
    questions_for_qb = Question.find_all_by_question_bank_id(question_bank_id)
    questions_for_qb.each do |question|
      put_question_and_answer_related_mappings_for_existing(question,question_bank,user)
    end
  end

  # Temporary script to move v1's question tables data to v2's corresponding columns ends here

  # Script to send mail to all admins of tenants of LionSher for informing them about system maintenance
  def send_system_maintenance_mail_to_all_admins
    count = 0
    all_admins = User.find_all_by_typeofuser("admin")
    all_admins.each { |user|
      result = system_maintenance_notification_send_grid(user,user.tenant)
      if result == "success" then
        count = count + 1
      end
    }
    flash[:mails_sent_again] = "#{count} mails sent "
    redirect_to('/courses')
  end

  def system_maintenance_notification_send_grid(admin,tenant)
    begin
      url = "https://#{tenant.custom_url}.#{SITE_URL}"
      from_replacements = Hash["[tenant_name]" => tenant.organization,
        "[sender_name]" => admin.login,
        "[sender_email]" => admin.email
      ]

      subject_replacements = Hash["[tenant_name]" => tenant.organization,
        "[url]" => url,
        "[sender_name]" => admin.login,
        "[sender_email]" => admin.email
      ]
      body_replacements = Hash["[tenant_name]" => tenant.organization,
        "[url]" => url,
        "[sender_name]" => admin.login,
        "[sender_email]" => admin.email
      ]
      UserMailer.delay.send_mail(admin,'testadd_assessment_learner_notification',tenant.id,from_replacements,subject_replacements,body_replacements)
      return "success"
      #catch if any errors or exceptions and return that exception
    rescue Net::SMTPFatalError => exception
      return exception
    rescue Net::SMTPSyntaxError => exception
      return exception
    end
  end

  def report
    logger.info"PARAMS in report >> #{params.inspect}"
    @assessment = Assessment.find(params[:id])
    @learner = Learner.find(@assessment.current_learner_id)
    @reports = @assessment.reports.where(:for_whom => "admin")
    unless params.include? "report"
      @report = @reports[0]
    else
      @report = Report.find(params[:report])
    end
  end
end