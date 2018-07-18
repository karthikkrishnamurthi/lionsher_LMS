class ChangePlanExpiryType < ActiveRecord::Migration
  def self.up
    change_column :pricing_plans, :plan_expiry, :integer
  end

  def self.down
  end
end
