class Assessment < ActiveRecord::Base
  attr_protected
  has_attached_file :assessment_image, :styles => {:small => "120x90#"},
  :url => "/system/assessment_image/:id/:style/:basename.:extension",
  :path => ":rails_root/public/system/assessment_image/:id/:style/:basename.:extension"

  belongs_to :tenant
  belongs_to :user
  has_one :demographics
  has_many :assessments_question_banks, :dependent => :destroy
  has_many :question_banks, :through => :assessments_question_banks
  has_many :assessment_questions, :dependent => :destroy
  has_many :questions, :through => :assessments_questions
  has_many :descriptive_answers
  has_many :learners, :dependent => :destroy
  belongs_to :test_pattern
  belongs_to :assessment_package
  has_many  :coupons
  has_many  :assessment_courses
  has_many  :packages,  :through => :assessment_courses
  has_many  :assessment_rules, :dependent => :destroy
  has_many  :sections, :dependent => :destroy
  has_many  :structure_components, :dependent => :destroy
  has_many  :assessment_components, :through => :structure_components
  has_one   :calculated_data_assessment
  has_many  :calculated_data_learner_assessments
  has_many  :test_details
  has_many   :reports, :dependent => :destroy

  def score_for_incomplete_learners(current_learner,current_test,learner_column_values)
    learner_column_values = calculate_and_save_score(current_learner,current_test,learner_column_values)
    end_time = current_learner.test_start_time + (current_test.duration_hour * 3600) + (current_test.duration_min * 60)
    if (current_test.schedule_type == "fixed" and Time.now.getutc > current_test.end_time) or (current_test.schedule_type == "open" and Time.now.getutc > end_time)
      learner_column_values = update_timestamps("completed in report",current_learner,current_test.id,learner_column_values)
      learner_column_values['lesson_status'] = "completed"
      assessment_status_based_updation(current_test,current_learner)
    end
    current_learner.update_attributes(learner_column_values)    
  end

  def calculate_score_from_test_details(current_learner,learner_column_values)
    total_score = TestDetail.where(:learner_id => current_learner.id).sum("score")
    total_positive_mark = TestDetail.where(:learner_id => current_learner.id).sum("question_positive_mark")
    total_duration = TestDetail.where(:learner_id => current_learner.id).sum("duration_spent")
    percentage = store_percentage_of_learner(total_score,check_if_integer_or_float(current_learner.score_max.to_f))
    if total_score.to_i < current_learner.score_min.to_i then
      learner_column_values['credit'] = "fail"
    else
      learner_column_values['credit'] = "pass"
    end
    mm, ss = total_duration.divmod(60)  # Calculates minute and second
    hh, mm = mm.divmod(60)              # Calculates hour and minute 
    dd, hh = hh.divmod(24)              # Calculates day and hour
    time_in_hour_min_sec_format = hh.to_s+":"+mm.to_s+":"+ss.ceil.to_s
    learner_column_values['score_raw'] = check_if_integer_or_float(total_score)
    learner_column_values['assessment_score'] = check_if_integer_or_float(total_score)
    learner_column_values['percentage'] = check_if_integer_or_float(percentage)
    learner_column_values['rating'] = total_positive_mark
    learner_column_values['total_time'] = time_in_hour_min_sec_format
    learner_column_values['session_time'] = total_duration          # Store total time without rounding up
    answered = TestDetail.where(:learner_id => current_learner.id,:attempted_status => "answered").count
    answered_correct = TestDetail.where(:learner_id => current_learner.id,:answer_status => "correct").count
    answered_wrong = TestDetail.where(:learner_id => current_learner.id,:answer_status => "wrong").count
    questions_marked = TestDetail.where(:learner_id => current_learner.id,:marked_status => "marked").count
    logger.info"BEFORE RANK CALCULATE"
    get_rank_and_percentile(current_learner,current_learner.assessment)
    logger.info"AFTER RANK CALCULATE"
    # store all details of learner except percentile and rank. Calculate them after fixed assessment is
    # over. And calculate open assessment on click of reports.
    #create_calculated_data_learner_assessment(current_learner.id,current_learner.user_id,current_learner.tenant_id,current_learner.assessment_id,answered,answered_correct,answered_wrong,questions_marked,total_score,time_in_hour_min_sec_format,check_if_integer_or_float(percentage),0,0)
    return learner_column_values
  end

  def calculate_and_save_question_score(current_learner,current_test,learner_column_values)
    learner_column_values = calculate_and_save_score(current_learner,current_test,learner_column_values)
    current_learner.update_attributes(learner_column_values)
  end

  def calculate_and_save_score(current_learner,current_test,learner_column_values)
    unless current_learner.test_details.nil? or current_learner.test_details.blank?
      learner_column_values = calculate_score_from_test_details(current_learner,learner_column_values)
      if current_test.assessment_type == "multiple" and !current_test.using_rules
        unless current_learner.entry.nil? or current_learner.entry.blank?
          calculate_and_save_qb_wise_score_for_learner(current_learner)
        end
      end
    else
    # question_list contains all question ids assigned to the learner
    questions_list = current_learner.launch_data.split(",")
    # answers_list contains all answer ids given by the learner
    answers_list = current_learner.suspend_data.split("|")

    #    correct_answers = Array.new
    correct_answers_list = Array.new
    
    # @test_score is one variable to initialize the score
    test_score = 0
    # creating question_scores array to store question wise scores
    question_scores = Array.new
    time_spent_on_questions = Array.new
    qb_list = Array.new
    # qb_list contains all question bank ids used for current assessment
    qb_list = current_learner.entry.split(",")

    # correct_answers_list will get all correct answer ids in an array
    correct_answers_list = Answer.where(:question_bank_id => qb_list).where(:answer_status => "correct").pluck(:id).join(',').split(',')

    # below we are creating one blank array of qb_list's length
    score_list = Array.new(qb_list.length)
    # here we are initializing all indexes of @score_list array with 0
    score_list.collect! {|x| x = 0 }
    # below we are creating one blank array of qb_list's length to store number of wrong answers given
    qb_wise_wrong_answer_count = Array.new(qb_list.length)
    # here we are initializing all indexes of qb_wise_wrong_answer_count array with 0
    qb_wise_wrong_answer_count.collect! {|x| x = 0 }
    total_qb_wise_score = 0
    j = 0
    total_mark = 0

    questions = Question.includes("assessment_questions").where(:id => questions_list, :assessment_questions => {:assessment_id => current_test.id})

    # If there is no question wise scoring, questions will be null. As eager loading will not extract
    # any record if no association found between questions table and assessment_questions table
    if questions.nil? or questions.blank?
      questions = Question.find(:all, :conditions => ["id in (?)",questions_list])
      questions.each {|question_obj|
        index_of_question = questions_list.index(question_obj.id.to_s)
        if !(question_obj.nil? or question_obj.blank?)
          qb = question_obj.question_bank_id.to_s
          if current_test.test_pattern.nil?
            current_test.update_attribute(:test_pattern_id, 1)
          end
          total_mark = total_mark + current_test.correct_ans_points
          case(question_obj.question_type)
          when "MCQ" then test_score,score_list,question_scores,qb_wise_wrong_answer_count,total_qb_wise_score = calculate_score_for_mcq(answers_list,index_of_question,qb_list,qb,current_test.correct_ans_points,current_test.wrong_ans_points,correct_answers_list,test_score,score_list,question_scores,qb_wise_wrong_answer_count,total_qb_wise_score)
          when "FIB","SA" then test_score,score_list,question_scores,total_qb_wise_score =  calculate_score_for_fib_or_sa(question_obj.id,answers_list,index_of_question,qb_list,qb,current_test.correct_ans_points,current_test.wrong_ans_points,test_score,score_list,question_scores,qb_wise_wrong_answer_count,total_qb_wise_score)
          when "MAQ" then test_score,score_list,question_scores,total_qb_wise_score =  calculate_score_for_maq(answers_list,index_of_question,qb_list,qb,current_test.correct_ans_points,current_test.wrong_ans_points,correct_answers_list,test_score,score_list,question_scores,qb_wise_wrong_answer_count,question_obj,total_qb_wise_score)
          when "MTF" then test_score,score_list,question_scores,total_qb_wise_score =  calculate_score_for_mtf(answers_list,index_of_question,qb_list,qb,current_test.correct_ans_points,current_test.wrong_ans_points,question_obj.id,test_score,score_list,question_scores,qb_wise_wrong_answer_count,total_qb_wise_score)
          end
        end
        j = j + 1
        unless current_learner.timestamps.nil?
          time_spent_on_questions << time_spent_on_question(current_learner,j)
        end
      }
    else
      questions.each {|question_obj|
        index_of_question = questions_list.index(question_obj.id.to_s)
        qb = question_obj.question_bank_id.to_s
        assessment_question_obj = question_obj.assessment_questions[0]
        unless assessment_question_obj.nil? or assessment_question_obj.blank?
          correct_mark = assessment_question_obj.mark
          negative_mark = assessment_question_obj.negative_mark
        else
          correct_mark = current_test.correct_ans_points
          negative_mark = current_test.wrong_ans_points
        end
        total_mark = total_mark + correct_mark
        case(question_obj.question_type)
        when "MCQ" then test_score,score_list,question_scores,qb_wise_wrong_answer_count,total_qb_wise_score = calculate_score_for_mcq(answers_list,index_of_question,qb_list,qb,correct_mark,negative_mark,correct_answers_list,test_score,score_list,question_scores,qb_wise_wrong_answer_count,total_qb_wise_score)
        when "FIB","SA" then test_score,score_list,question_scores,total_qb_wise_score =  calculate_score_for_fib_or_sa(question_obj.id,answers_list,index_of_question,qb_list,qb,correct_mark,negative_mark,test_score,score_list,question_scores,qb_wise_wrong_answer_count,total_qb_wise_score)
        when "MAQ" then test_score,score_list,question_scores,total_qb_wise_score =  calculate_score_for_maq(answers_list,index_of_question,qb_list,qb,correct_mark,negative_mark,correct_answers_list,test_score,score_list,question_scores,qb_wise_wrong_answer_count,question_obj,total_qb_wise_score)
        when "MTF" then test_score,score_list,question_scores,total_qb_wise_score =  calculate_score_for_mtf(answers_list,index_of_question,qb_list,qb,correct_mark,negative_mark,question_obj.id,test_score,score_list,question_scores,qb_wise_wrong_answer_count,total_qb_wise_score)
        end
        j = j + 1
        unless current_learner.timestamps.nil?
          time_spent_on_questions << time_spent_on_question(current_learner,j)
        end
      }
    end
    question_scores = question_scores.join(",")
    total_time_in_seconds_for_test = 0
    
    unless time_spent_on_questions.nil? or time_spent_on_questions.blank?
      for time in time_spent_on_questions
        total_time_in_seconds_for_test += time.to_i
      end
      total_time_spent_on_test = convert_seconds_to_time_format(total_time_in_seconds_for_test)

      time_spent_on_questions = time_spent_on_questions.join(",")
      learner_column_values['total_time'] = total_time_spent_on_test
      learner_column_values['session_time'] = time_spent_on_questions
    end
    qb_wise_wrong_answer_count = qb_wise_wrong_answer_count.join(",")
    score_list_and_no_of_wrong_answers = question_scores + "|" + qb_wise_wrong_answer_count
    score_list = score_list.join(",")
    test_score = check_if_integer_or_float(test_score)
    
    learner_column_values['question_scores'] = score_list_and_no_of_wrong_answers
    learner_column_values['lesson_exit'] = score_list
    learner_column_values['score_raw'] = test_score
    learner_column_values['assessment_score'] = test_score
    learner_column_values['rating'] = total_mark

    unless current_test.test_pattern.question_wise_scoring
      percentage = store_percentage_of_learner(test_score,check_if_integer_or_float(current_learner.score_max.to_f))
    else
      percentage = store_percentage_of_learner(test_score,total_mark)
    end
    if test_score.to_i < current_learner.score_min.to_i then
      learner_column_values['credit'] = "fail"
    else
      learner_column_values['credit'] = "pass"
    end
    learner_column_values['percentage'] = check_if_integer_or_float(percentage)
  end
  return learner_column_values    
