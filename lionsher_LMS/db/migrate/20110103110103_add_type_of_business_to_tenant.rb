class AddTypeOfBusinessToTenant < ActiveRecord::Migration
  def self.up
    add_column :tenants, :type_of_business, :string
  end

  def self.down
  end
end
