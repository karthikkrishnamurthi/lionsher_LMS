class RulesMailer < ActionMailer::Base

# def send_day_1_mail(tenant,days_left)
#    @user = User.find_by_id(tenant.user_id)
#    @total_days_left = days_left
#    unless @user.nil? or @user.blank? then
#      setup_email(@user)
#      @subject    = '14-day Free Trial expires – Upgrade your Lionsher account'
#      content_type "text/html"
#    end
#  end

# protected
#  def setup_email(user)
#    @recipients  = "#{user.email}"
#    @from        = "Team LionSher <team@lionsher.com>"
#    @subject     = ""
#    @sent_on     = Time.now
#    @body[:user] = user
#  end

end
