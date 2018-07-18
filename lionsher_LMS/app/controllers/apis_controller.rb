# This class contains the definitions of the lionsher api methods.
# Each method is called using a specific url from a third party web application.
# e.g. https://subdomain.lionsher.com/apis/assessments/USER_ID?api_key=API_KEY
# The procedure to call the urls are defined in LionSher API documentation.
class ApisController < ApplicationController
  # Filter to authenticate api user
  before_filter :authenticate_api_user

  # Response to the api call is in xml format
  respond_to :xml
  
  # response xml contains assessment name
  # params[:id] is the user's id in users table
  def assessments
    respond_with Assessment.find_all_by_user_id(params[:id],:select => [:name])
  end

  # response xml contains course name
  # params[:id] is the user's id in users table
  def courses
    respond_with Course.find_all_by_user_id(params[:id],:select => [:course_name])
  end

  # create a new learner in users table by an admin of a tenant
  # response xml contains id,login,email,crypted_password for user
  def create_user
    admin_user = User.find_by_id(params[:id])
    user = User.find_by_email(params[:email])
    if user.nil? then
      user = User.new
      unless params.include? "last_name"
        user.login = "#{params[:first_name]}"
      else
        user.login = "#{params[:first_name]} #{params[:last_name]}"
      end
      user.email = params[:email].strip()
      user.typeofuser = "learner"
      user.user_id = admin_user.id
      user.tenant_id = admin_user.tenant_id
      user.crypted_password = Digest::SHA1.hexdigest(params[:password])
      user.save!
      user.activate
    end
    respond_with User.find(user.id,:select => "id,login,email,crypted_password")
  end

  # edit user's firstname, lastname and password
  # response xml contains id,login,email,crypted_password for user
  def edit_user
    user = User.find(params[:user_id])
    unless user.nil? then
      if params.include? "first_name" and params.include? "last_name"
        user.login = "#{params[:first_name]} #{params[:last_name]}"
      elsif !params.include? "first_name" and params.include? "last_name"
        first_name = user.login.split(' ').first
        user.login = "#{first_name} #{params[:last_name]}"
      elsif params.include? "first_name" and !params.include? "last_name"
        last_name = user.login.split(' ').last
        user.login = "#{params[:first_name]} #{last_name}"
      end
      if params.include? "email"
        user_with_same_email = User.find_by_email(params[:email])
        if user_with_same_email.nil? 
          user.email = params[:email].strip()
        end
      end
      if params.include? "password"
        user.crypted_password = Digest::SHA1.hexdigest(params[:password])
      end
      user.save!
    end
    respond_with User.find(user.id,:select => "login,email,crypted_password")
  end

  # delete a user
  def delete_user
    user = User.find(params[:user_id])
    unless user.typeofuser == "admin"
      user.destroy
    end
    respond_with user
  end

  def assign_learner
    user = User.find(params[:id])
    @assessment = Assessment.find(283)
    @learner = Learner.new
    @learner.admin_id = user.user_id
    @learner.user_id = user.user_id
    @learner.tenant_id = user.tenant_id
    @learner.lesson_location = 0
    @learner.assessment_id = @assessment.id
    @learner.group_id = 1
    @learner.save
    logger.info"Learner >>>>>>>>>>>>>>>>>>>#{@learner.inspect}"
    respond_with @learner
  end

  

  private

  # check if the user who is calling the api methods exists with the correct API_KEY
  # params[:id] is the user's id and params[:api_key] is crypted_password in users table
  def authenticate_api_user
    api_key_user = User.find_by_id_and_crypted_password(params[:id],params[:api_key])
    head :unauthorized unless api_key_user
  end
end
