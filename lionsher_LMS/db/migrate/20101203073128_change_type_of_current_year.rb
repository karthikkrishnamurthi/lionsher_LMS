class ChangeTypeOfCurrentYear < ActiveRecord::Migration
  def self.up
    change_column :tenants, :current_year, :integer
  end

  def self.down
  end
end
