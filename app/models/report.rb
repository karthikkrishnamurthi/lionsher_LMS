class Report < ActiveRecord::Base
	belongs_to	:assessment
	belongs_to	:structure_component
	belongs_to	:tenant
	belongs_to	:report_template

  def student_name(learner)
    return learner.user.login
  end

  def group_name(learner)
  	return learner.group.group_name
  end

  def test_name(learner)
    return learner.assessment.name
  end

  def date(learner)
    return learner.test_start_time
  end

  def profile(learner)
    return learner.profile_details
  end

  def score(learner)
    return learner.score_raw
  end

  def rank(learner)
    return learner.rank
  end

  def result(learner)
    return learner.credit
  end

  def percentage(learner)
    return learner.percentage
  end

  def percentile(learner)
    return learner.percentile
  end

  def correct_answer_count(learner)
    return learner.test_details.where(:answer_status => "correct").count
  end

  def incorrect_answer_count(learner)
    return learner.test_details.where(:answer_status => "wrong").count
  end

  def time_spent(learner)
    return learner.total_time
  end

  def question_wise_report(learner)   
    return learner.test_details
  end

  def frequency_analysis_graph(learner)
    assessment = learner.assessment
    assessment_learners = assessment.learners.where("lesson_status != ? AND active = ? AND type_of_test_taker = ?","not attempted","yes","learner").order("assessment_score desc")
    chart_learners = assessment.frequency_analysis(assessment,assessment_learners)
    chart = assessment.column_chart(chart_learners)
    return chart
  end

  def test_summary_graph(learner)
    chart_data = []
    correct_answers = 'correct'
    wrong_answers = 'wrong'
    total_attempted,no_of_correct_answers,no_of_wrong_answers,maq_questions_count = get_learner_test_report_counts(learner)
    total = no_of_correct_answers + no_of_wrong_answers
    chart_data<<{:status=>correct_answers,:number=>no_of_correct_answers}
    chart_data<<{:status=>wrong_answers,:number=>no_of_wrong_answers}
    chart_data<<{:total=>total}
    return chart_data
  end

  def get_learner_test_report_counts(learner)
    total_attempted = TestDetail.where(:learner_id => learner.id,:attempted_status => "answered").length
    no_of_correct_answers = TestDetail.where(:learner_id => learner.id,:answer_status => "correct").length
    no_of_wrong_answers = TestDetail.where(:learner_id => learner.id,:answer_status => "wrong").length
    maq_questions_count = TestDetail.where(:learner_id => learner.id,:question_type => "MAQ").length
    return [total_attempted,no_of_correct_answers,no_of_wrong_answers,maq_questions_count]
  end

  def score_by_topic(learner)
    if learner.assessment.assessment_type == "multiple"
      question_bank_ids = TestDetail.where(:learner_id => learner.id).pluck(:question_bank_id).uniq
    end
    return question_bank_ids
  end

  def question_analysis_report(learner)
    learners = learner.assessment.learners.where('lesson_status != "not attempted"').order(:id)    
    return learners
  end

  def get_question_analysis_report_details(learner,learners)
    learner_limit = (learners.count * 0.27).round
    upper_group = learner.assessment.learners.where('lesson_status != "not attempted"').order('rank').limit(learner_limit).pluck(:id)
    lower_group = learner.assessment.learners.where('lesson_status != "not attempted"').order('rank desc').limit(learner_limit).pluck(:id)
    upper_group_test_details = TestDetail.where(:learner_id => upper_group)
    lower_group_test_details = TestDetail.where(:learner_id => lower_group)
    return [learner_limit,upper_group_test_details,lower_group_test_details]
  end

  def progress_report(learner)
    learners = learner.assessment.learners.where("lesson_status != ? AND active = ? AND type_of_test_taker = ?","not attempted","yes","learner").includes(:user).order("assessment_score desc")
    return learners
  end

  def progress_report_graph(learner)
    assessment_chart_data = []
    if !(learner.assessment.pass_score.nil? or learner.assessment.pass_score.blank?) and learner.assessment.pass_score.to_i > 0
      assessment_passed = "pass"
      assessment_failed = "fail"
    else
      assessment_passed = "completed"
      assessment_failed = "incomplete"
    end
    assessment_unattempted = "unattempted"
    assessment_timeup = "time up"
    pass_or_complete_count,fail_or_incomplete_count,unattempted_count,timeup_count,total = get_all_progress_report_graph_details(learner.assessment)
    assessment_chart_data<<{:assessment_name=>assessment_passed,:assessment_output=>pass_or_complete_count}
    assessment_chart_data<<{:assessment_name=>assessment_failed,:assessment_output=>fail_or_incomplete_count}
    assessment_chart_data<<{:assessment_name=>assessment_unattempted,:assessment_output=>unattempted_count}
    assessment_chart_data<<{:assessment_name=>assessment_timeup,:assessment_output=>timeup_count}
    assessment_chart_data<<{:total=>total}
    return assessment_chart_data
  end

  def get_all_progress_report_graph_details(assessment)
    if !(assessment.pass_score.nil? or assessment.pass_score.blank?) and assessment.pass_score.to_i > 0
      pass_or_complete_count = assessment.learners.where(:credit => "pass",:active => "yes",:type_of_test_taker => "learner").count
      fail_or_incomplete_count = assessment.learners.where(:credit => "fail",:active => "yes",:type_of_test_taker => "learner").count
    else
      pass_or_complete_count = assessment.learners.where(:lesson_status => "completed",:active => "yes",:type_of_test_taker => "learner").count
      fail_or_incomplete_count = assessment.learners.where(:lesson_status => "incomplete",:active => "yes",:type_of_test_taker => "learner").count
    end
    unattempted_count = assessment.learners.where(:lesson_status => "not attempted",:active => "yes",:type_of_test_taker => "learner").count
    timeup_count = assessment.learners.where(:lesson_status => "time up",:active => "yes",:type_of_test_taker => "learner").count
    total = assessment.learners.where(:active => "yes",:type_of_test_taker => "learner").count
    return [pass_or_complete_count,fail_or_incomplete_count,unattempted_count,timeup_count,total]
  end
end
