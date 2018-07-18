class ChangePlanExpiryToFloatInPricingPlans < ActiveRecord::Migration
  def self.up
    change_column :pricing_plans, :plan_expiry, :float
  end

  def self.down
  end
end
