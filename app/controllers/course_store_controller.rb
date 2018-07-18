require 'mime/types'

class CourseStoreController < ApplicationController
  before_filter :login_required , :only => [:sellers_courses]

  def sellers_courses
    @seller = Tenant.find_by_user_id(current_user.id)
    @courses = current_user.courses.find(:all, :order => "id DESC", :conditions => 'size > 0')
  end

  def index
    if current_user.nil? and request.subdomain.nil?
      @rules = YAML::load(File.open("#{Rails.root}/config/website_content.yml"))
      page = params[:page]
      if params.include? "search" and !(params[:search].nil? or params[:search].blank?) then
        search = params[:search]
        if search.nil? or search.blank? then
          search = ""
        end
        @total_courses = Course.find(:all, :conditions => "lms_cs = 'course_store' AND description IS NOT NULL AND published = 1 AND (vendor like '%#{search}%' OR course_name like '%#{search}%' OR description like '%#{search}%')")
      else
        @total_courses = Course.find(:all, :conditions => "lms_cs = 'course_store' AND description IS NOT NULL AND published = 1",:order => "id DESC")
      end
      @coursestore = @total_courses.paginate(:page => page, :per_page => 25)
    else
      redirect_to("http://#{request.subdomain}.#{SITE_URL}/courses")
    end
  end

  def coursestore_upload

  end

  def save_coursestore_details
    course = Course.find_by_id(File.read("public/files/undefined"))
    if course.nil? then
      flash[:course_not_uploaded] = "Please upload a course then press submit"
      redirect_to("/course_store/coursestore_upload")
    else
      course.update_attributes(params[:courses])
      course_expiry = params[:course][:course_expiry_year].to_i*365 + params[:course][:course_expiry_month].to_i*30
      course.update_attribute(:course_expiry,course_expiry)
      course.update_attribute(:lms_cs,"course_store")
      user = User.find_by_email(params[:users][:email])
      if user.nil? or user.blank?
        user = User.new
        user.update_attributes(params[:users])
        user.update_attribute(:typeofuser, "seller")
        user.update_attribute(:user_id, user.id)
        seller = Tenant.new
        seller.user_id = user.id
        custom_url = params[:tenants][:organization].split(' ').join('').downcase
        course.update_attribute(:vendor,params[:tenants][:organization])
        seller.custom_url = custom_url
        seller.pricing_plan_id = 3
        seller.selected_plan_id = 3
        seller.type_of_tenant = "seller"
        seller.save
        seller.update_attributes(params[:tenants])
        UserMailer.deliver_course_store_signup_notification(User.find_by_email(params[:users][:email]))
      else
        user.update_attributes(params[:user])
        UserMailer.deliver_new_course_added_notification(User.find_by_email(params[:users][:email]),course.id)
      end
      course.update_attribute(:user_id,user.id)
      redirect_to("/course_store/coursestore_signup_confirmation/#{User.find_by_id(user.id)}")
    end
  end

  def coursestore_signup_confirmation
    @user = User.find_by_id(params[:id])
    render :file => "/course_store/coursestore_signup_confirmation"
  end

  def coursestore_preview
    @course = Course.find_by_id(params[:id])
  end

  def courses_for_vendor
    seller = Tenant.find_by_custom_url(params[:custom_url], :conditions => "type_of_tenant = 'seller'")
    if !(seller.nil? or seller.blank?) then
      @vendor = Course.find_by_user_id(seller.user_id).vendor
      @vendor_courses = Course.find(:all, :conditions => ["vendor = ? AND description IS NOT NULL",@vendor],:order => "id DESC")
      @courses = @vendor_courses.paginate(:page => params[:page], :per_page => 25)
    else
      redirect_to("/course_store")
    end
  end

  def buy_confirmation
    @course = Course.find_by_id(params[:id])
  end

  def get_buyers_info
    @course = Course.find_by_id(params[:id])
    @buyer_seller = BuyerSeller.find(params[:buyer_id].to_i)
  end

  def get_sellers_info
  end

  def save_sellers_details
    seller = Tenant.new(params[:seller])
    seller.save
    flash[:saved_successfully_msg] = "Thank you for your contact information. We will contact you in the 2 working days."
    redirect_to('/course_store')
  end

  def save_buyers_course_details
    course = Course.find_by_id(params[:id])
    if  params[:buyer_seller].include? "no_of_license"
      buyer_seller = BuyerSeller.new(params[:buyer_seller])
      buyer_seller.course_id = course.id
      buyer_seller.seller_user_id = course.user_id
      buyer_seller.price = params[:buyer_seller][:no_of_license].to_i * course.course_price
      buyer_seller.save
      redirect_to('/course_store/get_buyers_info/'+params[:id].to_s+'?buyer_id='+buyer_seller.id.to_s)
    else
      redirect_to('/course_store/coursestore_preview/'+params[:id].to_s)
    end
  end

  
  def save_buyers_details
    if params.include? "user" then
      if (params[:user][:login].nil? or params[:user][:login].blank?) and (params[:email].nil? or params[:email].blank?) and (params[:tenant][:organization].nil? or params[:tenant][:organization].blank?) and (params[:tenant][:custom_link].nil? or params[:tenant][:custom_link].blank?) then
        flash[:signup_notice] = "Fields can't be blank"
        redirect_to('/course_store/get_buyers_info/'+params[:id].to_s)
      else
        @user = User.find_by_email(params[:email])
        buyer_seller = BuyerSeller.find_by_id(params[:id])
        if buyer_seller.no_of_license > 1 then
          tenant_url = Tenant.find_by_custom_url(params[:tenant][:custom_link])
          if tenant_url.nil? or tenant_url.blank? then
            initialize_tenant_object(params[:tenant][:organization],params[:tenant][:custom_link],params[:tenant][:zone])
            file_name = params[:tenant][:logo].original_filename
            media_type = ((MIME::Types.type_for(file_name))[0]).media_type
            if media_type == "image" then
              if @user.nil? then                
                update_user_and_tenant_object(params[:user][:login],params[:email].strip(),params[:password],2,params[:tenant][:logo],"corporate buyer")
                buyer_seller.update_attribute(:buyer_user_id, @user.id)
                self.current_user = @user.activation_code.blank? ? false : User.find_by_activation_code(@user.activation_code)
                if logged_in? && !current_user.active?
                  current_user.activate
                end
                redirect_to("http://#{@tenant.custom_url}.#{SITE_URL}/sessions/create/#{params[:id].to_s}"+"?email=#{@user.email}"+"&password=#{params[:password]}")
              else
                flash[:signup_notice] = "User #{@user.email} already exists"
                redirect_to('/course_store/get_buyers_info/'+params[:id].to_s)
              end
            end
          else
            flash[:signup_notice] = "Custom url #{tenant_url.custom_url} already exists"
            redirect_to('/course_store/get_buyers_info/'+params[:id].to_s)
          end
        else
          custom_url = params[:email].gsub(/[^a-zA-Z 0-9]/,"")
          tenant_url = Tenant.find_by_custom_url(custom_url)
          if tenant_url.nil? or tenant_url.blank? then
            initialize_tenant_object("LIONSHER",custom_url,"+05:30")
            if @user.nil? then
              update_user_and_tenant_object(params[:user][:login],params[:email].strip(),params[:password],2,"","individual buyer")
              make_individual_buyer_as_learner(buyer_seller.course_id,@user.id,@tenant.id)
              buyer_seller.update_attribute(:buyer_user_id, @user.id)
              self.current_user = @user.activation_code.blank? ? false : User.find_by_activation_code(@user.activation_code)
              if logged_in? && !current_user.active?
                current_user.activate
              end
              redirect_to("http://#{@tenant.custom_url}.#{SITE_URL}/sessions/create/#{params[:id].to_s}"+"?email=#{@user.email}"+"&password=#{params[:password]}")
            else
              flash[:signup_notice] = "User #{@user.email} already exists"
              redirect_to('/course_store/get_buyers_info/'+params[:id].to_s)
            end
          else
            flash[:signup_notice] = "Custom url #{tenant_url.custom_url} already exists"
            redirect_to('/course_store/get_buyers_info/'+params[:id].to_s)
          end
        end
      end
    else
      redirect_to('/course_store/get_buyers_info/'+params[:id].to_s)
    end
  end

  def initialize_tenant_object(organization,custom_url,zone)
    @tenant = Tenant.new
    @tenant.organization = organization
    @tenant.custom_url = custom_url
    @tenant.zone = zone
    @tenant.save
  end

  def update_user_and_tenant_object(login,email,password,plan_id,logo,type_of_buyer)
    @user = User.new
    @user.login = login
    @user.email = email
    @user.save
    @user.update_attribute(:user_id,@user.id)
    @user.update_attribute(:tenant_id,@tenant.id)
    @user.update_attribute(:crypted_password, Digest::SHA1.hexdigest(password))
    @user.update_attribute(:typeofuser,type_of_buyer)
    @tenant.update_attribute(:user_id,@user.id)
    @tenant.update_attribute(:pricing_plan_id,plan_id)
    @tenant.update_attribute(:selected_plan_id,plan_id)
    @tenant.update_attribute(:expiry_date,Time.now.utc)
    @tenant.update_attribute(:type_of_tenant,type_of_buyer)
    @tenant.update_attribute(:logo,logo)
  end

  def make_individual_buyer_as_learner(course_id,user_id,tenant_id)
    learner = Learner.find_by_course_id_and_user_id(course_id,user_id)
    if learner.nil? then
      learner = Learner.new
      learner.course_id = course_id
      learner.user_id = user_id
      learner.user_id = user_id
      learner.tenant_id = tenant_id
      learner.type_of_test_taker = "learner"
      type_of_course = Course.find_by_id(course_id).typeofcourse
      if type_of_course == "presentation" then
        learner.lesson_location = "0"
      end
      learner.save
    end
  end

  def login_already_buyer
    user = User.find_by_email(params[:email])
    tenant = Tenant.find_by_user_id(user.id)
    buyer_seller = BuyerSeller.find_by_buyer_user_id_and_course_id(user.id,params[:course_id])
    if buyer_seller.nil? or buyer_seller.blank?
      buyer_seller.update_attribute(:buyer_user_id, user.id)
      make_individual_buyer_as_learner(buyer_seller.course_id,user.id,tenant.id)
      redirect_to("http://#{tenant.custom_url}.#{SITE_URL}/sessions/create/#{params[:id].to_s}"+"?email=#{user.email}"+"&password=#{params[:password]}")
    else
      new_buyer_seller_object = BuyerSeller.find_by_id(params[:id])
      new_buyer_seller_object.destroy
      flash[:course_already_bought] = "You have already bought the course. Choose another course."
      redirect_to("/course_store")
    end    
  end

  def upload_course
    @seller = Tenant.find_by_user_id(current_user.id)
    if params.include? 'Filedata' then
      uploaded_file = params[:Filedata]
      file_name = params[:Filename]
      course_file_name = file_name.split('.')[0]
      extension = File.extname(file_name)
      directory = "public/data"
      @course = Course.new
      @course.save
      @course.update_attribute(:user_id,params[:tenant])
      course_id = @course.id.to_s
      tenantfilepath = directory + "/" + params[:tenant]
      File.open(tenantfilepath, "w+") { |f| f.write(course_id) }
      error_file_path = directory + "/E" + params[:tenant]
      File.open(error_file_path, "w+") { |f| f.write("true") }
      mime_obj = MIME::Types.type_for(file_name)
      if mime_obj.nil? or mime_obj.blank? then
        File.open(error_file_path, "w+") { |f| f.write("processing") }
        @course.destroy
        return
      end #TODO: else what?

      media_type = ((MIME::Types.type_for(file_name))[0]).media_type
      sub_type = ((MIME::Types.type_for(file_name))[0]).sub_type
      mime_extension = ((MIME::Types.type_for(file_name))[0]).extensions[0]

      if upload_valid(media_type,sub_type,mime_extension)
        case
        when sub_type == "zip" then name =  type = "e-learning"
        when media_type == "audio" then name = type = "audio"
        when media_type == "video" then name = type = "video"
        when mime_extension == "ppt" || mime_extension == "odp" || mime_extension == "pptx" then name = type = "presentation"
        when sub_type == "shockwave-flash" then name = type = "flash"
        when sub_type == "pdf" || sub_type == "msword" || sub_type == "vnd.openxmlformats-officedocument.wordprocessingml.document" then name = type = "document"
        else
          File.open(error_file_path, "w+") { |f| f.write("false") }
          @course.destroy
          return
        end
        path = File.join(directory,name)
        new_path = path + "_" + course_id
        basepath = new_path
        is_saved = case
        when type == "e-learning" then  elearning(new_path,extension,uploaded_file,error_file_path,basepath,course_file_name,type)
        when sub_type == "flv" || sub_type == "shockwave-flash" then aud_vid_ppt_flv_swf(basepath,name,course_id,extension,uploaded_file,error_file_path,type,course_file_name,sub_type)
        when media_type == "audio" || media_type == "video" then aud_vid_ppt_flv_swf(basepath,name,course_id,extension,uploaded_file,error_file_path,type,course_file_name,media_type)
        else aud_vid_ppt_flv_swf(basepath,name,course_id,extension,uploaded_file,error_file_path,type,course_file_name,mime_extension)
        end
        if is_saved == false
          File.open(error_file_path, "w+") { |f| f.write("false") }
          return
        end
      else
        File.open(error_file_path, "w+") { |f| f.write("processing") }
        @course.destroy
        return
      end
    end
  end

  #Control comes here if the uploaded file is SCORM, Non-SCORM.
  #It takes the needed paths as arguments, reads the uploaded file, unzips,checks for virus and saves to db.
  #Also returns a variable is_saved as true if the upload process and saving process is done perfectly else returns false.
  def elearning(new_path,extension,uploaded_file,error_file_path,basepath,course_file_name,type)
    new_path = new_path + extension
    File.open(new_path, "w") { |f| f.write(uploaded_file.read) }

    scan_value = virus_scan(new_path)
    if scan_value != 0 then
      remove_virus_affected_file(error_file_path,basepath)
      return
    end #TODO: else what?
    # extract the zipped file
    Zip::ZipFile.open(new_path) { |zip_file|
      zip_file.each { |f|
        f_path=File.join(basepath,f.name)
        FileUtils.mkdir_p(File.dirname(f_path))
        zip_file.extract(f, f_path) unless File.exist?(f_path)
      }
    }
    # search for imsmanifest.xml file and get its path
    Dir::chdir(basepath) do
      files = File.join('**','imsmanifest.xml')
      manifest=Dir.glob(files)
      @xmlfile = manifest[0]
    end

    # Modified here KK:jan7:handling nonscorm courses
    # if imsmanifest.xml not found then add imsmanifest.xml file to the unzipped folder
    if @xmlfile.nil?
      File.open(error_file_path, "w+") { |f| f.write("nonscorm") }
      title = course_file_name
      url = "tbd"
    else
      # read xml content from manifest file if scorm course
      manifestpath = File.join(basepath, @xmlfile)
      xml_data = File.read(manifestpath)

      # parse the xml data for launch file
      launch_file = find_launch_file(xml_data)

      # parse the xml data for course title
      title = find_course_title(xml_data)

      # recursive search for launch file
      Dir::chdir(basepath) do
        files = File.join("**",launch_file)
        launch = Dir.glob(files)
        @launch=launch[0]
      end

      # construct url
      launchpath = File.join(basepath,@launch)
      url = launchpath.gsub("public/","")
    end

    # calculate size of extracted folder
    dirsize = 0
    Find.find(basepath) do |file|
      dirsize += File.size(file)
    end

    # save to database
    is_saved = save_to_database(basepath,type,dirsize,url,title)

    # delete the zip file
    File.delete(new_path)
    return is_saved
  end

  #Control comes here if the uploaded file is audio, video,flv audio,flv video, shockwave-flash.
  #It takes the needed paths as arguments, reads the uploaded file,checks for virus and saves to db.
  #Also returns a variable is_saved as true if the upload process and saving process is done perfectly else returns false.
  def aud_vid_ppt_flv_swf(basepath,name,course_id,extension,uploaded_file,error_file_path,type,course_file_name,media_sub_type)
    FileUtils.mkdir_p(basepath)
    path_to_save = basepath
    new_path = basepath + "/" + name + "_" + course_id
    basepath = new_path + extension

    #write the uploaded file to baspath
    File.open(basepath, "w") { |f| f.write(uploaded_file.read) }
    scan_value = virus_scan(basepath)
    if scan_value != 0 then
      remove_virus_affected_file(error_file_path,basepath)
      return
    end #TODO: else what?

    #if uploaded file is audio or video the convert it to flv and delete the actual uploaded file
    if media_sub_type == "audio" or media_sub_type == "video" then
      convert_to_flv(basepath,new_path)
      basepath_to_delete = basepath
      File.delete(basepath_to_delete)
      basepath = new_path + ".flv"
    end

    #if uploaded file is ppt or pptx or odp then convert to swf
    if media_sub_type == "ppt" or media_sub_type == "pptx" or media_sub_type == "odp" then
      pdf_file = new_path + ".pdf"
      ppt_file = new_path + ".ppt"
      swf_file = new_path + ".swf"
      image_path = new_path + ".jpg"
      convert_to_swf(path_to_save,pdf_file,swf_file,image_path,basepath,media_sub_type,ppt_file)
      basepath = swf_file
    end

    if media_sub_type == "pdf" then
      pdf_file = new_path + ".pdf"
      swf_file = new_path + ".swf"
      image_path = new_path + ".jpg"
      system "pdf2swf "+pdf_file+" -o "+swf_file+" -T 9 -f"
      extract_image(pdf_file,image_path,"document")
      basepath = swf_file
    end

    if media_sub_type == "doc" or media_sub_type == "docx" then
      pdf_file = new_path + ".pdf"
      swf_file = new_path + ".swf"
      image_path = new_path + ".jpg"
      system "public/unoconv-0.4/unoconv -f pdf -o " + path_to_save + " -e Quality=100 "+basepath
      system "pdf2swf "+pdf_file+" -o "+swf_file+" -T 9 -f"
      extract_image(pdf_file,image_path,"document")
      basepath = swf_file
    end

    url = basepath.gsub("public/","")
    file_size = File.size(basepath)

    # save to database
    is_saved = save_to_database(path_to_save,type,file_size,url,course_file_name)

    #If the flv is a video then extract image
    if type == "video" then
      video_pic(new_path,basepath)
    end # TODO: else what ?
    return is_saved
  end

  #control comes here to delete the uploaded file if it is virus affected.
  def remove_virus_affected_file(error_file_path,basepath)
    File.open(error_file_path, "w+") { |f| f.write("virus") }
    @course.destroy
    FileUtils.rm_r basepath
  end

  #control comes here for convertion of ppt to swf.
  #Takes required paths as input and process the ppt to pdf and pdf to swf with system commands and stores the output in the data folder.
  #Also extracts a image from pdf and we get swf file, delete the unnecessary files like ppt, pdf.
  def convert_to_swf(path_to_save,pdf_file,swf_file,image_path,basepath,mime_extension,ppt_file)
    #system "java -Doffice.home=/usr/lib/openoffice -jar public/jodconverter-core-3.0-beta-3/lib/jodconverter-core-3.0-beta-3.jar " + basepath + " " + pdf_file
    if mime_extension == "pptx"
      system "public/unoconv-0.4/unoconv -f ppt -o " + path_to_save + " "+basepath
      system "public/unoconv-0.4/unoconv -f pdf -o " + path_to_save + " -e Quality=100 "+ppt_file
    else
      system "public/unoconv-0.4/unoconv -f pdf -o " + path_to_save + " -e Quality=100 "+basepath
    end
    system "pdf2swf "+pdf_file+" -t "+swf_file
    extract_image(pdf_file,image_path,"presentation")
    File.delete(basepath)
    File.delete(pdf_file)
    #if the uploaded file is pptx then delete the ppt file
    if mime_extension == "pptx"
      File.delete(ppt_file)
    end # TODO:else what?
  end

  def find_launch_file(xml_data)
    doc = REXML::Document.new(xml_data)
    doc.elements.each("manifest/resources/resource") { |resource_element|
      launch_file = resource_element.attributes["href"]
      return launch_file
    }
  end

  #control comes here for auto finding the title of e-learning course
  def find_course_title(xml_data)
    doc = REXML::Document.new(xml_data)
    doc.elements.each("manifest/organizations/organization/item/title") { |resource_element|
      title = resource_element.text
      return title
    }
  end

  #control comes here for saving the details into db.
  def save_to_database(basepath,type,dirsize,url,title)
    if dirsize > 0
      @course.course_name = title
      @course.url = url
      @course.path = basepath
      @course.size = dirsize
      @course.typeofcourse = type
      @course.save
      return true
    else
      @course.destroy
      return false
    end
  end

  #control comes here for setting the input, output values for extracting an image from a video.
  def video_pic(new_path,basepath)
    options = {
      :input_file => basepath,
      :output_file => new_path + ".jpg",
    }
    extract_image(new_path,options,"video")
  end

  #Control comes here for extracting the image if it is video file. Also extracts image from pdf.
  #install 'convert' for converting a page of pdf to image
  def extract_image(new_path,options,type)
    if type == "video" then
      command = "ffmpeg -ss 3 -t 1 -i $input_file$ -r 1 -s 120x90 -f image2 $output_file$"
      new_path = new_path.gsub("public/", "")
      video_frame = (new_path +".jpg")
      @course.image_file_name = video_frame
      @course.save
      transcoder = RVideo::Transcoder.new
      transcoder.execute(command, options)
    else
      system "convert "+new_path+"[0] -resize 120x90 "+ options
      options = options.gsub("public/","")
      @course.image_file_name = options
      @course.save
    end
  end

  #control comes here for convertions of audio or video files to flv file.Rvideo is needed for this.
  def convert_to_flv(basepath,new_path)
    options = {
      :input_file => basepath,
      :output_file => new_path + ".flv"
    }
    command = "ffmpeg -i $input_file$ -ab 56 -ar 44100 -r 15 -y -qscale 9 $output_file$"
    transcoder = RVideo::Transcoder.new
    transcoder.execute(command, options)
  end

  #control comes here to check for virus.It returns an integer value 0 if it is not virus affected else returns a non-zero value.
  #ClamAV is needed for this.
