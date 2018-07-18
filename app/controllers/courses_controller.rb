#Manages course related functionalities
#Authors : Karthik,Surupa(reports),Aarthi(Audio/video)
require 'zip/zip'
require 'fileutils'
require 'find'
require 'rvideo'
require 'mime/types'
require 'rubygems'
require 'fastercsv'

class CoursesController < ApplicationController

  before_filter :login_required
  before_filter :is_expired?

  # Control comes from users/set_admin_password.html or sessions/new.html
  def index
    #SCROOGE: When using relationships to implement scrooge there use ': include => user' where user is model name
    courses_index
  end

  def course_type_selection

  end

  #control comes here when course is uploaded in IE
  def upload_course
    if params.include? 'Filedata' then
      uploaded_file = params[:Filedata]
      file_name = uploaded_file.original_filename
      course_file_name = file_name.split('.')[0]
      extension = File.extname(file_name)
      directory = "public/data"
      @course = Course.new
      @course.save
      @course.update_attribute(:user_id,params[:tenant])
      course_id = @course.id.to_s
      tenantfilepath = "public/files/" + params[:tenant]
      File.open(tenantfilepath, "w+") { |f| f.write(course_id) }
      error_file_path = "public/files/E" + params[:tenant]
      File.open(error_file_path, "w+") { |f| f.write("true") }
      mime_obj = MIME::Types.type_for(file_name)
      if mime_obj.nil? or mime_obj.blank? then
        File.open(error_file_path, "w+") { |f| f.write("false") }
        @course.destroy
        return
      end #TODO: else what?

      media_type = ((MIME::Types.type_for(file_name))[0]).media_type
      sub_type = ((MIME::Types.type_for(file_name))[0]).sub_type
      mime_extension = ((MIME::Types.type_for(file_name))[0]).extensions[0]
      logger.info"upload_valid(media_type,sub_type,mime_extension) #{upload_valid(media_type,sub_type,mime_extension).inspect}"
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
        when type == "e-learning" then elearning(new_path,extension,uploaded_file,error_file_path,basepath,course_file_name,type)
        when sub_type == "flv" || sub_type == "shockwave-flash" then aud_vid_ppt_flv_swf(basepath,name,course_id,extension,uploaded_file,error_file_path,type,course_file_name,sub_type)
        when media_type == "audio" || media_type == "video" then aud_vid_ppt_flv_swf(basepath,name,course_id,extension,uploaded_file,error_file_path,type,course_file_name,media_type)
        else aud_vid_ppt_flv_swf(basepath,name,course_id,extension,uploaded_file,error_file_path,type,course_file_name,mime_extension)
        end
        if is_saved == false
          File.open(error_file_path, "w+") { |f| f.write("false") }
          @course.destroy
          return
        end
      else
        File.open(error_file_path, "w+") { |f| f.write("processing") }
        @course.destroy
        return
      end
      redirect_to("/courses/processing/#{params[:tenant]}")
    end    
  end

  #Control comes here if the uploaded file is SCORM, Non-SCORM.
  #It takes the needed paths as arguments, reads the uploaded file, unzips,checks for virus and saves to db.
  #Also returns a variable is_saved as true if the upload process and saving process is done perfectly else returns false.
  def elearning(new_path,extension,uploaded_file,error_file_path,basepath,course_file_name,type)
    new_path = new_path + extension
    File.open(new_path, "wb") { |f| f.write(uploaded_file.read) }

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

    is_saved = true

    if valid_space(dirsize)
      # save to database
      is_saved = save_to_database(basepath,type,dirsize,url,title)

      # delete the zip file
      File.delete(new_path)
      return is_saved
    else
      FileUtils.rm_r basepath

      # delete the zip file
      File.delete(new_path)
      return false
    end
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
    File.open(basepath, "wb") { |f| f.write(uploaded_file.read) }
    scan_value = virus_scan(basepath)
    if scan_value != 0 then
      remove_virus_affected_file(error_file_path,basepath)
      return
    end #TODO: else what?

    #if uploaded file is audio or video the convert it to flv and delete the actual uploaded file
    case
    when (media_sub_type == "audio" or media_sub_type == "video" or type == "video") then
      convert_to_flv(basepath,new_path)
      basepath_to_delete = basepath
      File.delete(basepath_to_delete)
      basepath = new_path + ".flv"


      #if uploaded file is ppt or pptx or odp then convert to swf
    when (media_sub_type == "ppt" or media_sub_type == "pptx" or media_sub_type == "odp") then
      pdf_file = new_path + ".pdf"
      swf_file = new_path + ".swf"
      image_path = new_path + ".jpg"
      convert_to_swf(pdf_file,swf_file,image_path,basepath,path_to_save)
      basepath = swf_file

    when media_sub_type == "pdf" then
      pdf_file = new_path + ".pdf"
      swf_file = new_path + ".swf"
      image_path = new_path + ".jpg"
      system "pdf2swf #{pdf_file} -o #{swf_file} -T 9 -f"
      extract_image(pdf_file,image_path,"document")
      basepath = swf_file


    when (media_sub_type == "doc" or media_sub_type == "docx") then
      pdf_file = new_path + ".pdf"
      swf_file = new_path + ".swf"
      image_path = new_path + ".jpg"
      system "unoconv -f pdf #{basepath}"
      system "pdf2swf #{pdf_file} -o #{swf_file} -T 9 -f"
      extract_image(pdf_file,image_path,"document")
      basepath = swf_file
    end

    url = basepath.gsub("public/","")

    dirsize = 0
    Find.find(path_to_save) do |file|
      dirsize += File.size(file)
    end

    is_saved = true

    if valid_space(dirsize)
      # save to database
      is_saved = save_to_database(path_to_save,type,dirsize,url,course_file_name)

      #If the flv is a video then extract image
      if type == "video" then
        video_pic(new_path,basepath)
      end
      return is_saved

    else
      FileUtils.rm_r path_to_save
      return false
    end
  end

  #control comes here for convertion of ppt to swf.
  #Takes required paths as input and process the ppt to pdf and pdf to swf with system commands and stores the output in the data folder.
  #Also extracts a image from pdf and we get swf file, delete the unnecessary files like ppt, pdf.
  def convert_to_swf(pdf_file,swf_file,image_path,basepath,path_to_save)
    system "unoconv -f pdf #{basepath}"
    system "pdf2swf #{pdf_file} -t #{swf_file}"
    extract_image(pdf_file,image_path,"presentation")
    #File.delete(basepath)
    #File.delete(pdf_file)
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
      system "convert #{new_path}[0] -resize 120x90 #{options}"
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

  # launch course for a learner
  def launch_course
    @type = params[:type]
    @learner_course = Learner.find(params[:id])
    if @learner_course.lesson_status == "not attempted"
      @learner_course.update_attribute(:test_start_time,Time.now)
    end
    @learner_course.update_attribute(:no_of_times_attempted,(@learner_course.no_of_times_attempted + 1))
    @course = Course.find(@learner_course.course_id)
    case
    when @type == "e-learning" then
      if @course.is_scorm == false
        @learner_course.update_attribute(:lesson_status, "completed")
        course_status_based_updation(@course,@learner_course)
      end
    when @type == "audio" || @type == "video"  then
      #      @audvid = Learner.find_by_course_id_and_user_id(params[:id], current_user.id)
      #      @course_url = Course.find_by_id(@audvid.course_id).url
    when @type == "presentation"  then
      #      @ppt = Learner.find_by_course_id_and_user_id(params[:id], current_user.id)
      #      @course_url = Course.find_by_id(@ppt.course_id).url
    when @type == "flash"  then
      #      @swf = Learner.find_by_course_id_and_user_id(params[:id], current_user.id)
      #      course = Course.find_by_id(@swf.course_id)
      #      @course_url = course.url
      @learner_course.update_attribute(:lesson_status, "completed")
      course_status_based_updation(@course,@learner_course)
    end
    redirect_to("/scorm/launch/#{@learner_course.course_id}?learner_id=#{@learner_course.id}&type=#{params[:type]}")
  end

  def learner_myaccount
  end

  def update_learner_myaccount
    @user = User.find_by_id(current_user.id)
    if !params[:password].nil? and !params[:password].blank? then
      @user.update_attribute(:crypted_password, Digest::SHA1.hexdigest(params[:password]))
    end #TODO: else what?
    if @user.update_attributes(params[:user]) then
      flash[:myaccount_changes] = "Details updated successfully"
      redirect_to('/mycourses')
    end #TODO: else what?
  end

  # saves the selected theme.
  def set_theme
    @tenant = Tenant.find_by_custom_url_and_user_id(request.subdomain,current_user.id)
    @tenant.theme = '#'+params[:color]
    @tenant.text_color = '#'+params[:text_color]
    @tenant.save
  end

  def set_feedback
    @courses = Course.find_all_by_user_id(current_user.id)
    for learner in @courses
      learner.feedback = params[:feedback]
      learner.save
    end
  end

  #After the course completion by the learner, based on the condition that if the feedback
  def give_feedback
    learner = Learner.find_by_id(params[:id])
    course_object = Course.find_by_id(learner.course_id)
    assessment_obj = AssessmentsController.new
    if learner.lesson_status == "completed" or learner.lesson_status == "Completed"
      unless learner.package_id.nil? or learner.package_id.blank?
        next_assessment_course,assessment_course = assessment_obj.new_pick_next_assessment_course_in_package(learner.package,course_object,"course")
        # if the next_assment is empty from the method then it means he has been assigned to all the assmts in that package and no more assmnts are left.
        unless next_assessment_course == ""
          if assessment_course == "assessment"
          #        store_learner_details(next_assessment,current_user.user_id,current_user)
          admin_user = course_object.user
          assessment_obj.assign_next_assessment_to_learner(next_assessment_course,admin_user,current_user,learner.package_id)
          elsif assessment_course == "course"
            admin_user = course_object.user
            assessment_obj.assign_next_course_to_learner(next_assessment_course,admin_user,current_user,learner.package_id)
          end
        end
      end
  end
    case(learner.type_of_test_taker)
    when "learner"
      if learner.lesson_status == "completed" or learner.lesson_status == "Completed" and course_object.feedback == "checked" and learner.rating == 0 then
        redirect_to("/courses/feedback/#{params[:id]}?course_id=#{course_object.id}")
      else
        redirect_to("/mycourses")
      end
    when "admin"
      redirect_to("/courses")
    end

  end

  def feedback
  end

  #control comes here to calculate the required objects before going to mycourses page.
  def mycourses
    @tenant = Tenant.find_by_custom_url_and_user_id(request.subdomain,current_user.user_id)
    @learners = Learner.find_all_by_user_id_and_type_of_test_taker_and_active(current_user.id,"learner","yes",:order => "id DESC")
  end

  def mypapers
    @tenant = Tenant.find_by_custom_url_and_user_id(request.subdomain,current_user.user_id)
    @learners = Learner.find_all_by_user_id_and_type_of_test_taker_and_active(current_user.id,"evaluator","yes",:order => "id DESC")
  end


  # To edit the course details
  def edit
    @course = current_user.courses.find(params[:id])

    @tenant = Tenant.find_by_custom_url_and_user_id(request.subdomain,current_user.id)
    time = Time.now.getutc
    @zone = Tenant.find_by_custom_url_and_user_id(request.subdomain,current_user.id).zone
    if @zone.include? "+"
      offset = @zone.gsub('+','')
    else
      offset = @zone.gsub('-','')
    end
    offset_hour = offset.split(':')[0].to_i
    offset_min = offset.split(':')[1].to_i
    total_offset = (offset_hour * 60 * 60) + (offset_min * 60)

    if @zone.include? "+"
      @show_time = time + total_offset
    else
      @show_time = time - total_offset
    end
    if @show_time.strftime("%p")=="AM"
      @hour = @show_time.hour
    elsif (@show_time.strftime("%p")=="PM" and @show_time.hour == 12) or (@show_time.strftime("%p")=="AM" and @show_time.hour == 0)
      @hour = 12
    else
      @hour = @show_time.hour - 12
    end
    @days = (Date.new(@show_time.year,12, 31) << (12-@show_time.month)).day
    @months = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
    @years = ['2011','2012','2013','2014','2015']

    if @zone.include? "+"
      show_start_course_time = @course.start_time + total_offset
    else
      show_start_course_time = @course.start_time - total_offset
    end

    selected_start_day = show_start_course_time.strftime('%d')
    selected_start_month = show_start_course_time.month
    selected_start_year = show_start_course_time.strftime('%Y')

    @selected_start_hour = show_start_course_time.strftime('%I').to_i
    @selected_start_min = show_start_course_time.strftime('%M').to_i
    @selected_start_am_pm = show_start_course_time.strftime('%p')

    @calander_start_date = selected_start_year + "-" + selected_start_month.to_s + "-" + selected_start_day.to_s
