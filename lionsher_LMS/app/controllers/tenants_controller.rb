# TODO : Complete code reviewing, methods, file renaming, views
# Author : Surupa

class TenantsController < ApplicationController

  before_filter :login_required
  before_filter :is_superuser?

  def index
    @tenants = Tenant.find_all_by_is_expired("false", :conditions => ["organization not in (?) and pricing_plan_id != 4 and pricing_plan_id != 3 and pricing_plan_id != 11",'lionsher'], :order => "id desc")
    @total_count = @tenants.length
  end
  
  def all_tenants
    @tenants = Tenant.find(:all, :conditions => ["organization not in (?)",'lionsher'], :order => "id desc")
    @total_count = @tenants.length
  end

  def show_all_buyers
    @buyers = Tenant.find(:all, :conditions => "type_of_tenant = 'corporate buyer' OR type_of_tenant = 'individual buyer'")
    #    @buyers = Subscribe.find(:all, :conditions => "type_of_tenant = 'corporate buyer' OR type_of_tenant = 'individual buyer'")    # on production
  end

  def show_all_sellers
    @sellers = Tenant.find(:all, :conditions => "type_of_tenant = 'seller'")
    #    @sellers = Subscribe.find(:all, :conditions => "type_of_user = 'seller'")  # on production
  end

  def tenant_destroy
    tenant = Tenant.find(params[:id])
    learners = Learner.find_all_by_tenant_id(params[:id])
    user_learner = User.find_all_by_user_id(tenant.user_id)
    for user in user_learner
      user.destroy        #delete all learners from user table
    end
    courses = Course.find_all_by_user_id(tenant.user_id)
    courses.each { |c|
      if !c.image_file_name.nil? then
        image_url = "public/system/images/"+c.id.to_s
        FileUtils.rm_r image_url
      end
      FileUtils.rm_r c.path
      c.destroy
    }
    assessments = Assessment.find_all_by_user_id(tenant.user_id)
    question_banks = QuestionBank.find_all_by_user_id(tenant.user_id)
    assessments.each { |a|
      assessment = Assessment.find_by_id(a.id)
      if assessment.assessment_type == "single"
        question_bank_id = assessment.qb_limit.split('-')[0]
        destroy_questions(question_bank_id)
      else
        qb_limit = assessment.qb_limit.split(',')
        qb_limit.each { |qb|
          qb_lim_arr = Array.new
          qb_lim_arr << qb.split("-")
          destroy_questions(qb_lim_arr[0][0].to_i)
        }
      end
    }
    question_banks.each { |qb| qb.destroy}
    learners.each { |l| l.destroy}  #delete all learners from learner table    
    tenant.destroy
    redirect_to('/tenants')
  end

  def user_details
    @tenant = Tenant.find_by_user_id(params[:id])
    @user = User.find_by_id(params[:id])
    @learners = User.find_all_by_user_id_and_typeofuser(@user.id, "learner", :order => "id desc")
  end

  def course_details
    @user = User.find_by_id(params[:id])
    @learners = Learner.find_all_by_user_id_and_active(params[:id],"yes", :conditions => "type_of_test_taker = 'learner'")
  end

  def all_courses
    @user = User.find_by_id(params[:id])
    @courses = Course.find_all_by_user_id(params[:id], :conditions => "size != 0", :order => "id desc")
    @assessments = Assessment.find_all_by_user_id(params[:id], :order => "id desc", :conditions => "no_of_questions > 0")
  end

  def user_destroy
    user = User.find_by_id(params[:id])    
    if user.user_id.nil? then
      user_id = user.id
    else
      user_id = user.user_id
    end
    if user.typeofuser != "admin"
      learners = Learner.find_all_by_user_id(params[:id])
      learners.each { |l| l.destroy }
      user.destroy
    end
    redirect_to('/tenants/user_details/'+user_id.to_s)
  end
  
  def course_destroy
    course = Course.find_by_id(params[:id])
    learners = Learner.find_all_by_course_id(course.id)
    learners_id = ""
    user = User.find_by_id(course.user_id)
    if !course.image_file_name.nil? then
      image_url = "public/system/images/"+course.id.to_s
      FileUtils.rm_r image_url
    end
    if (!learners.nil?) and (!learners.blank?)  then
      learners.each { |l|
        learners_id = l.user_id
        l.destroy           #delete all learners from learner table for corresponding course
      }
    end
    if !course.path.nil? or !course.path.blank? then
      FileUtils.rm_r course.path
    end
    course.destroy
    if learners_id.nil? or learners_id.blank? then
      redirect_to('/tenants/all_courses/'+user.id.to_s)
    else
      redirect_to('/tenants/course_details/'+learners_id.to_s)
    end
  end

  def assessment_destroy
    assessment = Assessment.find_by_id(params[:id])
    user = User.find_by_id(assessment.user_id)
    if assessment.assessment_type == "single"
      question_bank_id = assessment.qb_limit.split('-')[0]
      destroy_questions(question_bank_id)      
    else
      qb_limit = assessment.qb_limit.split(',')
      qb_limit.each { |qb|
        qb_lim_arr = Array.new
        qb_lim_arr << qb.split("-")
        destroy_questions(qb_lim_arr[0][0].to_i)        
      }
    end
    learners = Learner.find_all_by_assessment_id(params[:id])
    learners.each do | learner |
      learner.destroy
    end
    assessment.destroy
    redirect_to('/tenants/all_courses/'+user.id.to_s)
  end

  def destroy_questions(question_bank_id)
    questions = Question.find_all_by_question_bank_id(question_bank_id)
    questions.each do | q |
      if !(q.nil? or q.blank?)
        if !q.question_image_file_size.nil? and q.question_image_file_size > 0 then
          image_url = "public/system/question_images/"+q.id.to_s
          FileUtils.rm_r image_url
        end
        if q.question_type == "MTF"
          mtf_options = Question.find_all_by_mtf_id(q.id)
          mtf_options.each {|mq|
            answer = Answer.find_by_question_id(mq.id)
            answer.destroy
            mq.destroy
          }
          q.destroy
        elsif q.question_type == "PTQ"
          ptq_question = Question.find_by_id(q.id)
          ptq_sub_questions = Question.find_all_by_mtf_id(q.id)
          ptq_sub_questions.each do | question |
            answers = Answer.find_all_by_question_id(question.id)
            answers.each { |a| a.destroy}
            question.destroy
          end
          ptq_question.destroy
        else
          answers = Answer.find_all_by_question_id(q.id)
          answers.each { |a| a.destroy}
          q.destroy
        end
      end
    end
  end

  def destroy_all_courses
    courses = Course.find_all_by_user_id(params[:id])
    user = User.find_by_id(params[:id])
    if (!courses.nil?) and (!courses.blank?)  then
      courses.each { |c| 
        learners = Learner.find_all_by_course_id(c.id)
        if (!learners.nil?) and (!learners.blank?)  then
          learners.each { |l|
            l.destroy           #delete all learners from learner table for corresponding course
          }
        end
        if !c.image_file_name.nil? then
          image_url = "public/system/images/"+c.id.to_s
          FileUtils.rm_r image_url
        end
        if !c.path.nil? and !c.path.blank? then
          FileUtils.rm_r c.path
        end
        c.destroy 
      }
    end
    redirect_to('/'+params[:tenant]+'/users/'+user.id.to_s)
  end

  def destroy_all_learners
    learners_of_admin = User.find_all_by_user_id(params[:id], :conditions => "typeofuser = 'learner'")
    learner_mappings = Learner.find_all_by_admin_id(params[:id], :conditions => "type_of_test_taker = 'learner'")
    user = User.find_by_id(params[:id])
    if (!learner_mappings.nil?) and (!learner_mappings.blank?)  then
      learner_mappings.each { |l|
        l.destroy             #delete all mappings from learner table for corresponding admin
      }
    end
    if (!learners_of_admin.nil?) and (!learners_of_admin.blank?)  then
      learners_of_admin.each { |l|
        l.destroy             #delete all learners from user table for corresponding admin
      }
    end
    redirect_to('/tenants/user_details/'+user.id.to_s)
  end


  def null_courses
    @null_courses = Course.find(:all, :conditions => 'size = 0', :order => "id DESC")
    @null_assessments = Assessment.find(:all, :conditions => 'no_of_questions IS NULL', :order => "id DESC")
  end

  def destroy_null_courses
    null_courses = Course.find(:all, :conditions => 'size = 0', :order => "id DESC")
    null_assessments = Assessment.find(:all, :conditions => 'no_of_questions IS NULL', :order => "id DESC")
    if (!null_courses.nil?) and (!null_courses.blank?)  then
      null_courses.each { |c|
        if !c.image_file_name.nil? then
          image_url = "public/system/images/"+c.id.to_s
          FileUtils.rm_r image_url
        end
        if !c.path.nil? and !c.path.blank? then
          FileUtils.rm_r c.path          
        end
        c.destroy
      }
    end
    if (!null_assessments.nil?) and (!null_assessments.blank?)  then
      null_assessments.each { |a|
        a.destroy
      }
    end
    redirect_to("/tenants/null_courses/#{current_user.id}")
  end  

  def free_trial_tenants
    @tenants = Tenant.find_all_by_is_expired("false", :conditions => ["organization not in (?) and pricing_plan_id = 4",'lionsher'], :order => "id desc")
    @total_count = @tenants.length
  end

  def expired_tenants
    @tenants = Tenant.find_all_by_is_expired("true", :conditions => ["organization not in (?)",'lionsher'], :order => "id desc")
    @total_count = @tenants.length
  end

  def tenant_user_details
    #    @tennat_users = SELECT users.login,users.email,users.typeofuser,tenants.organization,tenants.custom_url from users,tenants where users.user_id=tenants.user_id order by tenants.custom_url
  end

  # temporary code starts from here

  def fill_assessment_table_with_learner_details
    tenants = Tenant.find(:all, :conditions => ["organization not in (?)",'lionsher'])
    for tenant in tenants
      assessments = Assessment.find_all_by_user_id(tenant.user_id)
      for a in assessments
        current_learner = Learner.find_by_admin_id_and_assessment_id_and_type_of_test_taker(tenant.user_id,a.id,"admin")
        if !(current_learner.nil? or current_learner.blank?)
          a.update_attribute(:current_learner_id,current_learner.id)
        end
        #          if a.total_learners.nil? or a.total_learners.blank?
        total = Learner.find_all_by_assessment_id_and_active(a.id,"yes", :conditions => "type_of_test_taker = 'learner'")
        a.update_attribute(:total_learners,total.length)
        #          end
        #        if a.no_of_attempted_learners.nil? or a.no_of_attempted_learners.blank?
        attempted = Learner.find_all_by_assessment_id_and_active(a.id,"yes", :conditions => "lesson_status != 'not attempted' AND type_of_test_taker = 'learner'")
        a.update_attribute(:no_of_attempted_learners,attempted.length)
        #        end
        #        if a.completed_learners.nil? or a.completed_learners.blank?
        completed = Learner.find_all_by_assessment_id_and_active(a.id,"yes", :conditions => "lesson_status = 'completed' AND type_of_test_taker = 'learner'")
        a.update_attribute(:completed_learners,completed.length)
        #        end
        #        if a.incomplete_learners.nil? or a.incomplete_learners.blank?
        incomplete = Learner.find_all_by_assessment_id_and_active(a.id,"yes", :conditions => "lesson_status = 'incomplete' AND type_of_test_taker = 'learner'")
        a.update_attribute(:incomplete_learners,incomplete.length)
        #        end
        #        if a.unattempted_learners.nil? or a.unattempted_learners.blank?
        unattempted = Learner.find_all_by_assessment_id_and_active(a.id,"yes", :conditions => "lesson_status = 'not attempted' AND type_of_test_taker = 'learner'")
        a.update_attribute(:unattempted_learners,unattempted.length)
        #        end
        #        if a.timeup_learners.nil? or a.timeup_learners.blank?
        timeup = Learner.find_all_by_assessment_id_and_active(a.id,"yes", :conditions => "lesson_status = 'time up' AND type_of_test_taker = 'learner'")
        a.update_attribute(:timeup_learners,timeup.length)
        #        end
      end
    end
    flash[:executed] = "Method Executed."
    redirect_to('/tenants/method_executed/'+current_user.id.to_s)
  end

  def fill_course_table_with_learner_details
    tenants = Tenant.find(:all, :conditions => ["organization not in (?)",'lionsher'])
    for tenant in tenants
      courses = Course.find_all_by_user_id(tenant.user_id)
      for c in courses
        if c.total_learners.nil? or c.total_learners.blank?
          total = Learner.find_all_by_course_id_and_active(c.id,"yes")
          c.update_attribute(:total_learners,total.length)
        end
        if c.completed_learners.nil? or c.completed_learners.blank?
          completed = Learner.find_all_by_course_id_and_lesson_status_and_active(c.id,'completed',"yes")
          c.update_attribute(:completed_learners,completed.length)
        end
        if c.incomplete_learners.nil? or c.incomplete_learners.blank?
          incomplete = Learner.find_all_by_course_id_and_lesson_status_and_active(c.id,'incomplete',"yes")
          c.update_attribute(:incomplete_learners,incomplete.length)
        end
        if c.unattempted_learners.nil? or c.unattempted_learners.blank?
          unattempted = Learner.find_all_by_course_id_and_lesson_status_and_active(c.id,'not attempted',"yes")
          c.update_attribute(:unattempted_learners,unattempted.length)
        end
        if c.timeup_learners.nil? or c.timeup_learners.blank?
          timeup = Learner.find_all_by_course_id_and_lesson_status_and_active(c.id,'time up',"yes")
          c.update_attribute(:timeup_learners,timeup.length)
        end
        if !(c.completed_learners.nil? or c.completed_learners.blank?) and c.no_of_comments.nil? or c.no_of_comments.blank?
          comments = Array.new
          completed.each do |complete|
            comments << complete.comments
          end
          c.update_attribute(:no_of_comments,comments.length)
        end
        if (c.total_no_of_ratings.nil? or c.total_no_of_ratings.blank?) or (c.no_of_rating_records.nil? or c.no_of_rating_records.blank?) or (c.average_rating.nil? or c.average_rating.blank?)
          rating_records = Learner.find_all_by_course_id_and_lesson_status_and_active(c.id,'completed','yes',:conditions => "rating > 0")
          if !rating_records.nil? and rating_records.length > 0
            total = 0.0
            rating_records.each { |record| total += record.rating }
            count = rating_records.length
            avg_rating = 0
            if count > 0 and total > 0
              avg_rating = (total/count).round
            end
            c.update_attribute(:total_no_of_ratings,total)
            c.update_attribute(:no_of_rating_records,count)
            c.update_attribute(:average_rating,avg_rating)
          end
        end
      end
    end
    flash[:executed] = "Method Executed."
    redirect_to('/tenants/method_executed/'+current_user.id.to_s)
  end

  def fill_users_with_tenant_id
    tenants = Tenant.find(:all)
    for tenant in tenants
      users = User.find_all_by_user_id(tenant.user_id)
      for u in users
        if u.tenant_id.nil? or u.tenant_id.blank?
          u.update_attribute(:tenant_id, tenant.id)
        end
        if u.no_of_courses_assigned.nil? or u.no_of_courses_assigned.blank?
          courses = Learner.find_all_by_user_id_and_active(u.id,"yes",:conditions => "course_id is not NULL")
          u.update_attribute(:no_of_courses_assigned, courses.length)
        end
        if u.no_of_assessments_assigned.nil? or u.no_of_assessments_assigned.blank?
          assessments = Learner.find_all_by_user_id_and_active(u.id,"yes",:conditions => "assessment_id is not NULL AND type_of_test_taker = 'learner'")
          u.update_attribute(:no_of_assessments_assigned, assessments.length)
        end
        if u.completed.nil? or u.completed.blank?
          completed = Learner.find_all_by_user_id_and_lesson_status_and_active(u.id,'completed','yes',:conditions => "type_of_test_taker = 'learner'")
          u.update_attribute(:completed, completed.length)
        end
        if u.incomplete.nil? or u.incomplete.blank?
          incomplete = Learner.find_all_by_user_id_and_lesson_status_and_active(u.id,'incomplete','yes',:conditions => "type_of_test_taker = 'learner'")
          u.update_attribute(:incomplete, incomplete.length)
        end
        if u.unattempted.nil? or u.unattempted.blank?
          unattempted = Learner.find_all_by_user_id_and_lesson_status_and_active(u.id,'not attempted','yes',:conditions => "type_of_test_taker = 'learner'")
          u.update_attribute(:unattempted, unattempted.length)
        end
        if u.timeup.nil? or u.timeup.blank?
          timeup = Learner.find_all_by_user_id_and_lesson_status_and_active(u.id,'time up','yes',:conditions => "type_of_test_taker = 'learner'")
          u.update_attribute(:timeup, timeup.length)
        end
      end
    end
    flash[:executed] = "Method Executed."
    redirect_to('/tenants/method_executed/'+current_user.id.to_s)
  end

  def fill_assessment_question_banks_table
    tenants = Tenant.find(:all, :conditions => ["organization not in (?)",'lionsher'])
    for tenant in tenants
      users = User.find_all_by_user_id(tenant.user_id)
      for u in users
        u.question_banks.each{|qb|
          qb.questions.each{|q|
            q.answers.each{|ans|
              ans.update_attribute(:question_bank_id, qb.id)
            }
          }
        }
      end
    end
  end

  # temporary code ends here

  #find the current_smtp_setting and store in obj to use in its view page
  def smtp_account_settings
    @current_smtp_setting = SmtpSettings.find_by_is_active(1)
  end

  #save the new selected smtp settings is_active column to 1 and all others smtp_settings to 0
  def save_smtp_settings
    all_smtp_accounts = SmtpSettings.find(:all)
    all_smtp_accounts.each { |smtp_account|
      if smtp_account.name == params[:smpt_settings][:name] then
        smtp_account.update_attribute(:is_active, 1)
      else
        smtp_account.update_attribute(:is_active, 0)
      end
    }
    flash[:update_success] = "Updated successfully"
    redirect_to('/tenants/smtp_account_settings/'+current_user.id.to_s)
  end

  def method_executed
    
  end

  def put_test_pattern_id_for_existing_assessments
    tenants = Tenant.find(:all, :conditions => ["organization not in (?)",'lionsher'])
    for tenant in tenants
      assessments = Assessment.find_all_by_user_id(tenant.user_id)
      for a in assessments
        if a.test_pattern_id.nil? or a.test_pattern_id.blank?
          a.update_attribute(:test_pattern_id,1)
        end
      end
    end
  end

end