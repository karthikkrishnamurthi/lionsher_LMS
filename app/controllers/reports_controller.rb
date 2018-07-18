# Author : Surupa
# Total assigned learners = [currently assigned learners(includes admin if self assigned) + deleted(or anything else)]  i.e,learners assigned for this test/course at any point of time
# Active learners = Total assigned learners - deleted learners
# COMPLETED - Completed test/course within time
# INCOMPLETE - Currently in incomplete status/when the test finished, learner was not logged in
# TIMEUP - Within given time not able to complete(when the test finished, learner was logged in)
# UNATTEMPTED - Learner never attempted the test/course
# Scoring : Pass/Fail
# If pass_score = 0 then pass/fail is not applicable

require 'csv'

class ReportsController < ApplicationController
  before_filter :login_required
  before_filter :is_expired?

  def career_avenues
    @learners = Learner.find_all_by_admin_id_and_assessment_id(params[:admin],params[:id])
    answer_list = Array.new
    @learners.each do |learner|
      total = 0
      answer_list = []
      answer_list = learner.suspend_data.split('|')
      answer_list.each do |answer|
        unless answer == "*"
          a = Answer.find(answer)
          if a.answer_status == "correct"
            unless a.question.assessment_questions[0].nil?
              mark_for_answer = a.question.assessment_questions[0].mark
            else
              mark_for_answer = 1
            end
            total = total + mark_for_answer
          end
        else
        end
      end
    end
  end
  
  #control comes here when we click on Reports link or select "All Courses/Assessments" option from dropdown
  def course_report
    if current_user.tenant.selected_quarter != 'Show All' then
      find_quarter_and_timings()
      @records = Course.find_all_by_user_id(current_user.id,:conditions => ["created_at > ? AND created_at <= ? AND size > 0",@start_time.strftime("%Y-%m-%d %H:%M:%S"),@end_time.strftime("%Y-%m-%d %H:%M:%S")],:order => "course_name")
      @assessments = Assessment.find_all_by_user_id(current_user.id,:conditions => ["created_at > ? AND created_at <= ? AND no_of_questions > 0",@start_time.strftime("%Y-%m-%d %H:%M:%S"),@end_time.strftime("%Y-%m-%d %H:%M:%S")],:order => "name")
    else
      @records = Course.find_all_by_user_id(current_user.id, :order => "course_name", :conditions => ["size > 0"])
      @assessments = Assessment.find_all_by_user_id(current_user.id,:order => "name", :conditions => ["no_of_questions > 0"])
    end
  end

  #control comes here when we click on any course in course_report
  def learners_for_course
    @chart_data = []        
    if current_user.tenant.selected_quarter != 'Show All' then
      find_records_based_on_quarter(params[:id],params[:action])
    else
      @learners = Learner.find_all_by_course_id_and_active(params[:id],"yes",:conditions => ["type_of_test_taker = 'learner'"])
      @deleted_learners = Learner.find_all_by_course_id_and_active(params[:id],"no",:conditions => ["type_of_test_taker = 'learner'"])
    end
    declare_var()
    create_chart("course",params[:id])
    end_chart()    
  end

  #control comes here when we click on Reports link and select "All Learners" option from dropdown
  def learner_report    
    if current_user.tenant.selected_quarter != 'Show All' then
      find_records_based_on_quarter(current_user.tenant.id,params[:action])
      @learners_id = Hash.new
      for learner in @learners
        @learners_id[learner.user_id] = learner.user.login
      end
      @learners_id = @learners_id.sort {|a,b| a[1].downcase<=>b[1].downcase}
    else
      #      @learners = Learner.find_all_by_admin_id_and_active(params[:id],"yes",:conditions => ["type_of_test_taker = 'learner'"])
      @learners_id = User.find(:all, :conditions => ["user_id = ? AND (no_of_courses_assigned > 0 OR no_of_assessments_assigned > 0) AND deactivated_at is NULL",current_user.id], :order => "login")
    end
    @learners_for_pagination = @learners_id
    #    Two-to-three-upgrade-error
    #    @learners_for_pagination = @learners_id.paginate(:page => params[:page], :per_page => 100)
  end

  #control comes here when we click on any learner in learner_report
  def courses_for_learner
    @chart_data = []    
    if current_user.tenant.selected_quarter != 'Show All' then
      find_records_based_on_quarter(params[:id],params[:action])
    else
      @learners = Learner.find_all_by_user_id_and_active(params[:id],"yes",:conditions => ["type_of_test_taker = 'learner'"])
    end
    declare_var()
    create_chart("learner",params[:id])
    end_chart()
  end

  def find_records_based_on_quarter(id,action)
    find_quarter_and_timings()
    case
    when action == "learner_report" then
      @learners = Learner.find_all_by_tenant_id_and_active(id,"yes",:conditions => ["created_at > ? AND created_at <= ? AND type_of_test_taker = 'learner'",@start_time.strftime("%Y-%m-%d %H:%M:%S"),@end_time.strftime("%Y-%m-%d %H:%M:%S")])
    when action == "courses_for_learner" then
      @learners = Learner.find_all_by_user_id_and_active(id,"yes",:conditions => ["created_at > ? AND created_at <= ? AND type_of_test_taker = 'learner'",@start_time.strftime("%Y-%m-%d %H:%M:%S"),@end_time.strftime("%Y-%m-%d %H:%M:%S")])
    when action == "learners_for_course" then
      @learners = Learner.find_all_by_course_id_and_active(id,"yes",:conditions => ["created_at > ? AND created_at <= ? AND type_of_test_taker = 'learner'",@start_time.strftime("%Y-%m-%d %H:%M:%S"),@end_time.strftime("%Y-%m-%d %H:%M:%S")])
      @deleted_learners = Learner.find_all_by_course_id_and_active(id,"no",:conditions => ["created_at > ? AND created_at <= ? AND type_of_test_taker = 'learner'",@start_time.strftime("%Y-%m-%d %H:%M:%S"),@end_time.strftime("%Y-%m-%d %H:%M:%S")])
    when action == "report_based_on_status"
      @learners = Learner.find_all_by_course_id_and_lesson_status_and_active(id,params[:status],"yes",:conditions => ["created_at > ? AND created_at <= ? AND type_of_test_taker = 'learner'",@start_time.strftime("%Y-%m-%d %H:%M:%S"),@end_time.strftime("%Y-%m-%d %H:%M:%S")])
    end
    @show_start_time = @start_time.strftime("%b %d")
    @show_end_time = @end_time.strftime("%b %d, %Y")
  end

  def find_quarter_and_timings
    current_year = current_user.tenant.current_year
    last_year = current_user.tenant.previous_year
    if params.include? 'quarter'
      quarter = params[:quarter]
    else
      quarter = current_user.tenant.selected_quarter
    end
    case
    when (quarter.include? 'Q1') then
      start_month = 'jan'
      end_month = 'mar'
      selected_quarter = 'Q1'
    when (quarter.include? 'Q2') then
      start_month = 'apr'
      end_month = 'jun'
      selected_quarter = 'Q2'
    when (quarter.include? 'Q3') then
      start_month = 'jul'
      end_month = 'sep'
      selected_quarter = 'Q3'
    when (quarter.include? 'Q4') then
      start_month = 'oct'
      end_month = 'dec'
      selected_quarter = 'Q4'
    end
    case
    when (current_user.tenant.selected_quarter == "Current Quarter("+current_user.tenant.quarter+")") then
      @start_time = Time.local(current_year,start_month)
      @end_time = Time.now
    when (current_user.tenant.selected_quarter == "Current Year - "+current_year.to_s) then
      @start_time = Time.local(current_year,"jan")
      @end_time = Time.now
    when (current_user.tenant.selected_quarter == "Last Year - "+last_year.to_s) then
      @start_time = Time.local(last_year,"jan")
      @end_time = Time.local(last_year,"dec",31)
    when (current_user.tenant.selected_quarter == selected_quarter+" "+last_year.to_s) then
      @start_time = Time.local(last_year,start_month)
      end_month = Time.local(last_year,end_month).month
      @number_of_days = days_in_month(last_year,end_month)
      @end_time = Time.local(last_year,end_month,@number_of_days)
    else
      @start_time = Time.local(current_year,start_month)
      end_month = Time.local(current_year,end_month).month
      @number_of_days = days_in_month(current_year,end_month)
      @end_time = Time.local(current_year,end_month,@number_of_days)
    end
  end

  def days_in_month(year,month)
    return (Date.new(year,12, 31) << (12-month.to_i)).day
  end

  #declaring variables for creating chart for courses_for_learner or learners_for_course
  def declare_var
    @c_total = 0
    @i_total = 0
    @u_total = 0
    @t_total = 0
    @course_completed = 'completed'
    @course_unattempted = 'unattempted'
    @course_incomplete = 'incomplete'
    @course_timeup = 'time up'
  end


  def create_chart(report_type,id)
    if current_user.tenant.selected_quarter != 'Show All' then
      find_quarter_and_timings()
    end
    case
    when (report_type == "course" and current_user.tenant.selected_quarter != "Show All")
      @unattempted = Learner.find_all_by_course_id_and_lesson_status_and_active(id,'not attempted',"yes",:conditions => ["created_at > ? AND created_at <= ?",@start_time.strftime("%Y-%m-%d %H:%M:%S"),@end_time.strftime("%Y-%m-%d %H:%M:%S")])
      @completed = Learner.find_all_by_course_id_and_lesson_status_and_active(id,'completed',"yes",:conditions => ["created_at > ? AND created_at <= ?",@start_time.strftime("%Y-%m-%d %H:%M:%S"),@end_time.strftime("%Y-%m-%d %H:%M:%S")])
      @incomplete = Learner.find_all_by_course_id_and_lesson_status_and_active(id,'incomplete',"yes",:conditions => ["created_at > ? AND created_at <= ?",@start_time.strftime("%Y-%m-%d %H:%M:%S"),@end_time.strftime("%Y-%m-%d %H:%M:%S")])
    when (report_type == "course" and current_user.tenant.selected_quarter == "Show All")
      @unattempted = Learner.find_all_by_course_id_and_lesson_status_and_active(id,'not attempted',"yes")
      @completed = Learner.find_all_by_course_id_and_lesson_status_and_active(id,'completed',"yes")
      @incomplete = Learner.find_all_by_course_id_and_lesson_status_and_active(id,'incomplete',"yes")
    when (report_type == "learner" and current_user.tenant.selected_quarter != "Show All")
      @unattempted = Learner.find_all_by_user_id_and_lesson_status_and_active(id,'not attempted',"yes",:conditions => ["created_at > ? AND created_at <= ? AND type_of_test_taker = 'learner'",@start_time.strftime("%Y-%m-%d %H:%M:%S"),@end_time.strftime("%Y-%m-%d %H:%M:%S")])
      @completed = Learner.find_all_by_user_id_and_lesson_status_and_active(id,'completed',"yes",:conditions => ["created_at > ? AND created_at <= ? AND type_of_test_taker = 'learner'",@start_time.strftime("%Y-%m-%d %H:%M:%S"),@end_time.strftime("%Y-%m-%d %H:%M:%S")])
      @incomplete = Learner.find_all_by_user_id_and_lesson_status_and_active(id,'incomplete',"yes",:conditions => ["created_at > ? AND created_at <= ? AND type_of_test_taker = 'learner'",@start_time.strftime("%Y-%m-%d %H:%M:%S"),@end_time.strftime("%Y-%m-%d %H:%M:%S")])
      @timeup = Learner.find_all_by_user_id_and_lesson_status_and_active(id,'time up',"yes",:conditions => ["created_at > ? AND created_at <= ? AND type_of_test_taker = 'learner'",@start_time.strftime("%Y-%m-%d %H:%M:%S"),@end_time.strftime("%Y-%m-%d %H:%M:%S")])
    else
      @unattempted = Learner.find_all_by_user_id_and_lesson_status_and_active(id,'not attempted',"yes")
      @completed = Learner.find_all_by_user_id_and_lesson_status_and_active(id,'completed',"yes")
      @incomplete = Learner.find_all_by_user_id_and_lesson_status_and_active(id,'incomplete',"yes")
      @timeup = Learner.find_all_by_user_id_and_lesson_status_and_active(id,'time up',"yes")
    end
    @c_total = @c_total + @completed.length
    @i_total = @i_total + @incomplete.length
    @u_total = @u_total + @unattempted.length
    if report_type == "learner"
      @t_total = @t_total + @timeup.length
    end
  end


  def end_chart
    @total = @c_total + @i_total + @u_total + @t_total
    @chart_data<<{:course_name=>@course_completed,:course_output=>@c_total}
    @chart_data<<{:course_name=>@course_incomplete,:course_output=>@i_total}
    @chart_data<<{:course_name=>@course_unattempted,:course_output=>@u_total}
    @chart_data<<{:course_name=>@course_timeup,:course_output=>@t_total}
    @chart_data<<{:total=>@total}
    return @chart_data
  end

  def learners_for_assessment
    #    require 'kaminari'
    @assessment_chart_data = []
    @assessment = Assessment.find_by_id(params[:id])
    @assessment_deleted_learners = Learner.find_all_by_assessment_id_and_active(params[:id],"no",:conditions => ["type_of_test_taker = 'learner'"], :include => :user, :order => "assessment_score desc")
    @assessment_learners = @assessment.learners.where("lesson_status != ? AND active = ? AND type_of_test_taker = ?","not attempted","yes","learner").includes(:user).order("assessment_score desc")
    @chart_learners = @assessment.frequency_analysis(@assessment,@assessment_learners)
    @chart = @assessment.column_chart(@chart_learners)
    if (@assessment.schedule_type == "fixed" and Time.now.getutc > @assessment.end_time)
      unless @assessment_learners.nil? or @assessment_learners.blank?
        @learners_for_pagination = @assessment_learners
      end
    else
      unless @assessment_learners.nil? or @assessment_learners.blank?
        @learners_for_pagination = @assessment_learners
      end
    end
    declare_assessment_var(params[:id])
    create_assessment_chart(@assessment)
    end_assessment_chart()    
    if !(@assessment.pass_score.nil? or @assessment.pass_score.blank?) and @assessment.pass_score.to_i > 0
      @learner = Learner.find_by_assessment_id_and_active(params[:id],"yes")
      @total_passed_or_completed = @assessment_chart_data[0][:assessment_output]
      @total_failed_or_incomplete = @assessment_chart_data[1][:assessment_output]
    else
      @total_passed_or_completed = @assessment_chart_data[0][:assessment_output]
      @total_failed_or_incomplete = @assessment_chart_data[1][:assessment_output]
    end
    @total_unattempted = @assessment_chart_data[2][:assessment_output]
    @total_timeup = @assessment_chart_data[3][:assessment_output]
    @total_assigned = @assessment_chart_data[4][:total]
    #    @standard_deviation = get_standard_deviation(@assessment_learners)
  end

  def declare_assessment_var(id)
    @assessment = Assessment.find_by_id(id)
    @p_total = 0
    @f_total = 0
    @u_total = 0
    @t_total = 0
    if !(@assessment.pass_score.nil? or @assessment.pass_score.blank?) and @assessment.pass_score.to_i > 0
      @assessment_passed = 'pass'
      @assessment_failed = 'fail'
    else
      @assessment_passed = 'completed'
      @assessment_failed = 'incomplete'
    end
    @assessment_unattempted = 'unattempted'
    @assessment_timeup = 'time up'
  end


  # control comes here from course_report. If the report is for assessment then @assessment_learners
  # creates object for all learners of corresponding assessment and status. If the report is for course then
  # @learners object holds all learners for corresponding course, status and quarter.
  def report_based_on_status
    case
    when (params.include? "assessment_id") then
      @assessment = Assessment.find_by_id(params[:assessment_id])
      @learners = Learner.find_all_by_assessment_id_and_lesson_status_and_active(params[:assessment_id],params[:status],"yes",:conditions => ["type_of_test_taker = 'learner'"])
      sorted_learners = Hash.new
      for learner in @learners
        sorted_learners[learner.id] = learner.score_raw.to_f
      end
      sorted_learners = sorted_learners.sort {|a,b| b[1]<=>a[1]}
      @learners_for_pagination = sorted_learners.paginate(:page => params[:page], :per_page => 5)
      # @assessment.get_percentile_for_learners(@assessment,@learners)
      # @assessment.get_rank_for_learners(sorted_learners,@assessment.id)
      #      @standard_deviation = get_standard_deviation(@learners_for_pagination)
    when (params.include? "course_id") then
      @course = Course.find_by_id(params[:course_id])
      if current_user.tenant.selected_quarter != 'Show All' then
        find_records_based_on_quarter(params[:course_id],"report_based_on_status")
      else
        @learners = Learner.find_all_by_course_id_and_lesson_status_and_active(params[:course_id],params[:status],"yes",:conditions => ["type_of_test_taker = 'learner'"])
      end
    end
  end

  def create_assessment_chart(assessment)
    if !(assessment.pass_score.nil? or assessment.pass_score.blank?) and assessment.pass_score.to_i > 0
      @passed = Learner.find_all_by_assessment_id_and_credit_and_active(assessment.id,'pass',"yes",:conditions => ["type_of_test_taker = 'learner'"])
      @failed = Learner.find_all_by_assessment_id_and_credit_and_active(assessment.id,'fail',"yes",:conditions => ["type_of_test_taker = 'learner'"])
    else
      @completed = Learner.find_all_by_assessment_id_and_lesson_status_and_active(assessment.id,'completed',"yes",:conditions => ["type_of_test_taker = 'learner'"])
      @incomplete = Learner.find_all_by_assessment_id_and_lesson_status_and_active(assessment.id,'incomplete',"yes",:conditions => ["type_of_test_taker = 'learner'"])
    end
    @unattempted = Learner.find_all_by_assessment_id_and_lesson_status_and_active(assessment.id,'not attempted',"yes",:conditions => ["type_of_test_taker = 'learner'"])
    @timeup = Learner.find_all_by_assessment_id_and_lesson_status_and_active(assessment.id,'time up',"yes",:conditions => ["type_of_test_taker = 'learner'"])
    @total = Learner.find_all_by_assessment_id_and_active(assessment.id,"yes",:conditions => ["type_of_test_taker = 'learner'"])
    if !(@assessment.pass_score.nil? or @assessment.pass_score.blank?) and @assessment.pass_score.to_i > 0
      @p_total = @p_total + @passed.length
      @f_total = @f_total + @failed.length
    else
      @p_total = @p_total + @completed.length
      @f_total = @f_total + @incomplete.length
    end
    @u_total = @u_total + @unattempted.length
    @t_total = @t_total + @timeup.length
  end

  def end_assessment_chart
    @assessment_chart_data<<{:assessment_name=>@assessment_passed,:assessment_output=>@p_total}
    @assessment_chart_data<<{:assessment_name=>@assessment_failed,:assessment_output=>@f_total}
    @assessment_chart_data<<{:assessment_name=>@assessment_unattempted,:assessment_output=>@u_total}
    @assessment_chart_data<<{:assessment_name=>@assessment_timeup,:assessment_output=>@t_total}
    @assessment_chart_data<<{:total=>@total.length}
    return @assessment_chart_data
  end

  #control comes here when user clicks on download report for course.
  #This method uses fastercsv for generating a excel file.
  def download_elearning_report_csv
    course = Course.find(params[:id])
    learners = Learner.find_all_by_course_id_and_active(params[:id],"yes")
    csv_string = FasterCSV.generate do |csv|
      #set the header
      csv << ["Learners","Assigned","Status","Score"]
      learners.each do | learner |
        created_time = (learner.created_at).strftime("%d %b %Y")
        user_obj = User.find_by_id(learner.user_id)
        if learner.score_raw.blank? or learner.score_raw.nil?
          score = "-"
        elsif(!learner.score_max.nil? and learner.score_max != "")
          score = learner.score_raw.to_s  + " of " + learner.score_max.to_s
        else
          score = learner.score_raw.to_s
        end
        csv << [user_obj.login,created_time,learner.lesson_status,score]
      end
    end
    generate_csv_file(csv_string,course.course_name)
  end

  #control comes here when user clicks on download report for assessment.
  #This method uses fastercsv for generating a excel file.
  def download_assessment_report_csv    
    assessment_learners = Learner.find_all_by_assessment_id_and_active(params[:id],"yes",:conditions => ["lesson_status != 'not attempted' and type_of_test_taker = 'learner'"], :include => [:user,:group])
    assessment = Assessment.find_by_id(params[:id])
    admin_learner = Learner.find_by_assessment_id_and_admin_id_and_type_of_test_taker(params[:id],current_user.id,"learner")
    question_bank_arr = Array.new
    question_bank_arr = ["Learner ID","Name","Email","Group"]
    unless assessment.demographics.nil? or assessment.demographics.blank?
      unless assessment.demographics.demographic_type_1.nil? or assessment.demographics.demographic_type_1.blank?
        question_bank_arr << assessment.demographics.demographic_type_1
      end
      unless assessment.demographics.demographic_type_2.nil? or assessment.demographics.demographic_type_2.blank?
        question_bank_arr << assessment.demographics.demographic_type_2
      end
      unless assessment.demographics.demographic_type_3.nil? or assessment.demographics.demographic_type_3.blank?
        question_bank_arr << assessment.demographics.demographic_type_3
      end
      unless assessment.demographics.demographic_type_4.nil? or assessment.demographics.demographic_type_4.blank?
        question_bank_arr << assessment.demographics.demographic_type_4
      end
      unless assessment.demographics.demographic_type_5.nil? or assessment.demographics.demographic_type_5.blank?
        question_bank_arr << assessment.demographics.demographic_type_5
      end
      unless assessment.demographics.demographic_type_6.nil? or assessment.demographics.demographic_type_6.blank?
        question_bank_arr << assessment.demographics.demographic_type_6
      end
      unless assessment.demographics.demographic_type_7.nil? or assessment.demographics.demographic_type_7.blank?
        question_bank_arr << assessment.demographics.demographic_type_7
      end
      unless assessment.demographics.demographic_type_8.nil? or assessment.demographics.demographic_type_8.blank?
        question_bank_arr << assessment.demographics.demographic_type_8
      end
      unless assessment.demographics.demographic_type_9.nil? or assessment.demographics.demographic_type_9.blank?
        question_bank_arr << assessment.demographics.demographic_type_9
      end
      unless assessment.demographics.demographic_type_10.nil? or assessment.demographics.demographic_type_10.blank?
        question_bank_arr << assessment.demographics.demographic_type_10
      end
      unless assessment.demographics.demographic_type_11.nil? or assessment.demographics.demographic_type_11.blank?
        question_bank_arr << assessment.demographics.demographic_type_11
      end
      unless assessment.demographics.demographic_type_12.nil? or assessment.demographics.demographic_type_12.blank?
        question_bank_arr << assessment.demographics.demographic_type_12
      end
      unless assessment.demographics.demographic_type_13.nil? or assessment.demographics.demographic_type_13.blank?
        question_bank_arr << assessment.demographics.demographic_type_13
      end
      unless assessment.demographics.demographic_type_14.nil? or assessment.demographics.demographic_type_14.blank?
        question_bank_arr << assessment.demographics.demographic_type_14
      end
      unless assessment.demographics.demographic_type_15.nil? or assessment.demographics.demographic_type_15.blank?
        question_bank_arr << assessment.demographics.demographic_type_15
      end
    end
    qb_ids = Array.new
    admin_learner.entry.split(',').each { |qb_id|
      qb_ids << qb_id
    }
    question_banks = QuestionBank.find(:all, :select => :name, :conditions => ["id in (?)",qb_ids])
    question_banks.each do |qb|
      question_bank_arr << qb.name
    end
    question_bank_arr << "Total"
    question_bank_arr << "Status"
    if !(assessment.pass_score.nil? or assessment.pass_score.blank?) and assessment.pass_score.to_i > 0
      question_bank_arr << "Result"
    end
    question_bank_arr << "Attempted Time"
    csv_string = CSV.generate do |csv|
      #set the header
      csv << question_bank_arr

      assessment_learners.each do |learner|
        #      assessment_learners.each do | learner |
        initial_csv = Array.new
        #        user_obj = User.find_by_id(learner.user_id)
        unless learner.user.nil? or learner.user.blank?
          initial_csv = [learner.id,learner.user.login,learner.user.email,learner.group.group_name]
          unless assessment.demographics.nil? or assessment.demographics.blank?
            unless assessment.demographics.demographic_type_1.nil? or assessment.demographics.demographic_type_1.blank?
              initial_csv << learner.demographic_1
            end
            unless assessment.demographics.demographic_type_2.nil? or assessment.demographics.demographic_type_2.blank?
              initial_csv << learner.demographic_2
            end
            unless assessment.demographics.demographic_type_3.nil? or assessment.demographics.demographic_type_3.blank?
              initial_csv << learner.demographic_3
            end
            unless assessment.demographics.demographic_type_4.nil? or assessment.demographics.demographic_type_4.blank?
              initial_csv << learner.demographic_4
            end
            unless assessment.demographics.demographic_type_5.nil? or assessment.demographics.demographic_type_5.blank?
              initial_csv << learner.demographic_5
            end
            unless assessment.demographics.demographic_type_6.nil? or assessment.demographics.demographic_type_6.blank?
              initial_csv << learner.demographic_6
            end
            unless assessment.demographics.demographic_type_7.nil? or assessment.demographics.demographic_type_7.blank?
              initial_csv << learner.demographic_7
            end
            unless assessment.demographics.demographic_type_8.nil? or assessment.demographics.demographic_type_8.blank?
              initial_csv << learner.demographic_8
            end
            unless assessment.demographics.demographic_type_9.nil? or assessment.demographics.demographic_type_9.blank?
              initial_csv << learner.demographic_9
            end
            unless assessment.demographics.demographic_type_10.nil? or assessment.demographics.demographic_type_10.blank?
              initial_csv << learner.demographic_10
            end
            unless assessment.demographics.demographic_type_11.nil? or assessment.demographics.demographic_type_11.blank?
              initial_csv << learner.demographic_11
            end
            unless assessment.demographics.demographic_type_12.nil? or assessment.demographics.demographic_type_12.blank?
              initial_csv << learner.demographic_12
            end
            unless assessment.demographics.demographic_type_13.nil? or assessment.demographics.demographic_type_13.blank?
              initial_csv << learner.demographic_13
            end
            unless assessment.demographics.demographic_type_14.nil? or assessment.demographics.demographic_type_14.blank?
              initial_csv << learner.demographic_14
            end
            unless assessment.demographics.demographic_type_15.nil? or assessment.demographics.demographic_type_15.blank?
              initial_csv << learner.demographic_15
            end
          end
          unless learner.lesson_exit.nil? or learner.lesson_exit.blank?
            scores = learner.lesson_exit.split(',')
            scores.each {|score|
              initial_csv << score
            }
          else
            unless learner.test_details.nil? or learner.test_details.blank?
              lesson_exit = assessment.calculate_and_save_qb_wise_score_for_learner(learner)
              unless lesson_exit.nil? or lesson_exit.blank?
                scores = learner.lesson_exit.split(',')
                scores.each {|score|
                  initial_csv << score
                }
              end
            else
              question_banks.each do |qb|
                initial_csv << "-"
              end
            end
          end
          if learner.lesson_status == "completed" or learner.lesson_status == "time up" or learner.lesson_status == "incomplete"
            initial_csv << learner.score_raw
          else
            initial_csv << "-"
          end
          initial_csv << learner.lesson_status
          if !(assessment.pass_score.nil? or assessment.pass_score.blank?) and assessment.pass_score.to_i > 0
            if learner.lesson_status == "completed" or learner.lesson_status == "time up" or learner.lesson_status == "incomplete"
              initial_csv << learner.credit
            else
              initial_csv << "-"
            end
          end
          learner_test_start_time = assessment.convert_utc_time_to_system_time(learner.test_start_time,assessment.tenant)
          initial_csv << learner_test_start_time.strftime('%d %b %Y %I:%M%p')
          csv << initial_csv
        end
      end
    end
    generate_csv_file(csv_string,assessment.name)
  end

  def learner_question_paper
    @learner = Learner.find_by_id(params[:id])
    @questions_list = @learner.launch_data.split(",")
    @answers_list = @learner.suspend_data.split("|")
  end

  def learner_question_wise_report
    @learner = Learner.find_by_id(params[:id])
    @test_details = @learner.test_details
    @assessment = @learner.assessment
  end

  def get_twenty_fifth_percentile(current_assessment)
    return twenty_fifth_percentile
  end

  def get_median(current_assessment)
    return median
  end

  def get_seventy_fifth_percentile(current_assessment)
    return seventy_fifth_percentile
  end

  def get_standard_deviation(learners)
    scores = get_sorted_scores_for_learners(learners)
    mean = get_mean(scores)
    variance = get_variance(scores,mean)
    standard_deviation = Math.sqrt(variance)
    return standard_deviation.round(2)
  end

  def get_mean(scores)
    mean = scores.reduce(:+).to_f / scores.length
    return mean.round(2)
  end

  # standard_deviation = (sum of (score - mean)^2)/no. of values in list
  def get_variance(scores,mean)
    difference_square_array = Array.new
    scores.each do |score|
      difference = score - mean
      difference_square = difference * difference
      difference_square_array << difference_square
    end
    sum_of_difference_squares = difference_square_array.reduce(:+).to_f
    variance = sum_of_difference_squares/scores.length
    return variance.round(2)
  end

  def topic_wise_ranking

  end

  def proavenues_groupwise_numbers
    groups = Group.find_all_by_user_id(current_user.id)
    @a = Assessment.find(params[:id])
    groups.each do |g|
      learners = Learner.find_all_by_group_id_and_assessment_id(g.id,params[:id],:conditions => 'lesson_status = "completed"')
      if learners.count != 0
        @c = learners.count
        @g = g.group_name
      end
    end
  end

  def question_analysis_report
    @assessment = Assessment.find(params[:id], :include => :test_details)
    @test_details = @assessment.test_details
    @learners = @assessment.learners.where('lesson_status != "not attempted"').order(:id)
    @learner_limit = (@learners.count * 0.27).round
    upper_group = @assessment.learners.where('lesson_status != "not attempted"').order('rank').limit(@learner_limit).pluck(:id)
    lower_group = @assessment.learners.where('lesson_status != "not attempted"').order('rank desc').limit(@learner_limit).pluck(:id)
    @upper_group_test_details = TestDetail.where(:learner_id => upper_group)
    @lower_group_test_details = TestDetail.where(:learner_id => lower_group)
  end

  def download_report
    assessment = Assessment.find(params[:id])
    generate_csv_file(params[:csv_string],"QuestionAnalysis-"+assessment.name)
  end

  def learner_test_status
    @current_learner = Learner.find(params[:id])
    @assessment = @current_learner.assessment
    @chart_data = []
    @correct_answers = 'correct'
    @wrong_answers = 'wrong'
    @total_attempted = TestDetail.where(:learner_id => @current_learner.id,:attempted_status => "answered").length
    @no_of_correct_answers = TestDetail.where(:learner_id => @current_learner.id,:answer_status => "correct").length
    @no_of_wrong_answers = TestDetail.where(:learner_id => @current_learner.id,:answer_status => "wrong").length
    @maq_questions_count = TestDetail.where(:learner_id => @current_learner.id,:question_type => "MAQ").length
    @total = @no_of_correct_answers + @no_of_wrong_answers
    @chart_data<<{:status=>@correct_answers,:number=>@no_of_correct_answers}
    @chart_data<<{:status=>@wrong_answers,:number=>@no_of_wrong_answers}
    @chart_data<<{:total=>@total}
    if @assessment.assessment_type == "multiple"
      @question_bank_ids = TestDetail.where(:learner_id => @current_learner.id).pluck(:question_bank_id).uniq
    end
  end

  def create_report
    @structure_component = StructureComponent.find(params[:id])
    @report_templates = ReportTemplate.where(:for_whom => "learner")
    @assessment = Assessment.find(@structure_component.assessment_id)
  end

  def save_report
    @structure_component = StructureComponent.find(params[:id])
    @report = Report.find_by_structure_component_id(params[:id])
    if @report.nil?
      @report = Report.new
      @report.assessment_id = @structure_component.assessment_id
      @report.tenant_id = @structure_component.tenant_id
      @report.structure_component_id = @structure_component.id
      @report.report_template_id = params[:template].to_i
      @report.for_whom = "learner"
      @report.save
    else
      @report.update_attribute(:report_template_id, params[:template].to_i)
    end
    @structure_component.update_attribute(:is_saved, "true")
    redirect_to("/structure_components/create_structure/#{@structure_component.assessment_id}")
  end  

end