class PackagesController < ApplicationController
  before_filter :login_required

  #tempo method to migrate data from assessment_package table to package and coupon table

  def moving_data(assessment_package_id)
    assessment_package = AssessmentPackage.find(assessment_package_id)

    package = Package.new
    package.name = assessment_package.name
    package.tenant_id = assessment_package.tenant_id
    package.user_id = assessment_package.user_id
    package.save

    if !(assessment_package.assessment_order.nil?) and !(assessment_package.assessment_order.blank?)
      assessment_package.assessment_order.split(',').each { |ass|
        assessment_course = AssessmentCourse.new
        assessment_course.assessment_id = ass.to_i
        assessment_course.package_id = package.id
        assessment_course.user_id = assessment_package.user_id
        assessment_course.tenant_id = assessment_package.tenant_id
        assessment_course.save

        assessment = Assessment.find(ass.to_i)
        assessment.learners.each { |learner|
          learner.update_attribute(:package_id,package.id)
        }
      }
    else
      single_assessment = Assessment.find_by_assessment_package_id(assessment_package.id)
      unless single_assessment.id.nil?
        assessment_course = AssessmentCourse.new
        assessment_course.assessment_id = single_assessment.id
        assessment_course.package_id = package.id
        assessment_course.user_id = assessment_package.user_id
        assessment_course.tenant_id = assessment_package.tenant_id
        assessment_course.save

        single_assessment.learners.each { |learner|
          learner.update_attribute(:package_id,package.id)
        }
      end
    end
    assessment_package.coupons.each{|coupon|
      coupon.update_attribute(:package_id,package.id)
    }
   
  end

  #same method as for courses and assessments
  def schedule_package
    @package = Package.find(params[:id])
    time = Time.now.getutc
    convert_utc_time_to_system_time(time,@package.tenant)
    if @show_time.strftime("%p")=="AM"
      @hour = @show_time.hour
    elsif (@show_time.strftime("%p")=="PM" and @show_time.hour == 12) or (@show_time.strftime("%p")=="AM" and @show_time.hour == 0)
      @hour = 12
    else
      @hour = @show_time.hour - 12
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

  def save_package_schedule
    @package = Package.find(params[:id])
    @package.update_attributes(params[:package])
    package_schedule_details(@package)
    redirect_to "/courses"
  end

  def package_schedule_details(package)
    (params[:package].include? "reattempt")?package.update_attribute(:reattempt,"on"):package.update_attribute(:reattempt,"off")
    if params[:package][:schedule_type] == "open"
      open_schedule_calendar = params[:open][:start_schedule].split("-")
      start_date_time = time_conversions(open_schedule_calendar[2],open_schedule_calendar[1],open_schedule_calendar[0],params[:open][:hour],params[:open][:min],params[:open][:am_pm])
      end_date_time = start_date_time
    else
      fixed_start_schedule_calendar = params[:fixed_start][:start_schedule].split("-")
      start_date_time = time_conversions(fixed_start_schedule_calendar[2],fixed_start_schedule_calendar[1],fixed_start_schedule_calendar[0],params[:fixed_start][:hour],params[:fixed_start][:min],params[:fixed_start][:am_pm])
      fixed_end_schedule_calendar = params[:fixed_end][:start_schedule].split("-")
      end_date_time = time_conversions(fixed_end_schedule_calendar[2],fixed_end_schedule_calendar[1],fixed_end_schedule_calendar[0],params[:fixed_end][:hour],params[:fixed_end][:min],params[:fixed_end][:am_pm])
    end
    total_offset = calculate_total_offset(package.tenant)
    if package.tenant.zone.include? "+"
      start_time = start_date_time - total_offset
      end_time = end_date_time - total_offset
    else
      start_time = start_date_time + total_offset
      end_time = end_date_time + total_offset
    end
    package.update_attribute(:start_time,start_time)
    package.update_attribute(:end_time,end_time)
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

  #creates a new package and redirects to below url
  def create
    @package = Package.new(params[:package])
    @package.save
    redirect_to "/assessment_courses/new_assessment_course/#{@package.id}"
  end

  #calculate package object and takes to packages/manage_learners page
  def manage_learners
    @package = Package.find(params[:id])
  end


  # GET /packages
  # GET /packages.json
  def index
    @packages = Package.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @packages }
    end
  end

  # GET /packages/1
  # GET /packages/1.json
  def show
    @package = Package.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @package }
    end
  end

 #goes to new package
  def new
    @package = Package.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @package }
    end
  end

  # GET /packages/1/edit
  def edit
    @package = Package.find(params[:id])
  end

  

