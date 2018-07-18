class AddColumnsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :company_name, :string
    add_column :users, :company_url, :string
    add_column :users, :about_company, :string
  end

  def self.down
  end
end
