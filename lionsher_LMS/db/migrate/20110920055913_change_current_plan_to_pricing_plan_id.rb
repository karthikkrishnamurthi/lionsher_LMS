class ChangeCurrentPlanToPricingPlanId < ActiveRecord::Migration
  def self.up
    rename_column :tenants, :current_plan, :pricing_plan_id
  end

  def self.down
  end
end
