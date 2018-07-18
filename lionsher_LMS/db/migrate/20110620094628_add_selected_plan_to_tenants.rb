class AddSelectedPlanToTenants < ActiveRecord::Migration
  def self.up
    add_column :tenants, :selected_plan_id, :integer
  end

  def self.down
  end
end