#    @calander_start_date = selected_start_month[0..2] + " " + selected_start_day.to_s + ", " + selected_start_year

    if @course.schedule_type == "fixed" then

      if @zone.include? "+"
        show_end_course_time = @course.end_time + total_offset
      else
        show_end_course_time = @course.end_time - total_offset
      end

      selected_end_day = show_end_course_time.strftime('%d')
      selected_end_month = show_end_course_time.month
      selected_end_year = show_end_course_time.strftime('%Y')

      @selected_end_hour = show_end_course_time.strftime('%I').to_i
      @selected_end_min = show_end_course_time.strftime('%M').to_i
      @selected_end_am_pm = show_end_course_time.strftime('%p')

      @calander_end_date = selected_end_year + "-" +selected_end_month.to_s + "-" + selected_end_day
    end
  end

  #To update the edited details
  def update
    @course = current_user.courses.find(params[:id])
    if params[:checkbox] == "on" then
      @course.update_attribute("feedback","checked")
    else
      @course.update_attribute("feedback","not checked")
    end
    save_schedule_details()
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
    (params[:course].include? "reattempt")?@course.update_attribute(:reattempt,"on"):@course.update_attribute(:reattempt,"off")
    (params[:course].include? "course_expiry")?@course.update_attribute(:course_expiry,true):@course.update_attribute(:course_expiry,false)

    if is_image == true then
      redirect_to("/courses")
    else
      flash[:wrong_image_type] = "Upload only images"
      redirect_to("/edit/"+@course.id.to_s)
    end
  end

  #To destroy the course and corresponding learners
  def destroy
    @course = Course.find(params[:id])
    @learners = Learner.find_all_by_course_id(@course.id)
    @learners.each { |learner|
      decrease_course_columns_while_deleting(@course,learner)
      learner.destroy
    }
    FileUtils.rm_r @course.path
    @course.destroy
    redirect_to("/courses")
  end


  #To save the new course details
  def save_course_details
    @course = current_user.courses.find_by_id(params[:id])
    @course.update_attributes(params[:course])
    if current_user.typeofuser == "seller"
      tenant = Tenant.find_by_user_id(current_user.id)
      @course.update_attribute(:lms_cs, "course_store")
      @course.update_attribute(:vendor, tenant.organization)
      course_expiry = params[:course_expiry_year].to_i*365 + params[:course_expiry_month].to_i*30
      @course.update_attribute(:course_expiry, course_expiry)
    end
    if params[:checkbox] != "on" then
      @course.update_attribute("feedback","not checked")
    end #TODO: else what?
    redirect_to("/courses/preview/"+(params[:id].to_s))
  end

  def schedule_course
    @course = current_user.courses.find_by_id(params[:id])
    time = Time.now.getutc
    @zone = Tenant.find_by_custom_url_and_user_id(request.subdomain,current_user.id).zone
    if @zone.include? "+"
      offset = @zone.gsub('+','')
    else
      offset = @zone.gsub('-','')
    end
    offset_hour = offset.split(':')[0].to_i
    offset_min = offset.split(':')[1].to_i
    total_offset = (offset_hour * 60 * 60) + (offset_min * 60)
    if @zone.include? "+"
      @show_time = time + total_offset
    else
      @show_time = time - total_offset
    end
    if @show_time.strftime("%p")=="AM"
      @hour = @show_time.hour
    elsif (@show_time.strftime("%p")=="PM" and @show_time.hour == 12) or (@show_time.strftime("%p")=="AM" and @show_time.hour == 0)
      @hour = 12
    else
      @hour = @show_time.hour - 12
    end
    @days = (Date.new(@show_time.year,12, 31) << (12-@show_time.month)).day
    @months = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
    @years = ['2011','2012','2013','2014','2015']

  end

  def save_schedule_details
    if params[:course][:schedule_type] == "open"
      open_schedule_calendar = params[:open][:start_schedule].split("-")
      start_date_time = time_conversions(open_schedule_calendar[2],open_schedule_calendar[1],open_schedule_calendar[0],params[:open][:hour],params[:open][:min],params[:open][:am_pm])
      end_date_time = start_date_time
    else
      fixed_start_schedule_calendar = params[:fixed_start][:start_schedule].split("-")
      start_date_time = time_conversions(fixed_start_schedule_calendar[2],fixed_start_schedule_calendar[1],fixed_start_schedule_calendar[0],params[:fixed_start][:hour],params[:fixed_start][:min],params[:fixed_start][:am_pm])
      fixed_end_schedule_calendar = params[:fixed_end][:start_schedule].split("-")
      end_date_time = time_conversions(fixed_end_schedule_calendar[2],fixed_end_schedule_calendar[1],fixed_end_schedule_calendar[0],params[:fixed_end][:hour],params[:fixed_end][:min],params[:fixed_end][:am_pm])
    end
    @tenant = Tenant.find_by_custom_url_and_user_id(request.subdomain,current_user.id)
    @zone = @tenant.zone
    if @zone.include? "+"
      @offset = @zone.gsub('+','')
    else
      @offset = @zone.gsub('-','')
    end
    offset_hour = @offset.split(':')[0].to_i
    offset_min = @offset.split(':')[1].to_i
    total_offset = (offset_hour * 60 * 60) + (offset_min * 60)
    if @zone.include? "+"
      start_time = start_date_time - total_offset
      end_time = end_date_time - total_offset
    else
      start_time = start_date_time + total_offset
      end_time = end_date_time + total_offset
    end
    if params[:course][:schedule_type] == "open"
      end_time = start_time + (params[:no_of_active_days].to_i * 24 * 3600)
    end
    @course.update_attribute(:start_time,start_time)
    @course.update_attribute(:end_time,end_time)
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

  def save_course_schedule
    @course = current_user.courses.find_by_id(params[:id])
    @course.update_attributes(params[:course])
    save_schedule_details()

    redirect_to("/courses/preview/"+(params[:id].to_s))
  end

  #Saves the feedback given by the learner
  def save_feedback
    if params[:feedback][:rating].nil? or params[:feedback][:rating].blank?
      redirect_to("/courses/feedback/#{params[:id]}?course_id=#{params[:course_id]}")
    else
      @learner_object = Learner.find_by_course_id_and_user_id(params[:course_id], current_user.id)
      @learner_object.update_attribute(:rating, params[:feedback][:rating])
      @learner_object.update_attribute(:comments, params[:feedback][:comment])
      course_object = Course.find_by_id(params[:course_id])
      course_object.update_attribute(:total_no_of_ratings,course_object.total_no_of_ratings + @learner_object.rating)
      course_object.update_attribute(:no_of_rating_records,course_object.no_of_rating_records + 1)
      avg_rating = (course_object.total_no_of_ratings/course_object.no_of_rating_records).round
      course_object.update_attribute(:average_rating,avg_rating)
      if !(params[:feedback][:comment].nil? or params[:feedback][:comment].blank?)
        course_object.update_attribute(:no_of_comments,course_object.no_of_comments + 1)
      end
      redirect_to("/mycourses")
    end
  end

  #calculate the objects before going to comments page.
  def comments
    @completed = Learner.find_all_by_course_id_and_lesson_status(params[:id],'completed')
  end

  #redirect to preview page
  def preview
    if params.include? "assessment_id" then
      @assessment = Assessment.find_by_id(params[:assessment_id])
    elsif params.include? "id" then
      @course = Course.find_by_id(params[:id])
    else
      redirect_to("/courses")
    end
  end

  def get_error_status
    error_file_path = "public/files/E" + current_user.id.to_s
    @error_status = File.read(error_file_path)
  end

  def processing
    tenantfilepath = "public/files/" + current_user.id.to_s
    course_id = File.read(tenantfilepath)
    @course = Course.find_by_id(course_id)
    error_file_path = "public/files/E" + current_user.id.to_s
    error_file_message = File.read(error_file_path)
    unless @course.nil?
      @course.update_attribute(:tenant_id,current_user.tenant_id)
      if error_file_message == "nonscorm"
        redirect_to("/courses/select_launch_file/#{@course.id}")
      else
        redirect_to("/courses/course_details/#{@course.id}")
      end
    else
      if error_file_message == "false" or error_file_message == "nonscorm"
        flash[:nonscorm_notice] = "File format not supported"
      else
        flash[:nonscorm_notice] = "Your current plan does not support course upload"
      end
      redirect_to("/courses/upload_course/#{current_user.id}")
    end
  end

  #calculate the required object before going to course_details page
  def course_details
    @course = Course.find_by_id(params[:id])
    learner = Learner.find_by_course_id_and_type_of_test_taker(@course,"admin")
    if learner.nil?
      learner = @course.store_admin_details(@course,current_user)
    end
    if @course.current_learner_id.nil? or @course.current_learner_id.blank?
      @course.update_attribute(:current_learner_id,learner.id)
    end
  end

  #selects the launch file for a scorm, non-scorm course.
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
      redirect_to("/courses/upload_course/#{current_user.id}")
    end
  end

  def map_launch_file
    @course = Course.find_by_id(params[:id])
    @course.update_attribute(:is_scorm, false)
    url = @course.path.gsub("public/","")
    launchfilepath =  url + '/' + params[:launchfile]
    @course.update_attribute(:url,launchfilepath)
    redirect_to("/courses/course_details/#{@course.id}")
  end

  def save_selected
    @tenant = Tenant.find_by_custom_url_and_user_id(request.subdomain,current_user.id)
    @tenant.update_attribute('selected_quarter', params[:quarter])
  end

  #Saves customize page details.
  def customize
    @tenant = Tenant.find_by_custom_url_and_user_id(request.subdomain,current_user.id)
    if params.include? "commit"
      if params[:tenant][:logo].nil? or params[:tenant][:logo].blank? then        
        @tenant.update_attributes(params[:tenant])
        redirect_to("/courses")
      else
        file_name = params[:tenant][:logo].original_filename
        media_type = ((MIME::Types.type_for(file_name))[0]).media_type
        if media_type != "image" then
          flash[:wrong_image_type] = "Upload only images"
        else
          @tenant.update_attributes(params[:tenant])
          redirect_to("/courses")
        end
      end
    end
  end

  def kesdee_course_upload

  end

  def manage_learners
    @course = Course.find(params[:id])
    #remove_bounced_from_learners(@course)
  end

  def manage_groups
    unless params[:group].nil?
      course = Course.find(params[:id])

      #call this method for removing learners from learner table whose mails have been bounced.
      #remove_bounced_from_learners(course)

      #call this method for unassinging groups which have been already assigned in assessment.groups_assinged column and inactive the leaner.active column for the associated learners.
      #    unassign_groups_and_associated_learners(course,params[:group])
      #
      #    arr_groups_assigned = Array.new
      #    #update the groups_assigned column in assessments table
      #    unless params[:group].nil? then
      #      params[:group].each { |g|
      #        unless arr_groups_assigned.include? g[0].to_s then
      #          arr_groups_assigned << g[0].to_s
      #        end
      #      }
      #    end
      #    new_groups_assigned = arr_groups_assigned.join(',')
      #    course.update_attribute(:groups_assigned, new_groups_assigned)
      #
      #    #now for each group the user requested to assign, calculate the number of learners (who activated and inactivate separately) and enqueue in delayed_jobs
      #    groups_to_be_assigned = course.groups_assigned.split(',')
      groups_to_be_assigned = params[:group]
      groups_assign(groups_to_be_assigned,course)
      flash[:wait_feedback] = "The learners are being assigned. The process will take some time. Please check later for the updated learner count."
    end
    redirect_to("/courses")
  end

  def manage
    #    @email_error_count = Array.new
    @course = Course.find_by_id(params[:id])

    #    remove_bounced_from_learners(@assessment)

    no_of_learners_to_be_deleted = 0
    remaining_learners_from_already_assigned = Array.new
    remaining_learners_from_already_assigned = find_remaining_learners_from_already_assigned()
    @learners = Learner.find_all_by_course_id_and_active(params[:id],"yes", :conditions => ["type_of_test_taker != 'admin' AND group_id = ?",params[:group_id]])
    existing_learners_ids = Array.new
    for learner in @learners
      existing_learners_ids << learner.user_id
    end
    learners_to_be_deleted = existing_learners_ids - remaining_learners_from_already_assigned
    for learner_id in learners_to_be_deleted
      no_of_learners_to_be_deleted += 1
      learner_make_inactive = Learner.find_by_user_id_and_course_id(learner_id,@course.id, :conditions => ["type_of_test_taker != 'admin' AND group_id = ?",params[:group_id]])
      learner_make_inactive.update_attribute(:active,"no")
      decrease_course_columns_while_deleting(@course,learner_make_inactive)
    end
    learners_for_course_adding_ids = Array.new
    learners_for_course_adding_ids = learners_for_course_added_mails()
    learners_for_course_adding = Array.new
    learners_for_course_adding_ids.each {|user_id|
      learners_for_course_adding << User.find(user_id)
    }
    learners_for_signup = Hash.new
    learners_for_signup = map_login_to_email()
    learners_valid_for_signup = Hash.new
    learners_valid_for_signup = validate_email(learners_for_signup)
    no_of_learners_assigned = 0
    no_of_learners_assigned += save_and_send_mails(learners_for_course_adding,learners_valid_for_signup,current_user,@course.id)
    if no_of_learners_to_be_deleted == 1 then
      flash[:number_of_deleted_learner] = "#{no_of_learners_to_be_deleted} learner removed from course #{@course.course_name}"
    elsif no_of_learners_to_be_deleted > 0 then
      flash[:number_of_deleted_learner] = "#{no_of_learners_to_be_deleted} learners removed from course #{@course.course_name}"
    end
    if (@already_assigned.nil? or @already_assigned.blank?) and (@admin.nil? or @admin.blank?) and (@other_org.nil? or @other_org.blank?) and (@incorrect_mail_count == 0) then
      if no_of_learners_assigned == 1 then
        flash[:number_of_mails] = "#{no_of_learners_assigned} learner assigned to course #{@course.course_name}"
      elsif no_of_learners_assigned > 1 then
        flash[:number_of_mails] = "#{no_of_learners_assigned} learners assigned to course #{@course.course_name}"
      end
      redirect_to("/courses")
    else
      redirect_to("/courses/manage_learners/#{@course_id}")
    end
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
  
  def validate_email(learners_for_signup)
    email_pattern = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/
    valid_learners = Hash.new
    @incorrect_mail_count = 0
    learners_for_signup.each { |email,login|
      if email_pattern.match(email) then
        valid_learners[email] = login
      else
        @incorrect_mail_count += 1
        flash[:incorrect_mail_message] = "#{email} is incorrect"
      end
    }
    return valid_learners
  end

  def find_remaining_learners_from_already_assigned
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


  def learners_in_group
    @course = Course.find(params[:id])
    @group = Group.find(params[:group_id])
    @assigned_learners = @course.learners.find(:all, :conditions => ["type_of_test_taker = 'learner' AND active='yes' AND group_id= ?",params[:group_id]])
    @total_learners = @group.users.find(:all, :include=> "user", :conditions=> ["user_id = ? AND deactivated_at IS NULL",current_user.id])
  end

  #this method unassigns the groups from course.groups_assigned column and also inactivates the learner.active column for the associated learners.
  def unassign_groups_and_associated_learners(course,params_group)
    #put the group ids which come from params into an array
    unless params_group.nil? then
      arr_unassigned_groups = Array.new
      params_group.each { |g|
        arr_unassigned_groups << g[0]
      }
    else
      arr_unassigned_groups = Array.new
    end

    #calculate the group_ids for which learners have to be unassigned.logic is 'assessment.groups_assigned - params[group_ids]' which is stored in
    unless course.groups_assigned.nil? then
      arr_already_assigned_groups = course.groups_assigned.split(',')
      arr_to_be_unassigned_groups = arr_already_assigned_groups - arr_unassigned_groups

      arr_to_be_unassigned_groups.each { |group|
        users_to_be_unassigned = current_user.user.find(:all,:conditions => ["group_id = ?",group])

        users_to_be_unassigned.each { |user|
          course.learners.find_by_user_id(user.id, :conditions => "type_of_test_taker = 'learner'").update_attribute(:active,"no")
          #          update_assessment_columns(assessment,assessment.learners.find_by_user_id(user.id))
        }
      }
    end
  end

  #this method takes array of group_ids for which learners have to be assigned. It calculates learners_for_course_adding and learners_valid_for_signup and pushes into delayed_jobs table.
  def groups_assign(groups_to_be_assigned,course)
    groups_delayed = Array.new
    groups_to_be_assigned.each { |g|
      groups_delayed << g[0].to_i
    }
    course_id = course.id
    current_user_id = current_user.id

    course_obj = CoursesController.new
    course_obj.delay.calculate_delayed_group_learners(groups_delayed,current_user_id,course_id)
