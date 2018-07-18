class AddIsExpiredToTenants < ActiveRecord::Migration
 def self.up
    add_column :tenants , :is_expired ,:string, :default => "false"
    end

  def self.down
  end
end
