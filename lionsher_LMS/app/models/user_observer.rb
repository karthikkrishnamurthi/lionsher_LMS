# Author : Aarthi

class UserObserver < ActiveRecord::Observer  

#  def after_save(user)
#        UserMailer.deliver_activation(user) if user.recently_activated?
#logger.info" adter saves #{user.inspect}"
#        UserMailer.reset_notification(user).deliver if user.recently_reset?
#    if user.recently_activated?
#      if user.typeofuser == "learner" then
#        @tenant = Tenant.find_by_user_id(user.user_id)
#      elsif user.typeofuser == "admin" or user.typeofuser == "buyer" then
#        @tenant = Tenant.find_by_user_id(user.id)
#        @pricing_plan = PricingPlan.find(@tenant.selected_plan_id)
#      end
#      @subject   = 'LionSher Account Activated '
#      if user.typeofuser == "seller" then
#        @url  = "http://#{SITE_URL}"
#      else
#        @url  = "https://#{@tenant.custom_url}.#{SITE_URL}"
#      end
#      @html_body= activation_html_body(user)
#      aws_ses_send_email(user.email,@subject,@html_body)
#
#    elsif user.recently_reset?
#
#      if user.typeofuser == "learner" then
#        @tenant = Tenant.find_by_user_id(user.user_id)
#      elsif user.typeofuser == "admin" or user.typeofuser == "superuser" or user.typeofuser == "individual buyer" or user.typeofuser == "corporate buyer" then
#        @tenant = Tenant.find_by_user_id(user.id)
#      end
#      @subject    = 'Change Password '
#      @url  = "https://#{@tenant.custom_url}.#{SITE_URL}/pswrd_reset/#{user.reset_code}"
#      @html_body= reset_notification(user)
#      aws_ses_send_email(user.email,@subject,@html_body)
#    end

#  end


  def reset_notification(user)
    html_body= "<html>
                <head></head>
                <body>
              Hello #{user.login},<br/><br/>

              Use the link below to reset your password<br/><br/>

              <a href="+@url+">#{@url}</a><br/><br/>

              Regards,<br/>
              LionSher Team<br/><br/>

              Ignore this email if you do not want to reset your password.
              </body>
              </html>"

    return html_body
  end

  def activation_html_body(user)
    html_body =  "<html>
                      <head></head>
                      <body>"
    if user.typeofuser=="admin" then
      html_body = html_body +"Hello #{user.login},<br/><br/>

    Thank you for choosing LionSher. You now have an LMS complete with your company's logo and colors. To assign courses or assessments to learners or view the reports, click <br/><br/>

    <a href="+@url+">#{@url}</a><br/><br/>

    Your Email: #{user.email}

    You are under a 14-day free trial period. Upgrade your account at any time in these 14 days by making the payment. To make payments, click on My Account section while logged into LionSher.<br/><br/>

    For any support, please contact us at support@lionsher.com<br/><br/>

    Regards,<br/>
    LionSher Team"

    elsif user.typeofuser=="learner" then
      html_body = html_body + "Hello #{user.login},<br/><br/>

    You have been added as a learner in #{@tenant.organization} Learning Center. To take any courses or assessments assigned to you, click <br/><br/>

      <a href="+@url+">#{@url}</a><br/><br/>

    Your Email: #{user.email}<br/><br/>

    Regards,<br/>
    LionSher Team"
    end

    html_body = html_body + "</body>
              </html>"

  end

    def aws_ses_send_email(user,subject,html_body)
    AWS_SES.send_email :to => user, :source => '"LionSher" <team@lionsher.com>', :subject => subject, :html_body => html_body
  end
end

