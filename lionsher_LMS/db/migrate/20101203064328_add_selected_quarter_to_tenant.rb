class AddSelectedQuarterToTenant < ActiveRecord::Migration
  def self.up
    add_column :tenants, :selected_quarter, :string
  end

  def self.down
  end
end
