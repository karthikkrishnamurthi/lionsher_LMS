# Tracking details for scorm 1.2 course
# Author : Karthik
class ScormController < ApplicationController

  before_filter :login_required
  before_filter :is_expired?

  # upon ajax request from listener api (i.e. scorm/api.html), retrieve values from database as an object.
  # transfers this object to scorm/getvalue.html
  def getvalue
    @scormvalue = Learner.find_by_id(params[:SCOInstanceID])    
  end

  
  # store (key,value) details coming from listener api (i.e. scorm/api.html) via ajax into database.
  def setvalue
    @scormvar = Learner.find_by_id(params[:SCOInstanceID])
    course = Course.find(@scormvar.course_id)
    if @scormvar.lesson_status != 'completed' then
      if params[:varname] == 'cmi.core.score.raw' then
        @scormvar.update_attribute(:score_raw, params[:varvalue])
      elsif params[:varname] == 'cmi.core.score.max' then
        @scormvar.update_attribute(:score_max, params[:varvalue])
      elsif params[:varname] == 'cmi.core.score.min' then
        @scormvar.update_attribute(:score_min, params[:varvalue])
      elsif params[:varname] == 'cmi.core.lesson_status' then
        @scormvar.update_attribute(:lesson_status, params[:varvalue])
        if @scormvar.lesson_status == 'completed' then
          @scormvar.update_attribute(:lesson_location,"")
#          course.update_attribute(:completed_learners, course.completed_learners + 1)
          course_status_based_updation(course,@scormvar)
        end
      elsif params[:varname] == 'cmi.core.lesson_location' then
        @scormvar.update_attribute(:lesson_location, params[:varvalue])
      elsif params[:varname] == 'cmi.core.lesson_mode' then
        @scormvar.update_attribute(:lesson_mode, params[:varvalue])
      elsif params[:varname] == 'cmi.core.session_time' then
        @scormvar.update_attribute(:session_time, params[:varvalue])
      elsif params[:varname] == 'cmi.core.total_time' then
        @scormvar.update_attribute(:total_time, params[:varvalue])
      elsif params[:varname] == 'cmi.suspend_data' then
        @scormvar.update_attribute(:suspend_data, params[:varvalue])
      elsif params[:varname] == 'cmi.launch_data' then
        @scormvar.update_attribute(:launch_data, params[:varvalue])
      elsif params[:varname] == 'cmi.core.entry' then
        @scormvar.update_attribute(:entry, params[:varvalue])
      elsif params[:varname] == 'cmi.core.exit' then
        @scormvar.update_attribute(:lesson_exit, params[:varvalue])
      elsif params[:varname] == 'cmi.core.credit' then
        @scormvar.update_attribute(:credit, params[:varvalue])
      end
    else
      if params[:varname] == 'cmi.core.score.raw' then
        @scormvar.update_attribute(:score_raw, params[:varvalue])
      elsif params[:varname] == 'cmi.core.score.max' then
        @scormvar.update_attribute(:score_max, params[:varvalue])
      elsif params[:varname] == 'cmi.core.lesson_location' then
        @scormvar.update_attribute(:lesson_location, params[:varvalue])
      end
    end
  end

  def swf_save_to_db
    @learner = Learner.find_by_course_id_and_user_id(params[:SCOInstanceID], current_user.id)
    course = Course.find(@learner.course_id)
    @learner.update_attribute(:lesson_status, "completed")
    course_status_based_updation(course,@learner)
  end

  def ppt_get_location
    @scormvalue = Learner.find_by_id(params[:SCOInstanceID])
    logger.info"@scormvalue #{@scormvalue.inspect}"
  end

  def ppt_set_location
    @scormvar = Learner.find_by_id(params[:SCOInstanceID])
    @scormvar.update_attribute(:lesson_location, params[:varvalue])
  end

  def ppt_lesson_status
    @scormvar = Learner.find_by_id(params[:SCOInstanceID])
    course = Course.find(@scormvar.course_id)
    if @scormvar.lesson_status != "completed"
      @scormvar.update_attribute(:lesson_status,params[:varvalue])
      course_status_based_updation(course,@scormvar)
    end    
  end
  
  # TODO : Write Documentation for all methods
  def launch
  end

  def admin_scorm_preview

  end
  
  def api

  end

  def admin_api

  end

  def admin_audvid_preview

  end
  
  def admin_getvalue

  end

  def admin_setvalue

  end
  
end
