class AddSellerColumnsToTenants < ActiveRecord::Migration
  def self.up
   add_column :tenants, :type_of_tenant, :string, :default => "admin"
    add_column :tenants, :total_amount, :float,:default => 0
    add_column :tenants, :no_of_licenses_sold, :integer,:default => 0
    add_column :tenants, :bank_name, :string
    add_column :tenants, :account_name, :string
    add_column :tenants, :account_number, :string
    add_column :tenants, :postal_address, :text
    add_column :tenants, :linked_in, :string
    add_column :tenants, :facebook, :string
    add_column :tenants, :twitter, :string
  end

  def self.down
  end
end
