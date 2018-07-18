class Rules 
  def initialize(tenant_id)
    @tenant_id = tenant_id
  end

  #returns is_expired as ture or false
  def rule_14_day_trial_expiry(tenant_id)
    is_expired = false
    tenant = Tenant.find_by_id(tenant_id)
    @user = User.find_by_id(tenant.user_id)
    unless @user.activated_at.nil? or @user.blank? then
      if Time.now.utc > tenant.expiry_date then
        is_expired = true
      end
    end
    is_expired
  end

end 