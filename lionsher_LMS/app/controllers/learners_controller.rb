# Manage Learners
# Author : Surupa

class LearnersController < ApplicationController

  before_filter :login_required
  before_filter :is_expired?

  def send_reminder
#    UserMailer.reminder(session[:reminder_user]).deliver
    course_id = params[:id].to_s
    redirect_to('/users/manage_learners/'+course_id)
  end

  def send_reminder_admin
    check_id = Hash.new
    i = 0
    params.each_pair { |key,value|
      if value == "on" then
        check_id[key] = value
        i = i + 1
      end
    }
    check_id.each_pair { |id,value|
      @user = User.find_by_login(id)
#      UserMailer.reminder(@user).deliver
    }
    redirect_back_or_default('/courses')
  end

  def destroy
    check_id = Hash.new
    i = 0
    params.each_pair { |key,value|
      if value == "on" then
        check_id[key] = value
        i = i + 1
      end
    }
    check_id.each_pair { |id,value|
      @learner = current_user.learners.find(id)
      @learner.destroy
    }
    course_id = params[:id].to_s
    redirect_to('/users/manage_learners/'+course_id)
  end

end