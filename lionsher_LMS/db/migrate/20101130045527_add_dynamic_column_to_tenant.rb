class AddDynamicColumnToTenant < ActiveRecord::Migration
  def self.up
    add_column :tenants, :dynamic_quarter_values, :string
  end

  def self.down
  end
end
