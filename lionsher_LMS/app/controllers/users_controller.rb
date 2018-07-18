# Controller for User Management
# creating admins and learners
# sending emails for activation, forgot password, send reminder, reset password
# Authors : Aarthi, Karthik, Surupa
require 'mime/types'

class UsersController < ApplicationController
  before_filter :is_expired?, :only => [:deactivate_learner]

  #execute this method in stagin to pull the group_id frm user table to learner table(tempo method)
  def fill_respective_group_ids
    all_users = User.find(:all,:conditions => "group_id != 1")
    all_users.each { |user|
      unless user.learners.nil? then
        user.learners.each {|learner|
          learner.update_attribute(:group_id ,user.group_id)
        }
      end
    }
  end

  def learner_groups

  end

  #control comes here from views/users/change_group_of_learners. this will change the group of learners
  def save_change_group_of_learner
    group_already_existing = current_user.groups.find_by_group_name(params[:group][:group_name])
    if group_already_existing.nil? or group_already_existing.blank? then
      new_group = Group.new
      new_group.group_name = params[:group][:group_name]
      new_group.tenant_id = current_user.tenant.id
      new_group.user_id = current_user.id
      new_group.save
      group_already_existing = new_group
    end
    params[:user_id].each { |u_id|
      current_user.user.find(u_id[0]).update_attribute(:group_id,group_already_existing.id)
      if params[:group][:group_name].downcase == "evaluator"
        current_user.user.find(u_id[0]).update_attribute(:typeofuser,"evaluator")
      end
      update_learner_group_id(current_user.user.find(u_id[0]),group_already_existing)
    }
    redirect_to("/users/learner_groups/#{current_user.id}")
  end

  def change_group_of_learner

  end

  #updates the learners group_id in learners table
  def update_learner_group_id(user,group_already_existing_id)
    user.learners.each {|learner|
      learner.update_attribute(:group_id, group_already_existing_id)
    }
  end

  #control come frm edit_group.html view 
  def save_edit_group
    group_already_existing = current_user.groups.find_by_group_name(params[:group][:group_name])
    old_group = Group.find(params[:id])
    if (group_already_existing.nil? or group_already_existing.blank?) and params[:id] == "1"
      new_group = Group.new
      new_group.group_name = params[:group][:group_name]
      new_group.tenant_id = current_user.tenant.id
      new_group.user_id = current_user.id
      new_group.save
      current_user.user.find(:all,:conditions => "group_id = 1").each { |user|
        user.update_attribute(:group_id, new_group.id)
        update_learner_group_id(current_user.user.find(user.id),new_group.id)
      }
    else
      if group_already_existing.nil? or group_already_existing.blank? then
        old_group.update_attribute(:group_name,params[:group][:group_name])
        if params[:group][:group_name].downcase == "evaluator"
          old_group.users.find(:all,:conditions => ["user_id = ?",current_user.id]).each {|user|
            user.update_attribute(:typeofuser,"evaluator")
          }
        end
      else
        old_group.users.find(:all,:conditions => ["user_id = ?",current_user.id]).each {|user|
          user.update_attribute(:group_id,group_already_existing.id)
          unless user.learners.nil?
            update_learner_group_id(user,group_already_existing.id)
          end
        }
      end
    end
    redirect_to("/users/learner_groups/#{current_user.id}")
  end

  def edit_group
    @group = Group.find(params[:id])
  end

  #control comes here from /users
  #save the new email id for the bounced email users and send the activation mail again
  def edit_bounced_emails
    list_of_user_already_exists = Array.new
    params[:bounced].each_pair { |key,value|
      unless value.nil? or value.blank? then
        if value.length <=255 then
          value.gsub!(" ","")
          if validate_new_email(value)
            already_existing = User.find_by_email(value)
            if already_existing.nil? then
              user = User.find(key.to_i)
              user.update_attribute(:email,value)
              result = send_activation_mail_again(user,user.tenant,current_user)
              if result == "success" then
                user.update_attribute(:is_bounced, false)
              end
            else
              list_of_user_already_exists << value
              list_of_user_already_exists = list_of_user_already_exists.join(",")
              flash[:number_of_mails] = "#{list_of_user_already_exists} already exists."
            end
          end
        end
      end
    }
    redirect_to("/users/listing_all_learners/#{current_user.id}")
  end

  #sets the attributes from_replacements, subject_replacements and body_replacements for the activation mail
  #basically every attribute is a hash structured as seen below and these are sent to the 'send_mail' method in UserMailer model for further processing(check UserMailer model)
  def send_activation_mail_again(user,tenant,admin)
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
                         "[learner_email]" => user.email
                        ]

    body_replacements = Hash["[tenant_name]" => tenant.organization,
                         "[url]" => url,
                         "[sender_name]" => admin.login,
                         "[sender_email]" => admin.email,
                         "[learner_name]" => user.login,
                         "[learner_email]" => user.email
                        ]
      UserMailer.delay.send_mail(user,'send_bounced_mail_again',tenant.id,from_replacements,subject_replacements,body_replacements)
      return "success"
      #catch if any errors or exceptions and return that exception
    rescue Net::SMTPFatalError => exception
      return exception
    rescue Net::SMTPSyntaxError => exception
      return exception
    end
  end

  #control comes from listing_all_learners page to send activation mail for the inactivated learners
  def send_activation_for_inactive_users
    count = 0
    params[:inactive].each_pair { |key,value|
      unless value.nil? or value.blank? then
        user = User.find(key.to_i)
        result = send_activation_mail_again(user,user.tenant,current_user)
        count = count + 1
        flash[:mails_sent_to_inavtive_users] = "#{count} mails sent."
      end
    }
    redirect_to("/users/listing_all_learners/#{current_user.id}")
  end

  #matches pattern for email . returns true if its in email format else false
  def validate_new_email(email_id)
    email_pattern = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/
    if email_pattern.match(email_id) then
      return true
    else
      return false
    end
  end
  
  #add a user from text field to existing users list in assign,manage learners page using AJAX.
  def add_to_list
    if (if current_user.typeofuser == "admin" then valid_assign(params[:course_id]) else true end)
      obj_user = User.find_by_email(params[:email])
      if obj_user.nil? then
        @user = User.new
        @user.login = params[:login]
        @user.email = params[:email].strip()
        @user.typeofuser = "learner"
        @user.user_id = current_user.id
        @user.tenant_id = current_user.tenant_id
        @user.save!
      else
        @learner_already_exists = 0
      end
    else
      if current_user.typeofuser == "admin" then
        @learner_limit_exceeds = 1
      end
    end
  end

