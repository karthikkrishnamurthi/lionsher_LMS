class AddExpiryDateAndCurrentPlanToTenants < ActiveRecord::Migration
  def self.up
    add_column :tenants , :expiry_date ,:datetime
    add_column :tenants , :current_plan ,:integer
  end

  def self.down
  end
end
