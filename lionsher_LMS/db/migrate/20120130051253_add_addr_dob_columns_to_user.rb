class AddAddrDobColumnsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :address, :string
    add_column :users, :date_of_birth, :string
    add_column :users, :alternate_email, :string
  end

  def self.down
  end
end