end

def add_answer_points(qb_list,qb,points,test_score,score_list,qb_wise_wrong_answer_count,total_qb_wise_score)
  i = 0
  qb_list.each { |s|
    if qb == s
      break;
    end
    i = i + 1
  }
  unless points.nil? or points.blank?
    score_list[i] = score_list[i] + points
    score_list[i] = check_if_integer_or_float(score_list[i])
      if points == 0 or points < 0
        qb_wise_wrong_answer_count[i] = qb_wise_wrong_answer_count[i] + 1
      end
      test_score = test_score + points
      test_score = check_if_integer_or_float(test_score)
    end
    return [test_score,score_list,qb_wise_wrong_answer_count,total_qb_wise_score]
  end

  def calculate_score_for_mcq(answers_list,j,qb_list,qb,correct_ans_points,wrong_ans_points,correct_answers_list,test_score,score_list,question_scores,qb_wise_wrong_answer_count,total_qb_wise_score)
    if !(answers_list[j].nil? or answers_list[j].blank? or answers_list[j] == '*')
      if correct_answers_list.include? answers_list[j].to_s
        question_scores[j] = correct_ans_points
        test_score,score_list,qb_wise_wrong_answer_count,total_qb_wise_score = add_answer_points(qb_list,qb,correct_ans_points,test_score,score_list,qb_wise_wrong_answer_count,total_qb_wise_score)
      else
        question_scores[j] = wrong_ans_points
        test_score,score_list,qb_wise_wrong_answer_count,total_qb_wise_score = add_answer_points(qb_list,qb,wrong_ans_points,test_score,score_list,qb_wise_wrong_answer_count,total_qb_wise_score)
      end
    else
      question_scores[j] = 0
    end
    question_scores[j] = check_if_integer_or_float(question_scores[j])
    return [test_score,score_list,question_scores,qb_wise_wrong_answer_count,total_qb_wise_score]
  end

  def calculate_score_for_fib_or_sa(question_id,answers_list,j,qb_list,qb,correct_ans_points,wrong_ans_points,test_score,score_list,question_scores,qb_wise_wrong_answer_count,total_qb_wise_score)
    answer = Answer.find_by_question_id(question_id)
    if !(answers_list[j].nil? or answers_list[j].blank? or answers_list[j] == '*') and !(answer.nil? or answer.blank?)
      if answer.answer_text.strip.split(' ').join('').casecmp(answers_list[j].strip.split(' ').join('')) == 0
        question_scores[j] = correct_ans_points
        test_score,score_list,qb_wise_wrong_answer_count = add_answer_points(qb_list,qb,correct_ans_points,test_score,score_list,qb_wise_wrong_answer_count,total_qb_wise_score)
      else
        question_scores[j] = wrong_ans_points
        test_score,score_list,qb_wise_wrong_answer_count = add_answer_points(qb_list,qb,wrong_ans_points,test_score,score_list,qb_wise_wrong_answer_count,total_qb_wise_score)
      end
    else
      question_scores[j] = 0
    end
    question_scores[j] = check_if_integer_or_float(question_scores[j])
    return [test_score,score_list,question_scores,qb_wise_wrong_answer_count,total_qb_wise_score]
  end

  def calculate_score_for_maq(answers_list,j,qb_list,qb,correct_ans_points,wrong_ans_points,correct_answers_list,test_score,score_list,question_scores,qb_wise_wrong_answer_count,question_obj,total_qb_wise_score)
    mark = 0
    if !(answers_list[j].nil? or answers_list[j].blank?)
      answers = answers_list[j].split(",")
      correct_length = 0
      wrong_length = 0
      correct_length = question_obj.answers.where(:answer_status => "correct").count
      wrong_length = question_obj.answers.where(:answer_status => "wrong").count
      unless correct_ans_points.to_f == 0.0
        correct_points = (correct_ans_points.to_f/correct_length).round(3)
      else
        correct_points = 0
      end
      unless wrong_ans_points.to_f == 0.0
        wrong_points = (wrong_ans_points.to_f/wrong_length).round(3)
      else
        wrong_points = 0
      end
      unless (answers.include? "*" or answers.include? "")
        unless (correct_answers_list & answers).nil? or (correct_answers_list & answers).blank?
          if (correct_answers_list & answers).length > 0
            (correct_answers_list & answers).length.times do
              mark = mark + correct_points
              test_score,score_list,qb_wise_wrong_answer_count = add_answer_points(qb_list,qb,correct_points,test_score,score_list,qb_wise_wrong_answer_count,total_qb_wise_score)
            end
          end
          if (answers.length != (correct_answers_list & answers).length)
            ((answers.length) - (correct_answers_list & answers).length).times do
              mark = mark + wrong_points
              test_score,score_list,qb_wise_wrong_answer_count = add_answer_points(qb_list,qb,wrong_points,test_score,score_list,qb_wise_wrong_answer_count,total_qb_wise_score)
            end
          end
        end        
        question_scores[j] = mark
      else
        question_scores[j] = 0
      end
    else
      question_scores[j] = 0
    end
    question_scores[j] = check_if_integer_or_float(question_scores[j])
    return [test_score,score_list,question_scores,qb_wise_wrong_answer_count,total_qb_wise_score]
  end

  def calculate_score_for_mtf(answers_list,j,qb_list,qb,correct_ans_points,wrong_ans_points,question_id,test_score,score_list,question_scores,qb_wise_wrong_answer_count,total_qb_wise_score)
    if !(answers_list[j].nil? or answers_list[j].blank?)
      mark = 0
      answers = answers_list[j].split(",")
      unless answers.include? "*"
        options = Question.find_all_by_mtf_id(question_id, :order => 'id')
        correct_question_ids = Array.new
        correct_answer_question_ids = Array.new
        shown_answer_ids = Array.new
        for option in options
          correct_question_ids << option.id
          answer = Answer.find_by_question_id(option.id)
          correct_answer_question_ids << answer.answer_status.to_i
          answer_shown = Answer.find_by_question_id(Answer.find_by_question_id(option.id).answer_status.to_i)
          shown_answer_ids << answer_shown.question_id
        end
        unless correct_ans_points.to_i == 0
          correct_points = (correct_ans_points.to_f/answers.length).round(3)
        else
          correct_points = 0
        end
        unless wrong_ans_points.to_i == 0
          wrong_points = (wrong_ans_points.to_f/answers.length).round(3)
        else
          wrong_points = 0
        end
        k = 0
        answers.each { |id|
          if correct_question_ids[k].eql?shown_answer_ids[(id.to_i) -1]
            mark = mark + correct_points
            test_score,score_list,qb_wise_wrong_answer_count = add_answer_points(qb_list,qb,correct_points,test_score,score_list,qb_wise_wrong_answer_count,total_qb_wise_score)
          else
            mark = mark + wrong_points
            test_score,score_list,qb_wise_wrong_answer_count = add_answer_points(qb_list,qb,wrong_points,test_score,score_list,qb_wise_wrong_answer_count,total_qb_wise_score)
          end
          question_scores[j] = mark
          k = k + 1
        }
      else
        question_scores[j] = 0
      end
    end
    question_scores[j] = check_if_integer_or_float(question_scores[j])
    return [test_score,score_list,question_scores,qb_wise_wrong_answer_count,total_qb_wise_score]
  end

  def store_percentage_of_learner(score,total)
    unless total.zero?
      percentage = (score.to_f/total) * 100
    else
      percentage = 0
    end
    return percentage
  end

  def check_if_integer_or_float(value)
    unless value.nil? or value.blank?
      if (value % 1).zero?
        value = value.to_i
      else
        value = value.to_f.round(2)
      end
    else
      value = 0
    end
    return value
  end

  def calculate_time_spent(current_learner,current_test,learner_column_values)
    score_for_incomplete_learners(current_learner,current_test,learner_column_values)
  end

  def time_spent_on_question(current_learner,question_no)
    timestamps = current_learner.timestamps.split('|')
    visits = Array.new
    for timestamp in timestamps do
      visits << timestamp.split('=')[0]
    end
    question_indexes = Array.new
    i = 0
    while i < timestamps.length do
      if question_no.to_s == visits[i]
        question_indexes << i
      end
      i = i + 1
    end
    time_for_question = Array.new
    for question_index in question_indexes do
      time_for_question << calculate_time_spent_in_seconds(timestamps,question_index,question_index - 1)
    end
    total_time_in_seconds = 0
    for time in time_for_question
      total_time_in_seconds += time
    end
    return total_time_in_seconds
  end

  def calculate_time_spent_in_seconds(timestamps,current_question_index,previous_question_index)
    hc = timestamps[current_question_index].split(':')[0].split('=')[1].to_i
    mc = timestamps[current_question_index].split(':')[1].to_i
    sc = timestamps[current_question_index].split(':')[2].to_i
    hp = timestamps[previous_question_index].split(':')[0].split('=')[1].to_i
    mp = timestamps[previous_question_index].split(':')[1].to_i
    sp = timestamps[previous_question_index].split(':')[2].to_i
    if sc >= sp
      qs = sc - sp
    else
      sc = sc + 60
      qs = sc - sp
      mc = mc - 1
    end
    if mc >= mp
      qm = mc - mp
    else
      mc = mc + 60
      qm = mc - mp
      hc = hc - 1
    end
    qh = hc - hp
    time_spent_in_seconds = qh * 3600 + qm * 60 + qs
    return time_spent_in_seconds
  end

  def convert_seconds_to_time_format(seconds)
    hours = seconds/3600.to_i
    minutes = (seconds/60 - hours * 60).to_i
    seconds = (seconds - (minutes * 60 + hours * 3600))
    total_time = hours.to_s + ":" + minutes.to_s + ":" + seconds.to_s
    return total_time
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

  def convert_utc_time_to_system_time(time,tenant)
    @total_offset = calculate_total_offset(tenant)
    if @zone.include? "+"
      @show_time = time + @total_offset
    else
      @show_time = time - @total_offset
    end
    return @show_time
  end

  def assessment_status_based_updation(assessment,learner)
    case(learner.lesson_status)
    when "completed" then
      assessment.update_attribute(:completed_learners, assessment.completed_learners + 1)
      learner.user.update_attribute(:completed, learner.user.completed + 1)
    when "incomplete" then
      assessment.update_attribute(:no_of_attempted_learners,assessment.no_of_attempted_learners + 1)
      assessment.update_attribute(:incomplete_learners, assessment.incomplete_learners + 1)
      learner.user.update_attribute(:incomplete, learner.user.incomplete + 1)
    when "not attempted" then
      assessment.update_attribute(:unattempted_learners, assessment.unattempted_learners + 1)
      learner.user.update_attribute(:unattempted, learner.user.unattempted + 1)
    when "time up" then
      assessment.update_attribute(:timeup_learners, assessment.timeup_learners + 1)
      learner.user.update_attribute(:timeup, learner.user.timeup + 1)
    end
  end

  def get_assessment_object(id)
    @assessment = Assessment.find(id)
    return @assessment
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

  def calculate_and_save_qb_wise_score_for_learner(current_learner)
    unless current_learner.entry.nil? or current_learner.entry.blank?
      assigned_qb_ids = current_learner.entry.split(',')
      learner_qb_wise_score = Array.new
      question_bank_ids = TestDetail.where(:learner_id => current_learner.id).pluck(:question_bank_id).uniq
      question_banks = QuestionBank.find(question_bank_ids)
      question_banks.each do |question_bank|        
        learner_score_for_qb = TestDetail.where(:learner_id => current_learner.id,:question_bank_id => question_bank.id).sum("score")
        learner_qb_wise_score[assigned_qb_ids.index(question_bank.id.to_s)] = check_if_integer_or_float(learner_score_for_qb)
      end
      current_learner.update_attribute(:lesson_exit,learner_qb_wise_score.join(','))
      return current_learner.lesson_exit
    end
  end

  # Method to store all learner related calculated data for reports
  def create_calculated_data_learner_assessment(learner_id,user_id,tenant_id,assessment_id,answered,answered_correct,answered_wrong,questions_marked,total_score,total_time,percentage,percentile,rank)
    calculated_data_learner = CalculatedDataLearnerAssessment.new
    calculated_data_learner.learner_id = learner_id
    calculated_data_learner.user_id = user_id
    calculated_data_learner.tenant_id = tenant_id
    calculated_data_learner.assessment_id = assessment_id
    calculated_data_learner.answered = answered
    calculated_data_learner.answered_correct = answered_correct
    calculated_data_learner.answered_wrong = answered_wrong
    calculated_data_learner.questions_marked = questions_marked
    calculated_data_learner.total_score = total_score
    calculated_data_learner.total_time = total_time
    calculated_data_learner.percentage = percentage
    calculated_data_learner.percentile = percentile
    calculated_data_learner.rank = rank
    calculated_data_learner.save
  end

  def column_chart(chart_learners)
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('string', 'No of learners')
    data_table.new_column('number', 'Score')
    data_table.add_rows(chart_learners.length)
    index_value = 0
    chart_learners.each do |output|
      output.each do |key,value|
        data_table.set_cell(index_value, 0, key)
        data_table.set_cell(index_value, 1, value)
      end
      index_value = index_value + 1
    end
    opts   = { :width => 720, :height => 200, :legend => {:position =>'none'}}
    @chart = GoogleVisualr::Interactive::ColumnChart.new(data_table, opts)
    return @chart
  end

  # author: KK, sep 12, 2011
  # called from learners_for_assessment method
  # accept assessment object
  # initialize max_score,no_of_steps
  # calculate interval, step points to be plotted on the graph
  # get scores of learners for the current assessment object
  # find frequency for each step
  # returns step_frequency_array
  def frequency_analysis(assessment,learners)
    max_score = assessment.check_if_integer_or_float(assessment.correct_ans_points.to_f) * assessment.no_of_questions
    no_of_steps = 10
    if max_score <= 10
      interval = 1
    else
      interval = max_score.to_f/no_of_steps
    end
    steps = calculate_steps(no_of_steps,interval)
    scores = get_sorted_scores_for_learners(learners)
    scores.delete_if {|x| x > max_score }
    case
    when ((steps.nil? or steps.blank?) and !(scores.nil? or scores.blank?)) then step_frequency_array = find_frequency_for_each_step(assessment,[0],scores)
    when (!(steps.nil? or steps.blank?) and (scores.nil? or scores.blank?)) then step_frequency_array = find_frequency_for_each_step(assessment,steps,[0])
    when ((steps.nil? or steps.blank?) and (scores.nil? or scores.blank?)) then step_frequency_array = find_frequency_for_each_step(assessment,[0],[0])
    when (!(steps.nil? or steps.blank?) and !(scores.nil? or scores.blank?)) then step_frequency_array = find_frequency_for_each_step(assessment,steps,scores)
    end
    return step_frequency_array
  end

  # author: KK, sep 12, 2011
  # called from frequency_analysis method
  # accepts no_of_steps and interval
  # fill steps array one by one
  # return steps
  def calculate_steps(no_of_steps,interval)
    steps = Array.new
    i = 1
    while i <= no_of_steps
      if ((interval * i) % 1).zero?
        steps << (interval * i).to_i
      else
        steps << interval * i
      end
      i = i + 1
    end
    return steps
  end

  # author: KK, sep 12, 2011
  # called from frequency_analysis method
  # accepts assessment_id
  # create learners object for the current assessment id
  # fill scores array one by one for each learner in learners object
  # sort the scores array in ascending order
  # return scores array
  def get_sorted_scores_for_learners(learners)
    scores = learners.pluck(:assessment_score).sort
    return scores
  end

  # author: KK, sep 12, 2011
  # called from frequency_analysis method
  # accepts steps and scores
  # initialize count to zero for each step
  # if the first step is >= score in scores array then increment count for that step,
  # remove that score from scores list and continue.
  # else fix the count for that particular step and delete that step from steps array and continue
  # return step_frequency_array
  def find_frequency_for_each_step(assessment,steps,scores)
    step_frequency_array = Array.new
    count = 0
    i = 0
    last_step = 0
    while i < scores.length
      step_frequency = Hash.new
      unless steps[i].nil? or steps[i].blank?
        if steps[i] >= scores[i]
          count = count + 1
          scores.shift
        else
          if (last_step % 1).zero?
            last_step = last_step + 1
          else
            last_step = last_step.to_f + 0.1
          end
          step_frequency[last_step.to_s+'-'+steps[i].to_s] = count
          last_step = steps[i]
          step_frequency_array << step_frequency
          steps.shift
          count = 0
        end
      end
    end
    unless steps[i].nil? or steps[i].blank?
      if (last_step % 1).zero?
        last_step = last_step + 1
      else
        last_step = last_step.to_f + 0.1
      end
      step_frequency[last_step.to_s+'-'+steps[i].to_s] = count
      last_step = steps[i]
      step_frequency_array << step_frequency
      steps.shift
      count = 0
      while steps.length > 0
        if (last_step % 1).zero?
          last_step = last_step + 1
        else
          last_step = last_step.to_f + 0.1
        end
        step_frequency = Hash.new
        step_frequency[last_step.to_s+'-'+steps[0].to_s] = count
        last_step = steps[0]
        step_frequency_array << step_frequency
        steps.shift
      end
    end
    return step_frequency_array
  end

  def get_rank_and_percentile(current_learner,assessment)
    assessment_learners = assessment.learners.where("lesson_status != ? AND active = ? AND type_of_test_taker = ?","not attempted","yes","learner").order("assessment_score desc")
    get_rank_for_learners(current_learner,assessment_learners,assessment.id)
    get_percentile_for_learners(current_learner,assessment,assessment_learners)
  end

  # author: KK, sep 13, 2011
  # called from learners_for_assessment method
  # A percentile is a measure that tells us what percent of the total
  # frequency scored at or below that measure. A percentile rank is the
  # percentage of scores that fall at or below a given score.
  # b = number of scores below current_score
  # e = number of scores equal to current_score
  # n = length of scores array
  def get_percentile_for_learners(current_learner,assessment,learners)
    logger.info"In get_percentile_for_learners"
    scores = learners.pluck(:assessment_score).sort
    n = scores.length
    if n != 0 then
      learners.each do |learner|
        b = get_no_of_scores_below_current_score(learner.score_raw.to_i,scores)
        e = get_no_of_scores_equal_to_current_score(learner.score_raw.to_i,scores)
        unless n.zero?
          percentile = ((b + (0.5 * e))/n) * 100
        else
          percentile = 0
        end
        # The percentile will get updated for only the current learner
        if learner.id == current_learner.id
          unless learner.percentile.eql? assessment.check_if_integer_or_float(percentile)          
            learner.update_attribute(:percentile, assessment.check_if_integer_or_float(percentile))
          end
        end
      end
    end
  end

  # author: KK, oct 11, 2011
  # called from learners_for_assessment method
  # stores rank of learners in database
  def get_rank_for_learners(current_learner,learners,assessment_id)
    logger.info"In get_rank_for_learners"
    # TODO calculation and update for percentile and rank have to be done only once
    i = 0
    rank = 1
    while i < learners.length-1
      if learners[i].assessment_score <= learners[i+1].assessment_score
        unless learners[i].rank.eql? rank
          learners[i].update_attribute(:rank,rank)
        end
      else
        unless learners[i].rank.eql? rank
          learners[i].update_attribute(:rank,rank)
        end
        rank = rank + 1
      end
      i = i + 1
    end
    unless learners[i].nil?
      unless learners[i].rank.eql? rank
        learners[i].update_attribute(:rank,rank)
      end
    end
  end

  # author: KK, sep 13, 2011
  # called from get_percentile_for_learners method
  def get_no_of_scores_below_current_score(current_score,scores)
    count = 0
    scores.each do |score|
      if score < current_score
        count = count + 1
      end
    end
    return count
  end

  # author: KK, sep 13, 2011
  # called from get_percentile_for_learners method
  def get_no_of_scores_equal_to_current_score(current_score,scores)
    count = 0
    scores.each do |score|
      if score == current_score
        count = count + 1
      end
    end
    return count
  end

end