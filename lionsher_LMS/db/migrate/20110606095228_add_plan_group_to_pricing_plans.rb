class AddPlanGroupToPricingPlans < ActiveRecord::Migration
  def self.up
    add_column :pricing_plans, :plan_group, :string, :default => "small"
  end

  def self.down
  end
end
