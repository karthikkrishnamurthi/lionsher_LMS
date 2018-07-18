class AddTwoColumnsToTenant < ActiveRecord::Migration
  def self.up
    add_column :tenants, :company_website, :string
    add_column :tenants, :about_your_company, :string
  end

  def self.down
  end
end