#    delayed_id = Delayed::Job.enqueue(AssigningJob.new(groups_delayed,current_user_id,course_id,"assign_to_course"))

#    groups_to_be_assigned.each { |g|
#
#      learners_for_course_adding = Array.new
#      learners_valid_for_signup = Array.new
#
#      learners_for_course_adding = current_user.user.find(:all,:conditions => ["group_id = ? AND crypted_password IS NOT NULL AND deactivated_at IS NULL",g[0].to_i])
#      learners_valid_for_signup = current_user.user.find(:all,:conditions => ["group_id = ? AND crypted_password IS NULL AND deactivated_at IS NULL",g[0].to_i])
#
#      Delayed::Job.enqueue(AssigningJob.new(learners_for_course_adding,learners_valid_for_signup,current_user,course.id,"assign_to_course"))
#    }
  end

  def calculate_delayed_group_learners(groups_to_be_assigned,current_user_id,assessment_course_id)
    current_user = User.find(current_user_id)

    groups_to_be_assigned.each { |g|
      learners_for_course_adding = current_user.user.find(:all,:conditions => ["group_id = ? AND crypted_password IS NOT NULL AND deactivated_at IS NULL",g])
      learners_valid_for_signup = current_user.user.find(:all,:conditions => ["group_id = ? AND crypted_password IS NULL AND deactivated_at IS NULL",g])
      save_and_send_mails(learners_for_course_adding,learners_valid_for_signup,current_user,assessment_course_id)
    }
  end

  #new code: With groups
  def save_and_send_mails(learners_for_course_adding,learners_valid_for_signup,current_user,course_id)
    @final_signup_learners = Array.new     #Creates a global hash to store filtered learners for sending signup mail.
    final_course_added_learners = Array.new
    @total_final_course_added_learners = Array.new
    @already_assigned = Array.new
    @admin = Array.new
    @other_org = Array.new
    @course = Course.find(course_id)
    unless learners_valid_for_signup.nil? or learners_valid_for_signup.blank? then
      learners_valid_for_signup.each { |learner|
        if valid_assign(@course.id,current_user)
          @user = User.find_by_email(learner.email)
          #          final_signup_learners << learner.email
          case
          when (@user.user_id == current_user.id or @user.id == current_user.id) then     # whether the learner is for current admin or not or whether admin is assigning himself as learner
            @learner = Learner.find_by_course_id_and_user_id_and_type_of_test_taker(course_id,@user.id,"learner")
            if @learner.nil? then   # whether the learner is already present or not
              if (if current_user.typeofuser == "individual buyer" or current_user.typeofuser == "corporate buyer" then valid_assign(@course.id,current_user) else true end)
                store_learner_details(@course,current_user,@user,"")
                fill_signup_course_added_array(@user)
              end
            elsif !@learner.nil? and @learner.active == "no" then        # if learner is existing in learners table with active status "no" then just change the status to "yes"No need to add new record for him again
              @learner.update_attribute(:active,"yes")
              fill_signup_course_added_array(@learner.user)
              increase_course_columns_while_assigning(@course,@learner)
            end
          end
        end
      }
    end

    #dont write final_course_added_learners= total_final_course_added_learners = learners_for_course_adding. This doesnt work.. they make use of same address and mem space.
    # so x=y=3, here if u make any changes on x they reflect on y also.
    
    final_course_added_learners = learners_for_course_adding
    #    total_final_course_added_learners.replace(final_course_added_learners)
    final_course_added_learners.each { |learner|
      @user = User.find_by_email(learner.email)
     
      @learner = Learner.find_by_course_id_and_user_id_and_type_of_test_taker(course_id,@user.id,"learner")
      if @learner.nil? then   # whether the learner is already present or not
        if (if current_user.typeofuser == "individual buyer" or current_user.typeofuser == "corporate buyer" then valid_assign(@course.id,current_user) else true end)
          store_learner_details(@course,current_user,@user,"")
          fill_signup_course_added_array(@user)
        end
      elsif !@learner.nil? and @learner.active == "no" then        # if learner is existing in learners table with active status "no" then just change the status to "yes"No need to add new record for him again
        @learner.update_attribute(:active,"yes")
        fill_signup_course_added_array(@learner.user)
        increase_course_columns_while_assigning(@course,@learner)
      end
    }
    signup_count = send_signup_mails(@final_signup_learners,course_id,current_user)
    course_added_count = send_course_added_mails(@total_final_course_added_learners,course_id,current_user)
    return (signup_count + course_added_count)
  end

  def fill_signup_course_added_array(user)
    if user.crypted_password.nil? then
      @final_signup_learners << user.email
    else
      @total_final_course_added_learners << user
    end
  end

  #stores details in learners table for every learner.
  #We got to pass current_user because there wont be any session during
  #delayed job worker process is running.
  def store_learner_details(course,current_user,user,package_id)
    learner = Learner.new
    learner.course_id = course.id
    learner.user_id = user.id
    learner.admin_id = current_user.id
    learner.tenant_id = current_user.tenant.id
    learner.group_id = user.group_id
    learner.type_of_test_taker = "learner"
    if course.typeofcourse == "presentation" then
      learner.lesson_location = "0"
    end
    unless package_id.nil? and package_id.blank?
      learner.package_id = package_id
    end
    learner.save
    increase_course_columns_while_assigning(course,learner)
  end    

  def send_signup_mails(learners_for_signup,course_id,current_user)
    count = 0
    @course = Course.find(course_id)
    learners_for_signup.each { |learner|
      @user = User.find_by_email(learner)
      if valid_assign(course_id,current_user)
        if !@user.nil? then
          current_learner = Learner.find_by_course_id_and_user_id_and_type_of_test_taker(course_id,@user.id,'learner')
          result = signup_learner_notification_send_grid(@user,@course,@user.tenant,@user.tenant.user,current_learner)
          if result == "success" then
            count = count + 1
          end
        end
      end
    }
    return count
  end

  def send_course_added_mails(learners_for_course_adding,course_id,current_user)
    count = 0
    course = Course.find(course_id)
    learners_for_course_adding.each { |learner|
      @user = User.find_by_email(learner.email)
      if valid_assign(course_id,current_user)
        if !@user.nil? then
          @course = Course.find_by_id(course_id)
          #          @tenant = Tenant.find_by_user_id(@user.user_id)
          #          @subject    = 'A new course has been assigned to you.'
          #          if @user.activation_code.nil? then
          #            @url  = "https://#{@tenant.custom_url}.#{SITE_URL}"
          #          else
          #            @url  = "https://#{@tenant.custom_url}.#{SITE_URL}/activate/#{@user.activation_code}"
          #          end
          #          @html_body= course_added_html_body()
          #            email_result = aws_ses_send_email(@user.email,@subject,@html_body)
          current_learner = Learner.find_by_course_id_and_user_id_and_type_of_test_taker(course_id,@user.id,'learner')
          result = course_added_send_grid(@user,@course,@user.tenant,@user.tenant.user,current_learner)
          if result == "success" then
            count = count + 1
          end
        end
      end
    }
    return count
  end

  def course_added_send_grid(user,course,tenant,admin,learner)
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
      UserMailer.delay.send_mail(user,'course_added',tenant.id,from_replacements,subject_replacements,body_replacements)
