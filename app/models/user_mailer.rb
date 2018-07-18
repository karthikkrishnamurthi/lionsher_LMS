
# Author : Aarthi

class UserMailer < ActionMailer::Base
  include Mailer
  default :from => "LionSher <team@lionsher.com>"

  #For the SMTP settings check /config/environemnts/dev.rb and prod.rb

  #all the mails from the controllers will call this method passing the required arguments like
  #user(to whom the mail has to be sent), email_template(which email template has to be loaded), tenant_id
  #from_replacements, subject_replacements, body_replacements
  #need assmt, course, learner, url
  def send_mail(user,email_template,tenant_id,from_replacements,subject_replacements,body_replacements)
    setup_email(user)
    email = email_template(email_template,tenant_id)
    #load_email_content method is in lib/Mailer.rb module
    @from,@subject,@body = load_email_content(email,from_replacements,subject_replacements,body_replacements)
    mail(:to => "<#{user.email}>", :from => @from, :subject => @subject)
  end

  #load the email_template from the table 'emails' for that tenant. If tenant has not set his custom email template then load default lionsher's email templates
  def email_template(email_template,tenant_id)
    email = Email.find_by_email_type_and_tenant_id(email_template,tenant_id)
    #If tenant has not set his custom email template then load default lionsher's email templates
    if email.nil? or email.blank?
      email = Email.find_by_email_type(email_template,:conditions => "tenant_id IS NULL")
    end
    return email
  end

  def test_contact_us_details(user,number_of_users,frequency_of_tests)
    @user = user
    @frequency_of_tests = frequency_of_tests
    @number_of_users = number_of_users
    mail(:to => "sales@lionsher.com", :subject => "Want to Buy Lionsher Tests Pack")
  end

  def activating_14_day_trial_plan(user)
    @user = user
    mail(:to => "#{user.login} <#{user.email}>", :subject => "14-days Free Trial on Lionsher: An easy-to-use, cost effective, web-based LMS")
  end

  def send_survey_mails(user,url)
    @user = user
    @url = url
    mail(:to => "#{user.login} <#{user.email}>", :subject => "Pulse Survey 2012")
  end

   def reset_notification(user)
    setup_email(user)
    if user.typeofuser == "learner" then
      @tenant = Tenant.find_by_user_id(user.user_id)
    elsif user.typeofuser == "admin" or user.typeofuser == "superuser" then
      @tenant = Tenant.find_by_user_id(user.id)
    end
    @subject    += 'Link to reset your password'
    @url  = "https://#{@tenant.custom_url}.#{SITE_URL}/pswrd_reset/#{user.reset_code}"
    mail(:to => "#{user.login} <#{user.email}>", :subject => @subject)
  end

  protected
  #sets the recipient, subject and sent_on objects to display in the mail
  def setup_email(user)
    @recipients  = "#{user.email}"
#    @from        = "LionSher <team@lionsher.com>"
    @subject     = ""
    @sent_on     = Time.now
    @user = user
  end

  def calculate_time(assessment,tenant)
    @zone = tenant.zone
    if @zone.include? "+"
      @offset = @zone.gsub('+','')
    else
      @offset = @zone.gsub('-','')
    end
    offset_hour = @offset.split(':')[0].to_i
    offset_min = @offset.split(':')[1].to_i
    total_offset = (offset_hour * 60 * 60) + (offset_min * 60)
    if @zone.include? "+"
      @show_time = assessment.start_time + total_offset
    else
      @show_time = assessment.start_time - total_offset
    end
  end
end
