class AddCurrentYearToTenant < ActiveRecord::Migration
  def self.up
    add_column :tenants, :current_year, :string
  end

  def self.down
  end
end
