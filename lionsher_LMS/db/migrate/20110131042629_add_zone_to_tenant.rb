class AddZoneToTenant < ActiveRecord::Migration
  def self.up
    add_column :tenants, :zone, :string
  end

  def self.down
  end
end
