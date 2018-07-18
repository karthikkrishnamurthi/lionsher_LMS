class AddPlanTypeToPricingPlans < ActiveRecord::Migration
  def self.up
    add_column :pricing_plans, :plan_type, :string, :default => "private"
  end

  def self.down
  end
end
