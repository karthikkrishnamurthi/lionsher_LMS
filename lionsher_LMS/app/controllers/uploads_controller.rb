require 'zip/zip'
require 'fileutils'
require 'find'
require 'rvideo'
require 'mime/types'
require 'rubygems'

class UploadsController < ApplicationController

  def index
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
      tenantfilepath = "public/files/" + params[:tenant]
      File.open(tenantfilepath, "w+") { |f| f.write(course_id) }
      error_file_path = "public/files/E" + params[:tenant]
      File.open(error_file_path, "w+") { |f| f.write("true") } # @is_scorm = true
      mime_obj = MIME::Types.type_for(file_name)
      if mime_obj.nil? or mime_obj.blank? then
        File.open(error_file_path, "w+") { |f| f.write("false") }
        @course.destroy
        return
      end #TODO: else what?

      media_type = ((MIME::Types.type_for(file_name))[0]).media_type
      sub_type = ((MIME::Types.type_for(file_name))[0]).sub_type
      mime_extension = ((MIME::Types.type_for(file_name))[0]).extensions[0]
      if upload_valid(media_type,sub_type,mime_extension)        
        case
        when sub_type == "zip" then
          name =  type = "e-learning"
        when media_type == "audio" then
          name = type = "audio"
        when (media_type == "video" or sub_type == "mp4") then
          name = type = "video"
        when mime_extension == "ppt" || mime_extension == "odp" || mime_extension == "pptx" then
          name = type = "presentation"
        when sub_type == "shockwave-flash" then
          name = type = "flash"
        when sub_type == "pdf" || sub_type == "msword" || sub_type == "vnd.openxmlformats-officedocument.wordprocessingml.document" then
          name = type = "document"
        else
          File.open(error_file_path, "w+") { |f| f.write("false") }
          @course.destroy
          return
        end
        @course.update_attribute(:typeofcourse,type)
        path = File.join(directory,name)
        new_path = path + "_" + course_id
        basepath = new_path
        is_saved = case
        when type == "e-learning" then  elearning(new_path,extension,uploaded_file,error_file_path,basepath,course_file_name)
        when sub_type == "flv" || sub_type == "shockwave-flash" then aud_vid_ppt_flv_swf(basepath,name,course_id,extension,uploaded_file,error_file_path,type,course_file_name,sub_type)
        when type == "audio" || type == "video" then aud_vid_ppt_flv_swf(basepath,name,course_id,extension,uploaded_file,error_file_path,type,course_file_name,media_type)
        else aud_vid_ppt_flv_swf(basepath,name,course_id,extension,uploaded_file,error_file_path,type,course_file_name,mime_extension)
        end
        if is_saved == false
          File.open(error_file_path, "wb+") { |f| f.write("false") }
          @course.destroy
          return
        end
      else
        File.open(error_file_path, "wb+") { |f| f.write("processing") }
        @course.destroy
        return
      end
    end
  end

  #Control comes here if the uploaded file is SCORM, Non-SCORM.
  #It takes the needed paths as arguments, reads the uploaded file, unzips,checks for virus and saves to db.
  #Also returns a variable is_saved as true if the upload process and saving process is done perfectly else returns false.
  def elearning(new_path,extension,uploaded_file,error_file_path,basepath,course_file_name)
    new_path = new_path + extension
    File.open(new_path, "wb") { |f| f.write(uploaded_file.read) }
    scan_value = virus_scan(new_path)
    if scan_value != 0 then
      remove_virus_affected_file(error_file_path,new_path)
      return
    end

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
        if @launch.nil? or @launch.blank? then
          file = launch_file.split("?")
          @launch=file[0]
          # initialize Scorm Model and assign Url params
          @launch_parameters = file[1]
          @course.update_attribute(:scorm_url_parameters,@launch_parameters)
        end
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
      is_saved = save_to_database(basepath,dirsize,url,title)
      
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
    #write the uploaded file to basepath
    File.open(basepath, "wb") { |f| f.write(uploaded_file.read) }
    scan_value = virus_scan(basepath)
    if scan_value != 0 then
      remove_virus_affected_file(error_file_path,basepath)
      return
    end #TODO:else what?

    #if uploaded file is audio or video the convert it to flv and delete the actual uploaded file
    if media_sub_type == "audio" or media_sub_type == "video" or type == "video" then
      convert_to_flv(basepath,new_path)
      basepath_to_delete = basepath
      File.delete(basepath_to_delete)
      basepath = new_path + ".flv"


      #if uploaded file is ppt or pptx or odp then convert to swf
    elsif media_sub_type == "ppt" or media_sub_type == "pptx" or media_sub_type == "odp" then
      pdf_file = new_path + ".pdf"
      swf_file = new_path + ".swf"
      image_path = new_path + ".jpg"
      convert_to_swf(pdf_file,swf_file,image_path,basepath,path_to_save)
      basepath = swf_file


      #if uploaded file is pdf
    elsif media_sub_type == "pdf" then
      pdf_file = new_path + ".pdf"
      swf_file = new_path + ".swf"
      image_path = new_path + ".jpg"
      system "pdf2swf #{pdf_file} -o #{swf_file} -T 9 -f"
      extract_image(pdf_file,image_path,"document")
      basepath = swf_file


      #if uploaded file is doc or docx
    elsif media_sub_type == "doc" or media_sub_type == "docx" then
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
      is_saved = save_to_database(path_to_save,dirsize,url,course_file_name)

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
  def save_to_database(basepath,dirsize,url,title)
    if dirsize > 0
      @course.course_name = title
      @course.url = url
      @course.path = basepath
      @course.size = dirsize
      @course.save!
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

  private

  def valid_space(dirsize)
    unless params[:tenant].nil? or params[:tenant].blank? or params[:tenant] == "undefined" then

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
    else
      return true
    end
  end

  def upload_valid(media_type,sub_type,mime_extension)
    unless params[:tenant].nil? or params[:tenant].blank? or params[:tenant] == "undefined" then
      current_plan = Tenant.find_by_user_id(params[:tenant]).pricing_plan
      case
      when sub_type == "zip" then
        return current_plan.allow_scorm
      when media_type == "audio" then
        return current_plan.allow_audio
      when (media_type == "video" or sub_type == "mp4") then
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
    else
      return true
    end
  end
end