#updates the package after edition and then redirects to /courses page
  def update
    @package = Package.find(params[:id])
    @package.update_attributes(params[:package])
    redirect_to "/courses"
  end

 #deletes the package and deletes all its associations from other tables like assessment_courses, coupons(check package.rb)
  def destroy
    @package = Package.find(params[:id])
    @package.destroy
    redirect_to "/courses"
  end

  def preview_package
    @package = Package.find(params[:id])
  end

  #control comes here when admin selects groups in manage_learnes page of packages and clicks done.
  def manage_groups
    unless params[:group].nil?
      package = Package.find(params[:id])
      groups_to_be_assigned = params[:group]
      groups_assign(groups_to_be_assigned,package)
      flash[:wait_feedback] = "The learners are being assigned. The process will take some time. Please check later for the updated learner count."
    end
    redirect_to("/courses")
  end

  #this method takes array of group_ids for which learners have to be assigned. It calculates learners_for_course_adding and learners_valid_for_signup and pushes into delayed_jobs table.
  def groups_assign(groups_to_be_assigned,package)
    groups_delayed = Array.new
    groups_to_be_assigned.each { |g|
      groups_delayed << g[0].to_i
    }
    current_user_id = current_user.id
    #call calculate_delayed_group_learners method using delayedjob
    package_obj = PackagesController.new
    package_obj.delay.calculate_delayed_group_learners(groups_delayed,current_user_id,package.id)
  end

  #this method is called from groups_assign using delayed_job therefore this gets executed in background
  #this assigns the groups to the package
  def calculate_delayed_group_learners(groups_to_be_assigned,current_user_id,package_id)
    current_user = User.find(current_user_id)
    package = Package.find(package_id)
    groups_to_be_assigned.each { |g|
      #get all learners who belong to current group 'g'
      learners_for_package_adding = current_user.user.find(:all,:conditions => ["group_id = ? AND deactivated_at IS NULL",g])
      save_and_send_mails(learners_for_package_adding,current_user,package)
    }
  end

  #saves all details and sends package activation mail
  #if the first item in the package is assessment, then create obj for AssessmentController class and call store_leanrer_details of that class
  #else if the item is course then create obj for CoruseController class and call store_learner_detials of that class passing the required arguments
  #return the number of learners assigned for this package
  def save_and_send_mails(learners_for_package_adding,current_user,package_obj)
    assigned_count = 0
    unless learners_for_package_adding.nil? or learners_for_package_adding.blank? then
      ass_course = package_obj.assessment_courses[0]
      learners_for_package_adding.each { |learner|
        if valid_assign(package_obj.id,current_user)
          user_obj = UsersController.new
          if ass_course.assessment_id.nil?
            course_obj = CoursesController.new
            @learner_obj = Learner.find_by_course_id_and_user_id_and_type_of_test_taker_and_package_id(ass_course.course.id,learner.id,"learner",package_obj.id)
            if @learner_obj.nil? then
              course_obj.store_learner_details(ass_course.course,current_user,learner,package_obj.id)
              user_obj.package_send_activation_mail(learner,'signup_package_learner_notification',current_user.tenant,current_user)
              assigned_count = assigned_count + 1
            elsif !@learner_obj.nil? and @learner_obj.active == "no" then
              @learner_obj.update_attribute(:active,"yes")
              increase_course_columns_while_assigning(ass_course.course,@learner_obj)
              user_obj.package_send_activation_mail(learner,'signup_package_learner_notification',current_user.tenant,current_user)
              assigned_count = assigned_count + 1
            end            
          elsif ass_course.course_id.nil?
            assessment_obj = AssessmentsController.new
            @learner_obj = Learner.find_by_assessment_id_and_user_id_and_type_of_test_taker_and_package_id(ass_course.assessment.id,learner.id,"learner",package_obj.id)
            if @learner_obj.nil? then
              assessment_obj.store_learner_details(ass_course.assessment,current_user,learner,package_obj.id,"learner")
              user_obj.package_send_activation_mail(learner,'signup_package_learner_notification',current_user.tenant,current_user)
              assigned_count = assigned_count + 1
            elsif !@learner_obj.nil? and @learner_obj.active == "no" then
              @learner_obj.update_attribute(:active,"yes")
              increase_assessment_columns_while_assigning(ass_course.assessment,@learner_obj)
              user_obj.package_send_activation_mail(learner,'signup_package_learner_notification',current_user.tenant,current_user)
              assigned_count = assigned_count + 1
            end
          end
        end
      }
    end
    return assigned_count
  end 

  #calculates required objects for learners_in_group page. calculates totalleaners for that particular group in the system and total learners who are assigned to that package in that group
  def learners_in_group
    @package = Package.find(params[:id])
    @group = Group.find(params[:group_id])
    ass_course = @package.assessment_courses[0]
    if ass_course.course_id.nil?
      @assigned_learners = @package.learners.where("assessment_id = ? AND type_of_test_taker = 'learner' AND active = 'yes' AND group_id = ?",ass_course.assessment_id,params[:group_id])
    else
      @assigned_learners = @package.learners.where("course_id = ? AND type_of_test_taker = 'learner' AND active = 'yes' AND group_id = ?",ass_course.course_id,params[:group_id])
    end
    @total_learners = @group.users.find(:all, :include=> "user", :conditions=> ["user_id = ? AND deactivated_at IS NULL",current_user.id])
  end

  #comes from learners_in_groups page submit
  def manage
    @package = Package.find(params[:id])
    ass_course = @package.assessment_courses[0]

    if ass_course.course_id.nil?
      @assessment = Assessment.find(ass_course.assessment_id)
      for_assessment(@package,@assessment)
    else
      @course = Course.find(ass_course.course_id)
      for_course(@package,@course)
    end
  end

  #called from manage method if the first item in package is course. This method first checks if any learners have to be unassigned.
  # If there are any learners to be unassigned then update the learner.active = 'no' which will retain the learner record in the table but just he inactive for that course as his active attribute in learnes table is 'no'.
  def for_course(package,course)
    no_of_learners_to_be_deleted = 0
    remaining_learners_from_already_assigned = Array.new
    remaining_learners_from_already_assigned = find_remaining_learners_from_already_assigned()
    @learners = Learner.find_all_by_course_id_and_active(course.id,"yes", :conditions => ["type_of_test_taker != 'admin' AND group_id = ? AND package_id = ?",params[:group_id],package.id])
    existing_learners_ids = Array.new
    for learner in @learners
      existing_learners_ids << learner.user_id
    end
    learners_to_be_deleted = existing_learners_ids - remaining_learners_from_already_assigned
    for learner_id in learners_to_be_deleted
      no_of_learners_to_be_deleted += 1
      learner_make_inactive = Learner.find_by_user_id_and_course_id(learner_id,course.id, :conditions => ["type_of_test_taker != 'admin' AND group_id = ? AND package_id = ?",params[:group_id],package.id])
      learner_make_inactive.update_attribute(:active,"no")
      decrease_course_columns_while_deleting(course,learner_make_inactive)
    end
    learners_for_course_adding_ids = Array.new
    learners_for_course_adding_ids = learners_for_course_added_mails()
    learners_for_course_adding = Array.new
    learners_for_course_adding_ids.each {|user_id|
      learners_for_course_adding << User.find(user_id)
    }
   
    no_of_learners_assigned = 0
    # For the array of learners for whom the course has to be assigned, pass the array to save_and_send_mails
    no_of_learners_assigned += save_and_send_mails(learners_for_course_adding,current_user,package)

    if no_of_learners_to_be_deleted == 1 then
      flash[:number_of_deleted_learner] = "#{no_of_learners_to_be_deleted} learner removed from package #{package.name}"
    elsif no_of_learners_to_be_deleted > 0 then
      flash[:number_of_deleted_learner] = "#{no_of_learners_to_be_deleted} learners removed from package #{package.name}"
    end
      if no_of_learners_assigned == 1 then
        flash[:number_of_mails] = "#{no_of_learners_assigned} learner assigned to package #{package.name}"
      elsif no_of_learners_assigned > 1 then
        flash[:number_of_mails] = "#{no_of_learners_assigned} learners assigned to package #{package.name}"
      end
      redirect_to("/courses")
  end

  #called from manage method if the first item in package is assessment. This method first checks if any learners have to be unassigned.
  # If there are any learners to be unassigned then update the learner.active = 'no' which will retain the learner record in the table but just he inactive for that assessment as his active attribute in learnes table is 'no'.
  def for_assessment(package,assessment)
    no_of_learners_to_be_deleted = 0
    remaining_learners_from_already_assigned = Array.new
    remaining_learners_from_already_assigned = find_remaining_learners_from_already_assigned()
    @learners = Learner.find_all_by_assessment_id_and_active(assessment.id,"yes", :conditions => ["type_of_test_taker = 'learner' AND group_id = ? AND package_id = ?",params[:group_id],package.id])
    existing_learners_ids = Array.new
    for learner in @learners
      existing_learners_ids << learner.user_id
    end
    learners_to_be_deleted = existing_learners_ids - remaining_learners_from_already_assigned
    for learner_id in learners_to_be_deleted
      no_of_learners_to_be_deleted += 1
      learner_make_inactive = Learner.find_by_user_id_and_assessment_id(learner_id,assessment.id, :conditions => ["type_of_test_taker != 'admin' AND group_id = ? AND package_id = ?",params[:group_id],package.id])
      learner_make_inactive.update_attribute(:active,"no")
      decrease_assessment_columns_while_deleting(assessment,learner_make_inactive)
    end
    learners_for_course_adding_ids = Array.new
    learners_for_course_adding_ids = learners_for_course_added_mails()
    learners_for_course_adding = Array.new
    learners_for_course_adding_ids.each {|user_id|
      learners_for_course_adding << User.find(user_id)
    }

    no_of_learners_assigned = 0
    no_of_learners_assigned += save_and_send_mails(learners_for_course_adding,current_user,package)

    if no_of_learners_to_be_deleted == 1 then
      flash[:number_of_deleted_learner] = "#{no_of_learners_to_be_deleted} learner removed from package #{package.name}"
    elsif no_of_learners_to_be_deleted > 0 then
      flash[:number_of_deleted_learner] = "#{no_of_learners_to_be_deleted} learners removed from package #{package.name}"
    end
    if flash[:learner_limit_exceeds].nil? or flash[:learner_limit_exceeds].blank?
        if no_of_learners_assigned == 1 then
          flash[:number_of_mails] = "#{no_of_learners_assigned} learner assigned to package #{package.name}"
        elsif no_of_learners_assigned > 1 then
          flash[:number_of_mails] = "#{no_of_learners_assigned} learners assigned to package #{package.name}"
        end
        redirect_to("/courses")
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

  def find_remaining_learners_from_already_assigned()
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

  #calculates the required objects like how many courses and assessments are in that package and redirects to edit_package page
  def edit_package
    @package = Package.find(params[:id])
    @assessments = current_user.assessments.where("no_of_questions > 0")
    @courses = current_user.courses.where("size > 0")
  end

  #calculates the current_package and redirects to edit_package_details page
  def edit_package_details
    @package = Package.find(params[:id])
  end

end