#add a user from text field to existing users list in assign,manage learners page using RJS.
  def rjs_add_individual_learner
    if (if current_user.typeofuser == "admin" then valid_assign(params[:id],current_user) else true end)
      obj_user = User.find_by_email(params[:email])
      if obj_user.nil? then
        @user = User.new
        @user.login = params[:login]
        @user.email = params[:email].strip()
        @user.typeofuser = "learner"
        @user.user_id = current_user.id
        @user.tenant_id = current_user.tenant_id
        @user.group_id = params[:group_id]
        @user.save!
        @i = params[:i]
      else
        @learner_already_exists = "Learner already exists"
      end
    else
      if current_user.typeofuser == "admin" then
        @learner_limit_exceeds = "You cannot assign more leaners"
      end
    end
  end 

###########################################################################################################################

#control comes here from /views/coupons/package_signup.html. The learner who is coming from coupon code will fill the name, email and alternate email in the form and clicks submit and control comes here
# This is almost same as usual signup process where we fill details like email,tenant_id,group_id,login.
  def save_and_activate_package_learners
    if !params[:user][:email].nil? and !params[:user][:email].blank?
      @tenant = Tenant.find_by_custom_url(request.subdomain)
      admin_user = @tenant.user
      group = Group.find_by_user_id_and_group_name(admin_user.id,'Coupons')
      if User.find_by_email(params[:user][:email]).nil?

        #the below gets executed for DC books . control comes from /views/coupons/first_time_activation.html where learner fills many details like name,phonenumber,dateofbirth etc
        if !session[:user].nil?
          @user = User.new()
          @user.login = session[:user][:login]
          @user.email = params[:user][:email].strip()
          @user.typeofuser = "learner"
          @user.address = session[:user][:address]
          @user.date_of_birth = session[:user][:date_of_birth]
          @user.mob_number = session[:user][:mob_number]
          @user.designation = session[:user][:designation]
          @user.alternate_email = params[:user][:alternate_email]
          @user.student_course = session[:user][:student_course]
          @user.student_course_year = session[:user][:student_course_year]
          @user.student_college = session[:user][:student_college]
          @user.student_college_city = session[:user][:student_college_city]
          @user.user_id = admin_user.id
          @user.tenant_id = @tenant.id
          @user.group_id = group.id
          @user.save
        else

          if !params[:user][:login].nil? and !params[:user][:login].blank?
            @user = User.new()
            @user.login = params[:user][:login]
            @user.email = params[:user][:email].strip()
            @user.typeofuser = "learner"
           # @user.alternate_email = params[:user][:alternate_email]
            @user.user_id = admin_user.id
            @user.tenant_id = @tenant.id
            @user.group_id = group.id
            @user.save
          else
            flash[:enter_details] = "Enter details"
            redirect_to("/coupons/package_signup/#{params[:id]}")
          end
        end
        unless @user.nil?
          coupon = Coupon.find(params[:id])
          #assign the first test/course to the learner
          assign_first_course_or_assessment_for_coupon(coupon,@user,admin_user)
          package_send_activation_mail(@user,'signup_package_learner_notification',@user.tenant,@user.tenant.user)
          flash[:email_notice] = "Email was sent."
          redirect_to("/coupons/package_signup_confirmation/#{@user.id}")
        end
      else
        flash[:enter_details] = "Email already exists"
        redirect_to("/coupons/package_signup/#{params[:id]}")
      end
    else
      flash[:enter_details] = "Enter details"
      redirect_to("/coupons/package_signup/#{params[:id]}")
    end
  end

  #called from pacakges/save_and_send_mails method. sets the attributes from_replacements, subject_replacements and body_replacements for the package_send_activation mail
  #basically every attribute is a hash structured as seen below and these are sent to the 'send_mail' method in UserMailer model for further processing(check UserMailer model)
  def package_send_activation_mail(user,email_template,tenant,admin)
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
                         "[learner_email]" => user.email
                        ]

    body_replacements = Hash["[tenant_name]" => tenant.organization,
                         "[url]" => url,
                         "[sender_name]" => admin.login,
                         "[sender_email]" => admin.email,
                         "[learner_name]" => user.login,
                         "[learner_email]" => user.email
                        ]

   UserMailer.delay.send_mail(user,email_template,tenant.id,from_replacements,subject_replacements,body_replacements)
  end

  #sets the attributes from_replacements, subject_replacements and body_replacements for the package_send_activation_mail_again mail
  #basically every attribute is a hash structured as seen below and these are sent to the 'send_mail' method in UserMailer model for further processing(check UserMailer model)
  def package_send_activation_mail_again()
    user = User.find(params[:id])
     tenant = user.tenant
     admin = user.tenant.user
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
                         "[learner_email]" => user.email
                        ]

    body_replacements = Hash["[tenant_name]" => tenant.organization,
                         "[url]" => url,
                         "[sender_name]" => admin.login,
                         "[sender_email]" => admin.email,
                         "[learner_name]" => user.login,
                         "[learner_email]" => user.email
                        ]
     UserMailer.delay.send_mail(user,'signup_package_learner_notification',tenant.id,from_replacements,subject_replacements,body_replacements)
    flash[:email_notice] = "Email was sent again."
    redirect_to("/coupons/package_signup_confirmation/#{user.id}")
  end

  #
  def save_personal_details_in_session
    if !params[:user][:address].blank? and !params[:user][:mob_number].blank? and !params[:user][:designation].blank?  and !params[:user][:date_of_birth].blank? and !params[:user][:login].blank? and !params[:user][:login].blank?
      session[:user] = params[:user]
      redirect_to("/coupons/package_signup/#{params[:id]}")
    else
      flash[:enter_details]= "Enter all the details"
      redirect_to("/coupons/first_time_activation/#{params[:id]}")
    end
  end

  def signup_for_tests
  end

  # control comes here when user gives url: http://www.lionsher.com/signup ; refer routes
  # or control comes here after signup.
  def signup

    if params.include? "type_of_business" then
      if params.include? "user" then
        if (params[:user][:login].nil? or params[:user][:login].blank?) and (params[:user][:email].nil? or params[:user][:email].blank?) and (params[:tenant][:organization].nil? or params[:tenant][:organization].blank?) and (params[:tenant][:custom_link].nil? or params[:tenant][:custom_link].blank?) then
          flash[:signup_notice] = "Fields can't be blank"
        else
          cookies.delete :auth_token
          if params[:user][:typeofuser] == "admin" then
            @user = User.find_by_email(params[:user][:email])
            @tenant_org = Tenant.find_by_organization(params[:tenant][:organization], :conditions => "type_of_tenant != 'seller'")
            @tenant_url = Tenant.find_by_custom_url(params[:tenant][:custom_link], :conditions => "type_of_tenant != 'seller'")
            if (@tenant_org.nil? or @tenant_org.blank?) and (@tenant_url.nil? or @tenant_url.blank?) then
              @tenant = Tenant.new
              @tenant.organization = params[:tenant][:organization]
              @tenant.custom_url = params[:tenant][:custom_link]
              @tenant.selected_plan_id = params[:selected_plan_id]
              @tenant.type_of_business = params[:type_of_business]
              #if its a test plan then the free trial plan is 13 else (for lms plan) it is plan 4
              if params.include? 'assessment_only_plan' then
                @tenant.pricing_plan_id = 4
                @tenant.expiry_date = Time.now.utc + 30*24*60*60
                @tenant.max_learner_credit = PricingPlan.find(4).no_of_users
                @tenant.remaining_learner_credit = PricingPlan.find(4).no_of_users
              elsif params.include? '7days free trial'
                @tenant.pricing_plan_id = 20
                @tenant.expiry_date = Time.now.utc + 7*24*60*60
                @tenant.max_learner_credit = PricingPlan.find(20).no_of_users
                @tenant.remaining_learner_credit = PricingPlan.find(20).no_of_users
              else
                @tenant.pricing_plan_id = 13
                @tenant.expiry_date = Time.now.utc + 14*24*60*60
                @tenant.max_learner_credit = PricingPlan.find(13).no_of_users
                @tenant.remaining_learner_credit = PricingPlan.find(13).no_of_users
              end
              
              if @user.nil? then
                @user = User.new
                @user.login = params[:user][:login]
                @user.email = params[:user][:email].strip()
                @user.typeofuser = "admin"
                @user.mob_number = params[:user][:mob_number]
                @user.save
                @user.update_attribute(:user_id,@user.id)
                @tenant.user_id = @user.id
                @tenant.save

                result = signup_notification_send_grid(@user,@tenant)
                @user.update_attribute(:tenant_id,@tenant.id)
                flash[:email_notice] = "Email was sent."
                render :file => '/users/signup_confirmation.html.erb'
              else

                flash[:signup_notice] = "User #{@user.email} already exists"
                if params.include? 'assessment_only_plan' then
                  redirect_to("/users/signup_for_tests/#{params[:selected_plan_id]}?type_of_business=#{params[:type_of_business]}&assessment_only_plan=")
                else
                  redirect_to("/users/signup/#{params[:selected_plan_id]}?type_of_business=#{params[:type_of_business]}")
                end
                
              end
            else
              if !@tenant_org.nil?
                flash[:signup_notice] = "Organization #{@tenant_org.organization} already exists"
              elsif !@tenant_url.nil?
                flash[:signup_notice] = "Custom url #{@tenant_url.custom_url} already exists"
              end
              if params.include? 'assessment_only_plan' then
                redirect_to("/users/signup_for_tests/#{params[:selected_plan_id]}?type_of_business=#{params[:type_of_business]}&assessment_only_plan=")
              else
                redirect_to("/users/signup/#{params[:selected_plan_id]}?type_of_business=#{params[:type_of_business]}")
              end
            end
          end
        end
      end
    else
      redirect_to('/pricing_rupees')
    end
  end

  #sets the attributes from_replacements, subject_replacements and body_replacements for the signup mail
  #basically every attribute is a hash structured as seen below and these are sent to the 'send_mail' method in UserMailer model for further processing(check UserMailer model)
  def signup_notification_send_grid(user,tenant)
     admin = user
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
                         "[learner_email]" => user.email
                        ]

    body_replacements = Hash["[tenant_name]" => tenant.organization,
                         "[url]" => url,
                         "[sender_name]" => admin.login,
                         "[sender_email]" => admin.email,
                         "[learner_name]" => user.login,
                         "[learner_email]" => user.email
                        ]
    begin
      #if the tenant has registered for assessment only plan then send a different mail 'signup_for_tests_notification' else send normal signup mail
      if tenant.pricing_plan.plan_group == 'assessment_only_plan' then
        # Calls send_mail() in models/user_mailer.rb
        UserMailer.send_mail(user,'signup_for_tests_notification',tenant.id,from_replacements,subject_replacements,body_replacements).deliver
      else
        # Calls send_mail() in models/user_mailer.rb
       UserMailer.send_mail(user,'signup_notification',tenant.id,from_replacements,subject_replacements,body_replacements).deliver
