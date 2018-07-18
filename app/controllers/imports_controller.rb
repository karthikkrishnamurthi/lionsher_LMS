require 'mime/types'
require 'roo'

class ImportsController < ApplicationController
  before_filter :login_required
  before_filter :is_expired?

  #control comes here from assessments assign_learners/manage_learners, when the admin wants to assign learners through excel.
  #It takes excel file as input consisting of leaners and their names. It parses each line from excel and fills up the users table.
  def import_learners_from_csv
    assessment_id = params[:user][:assessment_id]
    unless params[:import][:excel].nil?  or params[:import][:excel].blank? then
      @import = Import.new(params[:import])
      mime = (MIME::Types.type_for(@import.excel.path)[0])
      unless mime.nil? or mime.blank? then
        mime_obj = mime.extensions[0]
        #dont process further if the uploaded file is other than xls,xls,csv
        if (!mime_obj.nil? and !mime_obj.blank?) and (mime_obj.include? "xls" or mime_obj.include? "xlsx" or mime_obj.include? "ods" or mime_obj.include? "csv" ) then
          if @import.save!
            #check for virus
            if no_virus(@import.excel.path) then
              #If mime_obj is not csv only then create roo_instace
              unless mime_obj.include? "csv" then
                @roo = create_roo_instance(@import.excel.path,mime_obj)
              else
                #so, its a csv format
                @roo = "csv format"
              end
              #if the uploaded
              unless @roo == "Upload correct excel format." then
                if @roo == "csv format" then
                  lines = parse_csv_file(@import.excel.path)
                else
                  lines = parse_excel_file_roo(@roo)
                end
                
                if lines.size > 0
                  @import.processed = lines.size
                  i = 1
                  failed_to_upload = Array.new
                  lines.each do |line|
                    if valid_assign(params[:id])
                      if valid_learners_excel_upload(line)
                      else
                        failed_to_upload << i
                      end
                    else
                      flash[:learner_limit_exceeds] = "You cannot assign more learners"
                    end
                    i = i + 1
                  end
                  @import.save

                  delete_csv(@import.excel.path)

                  @import.destroy
                  if params.include? 'from_assign_learners_page' then
                    redirect_to("/assessments/assign_learners/" + assessment_id.to_s)
                  else
                    total_failed_to_upload = failed_to_upload.join(",")
                    redirect_to("/assessments/manage_learners/#{assessment_id.to_s}?failed_to_upload=#{total_failed_to_upload}")
                  end
                else
                  flash[:error] = "CSV data processing failed."
                end
              else
                flash[:upload_error] = 'Upload correct excel format.'
                redirect_to("/assessments/manage_learners/#{assessment_id.to_s}")
              end
            else
              flash[:virus_error] = "The file is Infected with virus."
              redirect_to("/assessments/manage_learners/#{assessment_id.to_s}")
            end
          else
            flash[:error] = 'CSV data import failed.'
          end
        else
          flash[:upload_error] = 'Upload correct excel format.'
          redirect_to("/assessments/manage_learners/#{assessment_id.to_s}")
        end
      else
        flash[:upload_error] = 'Upload correct excel format.'
        redirect_to("/assessments/manage_learners/#{assessment_id.to_s}")
      end
    else
      redirect_to("/assessments/manage_learners/#{assessment_id.to_s}")
    end
  end

  #control comes here from assessments assign_learners/manage_learners, when the admin wants to assign learners through excel.
  #It takes excel file as input consisting of leaners and their names. It parses each line from excel and fills up the users table.
  def import_course_learners_from_csv
    assessment_id = params[:user][:course_id]
    unless params[:import][:excel].nil?  or params[:import][:excel].blank? then
      @import = Import.new(params[:import])
      mime = (MIME::Types.type_for(@import.excel.path)[0])
      unless mime.nil? or mime.blank? then
        mime_obj = mime.extensions[0]
        #dont process further if the uploaded file is other than xls,xls,csv
        if (!mime_obj.nil? and !mime_obj.blank?) and (mime_obj.include? "xls" or mime_obj.include? "xlsx" or mime_obj.include? "ods" or mime_obj.include? "csv" ) then
          if @import.save!
            #check for virus
            if no_virus(@import.excel.path) then
              #If mime_obj is not csv only then create roo_instace
              unless mime_obj.include? "csv" then
                @roo = create_roo_instance(@import.excel.path,mime_obj)
              else
                #so, its a csv format
                @roo = "csv format"
              end
              #if the uploaded
              unless @roo == "Upload correct excel format." then
                if @roo == "csv format" then
                  lines = parse_csv_file(@import.excel.path)
                else
                  lines = parse_excel_file_roo(@roo)
                end

                if lines.size > 0
                  @import.processed = lines.size
                  i = 1
                  failed_to_upload = Array.new
                  lines.each do |line|
                    if valid_assign(params[:id])
                      if valid_learners_excel_upload(line)
                      else
                        failed_to_upload << i
                      end
                    else
                      flash[:learner_limit_exceeds] = "You cannot assign more learners"
                    end
                    i = i + 1
                  end
                  @import.save

                  delete_csv(@import.excel.path)

                  @import.destroy
                  if params.include? 'from_assign_learners_page' then
                    redirect_to("/courses/assign_learners/" + assessment_id.to_s)
                  else
                    total_failed_to_upload = failed_to_upload.join(",")
                    redirect_to("/courses/manage_learners/#{assessment_id.to_s}?failed_to_upload=#{total_failed_to_upload}")
                  end
                else
                  flash[:error] = "CSV data processing failed."
                end
              else
                flash[:upload_error] = 'Upload correct excel format.'
                redirect_to("/courses/manage_learners/#{assessment_id.to_s}")
              end
            else
              flash[:virus_error] = "The file is Infected with virus."
              redirect_to("/courses/manage_learners/#{assessment_id.to_s}")
            end
          else
            flash[:error] = 'CSV data import failed.'
          end
        else
          flash[:upload_error] = 'Upload correct excel format.'
          redirect_to("/courses/manage_learners/#{assessment_id.to_s}")
        end
      else
        flash[:upload_error] = 'Upload correct excel format.'
        redirect_to("/courses/manage_learners/#{assessment_id.to_s}")
      end
    else
      redirect_to("/courses/manage_learners/#{assessment_id.to_s}")
    end
  end

  #control comes here from assessments assign_learners/manage_learners, when the admin wants to assign learners through excel.
  #It takes excel file as input consisting of leaners and their names. It parses each line from excel and fills up the users table.
  def import_package_learners_from_csv
    assessment_id = params[:user][:package_id]
    unless params[:import][:excel].nil?  or params[:import][:excel].blank? then
      @import = Import.new(params[:import])
      mime = (MIME::Types.type_for(@import.excel.path)[0])
      unless mime.nil? or mime.blank? then
        mime_obj = mime.extensions[0]
        #dont process further if the uploaded file is other than xls,xls,csv
        if (!mime_obj.nil? and !mime_obj.blank?) and (mime_obj.include? "xls" or mime_obj.include? "xlsx" or mime_obj.include? "ods" or mime_obj.include? "csv" ) then
          if @import.save!
            #check for virus
            if no_virus(@import.excel.path) then
              #If mime_obj is not csv only then create roo_instace
              unless mime_obj.include? "csv" then
                @roo = create_roo_instance(@import.excel.path,mime_obj)
              else
                #so, its a csv format
                @roo = "csv format"
              end
              #if the uploaded
              unless @roo == "Upload correct excel format." then
                if @roo == "csv format" then
                  lines = parse_csv_file(@import.excel.path)
                else
                  lines = parse_excel_file_roo(@roo)
                end

                if lines.size > 0
                  @import.processed = lines.size
                  i = 1
                  failed_to_upload = Array.new
                  lines.each do |line|
                    if valid_assign(params[:id])
                      if valid_learners_excel_upload(line)
                      else
                        failed_to_upload << i
                      end
                    else
                      flash[:learner_limit_exceeds] = "You cannot assign more learners"
                    end
                    i = i + 1
                  end
                  @import.save

                  delete_csv(@import.excel.path)

                  @import.destroy
                  if params.include? 'from_assign_learners_page' then
                    redirect_to("/packages/assign_learners/" + assessment_id.to_s)
                  else
                    total_failed_to_upload = failed_to_upload.join(",")
                    redirect_to("/packages/manage_learners/#{assessment_id.to_s}?failed_to_upload=#{total_failed_to_upload}")
                  end
                else
                  flash[:error] = "CSV data processing failed."
                end
              else
                flash[:upload_error] = 'Upload correct excel format.'
                redirect_to("/packages/manage_learners/#{assessment_id.to_s}")
              end
            else
              flash[:virus_error] = "The file is Infected with virus."
              redirect_to("/packages/manage_learners/#{assessment_id.to_s}")
            end
          else
            flash[:error] = 'CSV data import failed.'
          end
        else
          flash[:upload_error] = 'Upload correct excel format.'
          redirect_to("/packages/manage_learners/#{assessment_id.to_s}")
        end
      else
        flash[:upload_error] = 'Upload correct excel format.'
        redirect_to("/packages/manage_learners/#{assessment_id.to_s}")
      end
    else
      redirect_to("/packages/manage_learners/#{assessment_id.to_s}")
    end
  end



  #create roo object based on the mime_type. check http://roo.rubyforge.org/rdoc/index.html
  def create_roo_instance(imported_file_path,mime_obj)
    case
    when (mime_obj.include? 'xlsx') then
      roo = Excelx.new(imported_file_path)
    when (mime_obj.include? 'ods') then
      roo = Openoffice.new(imported_file_path)
    when (mime_obj.include? 'xls') then
      roo = Excel.new(imported_file_path)
    else
      roo = "Upload correct excel format."
    end
    return roo
  end

  def parse_excel_file_roo(roo_obj)
    roo_obj.default_sheet = roo_obj.sheets.first
    lines = Array.new
    (1..roo_obj.last_row).each do |r|
      lines << roo_obj.row(r)
    end
    return lines
  end

  #Scans for virus with help of 'clamav' gem and it returns true if no virus is detected
  #else if it detects virus it removes that uploaded file and returns false.
  def no_virus(file_tobe_scanned_path)
    scan_value = virus_scan(file_tobe_scanned_path)
    if scan_value != 0 then
      remove_virus_affected_file()
      return false
    else
      return true
    end
  end

  #control comes here to delete the uploaded file if it is virus affected and deletes it.
  def remove_virus_affected_file()
    @import.destroy
  end

  #takes the path to delete. it deletes the folder from
  def delete_csv(path_to_delete)
    file_to_del = path_to_delete.split("/").last
    path_to_del = path_to_delete.gsub("/original/"+file_to_del,"")
    FileUtils.rm_r path_to_del
  end

  #converts xls sheet to csv returning the xls path. Uses Jod converter. needs office.
  #Make sure that path is properly specified in the command and also make sure there is "jodconverter-core-3.0-beta-3" in 'public' folder.
  def convert_xls_to_csv
    mime_obj = (MIME::Types.type_for(@import.excel.path)[0]).extensions
    xls_path = @import.excel.path.gsub("."+mime_obj[0],".csv")
    system "java -Doffice.home=/usr/lib/openoffice -jar public/jodconverter-core-3.0-beta-3/lib/jodconverter-core-3.0-beta-3.jar " + @import.excel.path + " " + xls_path
    @import.update_attribute(:excel_file_name,xls_path.split("/").last)
    @import.update_attribute(:excel_content_type,"text/csv")
    return xls_path
  end

  #control comes here when the user wants to upload questions from csv file.
  def create_question_bank
    @tenant = Tenant.find_by_user_id(current_user.id)
    @obj_assessment = Assessment.find_by_id(params[:id])
    @obj_question_bank = QuestionBank.find_by_id(params[:question_bank_id])
    @import = Import.new(params[:import])
    if @import.save!
      if @import.excel_content_type == "application/vnd.ms-excel" or @import.excel_content_type == "application/vnd.oasis.opendocument.spreadsheet" or @import.excel_content_type == "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" then
        mime_obj = (MIME::Types.type_for(@import.excel.path)[0]).extensions
        xls_path = @import.excel.path.gsub("."+mime_obj[0],".csv")
        system "java -Doffice.home=/usr/lib/openoffice -jar public/jodconverter-core-3.0-beta-3/lib/jodconverter-core-3.0-beta-3.jar " + @import.excel.path + " " + xls_path
        @import.update_attribute(:excel_file_name,xls_path.split("/").last)
      end
      id=@import.id
      proc_csv_qb(id,@obj_question_bank.id)
      @questions = Question.find_all_by_question_bank_id(@obj_question_bank.id)
    else
      flash[:error] = 'CSV data import failed.'
    end
    no_of_questions = Question.find_all_by_question_bank_id(@obj_question_bank.id)
    @obj_question_bank.update_attribute(:no_of_questions,no_of_questions.length)
    @obj_assessment.update_attribute(:no_of_questions,no_of_questions.length)

    delete_csv(@import.excel.path)
    @import.destroy
    redirect_to('/question_banks/'+@obj_question_bank.id.to_s+'?wrong_entries='+@wrong_entries.to_s+'&assessment_id='+@obj_assessment.id.to_s+'&assessment_type='+params[:assessment_type])
  end

  def upload_kesdee_course
    @import = Import.new(params[:import])
    if @import.save!
      user = User.find_by_email("ls1@kern-comm.com")
      if user.nil? or user.blank?
        user = User.new
        user.update_attribute(:login,"Kesdee Ls1")
        user.update_attribute(:email,"ls1@kern-comm.com")
        user.update_attribute(:typeofuser, "seller")
        seller = Tenant.new
        seller.user_id = user.id
        seller.pricing_plan_id = 3
        seller.selected_plan_id = 3
        seller.type_of_tenant = "seller"
        seller.save
        seller.update_attribute(:organization, "Kesdee")
        seller.update_attribute(:custom_url, "kesdee")
        UserMailer.course_store_signup_notification(User.find_by_email("ls1@kern-comm.com")).deliver
      end
      xls_path = @import.excel.path
      if @import.excel_content_type == "application/vnd.ms-excel" or @import.excel_content_type == "application/vnd.oasis.opendocument.spreadsheet" or @import.excel_content_type == "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" then
        xls_path = convert_xls_to_csv
      end
      lines = parse_csv_file(xls_path)
      lines.shift  #    comment this line out if your CSV file doesn't contain a header row
      if lines.size > 0
        @import.processed = lines.size
        lines.each do |line|
          if !line[0].nil? and !line[1].nil? then
            @coure_library = line[0]
          end
          fill_kesdee_course_table(line,user.id)
        end
        @import.save
      end
    end
    redirect_to('/courses/kesdee_course_upload/1')
  end

  def upload_kern_course
    @import = Import.new(params[:import])
    if @import.save!
      user = User.find_by_email("ls2@kern-comm.com")
      if user.nil? or user.blank?
        user = User.new
        user.update_attribute(:login,"Kern Ls1")
        user.update_attribute(:email,"ls2@kern-comm.com")
        user.update_attribute(:typeofuser, "seller")
        seller = Tenant.new
        seller.user_id = user.id
        seller.pricing_plan_id = 3
        seller.selected_plan_id = 3
        seller.type_of_tenant = "seller"
        seller.save
        seller.update_attribute(:organization, "Kern Learning Solutions")
        seller.update_attribute(:custom_url, "kernlearningsolutions")
        UserMailer.course_store_signup_notification(User.find_by_email("ls2@kern-comm.com")).deliver
      end
      xls_path = @import.excel.path
      if @import.excel_content_type == "application/vnd.ms-excel" or @import.excel_content_type == "application/vnd.oasis.opendocument.spreadsheet" or @import.excel_content_type == "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" then
        xls_path = convert_xls_to_csv
      end
      lines = parse_csv_file(xls_path)
      lines.shift  #    comment this line out if your CSV file doesn't contain a header row
      if lines.size > 0
        @import.processed = lines.size
        lines.each do |line|
          fill_kern_course_table(line,user.id)
        end
        @import.save
      end
    end
    redirect_to('/courses/kesdee_course_upload/1')
  end

  def upload_kesdee_price
    @import = Import.new(params[:import])
    if @import.save!
      xls_path = @import.excel.path
      if @import.excel_content_type == "application/vnd.ms-excel" or @import.excel_content_type == "application/vnd.oasis.opendocument.spreadsheet" or @import.excel_content_type == "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" then
        xls_path = convert_xls_to_csv
      end
      lines = parse_csv_file(xls_path)
      lines.shift  #    comment this line out if your CSV file doesn't contain a header row
      if lines.size > 0
        @import.processed = lines.size
        lines.each do |line|
          fill_kesdee_course_price_table(line)
        end
        @import.save
      end
    end
    redirect_to('/courses/kesdee_course_upload/1')
  end

  def proc_csv_qb(id,question_bank_id)
    @import = Import.find(id)
    @question_bank_id = question_bank_id
    @wrong_entries = 0
    @wrong_answer_combination = 0
    lines = parse_csv_file(@import.excel.path)
    #    lines.shift  #    comment this line out if your CSV file doesn't contain a header row
    if lines.size > 0
      @import.processed = lines.size

      for i in 0..lines.length-1
        if lines[i][0]=="MTF" then
          mtf_array = Array.new
          no_of_mtf = 0
          k=i+1
          while lines[k][0].nil? and !lines[k][1].nil?
            no_of_mtf = no_of_mtf +1
            k = k+1
            if k > lines.length-1 then
              break
            end
          end
          for j in i..i+no_of_mtf
            mtf_array << lines[j]
          end
          fill_mtf_qb_db(mtf_array,@question_bank_id,@wrong_entries, @wrong_answer_combination)
        elsif !lines[i][0].nil? and lines[i][0]!="MTF" and lines[i][0]!="mtf" then
          fill_qb_db(lines[i],@question_bank_id,@wrong_entries, @wrong_answer_combination)
        end
      end
      @import.save
    else
      flash[:error] = "CSV data processing failed."
    end
	end

  def import_users_for_kraft_pulse_survey
    unless params[:import][:excel].nil?  or params[:import][:excel].blank? then
      @import = Import.new(params[:import])    
      lines = parse_csv_file('/home/aarthi/production/public/sg13.csv')
      lines.each do |line|
        pulse_survey = Hash.new
        pulse_survey['emp_id'] = line[0]
        pulse_survey['date_of_joining'] = line[1]
        pulse_survey['email'] = line[2]
        pulse_survey['salary_grade'] = line[3]
        pulse_survey['function'] = line[4]
        pulse_survey['location'] = line[5]
        pulse_survey['coupon_code'] = ActiveSupport::SecureRandom.hex(6)
        PulseSurvey.new(pulse_survey).save
      end
    end
  end

  private

  def parse_csv_file(path_to_csv)
    lines = []
    #if not installed run, sudo gem install fastercsv
    #http://fastercsv.rubyforge.org/
    require 'fastercsv'
    FasterCSV.foreach(path_to_csv) do |row|
      lines << row
    end
    lines
  end

  def fill_mtf_qb_db(csv_row,question_bank_id,wrong_entries,wrong_answer_combination)
    # save question to DB
    @wrong_entries = wrong_entries
    @wrong_answer_combination = wrong_answer_combination
    super_question_hash = Hash.new
    super_question_hash['question_type'] = csv_row[0][0]
    super_question_hash['question'] = csv_row[0][1]
    super_question_hash['question_bank_id'] = question_bank_id
    if super_question_hash['question'].nil? or super_question_hash['question'].blank? or super_question_hash['question'] == "" then
      @wrong_entries = @wrong_entries + 1
    else
      obj_super_question = Question.new(super_question_hash)
	    obj_super_question.save
    end

    sub_question_hash = Hash.new
    sub_answer_hash = Hash.new
    #    jumbled_answer_ids = Array.new
    jumbled_question_ids = Array.new

    sub_question_hash['mtf_id'] = obj_super_question.id
    sub_answer_hash['status'] = 'correct'

    for i in 1..csv_row.length-1
      sub_question_hash['question'] = csv_row[i][1]

      obj_sub_question = Question.new(sub_question_hash)
	    obj_sub_question.save

      sub_answer_hash['answer']= csv_row[i][2]
      sub_answer_hash['question_id'] = obj_sub_question.id
      jumbled_question_ids << obj_sub_question.id

      obj_sub_answer = Answer.new(sub_answer_hash)
	    obj_sub_answer.save
      #      jumbled_answer_ids << obj_sub_answer.id
    end
    #    jumbled_answer_ids = jumbled_answer_ids.shuffle
    jumbled_question_ids = jumbled_question_ids.shuffle
    i = 0
    options = Question.find_all_by_mtf_id(obj_super_question.id)
    for option in options
      answer = Answer.find_by_question_id(option.id)
      #       answer.update_attribute(:answer_status,jumbled_answer_ids[i])
      answer.update_attribute(:answer_status,jumbled_question_ids[i])
      i = i + 1
    end
  end



  def fill_qb_db(csv_row,question_bank_id,wrong_entries,wrong_answer_combination)
    # save question to DB
    @wrong_entries = wrong_entries
    @wrong_answer_combination = wrong_answer_combination
    question_hash = Hash.new
    question_hash['question_type'] = csv_row[0]
    question_hash['question'] = csv_row[1]
    #    question_hash['has_image'] = csv_row[7]
    if question_hash['question'].nil? or question_hash['question'].blank? or question_hash['question'] == "" then
      @wrong_entries = @wrong_entries + 1
    else
      obj_question = Question.new(question_hash)
      obj_question.question_bank_id = question_bank_id
	    obj_question.save

	    # save answers to DB
	    answer_hash = Hash.new

      for k in 2..6
        if csv_row[k].nil? or csv_row[k].blank? then

        else
          answer_hash['answer'] = csv_row[k]
          answer_hash['question_id'] = obj_question.id
          if question_hash['question_type'] == "MCQ" then
            if csv_row[k] == csv_row[7]
              answer_hash['status'] = 'correct'
            else
              answer_hash['status'] = 'wrong'
            end

          elsif question_hash['question_type'] == "FIB" or question_hash['question_type'] == "SA" then
            answer_hash['status'] = 'correct'

          elsif question_hash['question_type'] == "MAQ" then
            multi_ans =csv_row.length - 7
            for j in 1..multi_ans
              if csv_row[k] == csv_row[csv_row.length-j]
                answer_hash['status'] = 'correct'
                break
              else
                answer_hash['status'] = 'wrong'
              end
            end

          elsif question_hash['question_type'] == "MTF" then
            # do nothing
          end
          obj_answer = Answer.new(answer_hash)
          obj_answer.save!

        end
      end
    end
  end

  def fill_kesdee_course_table(csv_row,user_id)
    course_hash = Hash.new
    for i in 0..csv_row.length-1
      if !csv_row[i].nil? or !csv_row[i].blank?
        if csv_row[0].nil? and !csv_row[1].nil? then
          course_hash['course_library'] = @coure_library
        elsif !csv_row[0].nil? and !csv_row[1].nil? then
          course_hash['course_library'] = csv_row[0]
        end
        course_hash['course_name'] = csv_row[1]
        course_hash['description'] = csv_row[2]
        course_hash['size'] = 10
        minutes = csv_row[3].to_i
        if minutes >= 60
          hour = minutes / 60
          min = minutes % 60
        else
          hour = 0
          min = minutes
        end
        course_hash['duration_hour'] = hour
        course_hash['duration_min'] = min
        course_hash['lms_cs'] = "course_store"
        course_hash['vendor'] = "Kesdee"
        course_hash['typeofcourse'] = "e-learning"
        course_hash['published'] = 1
        course_hash['user_id'] = user_id
      end
    end
    if !course_hash['course_name'].nil?
      @obj_user = Course.new(course_hash)
      @obj_user.save!
    end
  end

  def fill_kern_course_table(csv_row,user_id)
    course_hash = Hash.new
    for i in 0..csv_row.length-1
      if !csv_row[i].nil? or !csv_row[i].blank?
        course_hash['course_name'] = csv_row[0]
        course_hash['description'] = csv_row[1]
        course_hash['course_price'] = csv_row[2].to_i * 46
        course_hash['size'] = 10
        minutes = csv_row[3].to_i
        if minutes >= 60
          hour = minutes / 60
          min = minutes % 60
        else
          hour = 0
          min = minutes
        end
        course_hash['duration_hour'] = hour
        course_hash['duration_min'] = min
        course_hash['lms_cs'] = "course_store"
        course_hash['vendor'] = "Kern Learning Solutions"
        course_hash['typeofcourse'] = "e-learning"
        course_hash['published'] = 1
        course_hash['user_id'] = user_id
      end
    end
    #      if !course_hash['course_name'].nil?
    @obj_user = Course.new(course_hash)
    @obj_user.save!
    #      end
  end

  def fill_kesdee_course_price_table(csv_row)
    course_hash = Hash.new
    #    for i in 0..csv_row.length-1
    #      if !csv_row[i].nil? or !csv_row[i].blank?
    obj_course = Course.find_by_course_library_and_course_name(csv_row[0],csv_row[2])
    if !obj_course.nil? then
      course_hash['course_price'] = csv_row[3].to_i * 46
    end
    #      end
    #    end
    if !course_hash['course_price'].nil?
      obj_course.update_attribute(:course_price, course_hash['course_price'])
    end
  end


  def fill_db(csv_row,assessment_id,wrong_entries,wrong_answer_combination)
    # save question to DB
    @wrong_entries = wrong_entries
    @wrong_answer_combination = wrong_answer_combination
    question_hash = Hash.new
    question_hash['question'] = csv_row[0]
    question_hash['has_image'] = csv_row[7]
    if question_hash['question'].nil? or question_hash['question'].blank? or question_hash['question'] == "" then
      @wrong_entries = @wrong_entries + 1
    else
      obj_question = Question.new(question_hash)
	    obj_question.save

	    # save question ID, Assessment IDs to DB
	    assessment_question_hash = Hash.new
	    assessment_question_hash['aid'] = assessment_id
	    assessment_question_hash['question_id'] = obj_question.id
	    obj_assessment_question = AssessmentQuestion.new(assessment_question_hash)
	    obj_assessment_question.save

	    # save answers to DB
	    answer_hash = Hash.new
	    for i in 1..csv_row.length-3
	      if csv_row[i].nil? or csv_row[i].blank? then
          #TODO: then....do what?
        else
          answer_hash['answer'] = csv_row[i]
          answer_hash['question_id'] = obj_question.id
          if csv_row[i] == csv_row[csv_row.length-2]
            answer_hash['status'] = 'correct'
          else
            answer_hash['status'] = 'wrong'
          end
          obj_answer = Answer.new(answer_hash)
          obj_answer.save!
	      end
	    end
    end
  end

  def fill_learners_table(csv_row)
    user_hash = Hash.new
    group_hash = Hash.new
    if !csv_row[0].nil? or !csv_row[0].blank? or !csv_row[1].nil? or !csv_row[1].blank? then
      @user = User.find_by_email(csv_row[1])
      if @user.nil? then
        user_hash['login'] = csv_row[0]
        user_hash['email'] = csv_row[1]
        user_hash['typeofuser'] = "learner"
        user_hash['user_id'] = current_user.id
        user_hash['tenant_id'] = current_user.tenant.id
        @obj_user = User.new(user_hash)
        @obj_user.save!

        if !csv_row[2].nil? or !csv_row[2].blank? then
          group = Group.find_by_user_id_and_group_name(current_user.id,csv_row[2])
          if group.nil? then
            group_hash['group_name'] = csv_row[2]
            group_hash['user_id'] = current_user.id
            group_hash['tenant_id'] = current_user.tenant.id
            @obj_group = Group.new(group_hash)
            @obj_group.save
            @obj_user.update_attribute(:group_id, @obj_group.id)
          else
            @obj_user.update_attribute(:group_id, group.id)
          end
        end
      end
    end
  end

  #returns true or false based on the below validations
  def valid_learners_excel_upload(csv_row)
    #if any of the fields are blank then dont allow. return false
    if (!csv_row[0].nil? or !csv_row[0].blank?) and (!csv_row[1].nil? or !csv_row[1].blank?) then
      #check the lengths of name and email are in limits else return false
      if csv_row[0].length <=40 and csv_row[1].length <=255 then
        #remove spaces in email_id
        csv_row[1] = csv_row[1].gsub(" ","")
        #validate_email() method validates the email id with the regular expression
        if validate_email(csv_row[1])
          fill_learners_table(csv_row)
          return true
        else
          return false
        end
      else
        return false
      end
    else
      return false
    end
  end

  #it validates the email id with standard regular expression and return true or false based on the check
  def validate_email(email_id)
    email_pattern = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/
    if email_pattern.match(email_id) then
      return true
    else
      return false
    end
  end

  def valid_assign(course_id)
    if current_user.typeofuser == "admin" then
      max_learners_to_be_assigned = Tenant.find_by_user_id(current_user.id).pricing_plan.no_of_users
      total_leaners_assigned = User.find_all_by_user_id(current_user.id).length
    elsif current_user.typeofuser == "individual buyer" or current_user.typeofuser == "corporate buyer" then
      max_learners_to_be_assigned = BuyerSeller.find_by_course_id_and_buyer_user_id(course_id,current_user.id).no_of_license
      total_leaners_assigned = Learner.find_all_by_admin_id_and_course_id(current_user.id,course_id).length
    end

    if total_leaners_assigned < max_learners_to_be_assigned
      return true
    else
      return false
    end
  end




end
