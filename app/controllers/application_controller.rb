require 'aws/ses'

class ApplicationController < ActionController::Base
  #  protect_from_forgery
  include AuthenticatedSystem
  #  include ExceptionLoggable
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    redirect_to root_url
  end

  def courses_index
    if current_user.typeofuser == "admin" then
      case(params[:filter_by])
      when "Courses"
        @user_courses = sort_courses(params[:sort_by])
      when "Assessments"
        @user_assessments = sort_assessments(params[:sort_by])
      when "Packages"
        @packages = sort_packages(params[:sort_by])
      else
        @user_courses = sort_courses(params[:sort_by])
        @user_assessments = sort_assessments(params[:sort_by])
        @packages = sort_packages(params[:sort_by])
      end
    end
  end


  def sort_packages(sort_by)
    case(sort_by)
    when "Alphabetical" then
      packages = current_user.packages.order("name")
    when "Date Wise Ascending" then
      packages = current_user.packages.order("id")
    else
      packages = current_user.packages.order("id DESC")
    end
    return packages
  end

  def sort_assessments(sort_by)
    case(sort_by)
    when "Alphabetical" then
      assessments = current_user.assessments.order("name")
    when "Date Wise Ascending" then
      assessments = current_user.assessments.order("id")
    else
      assessments = current_user.assessments.order("id DESC")
    end
    return assessments
  end

  def sort_courses(sort_by)
    case(sort_by)
    when "Alphabetical" then
      user_courses = current_user.courses.find(:all, :conditions => "size > 0", :order => "course_name")
    when "Date Wise Ascending" then
      user_courses = current_user.courses.find(:all, :conditions => "size > 0", :order => "id")
    else
      user_courses = current_user.courses.find(:all, :conditions => "size > 0", :order => "id DESC")
    end
    return user_courses
  end

  #checks if the current tenant is expired or not. If expired then reirect him to my_account page where he can upgrade his plan. This method is called in before_filter in almost all controllers
  def is_expired?
    tenant = Tenant.find_by_custom_url(request.subdomain)
    if tenant.is_expired == "true" then
      if current_user.typeofuser == "admin" then
        redirect_to("/my_account")
      end
    end
  end

  #This method invokes send_email method of aws-ses.Here AWS_SES is a dynamic constant (object) created aws-ses(check config/environments/prod.rb)
  #Any exception raised due to any reson is been handled with rescue. This method returns true if mail is sent successfully else returns false.
  #It will catch the following exceptions. Check the lin http://docs.amazonwebservices.com/ses/latest/APIReference/
  def aws_ses_send_email(user,subject,html_body)
    begin
      #creates qouta object to find out the max_24_hour_send and already sent in sent_last_24_hours.
      getsendquota_obj = AWS_SES.quota
      max_24_hour_send_limit = getsendquota_obj.max_24_hour_send.to_i
      sent_last_24_hours = getsendquota_obj.sent_last_24_hours.to_i

      # How many e-mails you can send per second
      #getsendquota_obj.max_send_rate
      #calculate available_limit at this point of time
      available_limit = max_24_hour_send_limit - sent_last_24_hours

      #if available_limit is greater than 1 only send the mail else
      if available_limit >= 1 then
        res_aws = AWS_SES.send_email :to => user, :source => '"LionSher" <team@lionsher.com>', :subject => subject, :html_body => html_body
        return "success"
      else
        return "Available Mail Limit Exceeded. Try later."
      end
    rescue AWS::SES::ResponseError => exception
      return exception
    end
  end

  #Takes assessment/course object as input and remove those learners from learners table who have been bounced
  def remove_bounced_from_learners(assessment_course)
    bounced_learners = current_user.user.find(:all,:conditions => "is_bounced = 1 AND crypted_password IS NULL")
    unless bounced_learners.nil? then
      bounced_learners.each{ |learner|
        unless assessment_course.learners.find_by_user_id_and_type_of_test_taker(learner.id,"learner").nil? then
          assessment_course.learners.find_by_user_id(learner.id).update_attribute(:active,"no")
        end
      }
    end
  end

  #This method will validate if the admin is allowed to assign more learners based on his plan.
  #Here we have 2 if's becoz if the current_user is 'admin' and if he has taken assessment_only_plan then always return ture becoz he can assign unlimited num of learners
  #the other if is for buyers in course store whoses learnes are rendered frm buyersellers.
  def valid_assign(course_id,current_user)
    if current_user.typeofuser == "admin" then
      if current_user.tenant.pricing_plan.plan_group == "assessment_only_plan" then
        #uncomment the below code if we want to stop the admin while assigning only
        #        if current_user.tenant.remaining_learner_credit > 0 then
        #          return true
        #        else
        #          return false
        #        end
        return true
      else
        max_learners_to_be_assigned = current_user.tenant.pricing_plan.no_of_users
        total_leaners_assigned = current_user.user.find(:all,:conditions=>["deactivated_at IS ?",nil]).length

        if total_leaners_assigned <= max_learners_to_be_assigned
          return true
        else
          return false
        end
      end

    elsif current_user.typeofuser == "individual buyer" or current_user.typeofuser == "corporate buyer" then
      max_learners_to_be_assigned = BuyerSeller.find_by_course_id_and_buyer_user_id(course_id,current_user.id).no_of_license
      total_leaners_assigned = Learner.find_all_by_admin_id_and_course_id(current_user.id,course_id).length
      if total_leaners_assigned < max_learners_to_be_assigned - 1
        return true
      else
        return false
      end
    end
  end

  #called from start test method in assmt contro
  def valid_test_taking()
    if current_user.tenant.pricing_plan.plan_group == "assessment_only_plan" then
      if current_user.tenant.remaining_learner_credit > 0 then
        return true
      else
        return false
      end
    else
      return true
    end
  end

  #Decrements the remaining_learner_credit column when a learner gets assigned for a assessment
  def update_remaining_learner_credit()
    remaining_learner_credit = current_user.tenant.remaining_learner_credit
    new_remaining_learner_credit = remaining_learner_credit -1
    current_user.tenant.update_attribute(:remaining_learner_credit, new_remaining_learner_credit)
  end

  #control comes here to check for virus.It returns an integer value 0 if it is not virus affected else returns a non-zero value.
  #ClamAV is needed for this.
  def virus_scan(file_path)
    #    Two-to-three-upgrade-error
    #    clam = ClamAV.instance
    #    clam.loaddb()
    #    value = clam.scanfile(file_path)
    #    return value
    return 0
  end

  #control comes here to delete the uploaded file if it is virus affected.
  def remove_virus_affected_file(error_file_path,basepath)
    File.open(error_file_path, "w+") { |f| f.write("virus") }
    @course.destroy
    FileUtils.rm_r basepath
  end

  #BOUNCES is object SendgridToolkit::Bounces module(check sendgrid web API)(check /config/environments/development.rb and production.rb)
  def send_grid_mail_bounces
    #get the parsed_response from sendgrid and store in all_bounces variable
    all_bounces = BOUNCES.retrieve.parsed_response
    all_bounces.each { |bounce|
      #for each bounce which gives the email id which was bounced, find it from User table and make :is_bounced column true
      email = bounce.values_at("email")[0]
      user = User.find_by_email(email)
      unless user.nil? then
        if user.crypted_password.nil? then
          user.update_attribute(:is_bounced, true)
          BOUNCES.delete :email => email
        end
      end
    }
  end

  #checks if the loggerin user is superuser i.e lionsher's admin. If its admin then take him to /courses/index page elsif learner then take to /mycourses. This method is called from before_filter of few controllers
  def is_superuser?
    unless current_user.typeofuser == "superuser" then
      if current_user.typeofuser == "admin" then
        redirect_to("/courses")
      elsif current_user.typeofuser == "learner" then
        redirect_to("/mycourses")
      end
    end
  end

  def decrease_assessment_columns_while_deleting(assessment,learner)
    assessment.update_attribute(:total_learners, assessment.total_learners - 1)
    if ((learner.lesson_status != "not attempted") and assessment.no_of_attempted_learners >= 1)
      assessment.update_attribute(:no_of_attempted_learners, assessment.no_of_attempted_learners - 1)
    end
    case(learner.lesson_status)
    when "completed" then
      assessment.update_attribute(:completed_learners, assessment.completed_learners - 1)
      learner.user.update_attribute(:completed, learner.user.completed - 1)
    when "incomplete" then
      assessment.update_attribute(:incomplete_learners, assessment.incomplete_learners - 1)
      learner.user.update_attribute(:incomplete, learner.user.incomplete - 1)
    when "not attempted" then
      assessment.update_attribute(:unattempted_learners, assessment.unattempted_learners - 1)
      learner.user.update_attribute(:unattempted, learner.user.unattempted - 1)
    when "time up" then
      assessment.update_attribute(:timeup_learners, assessment.timeup_learners - 1)
      learner.user.update_attribute(:timeup, learner.user.timeup - 1)
    end
  end

  def increase_assessment_columns_while_assigning(assessment,learner)
    assessment.update_attribute(:total_learners, assessment.total_learners + 1)
    if ((learner.lesson_status != "not attempted") and assessment.no_of_attempted_learners >= 1)
      assessment.update_attribute(:no_of_attempted_learners, assessment.no_of_attempted_learners + 1)
    end
    assessment.assessment_status_based_updation(assessment,learner)
  end

  def decrease_course_columns_while_deleting(course,learner)
    course.update_attribute(:total_learners, course.total_learners - 1)
    case(learner.lesson_status)
    when "completed" then
      course.update_attribute(:completed_learners, course.completed_learners - 1)
      learner.user.update_attribute(:completed, learner.user.completed - 1)
    when "incomplete" then
      course.update_attribute(:incomplete_learners, course.incomplete_learners - 1)
      learner.user.update_attribute(:incomplete, learner.user.incomplete - 1)
    when "not attempted" then
      course.update_attribute(:unattempted_learners, course.unattempted_learners - 1)
      learner.user.update_attribute(:unattempted, learner.user.unattempted - 1)
    when "time up" then
      course.update_attribute(:timeup_learners, course.timeup_learners - 1)
      learner.user.update_attribute(:timeup, learner.user.timeup - 1)
    end
  end

  def increase_course_columns_while_assigning(course,learner)
    course.update_attribute(:total_learners, course.total_learners + 1)
    course_status_based_updation(course,learner)
  end

  def course_status_based_updation(course,learner)
    case(learner.lesson_status)
    when "completed" then
      course.update_attribute(:completed_learners, course.completed_learners + 1)
      learner.user.update_attribute(:completed, learner.user.completed + 1)
    when "incomplete" then
      course.update_attribute(:no_of_attempted_learners,course.no_of_attempted_learners + 1)
      course.update_attribute(:incomplete_learners, course.incomplete_learners + 1)
      learner.user.update_attribute(:incomplete, learner.user.incomplete + 1)
    when "not attempted" then
      course.update_attribute(:unattempted_learners, course.unattempted_learners + 1)
      learner.user.update_attribute(:unattempted, learner.user.unattempted + 1)
    when "time up" then
      course.update_attribute(:timeup_learners, course.timeup_learners + 1)
      learner.user.update_attribute(:timeup, learner.user.timeup + 1)
    end
  end

  def delete_assessment_dependencies(assessment)
    # learners contains all learner objects for current assessment
    #    learners = Learner.find_all_by_assessment_id(params[:id])
    if (!(assessment.learners.nil? or assessment.learners.blank?))
      assessment.learners.each do | learner |
        decrease_assessment_columns_while_deleting(assessment,learner)
        learner.destroy
      end
    end
    #    # below code is to delete all rows from assessments_question_banks table for corresponding assessment
    assessment.assessments_question_banks.each do |assessment_qb|
      assessment_qb.destroy
    end
    # below code is to delete all rows from demographics table for corresponding assessment
    if (!(assessment.demographics.nil? or assessment.demographics.blank?))
      assessment.demographics.destroy
    end
    # below code is to delete all rows from descriptive_answers table for corresponding assessment
    if (!(assessment.descriptive_answers.nil? or assessment.descriptive_answers.blank?))
      assessment.descriptive_answers.each do |dtq|
        dtq.destroy
      end
    end
    assessment.destroy
  end

  def create_assessment_question_mapping(assessment,question,positive_mark,negative_mark)
    logger.info"in create_assessment_question_mapping"
    obj_assessment_question = AssessmentQuestion.find_by_assessment_id_and_question_id(assessment.id,question.id)
    if obj_assessment_question.nil? or obj_assessment_question.blank?
      obj_assessment_question = AssessmentQuestion.new()      
      obj_assessment_question.assessment_id = assessment.id
      obj_assessment_question.question_id = question.id
      obj_assessment_question.mark = assessment.check_if_integer_or_float(positive_mark.to_f)
      obj_assessment_question.negative_mark = assessment.check_if_integer_or_float(negative_mark.to_f)
      obj_assessment_question.save      
    end
    return obj_assessment_question
  end

  def edit_assessment_question_mapping(assessment,question,positive_mark,negative_mark)
    logger.info"in edit_assessment_question_mapping"
    obj_assessment_question = AssessmentQuestion.find_by_assessment_id_and_question_id(assessment.id,question.id)
    unless obj_assessment_question.nil? or obj_assessment_question.blank?
      obj_assessment_question.update_attribute(:mark, assessment.check_if_integer_or_float(positive_mark.to_f))
      obj_assessment_question.update_attribute(:negative_mark, assessment.check_if_integer_or_float(negative_mark.to_f))
    else
      obj_assessment_question = AssessmentQuestion.new()      
      obj_assessment_question.assessment_id = assessment.id
      obj_assessment_question.question_id = question.id
      obj_assessment_question.mark = assessment.check_if_integer_or_float(positive_mark.to_f)
      obj_assessment_question.negative_mark = assessment.check_if_integer_or_float(negative_mark.to_f)
      obj_assessment_question.save      
    end
    return obj_assessment_question
  end

  # v2 related methods starts from here
  def create_answer(answer_text,question_id,tenant_id,question_bank_id,answer_status)
    answer = Answer.new
    answer.answer_text = answer_text
    answer.question_id = question_id
    answer.question_bank_id = question_bank_id
    answer.tenant_id = tenant_id
    answer.answer_status = answer_status
    answer.save
    return answer
  end

  # author: Surupa
  # Takes inputs as question text, question bank id, tenant id, question type and explanation to create one question and saves to database.
  def create_question(question_text,question_bank_id,tenant_id,question_type,explanation,direction_id,passage_id)
    question = Question.new
    question.question_text = question_text
    question.question_bank_id = question_bank_id
    question.tenant_id = tenant_id
    question.explanation = explanation
    question.question_type = question_type
    question.save
    question_attribute = create_question_attribute(question.id,"",question_bank_id,"","","",direction_id,passage_id,"","",tenant_id)
    question_attribute.update_attribute("difficulty_id",get_difficulty("not defined"))
    unless question_type.nil? or question_type.blank?
      question_type = QuestionType.find_by_value(question_type)
      question_attribute.update_attribute("question_type_id",question_type.id)
    end
    return question
  end

  # author: Surupa
  # Takes inputs as question id, and returns answer objects.
  # Return type is array of objects.
  def get_answers_for_question(question_id)
    answers = Array.new
    question = Question.find_by_id(question_id, :include => :answers)
    question.answers.each do |ans|
      answers << ans
    end
    return answers
  end

  # author: Surupa
  # Takes inputs as difficulty value, and returns difficulty object and return difficulty id.
  def get_difficulty(difficulty)
    difficulty = Difficulty.find_by_difficulty_value(difficulty.downcase)
    if difficulty.nil? or difficulty.blank?
      difficulty = Difficulty.find_by_difficulty_value("not defined")
    end
    return difficulty.id
  end

  def get_question(question_id)
    question = Question.find_by_id(question_id, :include => :answers)
    return question
  end

  def get_question_bank(question_bank_id)
    question_bank = QuestionBank.find(question_bank_id)
    return question_bank
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

  def create_image(image_name,image_content_type,image_file_size,question_id,answer_id)
    image = Image.new
    image.image_file_name = image_name
    image.image_content_type = image_content_type
    image.image_file_size = image_file_size
    image.question_id = question_id
    image.answer_id = answer_id
    image.save
  end

  # author: Surupa
  # Takes inputs as error text and tenant id to create one error and saves to database.
  def create_error(error_text,tenant_id)
    error = Error.find_by_error_text_and_tenant_id(error_text,tenant_id)
    if error.nil? or error.blank?
      error = Error.new
      error.error_text = error_text
      error.tenant_id = tenant_id
      error.save
    end
    return error
  end

  # author: Surupa
  # Takes inputs as direction text, question id and tenant id to create one direction and saves
  # to database. Return type is object.
  def create_direction(direction_text,question_bank_id,tenant_id)
    direction = Direction.find_by_direction_text_and_question_bank_id(direction_text,question_bank_id)
    if direction.nil? or direction.blank?
      direction = Direction.new
      direction.direction_text = direction_text
      direction.question_bank_id = question_bank_id
      direction.tenant_id = tenant_id
      direction.save
    end
    return direction
  end

  # author: Surupa
  # Takes inputs as passage text and tenant id to create one passage, saves to database
  # and returns passage object.
  def create_passage(passage_text,question_bank_id,tenant_id)
    passage = Passage.find_by_passage_text_and_question_bank_id(passage_text,question_bank_id)
    if passage.nil? or passage.blank?
      passage = Passage.new
      passage.passage_text = passage_text
      passage.question_bank_id = question_bank_id
      passage.tenant_id = tenant_id
      passage.save
    end
    return passage
  end

  # author: Surupa
  # Takes inputs as question id to create one question attribute and saves to database.
  # Returns question attribute object
  def create_question_attribute(question_id,question_type_id,question_bank_id,topic_id,subtopic_id,difficulty_id,direction_id,passage_id,error_id,question_status_id,tenant_id)
    question_attribute = QuestionAttribute.find_by_question_id(question_id)
    if question_attribute.nil?
      question_attribute = QuestionAttribute.new
      question_attribute.question_id = question_id
      question_attribute.question_type_id = question_type_id
      question_attribute.question_bank_id = question_bank_id
      question_attribute.topic_id = topic_id
      question_attribute.subtopic_id = subtopic_id
      question_attribute.difficulty_id = difficulty_id
      question_attribute.direction_id = direction_id
      question_attribute.passage_id = passage_id
      question_attribute.error_id = error_id
      question_attribute.question_status_id = question_status_id
      question_attribute.tenant_id = tenant_id
      question_attribute.save
    end
    return question_attribute
  end

  # author: Surupa
  # Takes inputs as question bank name, tenant id and user id to create one question bank and saves to database.
  # And it returns question bank id.
  def create_question_bank(question_bank_name,tenant_id,user_id)
    question_bank = QuestionBank.find_by_name_and_tenant_id(question_bank_name,tenant_id)
    if question_bank.nil? or question_bank.blank?
      question_bank = QuestionBank.new
      question_bank.name = question_bank_name
      question_bank.type_of_question_bank = ""
      question_bank.tenant_id = tenant_id
      question_bank.user_id = user_id
      question_bank.save
    end
    return question_bank.id
  end

  # author: Surupa
  # Takes inputs as topic name, tenant id to create one topic and saves to database.
  def create_topic(topic_name,question_bank_id,tenant_id)
    topic = Topic.find_by_name_and_question_bank_id(topic_name,question_bank_id)
    if topic.nil? or topic.blank?
      topic = Topic.new
      topic.name = topic_name
      topic.question_bank_id = question_bank_id
      topic.tenant_id = tenant_id
      topic.save
    end
    return topic
  end

  # author: Surupa
  # Takes inputs as subtopic name, tenant id to create one subtopic and saves to database.
  def create_subtopic(subtopic_name,topic_id,question_bank_id,tenant_id)
    subtopic = Subtopic.find_by_name_and_topic_id_and_question_bank_id(subtopic_name,topic_id,question_bank_id)
    if subtopic.nil? or subtopic.blank?
      subtopic = Subtopic.new
      subtopic.name = subtopic_name
      subtopic.topic_id = topic_id
      subtopic.question_bank_id = question_bank_id
      subtopic.tenant_id = tenant_id
      subtopic.save
    end
    return subtopic
  end

  # author: Surupa
  # Takes inputs as direction id, and returns direction object.
  # Return type is object.
  def get_direction(direction_id)
    direction = Direction.find_by_id(direction_id)
    return direction
  end

  # author: Surupa
  # Takes inputs as error value, and returns error object and return error id.
  def get_error(error_text,tenant_id)
    error = Error.find_by_error_text_and_tenant_id(error_text.downcase,tenant_id)
    if error.nil? or error.blank?
      error = create_error(error_text.downcase,tenant_id)
    end
    return error.id
  end

  # author: Surupa
  # Takes inputs as question id, and returns question attribute object.
  # Return type is object.
  def get_question_attribute(question_id)
    question_attribute = QuestionAttribute.find_by_question_id(question_id)
    return question_attribute
  end

  # author: Surupa
  # Takes inputs as question type value, and returns question type object.
  # Return type is object.
  def get_question_type(value)
    logger.info"get_question_type value #{value.inspect}"
    question_type = QuestionType.find_by_value(value)
    return question_type
  end

  def send_question_to_another_question_bank(question_id,new_question_bank_id,tenant_id)
    question_attribute = get_question_attribute(question_id)
    topic = create_topic(question_attribute.topic.name,new_question_bank_id,tenant_id)
    subtopic = create_subtopic(question_attribute.subtopic.name,new_question_bank_id,tenant_id)
    question_attribute.update_attribute("question_bank_id",new_question_bank_id)
    question_attribute.update_attribute("topic_id",topic.id)
    question_attribute.update_attribute("subtopic_id",subtopic.id)
  end

  def get_question_attributes_for_tagvalues(assessment_rule,tagvalue_ids)
    logger.info"TAGVALUES >>>> #{tagvalue_ids.inspect}"
    question_bank_id,difficulty_id,question_type_id = get_all_question_related_table_ids(assessment_rule)
    logger.info"question_bank_ids after get_all #{question_bank_id.inspect}"
    logger.info"difficulty_ids after get_all #{difficulty_id.inspect}"
    logger.info"question_type_ids after get_all #{question_type_id.inspect}"
    question_ids_for_assessment_rule = QuestionAttribute.where("question_bank_id in (?) AND difficulty_id in (?) AND question_type_id in (?)",question_bank_id,difficulty_id,question_type_id).pluck(:question_id)
    logger.info"question_ids_for_assessment_rule #{question_ids_for_assessment_rule.inspect}"
    unless tagvalue_ids.nil? or tagvalue_ids.blank?
      question_ids_for_tagvalues = QuestionTag.where(:tagvalue_id => tagvalue_ids).group(:question_id).having("COUNT(tagvalue_id)=?",tagvalue_ids.length).pluck(:question_id)
    else
      tagvalue_ids = Tagvalue.pluck(:id)
      question_ids_for_tagvalues = QuestionTag.where(:tagvalue_id => tagvalue_ids).pluck(:question_id)
    end
    logger.info"question_ids_for_tagvalues #{question_ids_for_tagvalues.inspect}"
    question_ids = question_ids_for_assessment_rule & question_ids_for_tagvalues
    logger.info"QUESTION IDS #{question_ids.uniq.inspect}"
    question_attributes = QuestionAttribute.where(:question_id => question_ids.uniq).includes({:question => :answers})
    logger.info"QUESTION ATTRIBUTES #{question_attributes.inspect}"
    return question_attributes
  end

  def get_all_question_related_table_ids(assessment_rule)
    logger.info"assessment_rule.question_bank #{assessment_rule.question_bank.inspect}"
    if assessment_rule.question_bank.nil?
      question_bank_id = get_all_question_bank_ids(assessment_rule.tenant_id)
    else
      question_bank_id = assessment_rule.question_bank_id
    end
    if assessment_rule.difficulty.nil?
      difficulty_id = get_all_difficulty_ids(assessment_rule.tenant_id)
    else
      difficulty_id = assessment_rule.difficulty_id
    end
    if assessment_rule.question_type.nil?
      question_type_id = get_all_question_type_ids(assessment_rule.tenant_id)
    else
      question_type_id = assessment_rule.question_type_id
    end
    return [question_bank_id,difficulty_id,question_type_id]
  end

  def get_all_question_bank_ids(tenant_id)
    question_bank_ids = QuestionBank.where(:tenant_id => tenant_id).pluck(:id)
    return question_bank_ids
  end

  def get_all_difficulty_ids(tenant_id)
    difficulty_ids = Difficulty.pluck(:id)
    return difficulty_ids
  end

  def get_all_question_type_ids(tenant_id)
    question_type_ids = QuestionType.pluck(:id)
    return question_type_ids
  end
  # v2 related methods ends here

  #Takes the csv string as input and gives csv as output
  def generate_csv_file(csv_string,assessment_name)
    variable_time = Time.now.strftime("%Y%m%d")
    #The file name is generated based on time.
    filename = assessment_name+variable_time+".csv"
    #invoke send_data of fastercsv gem to generate a csv
    send_data(csv_string, :type => "text/plain", :filename => filename)
  end

  def assign_first_course_or_assessment_for_coupon(coupon,user,admin_user)
    #check if the coupon is associated with single assessment. If so create learner details for that assessment to this learner
    if !coupon.assessment_id.nil?
      assessment_obj = AssessmentsController.new
      assessment_obj.store_learner_details(coupon.assessment,admin_user,user,"","learner")
      #check if the coupon is associated with single course. If so create learner details for that course to this learner
    elsif !coupon.course_id.nil?
      course_obj = CoursesController.new
      course_obj.store_learner_details(coupon.course,admin_user,user,"")
      #check if the coupon is associated with single package. If so create learner details for first assessment/course in that package to this learner
    elsif !coupon.package_id.nil?
      #get the associated package
      package_obj = coupon.package
      #get the first associated assessment_course for that package
      ass_course = package_obj.assessment_courses[0]
      #check if the assessment_course is assessment or course. If assessment then call store details method of assessment_controller else call store details method for courses_controller
      if ass_course.assessment_id.nil?
        course_obj = CoursesController.new
        course_obj.store_learner_details(ass_course.course,admin_user,user,coupon.package_id)
      elsif ass_course.course_id.nil?
        assessment_obj = AssessmentsController.new
        assessment_obj.store_learner_details(ass_course.assesment,admin_user,user,coupon.package_id,"learner")
      end
      #the below is previous code when packages was only for assessments which is no more use now
    elsif !coupon.assessment_package_id.nil?
      assessment_package_obj = coupon.assessment_package
      assessment_order_arr = assessment_package_obj.assessment_order.split(',')
      assmt_id = assessment_order_arr[0].to_i
      package_assessment_one = Assessment.find(assmt_id)
      assessment_obj = AssessmentsController.new
      assessment_obj.store_learner_details(package_assessment_one,admin_user,user,"","learner")
    end
  end

  # New report related methods starts here
  # Method to store all assessment related calculated data for reports
  def create_calculated_data_for_assessment(assessment_id,tenant_id)
    calculated_data_assessment = CalculatedDataAssessment.new
    calculated_data_assessment.assessment_id = assessment_id
    calculated_data_assessment.tenant_id = tenant_id
    calculated_data_assessment.save    
  end
  # New report related methods ends here

  private

  def local_request?
    false
  end
end