#        UserMailer.deliver_signup_notification(user)  
      end
      return "success"
      #catch if any errors or exceptions and return that exception
    rescue Net::SMTPFatalError => exception
      return exception
    rescue Net::SMTPSyntaxError => exception
      return exception
    end
  end

  # Control comes here from users/email_again.html to send signup mail again
  def send_mail_again
    @user = User.find_by_id(params[:id])
    @tenant = Tenant.find_by_user_id(@user.id)
    result = signup_notification_send_grid(@user,@tenant)
    flash[:email_notice] = "Email was sent again."
    render :file => 'users/signup_confirmation.html.erb'
  end

  # Control comes here from users/set_password.html or users/learner_password.html
  def set_password
    if (params[:password].length >= 6) then
      if !(request.subdomain.nil? or request.subdomain.blank?)
        @tenant = Tenant.find_by_custom_url(request.subdomain)
      end
      #save the password after applying SHA and redirect to mycourse if learner
      if current_user.typeofuser == "learner" then
        current_user.update_attribute(:crypted_password, Digest::SHA1.hexdigest(params[:password]))
        if logged_in? && !current_user.active?
          current_user.activate
        end
        redirect_to("/mycourses")
      elsif current_user.typeofuser == "admin"
        #handles image upload erros which admin uploads along with the password
        if params[:tenant][:logo].nil? or params[:tenant][:logo].blank? then
          media_type =  "image"
        else
          file_name = params[:tenant][:logo].original_filename
          media_type = ((MIME::Types.type_for(file_name))[0]).media_type
        end
        if media_type == "image" then
          current_user.update_attribute(:crypted_password, Digest::SHA1.hexdigest(params[:password]))
          if logged_in? && !current_user.active?
            current_user.activate
          end
          @tenant.update_attributes(params[:tenant])
          current_time = Time.now
          current_month = current_time.month
          current_year = current_time.year
          if current_month <= 3 then
            quarter = "Q1"
            dynamic_quarter_values = "Q1,Q4,Q3,Q2"
          elsif current_month > 3 and current_month <= 6 then
            quarter = "Q2"
            dynamic_quarter_values = "Q2,Q1,Q4,Q3"
          elsif current_month > 6 and current_month <= 9 then
            quarter = "Q3"
            dynamic_quarter_values = "Q3,Q2,Q1,Q4"
          elsif current_month > 9 and current_month <= 12 then
            quarter = "Q4"
            dynamic_quarter_values = "Q4,Q3,Q2,Q1"
          end
          @tenant.dynamic_quarter_values = dynamic_quarter_values
          @tenant.quarter = quarter
          @tenant.current_year = current_year
          @tenant.previous_year = current_year - 1
          @tenant.save
          redirect_to("/courses")
        else
          flash[:wrong_image_type] = "Upload only images"
        end
      end
    else
      flash[:pwd_blank_msg] ="Provide a password with minimum 6 characters "
      redirect_to("/activate/#{params[:activation_code]}")
    end
  end

  #resets the password. control comes here whenever user clicks on the link mailed to him when he requests for forgot password
  def reset_password
    #reset password for learner and redirect to his home page i.e /mycourses
    if current_user.typeofuser == "learner" then
      current_user.update_attribute(:crypted_password, Digest::SHA1.hexdigest(params[:user][:password]))
      if logged_in? && !current_user.active?
        current_user.activate
      end
      current_user.update_attribute(:reset_code,"")
      redirect_to("/mycourses")
      #reset password for admin and superuser and rediect to his home page i.e /courses
    elsif current_user.typeofuser == "admin" or current_user.typeofuser == "superuser"  then
      current_user.update_attribute(:crypted_password, Digest::SHA1.hexdigest(params[:user][:password]))
      if logged_in? && !current_user.active?
        current_user.activate
      end
      current_user.update_attribute(:reset_code,"")
      redirect_to("/courses")
    end

  end

  #remember that there wont be any current_subdomain for a seller
  def pswrd_reset
    @tenant = Tenant.find_by_custom_url(request.subdomain)
    if User.find_by_reset_code(params[:reset_code]).nil? then
      redirect_to("/#{params[:tenant]}")
    else
      self.current_user = User.find_by_reset_code(params[:reset_code])
    end
  end

  # Control comes here when user clicks on activation link in activation email message
  # TODO : After coming to set admin password page from activation link in email message
  #        if simultaneously send email is requested then email message has no activation code.
  #        This is to be fixed.
  def activate
    if !(request.subdomain.nil? or request.subdomain.blank?)
      @tenant = Tenant.find_by_custom_url(request.subdomain)
    end
    self.current_user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.active?
      if current_user.typeofuser == "admin" or current_user.typeofuser == "individual buyer" or current_user.typeofuser == "corporate buyer" then
        render :file => 'users/set_password'
      elsif current_user.typeofuser == "seller" then
        render :file => 'users/seller_password'
      else
        render :file => 'users/learner_password'
      end
    else
      redirect_to("/")
    end
  end


  def forgot # Author :Aarthi. Control comes here when the user clicks submit in forgot password page
    @tenant = Tenant.find_by_custom_url(request.subdomain)
    if request.post?
      unless params[:email].nil? or params[:email].blank? then
        user = User.find_by_email(params[:email])
        unless user.nil? or user.blank? then
          unless user.crypted_password.nil? or user.crypted_password.blank? then
            @tenant_for_forgot = Tenant.find_by_user_id(user.user_id)
            if @tenant.custom_url == @tenant_for_forgot.custom_url then
              respond_to do |format|
                if user
                  user.create_reset_code
                  flash[:mail_sent_to_reset_password] = "A mail has been sent with instructions to create a new password"
                  format.html { redirect_to "/#{params[:tenant]}" }
                  format.xml { render :xml => user.email, :status => :created }
                else
                  format.html { redirect_to "/#{params[:tenant]}" }
                  format.xml { render :xml => user.email, :status => :unprocessable_entity }
                end
              end
            else
              flash[:wrong_email_for_tenant] = "#{params[:email]} does not belong to #{@tenant.organization}"
              redirect_to("")
            end
          else
            flash[:not_active_user] = "Not yet activated"
            redirect_to("")
          end
        else
          flash[:pwd_blank_msg] =" Can't find this Email."
        end
      else
        flash[:pwd_blank_msg] =" Enter Valid Email "
      end
    end
  end


  def reset
    @user = User.find_by_reset_code(params[:reset_code]) unless params[:reset_code].nil?
    if request.post?
      if @user.update_attributes(:password => params[:user][:password])
        self.current_user = @user
        @user.delete_reset_code
        redirect_back_or_default('/courses')
      else
        render :action => :reset
      end
    end
  end

  # Send reminder to incomplete and unattempted learners from courses/learner_details.html page
  # Control comes here from courses/learners_for_course.html
  # Author : Surupa
  # TODO : Send reminder for individual learner should be done in courses/learners_for_course.html
  def send_reminder
    @course = Course.find(params[:id])
    @learners = Learner.find_all_by_course_id_and_admin_id_and_active(params[:id],current_user.id,"yes",:conditions => ["lesson_status = ?",params[:status]])
    for learner in @learners
      @user = User.find_by_id(learner.user_id)
      result = reminder_send_grid(@user,@course,@user.tenant,current_user,learner)
    end
    redirect_to("/courses")
  end

   #sets the attributes from_replacements, subject_replacements and body_replacements for the reminder mail
  #basically every attribute is a hash structured as seen below and these are sent to the 'send_mail' method in UserMailer model for further processing(check UserMailer model)
  def reminder_send_grid(user,course,tenant,admin,learner)
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

                         "[course_name]" => course.course_name,
                         "[course_description]" => course.description,

                         "[course_start_schedule]" => course.start_time,
                         "[course_end_schedule]" => course.end_time,
                         "[course_duration_hour]" => course.duration_hour,
                         "[course_duration_min]" => course.duration_min,

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

                         "[course_name]" => course.course_name,
                         "[course_description]" => course.description,

                         "[course_start_schedule]" => course.start_time,
                         "[course_end_schedule]" => course.end_time,
                         "[course_duration_hour]" => course.duration_hour,
                         "[course_duration_min]" => course.duration_min,

                         "[learner_lesson_status]" => learner.lesson_status,
                         "[learner_lesson_raw_score]" => learner.score_raw,
                         "[learner_lesson_max_score]" => learner.score_max,
                         "[learner_lesson_credit]" => learner.credit
                        ]
       UserMailer.send_mail(user,'reminder',tenant.id,from_replacements,subject_replacements,body_replacements).deliver
      return "success"
      #catch if any errors or exceptions and return that exception
    rescue Net::SMTPFatalError => exception
      return exception
    rescue Net::SMTPSyntaxError => exception
      return exception
    end
  end

  #sends reminder for assessment
  def send_reminder_for_assessment
    @learners = Learner.find_all_by_assessment_id_and_admin_id_and_active(params[:id],current_user.id,"yes", :conditions => ["type_of_test_taker = 'learner' AND lesson_status = ?",params[:status]])
    @assessment = Assessment.find(params[:id])
    for learner in @learners
      @user = User.find_by_id(learner.user_id)
      @assessment = Assessment.find_by_id(params[:id])
      result = reminder_assessment_send_grid(@user,@assessment,learner,current_user.tenant,current_user)
    end
    redirect_to("/courses")
  end

  #sets the attributes from_replacements, subject_replacements and body_replacements for the reminder_assessment mail
  #basically every attribute is a hash structured as seen below and these are sent to the 'send_mail' method in UserMailer model for further processing(check UserMailer model)
  def reminder_assessment_send_grid(user,assessment,learner,tenant,admin)
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
       UserMailer.send_mail(user,'reminder_assessment',tenant.id,from_replacements,subject_replacements,body_replacements).deliver
      return "success"
      #catch if any errors or exceptions and return that exception
    rescue Net::SMTPFatalError => exception
      return exception
    rescue Net::SMTPSyntaxError => exception
      return exception
    end
  end

  #comes from the 'my account' tab click on the right corner in the header 
  #If this method is called from transactions controller with a parameter 'transaction_id' then redirect to my_account.html
  def my_account
    @tenant = current_user.tenant
    @pricing_plans = PricingPlan.find(:all)
    @current_plan = @tenant.pricing_plan 
    @recent_transactions = @tenant.transactions.order('id DESC')
    #if this method is called from transaction controller 
    if params.include? "transaction_id" then
      @transaction = Transaction.find(params[:transaction_id])
      flash[:payment_notice] = "#{@transaction.response_message}"
    end
  end

  #control comes when user clicks on learners tab on header. calculates required objects like @activated_users,@inactivated_users,@deactivated_users,@bounces_users
  def listing_all_learners
    #calculate bounces (check in app_controller)
    send_grid_mail_bounces()
    @activated_users = current_user.user.find(:all, :conditions => ["deactivated_at IS NULL AND is_bounced = 0 AND crypted_password IS NOT NULL"], :order => 'login')
    @inactivated_users = current_user.user.find(:all, :conditions => ["deactivated_at IS NULL AND is_bounced = 0 AND crypted_password IS NULL"], :order => 'login')
    @deactivated_users = current_user.user.find(:all, :conditions => ["deactivated_at IS NOT NULL"], :order => 'login')
    @bounces_users = current_user.user.find(:all, :conditions => "is_bounced = 1", :order => 'login')
  end

  def deactivate_learner
    @user = User.find_by_id(params[:id])
    @learners = Learner.find_all_by_user_id(params[:id],:conditions => "active = 'yes'")
    @learners.each {|learner|
      learner.update_attribute(:active, "no")
      if (learner.course_id.nil? or learner.course_id.blank?) 
        assessment = Assessment.find(learner.assessment_id)
        decrease_assessment_columns_while_deleting(assessment,learner)
      end
      if (learner.assessment_id.nil? or learner.assessment_id.blank?)
        course = Course.find(learner.course_id)
        decrease_course_columns_while_deleting(course,learner)
      end
    }
    @user.update_attribute(:deactivated_at, Time.now)
    concatenated_email = "aEyGf7k0dM1x" + @user.email
    @user.update_attribute(:email,concatenated_email)
    redirect_to("/users/listing_all_learners/"+current_user.id.to_s)
  end

  def activate_learner
    @user = User.find_by_id(params[:id])
    @user.update_attribute(:deactivated_at, nil)
    stripped_email = @user.email.split("aEyGf7k0dM1x")[1]
    @user.update_attribute(:email,stripped_email)
    redirect_to("/users/listing_all_learners/"+current_user.id.to_s)
  end

  def destroy
    learners = Learner.find_all_by_user_id(params[:id])
    learners.each { |learner|
      if learner.course_id.nil? or learner.course_id.blank?
        assessment = Assessment.find(learner.assessment_id)
        decrease_assessment_columns_while_deleting(assessment,learner)
      else
        course = Course.find(learner.course_id)
        decrease_course_columns_while_deleting(course,learner)
      end
      learner.destroy
    }
    User.find(params[:id]).destroy
    redirect_to("/users/listing_all_learners/#{current_user.id}")
  end

  def signup_from_email
    
  end

end
