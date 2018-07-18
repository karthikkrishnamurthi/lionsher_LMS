class MailingJob < Struct.new(:user,:email_template,:tenant_id,:from_replacements,:subject_replacements,:body_replacements)

  def perform
    UserMailer.deliver_send_mail(user,email_template,tenant_id,from_replacements,subject_replacements,body_replacements)
#    case(user_mailer_method)
#
#    when "testadd_assessment_learner_notification" then
#     UserMailer.deliver_testadd_assessment_learner_notification(arg_1,arg_2)
#    when "send_score_to_learner" then
#      UserMailer.deliver_send_score_to_learner(arg_1,arg_2)
#    when "signup_assessment_learner_notification" then
#      UserMailer.deliver_signup_assessment_learner_notification(arg_1,arg_2)
#    when "send_bounced_mail_again"
#      UserMailer.deliver_send_bounced_mail_again(arg_1)
#    when "signup_learner_notification"
#      UserMailer.deliver_signup_learner_notification(arg_1,arg_2)
#    when "course_added"
#      UserMailer.deliver_course_added(arg_1,arg_2)
#    when "signup_notification"
#      UserMailer.deliver_signup_notification(arg_1)
#    when "reminder"
#      UserMailer.deliver_reminder(arg_1,arg_2)
#    when "not attempted","incomplete" then
#      UserMailer.deliver_reminder_assessment(arg_1,arg_2,user_mailer_method)
#    when "signup_package_learner_notification"
#      UserMailer.deliver_signup_package_learner_notification(arg_1)
#    end
  end
end

