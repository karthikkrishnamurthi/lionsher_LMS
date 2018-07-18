
class CouponsController < ApplicationController
  before_filter :login_required, :only => [:index]
  # GET /coupons
  # GET /coupons.xml
  def index
    @coupons = Coupon.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @coupons }
    end
  end

  # GET /coupons/1
  # GET /coupons/1.xml
  def show
    @coupon = Coupon.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @coupon }
    end
  end

  # GET /coupons/new
  # GET /coupons/new.xml
  def new
    @coupon = Coupon.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @coupon }
    end
  end

  # GET /coupons/1/edit
  def edit
    @coupon = Coupon.find(params[:id])
  end

  # POST /coupons
  # POST /coupons.xml
  def create
    @coupon = Coupon.new(params[:coupon])

    respond_to do |format|
      if @coupon.save
        flash[:notice] = 'Coupon was successfully created.'
        format.html { redirect_to(@coupon) }
        format.xml  { render :xml => @coupon, :status => :created, :location => @coupon }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @coupon.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /coupons/1
  # PUT /coupons/1.xml
  def update
    @coupon = Coupon.find(params[:id])

    respond_to do |format|
      if @coupon.update_attributes(params[:coupon])
        flash[:notice] = 'Coupon was successfully updated.'
        format.html { redirect_to(@coupon) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @coupon.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /coupons/1
  # DELETE /coupons/1.xml
  def destroy
    @coupon = Coupon.find(params[:id])
    @coupon.destroy

    respond_to do |format|
      format.html { redirect_to(coupons_url) }
      format.xml  { head :ok }
    end
  end

  #this method is called from /manage_learners of assessment and manage_learners of courses and manage_learners of packages.(check side panel 'use coupon codes for learners')
  #Its called from link<a href>, passing assessment_id and for_course_assessment_package="assessment" as parameters when called from manage learners of assessment page
  #If called from manage_learnes of courses , then the parameters are course_id and for_course_assessment_package="course"
  #If called from manage_learnes of packages , then the parameters are package_id and for_course_assessment_package="pacakge"
  def generate_codes
    if params[:for_course_assessment_package]== "assessment"
     @assessment_course = Assessment.find(params[:id]).name
    elsif params[:for_course_assessment_package]== "course"
     @assessment_course = Course.find(params[:id]).course_name
    elsif params[:for_course_assessment_package]== "assessment_package"
     @assessment_course = AssessmentPackage.find(params[:id]).name
    elsif params[:for_course_assessment_package]== "package"
     @assessment_course = Package.find(params[:id]).name
    end
    #redirected to /coupons/generate_codes.html
  end

  #calculates or generates the coupon codes for the assessment. Takes params[:id] i.e assessment id as the exam code
  def assessment_calculate_coupon_codes
    @assessment_course = Assessment.find(params[:id])
    exam_code = params[:id]
    #create a group called 'Coupons' if its not already existing for that tenant
    group = Group.find_by_user_id_and_group_name(current_user.id,'Coupons')
          if group.nil? then
            @obj_group = Group.new
            @obj_group.group_name = 'Coupons'
            @obj_group.user_id = current_user.id
            @obj_group.tenant_id = current_user.tenant.id
            @obj_group.save
          end
    # create an empty array @coupons_generated
    @coupons_generated = Array.new
    # this is the regular expression to check if the coupon generated is alphanumeric or not. i.e making sure that the coupon generated should consists of minimum one digit and one one alphabet.
    alpha_numeric_pattern = /[a-zA-Z][a-zA-Z0-9]*/
    #SecureRandom is a ruby module. we call its 'hex' class to generate a random 6length code
    @code_for_download = SecureRandom.hex(6)
      params[:coupon_code_count].to_i.times do
        h = {}
        h[:code] = exam_code.to_s + SecureRandom.hex(6)
        h[:assessment_id] = params[:id]
        h[:status] = 'new'
        #we also store @code_for_download in :code_for_download column because its usefull when we try to download coupons generated in the next page.See method coupons/download_coupons_csv_file
        h[:code_for_download] = @code_for_download
        h[:email_authentication_required] = params[:email_authentication_required]
        #if h[:code] which is generated is not alphanumeric then regenerate the code again using method get_alpha_numeric_code
        unless alpha_numeric_pattern.match(h[:code]) then
          regenerated_alpha_numeric_code = get_alpha_numeric_code(alpha_numeric_pattern)
          h[:code] = exam_code.to_s + regenerated_alpha_numeric_code.to_s
        end
        coupon = Coupon.new(h)
        coupon.save
        @coupons_generated << coupon.code
      end
  end

  #Takes the csv string as input and gives csv as output.
  def download_coupons_csv_file
    current_coupons = Coupon.find_all_by_code_for_download(params[:id])
     coupon_codes = CSV.generate do |csv|
       current_coupons.each { |c|
       csv << [c.code]
       }
     end
    generate_csv_file(coupon_codes,"coupons_file")
  end

  #calculates or generates the coupon codes for the package. Takes params[:id] i.e package id as the exam code
  def package_calculate_coupon_codes
    @assessment_course = Package.find(params[:id])
    exam_code = params[:id]
    #create a group called 'Coupons' if its not already existing for that tenant
    group = Group.find_by_user_id_and_group_name(current_user.id,'Coupons')
          if group.nil? then
            @obj_group = Group.new
            @obj_group.group_name = 'Coupons'
            @obj_group.user_id = current_user.id
            @obj_group.tenant_id = current_user.tenant.id
            @obj_group.save
          end
    # create an empty array @coupons_generated
    @coupons_generated = Array.new
    # this is the regular expression to check if the coupon generated is alphanumeric or not. i.e making sure that the coupon generated should consists of minimum one digit and one one alphabet.
    alpha_numeric_pattern = /[a-zA-Z][a-zA-Z0-9]*/
    #SecureRandom is a ruby module. we call its 'hex' class to generate a random 6length code
    @code_for_download = SecureRandom.hex(6)
      params[:coupon_code_count].to_i.times do
        h = {}
        h[:code] = exam_code.to_s + SecureRandom.hex(6)
        h[:package_id] = params[:id]
        h[:status] = 'new'
        h[:code_for_download] = @code_for_download
        h[:email_authentication_required] = params[:email_authentication_required]
         #if h[:code] which is generated is not alphanumeric then regenerate the code again using method get_alpha_numeric_code
        unless alpha_numeric_pattern.match(h[:code]) then
          regenerated_alpha_numeric_code = get_alpha_numeric_code(alpha_numeric_pattern)
          h[:code] = exam_code.to_s + regenerated_alpha_numeric_code.to_s
        end
        coupon = Coupon.new(h)
        coupon.save
        @coupons_generated << coupon.code
      end
  end

  #calculates or generates the coupon codes for the course. Takes params[:id] i.e course id as the exam code
  def course_calculate_coupon_codes
    @assessment_course = Course.find(params[:id])
    exam_code = params[:id]
    #create a group called 'Coupons' if its not already existing for that tenant
    group = Group.find_by_user_id_and_group_name(current_user.id,'Coupons')
          if group.nil? then
            @obj_group = Group.new
            @obj_group.group_name = 'Coupons'
            @obj_group.user_id = current_user.id
            @obj_group.tenant_id = current_user.tenant.id
            @obj_group.save
          end
    # create an empty array @coupons_generated
    @coupons_generated = Array.new
    # this is the regular expression to check if the coupon generated is alphanumeric or not. i.e making sure that the coupon generated should consists of minimum one digit and one one alphabet.
    alpha_numeric_pattern = /[a-zA-Z][a-zA-Z0-9]*/
    #SecureRandom is a ruby module. we call its 'hex' class to generate a random 6length code
    @code_for_download = SecureRandom.hex(6)
      params[:coupon_code_count].to_i.times do
        h = {}
        h[:code] = exam_code.to_s + SecureRandom.hex(6)
        h[:course_id] = params[:id]
        h[:status] = 'new'
        h[:code_for_download] = @code_for_download
        h[:email_authentication_required] = params[:email_authentication_required]
        #if h[:code] which is generated is not alphanumeric then regenerate the code again using method get_alpha_numeric_code
        unless alpha_numeric_pattern.match(h[:code]) then
          regenerated_alpha_numeric_code = get_alpha_numeric_code(alpha_numeric_pattern)
          h[:code] = exam_code.to_s + regenerated_alpha_numeric_code.to_s
        end
        coupon = Coupon.new(h)
        coupon.save
        @coupons_generated << coupon.code
      end
  end
  
  def calculate_coupon_codes
    @assessment_course = AssessmentPackage.find(params[:id])
    exam_code = params[:id]
    group = Group.find_by_user_id_and_group_name(current_user.id,'Coupons')
          if group.nil? then
            @obj_group = Group.new
            @obj_group.group_name = 'Coupons'
            @obj_group.user_id = current_user.id
            @obj_group.tenant_id = current_user.tenant.id
            @obj_group.save
          end
    @coupons_generated = Array.new
    alpha_numeric_pattern = /[a-zA-Z][a-zA-Z0-9]*/
    @code_for_download = SecureRandom.hex(6)
      params[:coupon_code_count].to_i.times do
        h = {}
        h[:code] = exam_code.to_s + SecureRandom.hex(6)
        h[:assessment_package_id] = params[:id]
        h[:status] = 'new'
        h[:code_for_download] = @code_for_download
        h[:email_authentication_required] = params[:email_authentication_required]
        #if h[:code] which is generated is not alphanumeric then regenerate the code again using method get_alpha_numeric_code
        unless alpha_numeric_pattern.match(h[:code]) then
          regenerated_alpha_numeric_code = get_alpha_numeric_code(alpha_numeric_pattern)
          h[:code] = exam_code.to_s + regenerated_alpha_numeric_code.to_s
        end
        coupon = Coupon.new(h)
        coupon.save
        @coupons_generated << coupon.code
      end
  end

  #generates a assured alphanumeric code and returns that code
  def get_alpha_numeric_code(alpha_numeric_pattern)
    h = SecureRandom.hex(6)
#    h = '4001362715281850'
    while alpha_numeric_pattern.match(h).nil?
      h = SecureRandom.hex(6)
    end
    return h
  end

  #when /coupons/coupon page is submitted this method is called. This method validates if the entered coupon is correct coupon or not, already used or not.
  #If already used then redirect user to root page i.e normal login page where he enters email and password and logsin
  #If coupon status is new then then check if email_authentication is required or not. If required then redirect to package_signup page where user enters details like name,email,alternate_email
  #if authentication is not required then bipass the details filling and actiavting the account from mail and all. Directly create a user with couponcode.liosher.com as email and some default password. check auto_login_with_coupon_code method
  def validate
      coupon_code = params[:username]
      @coupon = Coupon.find_by_code(coupon_code)
      unless @coupon.nil? or @coupon.blank? then
          @coupon_user = User.find_by_email(@coupon.code)
        if @coupon.status == 'new' then
#          if @coupon.assessment_package_id == "1001"
#            @coupon.update_attribute(:status, "used")
#            redirect_to "/coupons/first_time_activation/#{@coupon.id}"
          if @coupon_user.nil? then
            if @coupon.email_authentication_required then
              @coupon.update_attribute(:status, "used")
             redirect_to("/coupons/package_signup/#{@coupon.id}")
            else
              @coupon.update_attribute(:status, "used")
              auto_login_with_coupon_code(@coupon)
            end
#          else
#            session[:user_id] = @coupon_user.id
#            redirect_to "/mycourses"
          end
        elsif @coupon.status == 'used' then
          if @coupon.email_authentication_required then
            redirect_to "/"
          else
            current_user = @coupon_user
            session[:user_id] = @coupon_user.id
            redirect_to "/mycourses"
          end
        end
      else
        redirect_to "/coupons/invalid_coupon_entry/1"
      end
  end

  #this is called from validate method if email_authentication is NOT required therefore bipasses the email entering and actiation. It directly takes the learner to his homepage
  #This creates a user record with coupon code as name and email and assigns the first course/test of that package(if coupon is associated with package) else assigns the course or assessment asscoiated to the coupon
  def auto_login_with_coupon_code(coupon)
    @tenant = Tenant.find_by_custom_url(request.subdomain)
    admin_user = @tenant.user
    user_email = coupon.code
    if User.find_by_email(user_email).nil?

      @user = User.new()
      @user.login = user_email
      @user.email = user_email
      @user.crypted_password = '0731fdeb307910eeaae4e58897b7baaba45e054b'
      @user.activation_code = ""
      @user.activated_at = '2011-08-01 11:33:48'
      @user.typeofuser = "learner"
      @user.user_id = admin_user.id
      @user.tenant_id = @tenant.id
      group = Group.find_by_group_name("no_group")
#      group = Group.find_by_user_id_and_group_name(admin_user.id,'Coupons')
      @user.group_id = group.id
      @user.save
      #assign the first test/course to the learner
      assign_first_course_or_assessment_for_coupon(coupon,@user,admin_user)
      current_user = @user
      session[:user_id] = @user.id
      redirect_to "/mycourses"
    else
      redirect_to "/coupons/used_coupon/#{coupon.id}"
    end
  end

  def first_time_activation
    
  end

  def invalid_coupon_entry
    
  end

  #
  def package_signup_confirmation
    @tenant = Tenant.find_by_custom_url(request.subdomain)
    @user = User.find(params[:id])
  end

  #this page is fetched when learner wants to enter his coupon code and activate his coupon code. subdomain.lionsher.com/coupon page
  def coupon
    @tenant= Tenant.find_by_custom_url(request.subdomain)
  end

  #this is called from the link 'download all coupons' from manage_learnes page of assessment. This will download all the coupons generated for that assessment till now
  def download_all_coupons_for_assessment
    coupons_for_assesment = Coupon.where("assessment_id = #{params[:id]}")
    @coupons = generate_download_file_for_coupons(coupons_for_assesment)
    generate_csv_file(@coupons,"coupons_file")
  end

  #this is called from the link 'download all coupons' from manage_learnes page of course. This will download all the coupons generated for that course till now
  def download_all_coupons_for_course
    coupons_for_assesment = Coupon.where("course_id = #{params[:id]}")
    @coupons = generate_download_file_for_coupons(coupons_for_assesment)
    generate_csv_file(@coupons,"coupons_file")
  end

  #this is called from the link 'download all coupons' from manage_learnes page of package. This will download all the coupons generated for that package till now
  def download_all_coupons_for_package
    coupons_for_assesment = Coupon.where("package_id = #{params[:id]}")
    @coupons = generate_download_file_for_coupons(coupons_for_assesment)
    generate_csv_file(@coupons,"coupons_file")
  end


  def download_all_coupons_for_assessment_package
    coupons_for_assesment = Coupon.where("assessment_package_id = #{params[:id]}")
    @coupons = generate_download_file_for_coupons(coupons_for_assesment)
    generate_csv_file(@coupons,"coupons_file")
  end

  #generates a csv file for downloading coupons with 2 columns coupon, status
  def generate_download_file_for_coupons(coupons)
    coupons = CSV.generate do |csv|
      csv << ["coupon","status"]
       coupons.each { |c|
       csv << [c.code,c.status]
       }
     end
     return coupons
  end
end
