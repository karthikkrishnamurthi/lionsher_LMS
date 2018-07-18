# This controller handles the login/logout function of the site.
# Authors : Karthik , Aarthi

require 'Rules.rb'
class SessionsController < ApplicationController

  # comes from routes if subdomain is given
  def login
    # Control goes to sessions/login.html
    @tenant = Tenant.find_by_custom_url(request.subdomain)
    if @tenant.nil? then
      flash[:signup_notice] = "#{request.subdomain} does not exist. You have to signup."
      redirect_to("/")
    end
    # AR: DO NOT DELETE this code. The below redirects are used to avoid "on preview logout in IE".
    if !current_user.nil? then
      tenant_for_user = Tenant.find_by_user_id(current_user.user_id)
      if @tenant.custom_url == tenant_for_user.custom_url then
        case(current_user.typeofuser)
        when "superuser" then
          redirect_to("/tenants")
        when "evaluator" then
          redirect_to("/mypapers")
        when "admin","corporate buyer" then
          redirect_to("/courses")
        when "learner","individual buyer" then
          redirect_to("/mycourses")
        when "seller" then
          redirect_to("/course_store/sellers_courses/#{current_user.id}")
        when "bugz" then
          redirect_to("/issues/my_issues/#{current_user.id}")
        end
      end
    end
  end

  def login_based_redirection
    if params[:commit] == "Sign in"
     redirect_to("/sessions/create/1?email=#{params[:email]}&password=#{params[:password]}")
    else
     redirect_to("/coupons/validate/1?username=#{params[:username]}")
    end
  end

  #routing to the login page if not logged in
  def new
    redirect_to("/")
  end

  # Redirects learner,admin and superuser to corresponding index pages
  def create
    self.current_user = User.authenticate(params[:email], params[:password])
    if allow_login() then
      case(current_user.typeofuser)
      when "admin","individual buyer","corporate buyer" then
        @tenant = Tenant.find_by_user_id(current_user.id)
      when "learner","evaluator" then
        @tenant = Tenant.find_by_user_id(current_user.user_id)
      end
      @user = User.find_by_email(params[:email])
      case
        #if already logged in
      when logged_in?
        if params[:remember_me] == "1"
          current_user.remember_me unless current_user.remember_token?
          cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
        end
        case(current_user.typeofuser)
          #if learner has loggedin then take him to /mycourses pages
        when "learner"
          if request.subdomain == @tenant.custom_url
            redirect_to("/mycourses")
          else
            redirect_to("/#{params[:tenant]}")
          end
          #if admin then check if he is expired. if expired then take to my_account page where he can upgrade plan else take to courses/index page
        when "admin"
          calculate_current_quarter(@tenant)
          if request.subdomain == @tenant.custom_url
            rules = Rules.new(@tenant.id)
            if rules.rule_14_day_trial_expiry(@tenant.id) then
              @tenant.is_expired = "true"
              @tenant.save
              redirect_to("/my_account")
            else
              @tenant.save
              redirect_to("/courses")
            end
          else
            redirect_to("/#{params[:tenant]}")
          end
        when "superuser"
          redirect_to("/tenants")
        when "evaluator"
          redirect_to("/mypapers")
        end
      when @user.nil? then
        flash[:login_notice] = "#{params[:email]} does not exist. You have to signup."
        redirect_to("/")
      else
        flash[:login_notice] = "Incorrect password"
        redirect_to("/")
      end
    else
      flash[:login_notice] = "The username or password you entered is incorrect."
      redirect_to("/")
    end
  end

  def calculate_current_quarter(tenant)
    current_time = Time.now
    current_month = current_time.month
    current_year = current_time.year
    case
    when current_month <= 3 then
      quarter = "Q1"
      dynamic_quarter_values = "Q1,Q4,Q3,Q2"
    when (current_month > 3 and current_month <= 6) then
      quarter = "Q2"
      dynamic_quarter_values = "Q2,Q1,Q4,Q3"
    when (current_month > 6 and current_month <= 9) then
      quarter = "Q3"
      dynamic_quarter_values = "Q3,Q2,Q1,Q4"
    when (current_month > 9 and current_month <= 12) then
      quarter = "Q4"
      dynamic_quarter_values = "Q4,Q3,Q2,Q1"
    end
    tenant.dynamic_quarter_values = dynamic_quarter_values
    tenant.quarter = quarter
    tenant.current_year = current_year
    tenant.previous_year = current_year - 1
    tenant.save
  end

  #checks if current_user object is nil or not.returns true if present else false
  def allow_login
    unless current_user.nil? then
      if (current_user.tenant_id.nil? or current_user.tenant_id.blank? or current_user.tenant_id == 0)
        tenant = Tenant.find_by_user_id(current_user.user_id)
        current_user.update_attribute(:tenant_id, tenant.id)
      end
      case(current_user.typeofuser)
      when "admin","superuser" then
        if request.subdomain == current_user.tenant.custom_url
          return true
        else
          return false
        end
      when "learner" then
        if request.subdomain == current_user.tenant.custom_url
          return true
        else
          return false
        end
      when "seller" then
        return true
      when "evaluator" then
        return true
      when "individual buyer","corporate buyer" then
        return true
      end
    else
      return false
    end
  end

  # Destroys user's session and logs out
  def logout
#    Two-to-three-upgrade-error . AloR>> the below line no longer need to be commented... error cleared.
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    redirect_to("/#{params[:tenant]}")
  end

  #Destroy's superuser's session and logs out to the tenants login page
  def logout_superuser
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    redirect_to("/")
  end
end
