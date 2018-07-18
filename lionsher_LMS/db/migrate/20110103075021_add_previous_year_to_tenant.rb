class AddPreviousYearToTenant < ActiveRecord::Migration
  def self.up
    add_column :tenants, :previous_year, :integer
  end

  def self.down
  end
end
