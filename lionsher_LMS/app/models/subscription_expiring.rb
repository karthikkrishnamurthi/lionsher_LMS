class SubscriptionExpiring < ActiveRecord::Base

  def self.send_mails
    tenant = Tenant.find_all_by_is_expired("false", :conditions => ["custom_url != 'lionsher' and pricing_plan_id = 4"], :order => "id desc")
      tenant.each { |t|
      secs = [ t.expiry_date - Time.now.utc, 0 ].max
      total_days_remaining = "%d" % [ secs.to_i / 86400, (secs % 86400).to_i / 3600, *((secs % 3600).divmod(60)) ]
      if (total_days_remaining.to_i <=3) then
        unless t.nil? or t.blank? then
            RulesMailer.deliver_send_day_1_mail(t,total_days_remaining)
          end
          if Time.now.utc > t.expiry_date then
            t.update_attribute(:is_expired, "true")
          end
      end
    }

  end
end