#  def virus_scan(file_path)
#    clam = ClamAV.instance
#    clam.loaddb()
#    value = clam.scanfile(file_path)
#    return value
#  end

  def get_error_status
    error_file_path = "public/data/E" + current_user.id.to_s
    @error_status = File.read(error_file_path)
  end

  def select_launch_file
    @course = Course.find_by_id(params[:id])
    @valid_files = Array.new
    basepath = @course.path
    Dir::chdir(basepath) do
      files = File.join("**")
      @files = Dir.glob(files)
    end
    @files.each { |file|
      file_extension = File.extname(file)
      if file_extension.include? "html" or file_extension.include? "swf" or file_extension.include? "htm" then
        @valid_files << file
      end
    }
    if @valid_files.nil? or @valid_files.blank? then
      FileUtils.rm_r basepath
      @course.destroy
      flash[:nonscorm_notice] = "This course does not contain launch files"
      redirect_to("/course_store/upload_course")
    end
  end

  def map_launch_file
    @course = Course.find_by_id(params[:id])
    url = @course.path.gsub("public/","")
    launchfilepath =  url + '/' + params[:launchfile]
    @course.update_attribute(:url,launchfilepath)
    redirect_to("/course_store/course_details/#{@course.id}")
  end

  def processing
    tenantfilepath = "public/files/" + current_user.id.to_s
    course_id = File.read(tenantfilepath)
    @course = Course.find_by_id(course_id)
    error_file_path = "public/files/E" + current_user.id.to_s
    is_nonscorm = File.read(error_file_path)
    File.delete(tenantfilepath)
    File.delete(error_file_path)
    if is_nonscorm == "nonscorm"
      redirect_to("/course_store/select_launch_file/#{@course.id}")
    else
      redirect_to("/course_store/course_details/#{@course.id}")
    end
  end

  def course_details
    @course = Course.find_by_id(params[:id])
    @seller = Tenant.find_by_user_id(current_user.id)
  end
  
  def edit
    @course = Course.find_by_id(params[:id])
    @seller = Tenant.find_by_user_id(current_user.id)
  end

  def save_course_details
    @seller = Tenant.find_by_user_id(current_user.id)
    @course = current_user.courses.find_by_id(params[:id])
    @course.update_attribute(:lms_cs,"course_store")
    @course.update_attribute(:vendor,@seller.organization)
    @course.update_attributes(params[:course])
    redirect_to("/course_store/preview/"+(params[:id].to_s))
  end

  def update
    @course = current_user.courses.find(params[:id])
    @course.update_attribute(:lms_cs,"course_store")
    is_image = true
    if params[:course][:image].nil? or params[:course][:image].blank? then
      @course.update_attributes(params[:course])
    else
      file_name = params[:course][:image].original_filename
      media_type = ((MIME::Types.type_for(file_name))[0]).media_type
      if media_type != "image" then
        is_image = false
      else
        @course.update_attributes(params[:course])
      end
    end
    if !(params[:course_price].nil? or params[:course_price].blank?) then
      @course.update_attribute(:course_price,params[:course_price])
    end
    if is_image == true then
      redirect_to("/course_store/sellers_courses/#{current_user.id}")
    else
      flash[:wrong_image_type] = "Upload only images"
      redirect_to("/course_store/edit/"+@course.id.to_s)
    end
  end

  def destroy
    @course = current_user.courses.find(params[:id])
    FileUtils.rm_r @course.path
    @course.destroy
    redirect_to("/course_store/sellers_courses/#{current_user.id}")
  end

  def preview
    @course = Course.find_by_id(params[:id])
    @seller = Tenant.find_by_user_id(current_user.id)
  end

  def publish
    @course = Course.find_by_id(params[:id])
    @seller = Tenant.find_by_user_id(current_user.id)
  end

  def save_account_details
    @course = Course.find_by_id(params[:id])
    @seller = Tenant.find_by_user_id(current_user.id)
    @seller.update_attributes(params[:seller])
    if params[:commit].eql? "Publish"
      @course.published = 1
    else
      @course.published = 0
    end
    @course.save
    redirect_to("/course_store/sellers_courses/#{current_user.id}")
  end
end