#      Delayed::Job.enqueue(MailingJob.new(user,'course_added',tenant.id,from_replacements,subject_replacements,body_replacements))
      #      UserMailer.deliver_course_added(user,course_id)
      #return 'success' once sent without any errors
#      UserMailer.delay.course_added(user,course_id)
      return "success"
      #catch if any errors or exceptions and return that exception
    rescue Net::SMTPFatalError => exception
      return exception
    rescue Net::SMTPSyntaxError => exception
      return exception
    end
  end
  
  def signup_learner_notification_send_grid(user,course,tenant,admin,learner)
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
       UserMailer.delay.send_mail(user,'signup_learner_notification',tenant.id,from_replacements,subject_replacements,body_replacements)
#      Delayed::Job.enqueue(MailingJob.new(user,'signup_learner_notification',tenant.id,from_replacements,subject_replacements,body_replacements))
      #      UserMailer.deliver_signup_learner_notification(user,course_id)
      #return 'success' once sent without any errors
#    UserMailer.delay.signup_learner_notification(user,course_id)
      return "success"
      #catch if any errors or exceptions and return that exception
    rescue Net::SMTPFatalError => exception
      return exception
    rescue Net::SMTPSyntaxError => exception
      return exception
    end
  end

  def signup_learner_notification_html_body
    @html_body= "<html>
                <head>
                </head>
                <body>
    Hello #{@user.login},<br/><br/>

        You have been assigned a course named #{@course.course_name}. To view the course, click:<br/><br/>

        #{@url}<br/><br/>

        Your Email: #{@user.email}<br/><br/>

        Regards,<br/>
        LionSher Team<br/><br/>
        Supports IE 7, Mozilla Firefox 2.0, Safari 5, Google Chrome 11.0 and above versions only.
      </body>
      </html>"
    return @html_body
  end

  def course_added_html_body
    html_body = "<html>
           <head></head><body>
    Hello #{@user.login},<br/><br/>

    You have been assigned #{@course.course_name} course. To take this course, click<br/><br/>

    <a href="+@url+" title='click here to take the course'>#{@course.course_name}</a><br/><br/>

    Your Email: #{@user.email}<br/><br/>

    Regards,<br/>
    LionSher Team
     </body>
          </html>"
    return html_body
  end

  def valid_space(dirsize)
    current_plan = Tenant.find_by_user_id(params[:tenant]).pricing_plan
    space = 0
    all_courses = Course.find_all_by_user_id(params[:tenant])
    all_courses.each { |c| space += c.size }
    total_space = (current_plan.space_in_gb)*1073741824
    if space.to_f + dirsize.to_f <= total_space
      return true
    else
      return false
    end
  end

  def upload_valid(media_type,sub_type,mime_extension)
    current_plan = Tenant.find_by_user_id(params[:tenant]).pricing_plan
    logger.info"current_plan #{current_plan.inspect}"
    case
    when sub_type == "zip" then
      return current_plan.allow_scorm
    when media_type == "audio" then
      return current_plan.allow_audio
    when media_type == "video" then
      return current_plan.allow_video
    when mime_extension == "ppt" || mime_extension == "odp" || mime_extension == "pptx" then
      return current_plan.allow_ppt
    when sub_type == "shockwave-flash" then
      return current_plan.allow_ppt
    when sub_type == "pdf" || sub_type == "msword" || sub_type == "vnd.openxmlformats-officedocument.wordprocessingml.document" then
      return current_plan.allow_ppt
    else
      return false
    end
  end

  # script to fill v2 report related tables starts here
  def fill_v2_report_tables
    tenants = Tenant.all(:conditions => "is_expired = 'false'")
    tenants.each do |tenant|
      assessments = Assessment.find_all_by_user_id(tenant.user_id)
      assessments.each do |assessment|
        learners = Learner.find_all_by_assessment_id(assessment.id)
        learners.each do |learner|
          answered = learner.suspend_data.split('|').count
          answered_correct = answered
          answered_wrong = answered
          total_score = learner.score_raw
          unless learner.session_time.nil? or learner.session_time.blank?
            total_time = learner.total_time
          else
            total_time = ""
          end
          assessment.create_calculated_data_learner_assessment(learner.id,learner.user_id,learner.tenant_id,learner.assessment_id,answered,answered_correct,answered_wrong,questions_marked,total_score,total_time,learner.percentage,learner.percentile,learner.rank)
        end # end of learners.each loop
      end # end of assessments.each loop
    end # end of tenants.each loop
  end
  # script to fill v2 report related tables ends here

end
